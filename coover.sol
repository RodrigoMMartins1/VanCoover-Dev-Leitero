// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


contract Coover {
// Definição da struct Participante
struct Participante {

    uint256 saldo; // Saldo do Participante da seu carteira
    bytes15 imei; // IMEI do celular do Participante que estará em hash
    address payable endereco; //endereço dos Participante
    uint256 valorAtivo; // Valor do celular do participante
    bytes15 bo; //bo do participante que estará em hash
    uint256 qntIndenizacao; //Quantidade de indenizações que um participante recebeu
    bool pediuIndenizacao; // Diz se um participante solicitou ou não uma indenização
    uint256 index; 
    bool depositoFeito;//Diz se o deposito inicial foi feito ou nao


   
}

// Definição da struct Grupo
struct Grupo {
    string nomeGrupo; // Nome do grupo de segurados
    uint256 saldoTotal; // Saldo total do grupo no contrato
    uint256 qntparticipantes; // Número de Participantes no grupo
    uint256 minimoParticipantes; // Número mínimo de Participantes para o grupo
    uint256 maximoParticipantes; // Número máximo de Participantes para o grupo
    address[]  participantes; //Array com os endereços dos participantes
    address payable seguradora; // endereço do criador do smart contract (owner)
    uint256 taxAdmin; //Taxa para entrar no grupo
    uint256 dataInicio; //Data de crição do contrato
    uint256 dataValidade; //Data do término do contrato
    uint256 duracaoDias; // Dias totais do contrato

    mapping (address => Participante) mapeamentoParticipantes; // Mapeamento de Participantes por endereço
}

//Outras Variáveis que serão usadas no projeto
    mapping (address => Participante) mapeamentoParticipantes2; // Mapeamento de Participantes por endereço
    address[] participantes2;
    uint256 qntparticipantes2;



//Eventos para serem usados mais tarde
event novoParticipanteGrupo(address indexed participante, uint256 valor);
event pedidoIndenizacao(address indexed participante, bytes15 bo);



//Constructor/Deploy do contrato, definir as variáveis dos grupos
 Grupo public meuGrupo; //Objeto do grupo

 constructor(string memory _nomeGrupo, uint256 _minimoParticipantes, uint256 _maximoParticipantes, uint256 _taxAdmin, uint256 _duracaoDias)  {
        meuGrupo.nomeGrupo = _nomeGrupo; //Nome do Grupo
        meuGrupo.minimoParticipantes = _minimoParticipantes; //Mínimo e máximo de participantes
        meuGrupo.maximoParticipantes = _maximoParticipantes; //Máximo de participantes
        meuGrupo.taxAdmin = _taxAdmin; //Taxa de entrada
        meuGrupo.duracaoDias = _duracaoDias; //Duração do contrato
        meuGrupo.dataInicio = block.timestamp; // define a data de início do contrato como a data atual do bloco
        meuGrupo.dataValidade = meuGrupo.dataInicio + meuGrupo.duracaoDias * 1 days; // Guarda a data de validade.
        meuGrupo.seguradora =  payable(msg.sender); // define o endereço da seguradora como o criador do contrato

    }



//Entrar no smart contract, requisitos imei, valor do ativo endereço da carteira do participante, colocar a função deposito inicial
function entrarGrupo(address payable _endereco)  public payable {
    require(meuGrupo.qntparticipantes < meuGrupo.maximoParticipantes, "Grupo ja atingiu o limite maximo de participantes.");
    Participante storage participante = mapeamentoParticipantes2[_endereco];

    require(participante.depositoFeito == true, "Deposito inicial incorreto.");    
    
    // Adiciona o novo Participante no mapeamento de participantes do grupo
    meuGrupo.mapeamentoParticipantes[_endereco] = participante;
    // Adiciona o endereço do participante no array de participantes do grupo
    meuGrupo.participantes.push(_endereco);

    // Incrementa o número de participantes do grupo
    meuGrupo.qntparticipantes++;

     // Transfere a taxa administrativa para a carteira da seguradora
    meuGrupo.seguradora.transfer(participante.saldo - participante.valorAtivo * 5/100);

    //Adiciona no saldo do Grupo
    meuGrupo.saldoTotal += participante.saldo;
    

    //Adicionado a lista de participantes
    emit novoParticipanteGrupo(participante.endereco, msg.value);
}

//Funções(Regras de negócios)
function adicionarUsuarios(bytes15 _imei, uint256 _valorAtivo, address payable  _endereco) public payable {
    require(meuGrupo.seguradora == msg.sender, "Apenas a seguradora pode executar");
    // Verifica se o número máximo de participantes não foi atingido
    require(meuGrupo.qntparticipantes < meuGrupo.maximoParticipantes, "Grupo ja atingiu o limite maximo de participantes.");
    
    // Cria um novo Participante no mapeamento de participantes do grupo
    mapeamentoParticipantes2[_endereco] = Participante({
        saldo: 0,
        imei: _imei,
        endereco: _endereco,
        valorAtivo: _valorAtivo,
        bo: "",
        qntIndenizacao: 0,
        pediuIndenizacao: false,
        index: meuGrupo.participantes.length,
        depositoFeito: false
    });
    
    // Adiciona o endereço do participante no array de participantes do grupo
    participantes2.push(_endereco);
    
    // Incrementa o número de participantes do grupo
    qntparticipantes2++;
    
    // Emite o evento de novo participante no grupo
    emit novoParticipanteGrupo(_endereco, 0);

    //Adiciona Participante no Grupo
    depositarInicial(_endereco);
    entrarGrupo(_endereco);
    
}







// Função para realizar um depósito de um participante no grupo
function depositarInicial(address payable _endereco) public payable {
    //Instancia o participante que entrou no grupo


    Participante storage participante = mapeamentoParticipantes2[_endereco];

    //Permite que só possa entrar so arquivo maior que 0
    require(participante.valorAtivo > 0, "Participante nao encontrado");

    //Deposito é o valor do ativo * 5 porcento
    uint256 deposito = participante.valorAtivo * 5 / 100 + meuGrupo.taxAdmin;

    //Colaca o saldo do participante como deposito
    participante.saldo = deposito;
    

    require(msg.value == deposito, "Valor de deposito incorreto");

    participante.depositoFeito = true;
}









//Fazer pedido de indenização, provas de documento de sinistralidade(BO), tem q ter emit do evento para notificar o adm(segurado) com o bo do participante

function solicitarIndenizacao( address _endereco, bytes15 _bo) public {
    Participante storage participante = meuGrupo.mapeamentoParticipantes[_endereco];
    require(participante.saldo >=   participante.valorAtivo * 5/100, "Saldo insuficiente para solicitar indenizacao");

    emit pedidoIndenizacao(msg.sender, _bo);
    participante.pediuIndenizacao = true;
    
}

function indenizacao(address payable _participante, bytes15 _imei, uint256 _valorAtivo) public {
    require(msg.sender == meuGrupo.seguradora, "Apenas a seguradora pode executar essa funcao");

    //Instancia o participante a ser indenizado
    Participante storage participanteIndenizado = meuGrupo.mapeamentoParticipantes[_participante];


    //Verificando se o IMEI compátivel
    require(participanteIndenizado.imei == _imei, "O IMEI nao e deste usuario");

    //Verificando se o valor do ativo é compátivel
    require(participanteIndenizado.valorAtivo == _valorAtivo, "O valor do ativo nao e deste usuario");

    //Verifica se o participante pediu indenizacao
    require(participanteIndenizado.pediuIndenizacao == true, "Participante nao solicitou indenizacao.");


    //Retira o indenizado do Grupo, ele terá que entrar no grupo de novo para pedir indenizacao
    delete meuGrupo.participantes[participanteIndenizado.index];

    //Faz a conta para o valor total do ativo retirando o deposito do indenizado
    uint256 valorParaContribuicao = 0;
    valorParaContribuicao = participanteIndenizado.valorAtivo - (participanteIndenizado.saldo);

    //Zera o valor de indenizado
    participanteIndenizado.saldo = 0;

    uint256 valorPago;


     for(uint i=0; i<meuGrupo.participantes.length; i++) {


         //Instancia participante do grupo para contribuicao
         Participante storage participante = meuGrupo.mapeamentoParticipantes[meuGrupo.participantes[i]];
         
         //Contribuicao é o valor proporcional de cada participante para pagar o valor do Ativo do indenizado
         uint256 contribuicao = (participante.valorAtivo * 5) / valorParaContribuicao;
         
         //Retira a contribuicao do saldo do participante
         participante.saldo -= contribuicao;

        //Itera o valor a ser pago

        valorPago += contribuicao;


     }

    


    //Transfere o valor indenizado
     participanteIndenizado.endereco.transfer(valorPago);
     
     //Retira a solicatacao 
     participanteIndenizado.pediuIndenizacao = false;

     //Soma a quantidade de indenizacao
     participanteIndenizado.qntIndenizacao += 1;

}

    

//Renovar contrato
function renovarContrato() public {

    require(msg.sender == meuGrupo.seguradora, "Apenas seguradora pode executar essa funcao");
    require(meuGrupo.qntparticipantes >= meuGrupo.minimoParticipantes, "Nao e possivel renovar o contrato pois o numero minimo de participantes nao foi alcancado.");
    // Atualiza a data de validade do contrato
    meuGrupo.dataValidade = block.timestamp + meuGrupo.duracaoDias * 1 days;
}


// Função para realizar depósito avulso, reserva de risco
function reservaRisco() public payable {
    //Instancia o participante que entrou no grupo
    Participante storage participante = meuGrupo.mapeamentoParticipantes[msg.sender];

    //Permite que só possa entrar so arquivo maior que 0
    require(participante.valorAtivo > 0, "Participante nao encontrado");

    //Reserva de risco
    uint256 reserva;

    reserva = msg.value;

    //Adiciona um depósito avulso ao saldo do participante
    participante.saldo += reserva;
    //Adiciona o depósito avulso ao saldo total do grupo
    meuGrupo.saldoTotal += reserva;
}

//Função que permite o participante sair do grupo
function sairGrupo() external {
    Participante memory participante = meuGrupo.mapeamentoParticipantes[msg.sender];
    require(participante.endereco != address(0), "Voce nao e um participante deste grupo.");

    // Transfere o saldo do participante de volta para a sua carteira
    payable(participante.endereco).transfer(participante.saldo);

    // Remove o participante do mapeamento e do array de participantes do grupo
    delete meuGrupo.mapeamentoParticipantes[msg.sender];
    for (uint256 i = 0; i < meuGrupo.participantes.length; i++) {
        if (meuGrupo.participantes[i] == msg.sender) {
            delete meuGrupo.participantes[i];
            break;
        }
    }

    // Decrementa o número de participantes do grupo
    meuGrupo.qntparticipantes--;

    // Subtrai o valor do ativo do participante do saldo total do grupo
    meuGrupo.saldoTotal -= participante.valorAtivo * 5 / 100;
}

// Função para deletar um participante do grupo
function deletarParticipante(address payable _endereco) external {
    require(msg.sender == meuGrupo.seguradora, "Somente a seguradora pode deletar um participante do grupo");

    //Index do participante na array
    uint256 indexParticipante = meuGrupo.mapeamentoParticipantes[_endereco].index;
    //Verifica se ele está no grupo
    require(indexParticipante < meuGrupo.participantes.length, "Participante nao encontrado no grupo");

    uint256 valorSaldo = meuGrupo.mapeamentoParticipantes[_endereco].saldo;//Valor saldo é o saldo do participante
    meuGrupo.saldoTotal -= valorSaldo; // remove o saldo do participante do total do grupo
    delete meuGrupo.participantes[indexParticipante]; // remove o endereço do participante do array de endereços de participantes

    // atualiza o mapeamento de participantes e a posição no array de endereços de participantes
    for (uint256 i = indexParticipante; i < meuGrupo.participantes.length - 1; i++) {
        meuGrupo.mapeamentoParticipantes[meuGrupo.participantes[i+1]].index = i;
        meuGrupo.participantes[i] = meuGrupo.participantes[i+1];
    }
    //Atualiza a quantidade de participantes do grupo
    meuGrupo.qntparticipantes--;

    delete meuGrupo.mapeamentoParticipantes[_endereco]; // remove o participante do mapeamento de participantes
}



//Funções view 

//Ver quantidade de pessoas do grupo
function quantidadeParticipantes() public view returns (uint256) {
    return meuGrupo.qntparticipantes;
}

//Ver quantidade máxima de participantes
function maximoParticipantes() external view returns(uint256) {
    return meuGrupo.maximoParticipantes;
}

//Numero de participantes
function qntParticipantes() external view returns(uint256) {
    return meuGrupo.qntparticipantes;
}

//Ver numero da taxa administrativa
function taxaAdmin() external view returns(uint256) {
    return meuGrupo.taxAdmin;
}

//Ver saldo do participante
function saldoParticipante(address _endereco) external view returns(uint256) {
    return meuGrupo.mapeamentoParticipantes[_endereco].saldo;
}

//Ver nome do Grupo
function nomeGrupo() external view returns (string memory) {
    return meuGrupo.nomeGrupo;
}

//Ver duração de dias
function duracaoDias() external view returns (uint256) {
    return meuGrupo.duracaoDias;
}

//Ver data de inicio
function dataInicio() external view returns (uint256) {
    return meuGrupo.dataInicio;
}

//Ver data de validade do Grupo
function dataValidade() external view returns (uint256) {
    return meuGrupo.dataValidade;
}

//Ver quantidade de indenização do participante
function indenizacao(address _endereco) external view returns (uint256){
    return meuGrupo.mapeamentoParticipantes[_endereco].qntIndenizacao;
}
//Ver saldo total do grupo
function saldoTotalGrupo() external view returns (uint256){
    return meuGrupo.saldoTotal;
}


}












