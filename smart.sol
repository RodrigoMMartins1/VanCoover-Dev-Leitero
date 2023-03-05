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





//Funções(Regras de negócios)


//Entrar no smart contract, requisitos imei, valor do ativo endereço da carteira do participante, colocar a função deposito inicial
function entrarGrupo(bytes15 _imei, uint256 _valorAtivo, address payable  _endereco) external payable {
    require(meuGrupo.qntparticipantes < meuGrupo.maximoParticipantes, "Grupo ja atingiu o limite maximo de participantes.");

    require(msg.value == (_valorAtivo * 5 / 100) + meuGrupo.taxAdmin, "Deposito inicial incorreto.");
    uint256 _qntIndenizacao = 0;
    

    
    // Adiciona o participante no mapeamento de participantes
    meuGrupo.mapeamentoParticipantes[_endereco] = Participante({
        saldo: msg.value,
        imei: _imei,
        endereco: _endereco,
        valorAtivo: _valorAtivo,
        bo: "",
        qntIndenizacao: _qntIndenizacao,
        pediuIndenizacao: false,
        index: meuGrupo.participantes.length - 1
    });

    

    
    // Adiciona o endereço do participante no array de participantes do grupo
    meuGrupo.participantes.push(_endereco);
    
    // Incrementa o número de participantes do grupo
    meuGrupo.qntparticipantes++;

     // Transfere a taxa administrativa para a carteira da seguradora
    meuGrupo.seguradora.transfer(meuGrupo.taxAdmin);

    //Adiciona no saldo do Grupo
    meuGrupo.saldoTotal += _valorAtivo * 5 / 100;
    

    //Adicionado a lista de participantes
    emit novoParticipanteGrupo(_endereco, msg.value);
}



// Função para realizar um depósito de um participante no grupo
function depositar() public payable {
    //Instancia o participante que entrou no grupo
    Participante storage participante = meuGrupo.mapeamentoParticipantes[msg.sender];

    //Permite que só possa entrar so arquivo maior que 0
    require(participante.valorAtivo > 0, "Participante nao encontrado");

    //Deposito é o valor do ativo * 5 porcento
    uint256 deposito = participante.valorAtivo * 5 / 100;

    //Colaca o saldo do participante como deposito
    participante.saldo = deposito;
    

    require(msg.value == deposito, "Valor de deposito incorreto");

    meuGrupo.saldoTotal += deposito;
}






//Fazer pedido de indenização, provas de documento de sinistralidade(BO), tem q ter emit do evento para notificar o adm(segurado) com o bo do participante

function solicitarIndenizacao( address _endereco, bytes15 _bo) public {
    Participante storage participante = meuGrupo.mapeamentoParticipantes[_endereco];
    require(participante.saldo >=   participante.valorAtivo * 5/100, "Saldo insuficiente para solicitar indenizacao");
    require(participante.bo == _bo, "BO invalido");

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


}






