// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
contract ContratoCoover {
    // Variáveis fundamentais para a manipulação dos conteúdos dentro das funções.
    uint public valorAtivo; //valor do celular
    uint public saldoUsuario; //valor que o usuário tem na carteira
    uint public saldoContrato; //saldo total do contrato
    uint public quantiUsuario; //quantidade de usuários
    uint public dataInicio; // data de criação do contrato
    uint public dataValidade; //data final do contrato
    uint public minPessoas = 5; //mínimo de pessoas para ativação do contrato
    uint public maxPessoas = 50; //máximo de pessoas para ativação do contrato
    uint public duracaoDias; //duração de dias do contrato
    uint public valorCobertura; //valor da taxa aplicado no valor do ativo
    uint public totalContrato; //total do valor do contrato
    string private IMEI; //já é o hash do IMEI
    uint public taxAdmin; //taxa administrativa

    string[] private listaIMEIs;
    address private _admin; //endereço da Coover(admin)
    Usuario[] public usuarios;
   

    // Struct definido para armazenar os dados das carteiras associadas ao contrato, tendo como membro os endereços das carteiras.
    struct Usuarios {
        address carteiraUsuario; //endereço da carteira do usuário
        string IMEI; // hash do IMEI do usuário 

    }

    Usuarios[] public usuarios;

    // Armazena-se as carteiras em um array público para serem lidas como a variável carteira.
    Usuarios[] public carteira;
    // Mapeamento do número de carteiras que estão associadas ao contrato.
    mapping(address => bool) public termoAceito;
    uint public numAceitaram;
    // Mapeamento do valor inteiro, dentro do endereço indicado, para identificação do saldo pertecente ao contrato.
    mapping (address => uint) public saldo;
    uint public saldoTotal;

    // Construtor utilizado para inicializar as variáveis de estado do contrato.
    // Os argumentos utilizados no construtor são o saldo, quantidade de usurios, minimo de usuários para funcionamento, máximo possível de usuários e duração do contrato.
    constructor(uint _saldoTotal, uint _usuarios, uint _usuarioMinimo, uint _usuarioMaximo, uint _duracaoDias) {
        _admin = msg.sender; // _admin representa o remetende do contrato.
        dataInicio = block.timestamp; // Armazena a data de inicialização do contrato.
        saldoContrato = _saldoTotal; 
        quantiUsuario = _usuarios;
        minPessoas = _usuarioMinimo;
        maxPessoas = _usuarioMaximo;
        dataValidade = dataInicio + _duracaoDias * 1 days; // Guarda a data de validade.
    }
    // Funções 
    // Modificador para permitir que apenas o dono do contrato (admin) acesse as funções.
    modifier donoUnico() {
        require(msg.sender == _admin, "Apenas o dono do contrato pode executar essa funcao.");
        _;
    }
    // Funcionalidade: criar um novo contrato
    function criarContrato(uint _dataInicio, uint _dataValidade, uint _taxaAdmin, uint _minPessoas, uint _maxPessoas) public {
        require(_dataInicio < _dataValidade, "A data de inicio deve ser anterior a data de validade");
        require(_minPessoas >= 2, "O minimo de pessoas deve ser maior ou igual a 2");
        require(_maxPessoas <= 100, "O maximo de pessoas deve ser menor ou igual a 100");
        require(_minPessoas <= _maxPessoas, "O minimo de pessoas deve ser menor ou igual ao maximo de pessoas");

        dataInicio = _dataInicio;
        dataValidade = _dataValidade;
        taxAdmin = _taxaAdmin;
        minPessoas = _minPessoas;
        maxPessoas = _maxPessoas;
    }
    // Funcionalidade: Entrar no contrato.
    function entrarContrato(address _carteira, string memory _imei /* preco celular */) public payable {
     require(block.timestamp <= dataValidade, "Este contrato expirou");
        require(usuarios.length < maxPessoas, "Este contrato ja atingiu o numero maximo de usuarios");

        uint precoCelular = 1000; // definir o preço do celular aqui
        uint precoTotal = precoCelular + (precoCelular * taxAdmin / 100);

        require(msg.value == precoTotal, "O valor enviado nao corresponde ao valor total do celular com a taxa administrativa");
        require(validarIMEI(_imei), "O IMEI e invalido");

        usuarios.push(Usuario(_carteira, _imei));
        saldoContrato += precoCelular;
}

    // Funcionalidade: Análise de pedido de entrada

    // dinheiro suficiente na wallet
    function balanceOf(address carteiraUsuario) public view returns (uint256) {
        if (saldoUsuario[carteiraUsuario] >= 0.05 * valorAtivo){
            return adicionarUsuario();
        }else {
            return removerUsuario(carteiraUsuario);
        }
     return saldoUsuario[carteiraUsuario];
}

    // Funcionalidade: Pedido de indenização 

    // Retorna o saldo do contrato.
    function mostrarSaldo() public view returns (uint) {
        return saldoContrato;
    }
    //Função para aceitar termo de adesão. Conforme a primeira regra de negócio selecionada como essencial ao contrato, a funcionalidade é diretamente relacionada à adesão do contrato pelo usuário.
    function aceitarTermo() public {
        require(termoAceito[msg.sender] == false, "Voce ja aceitou o termo de adesao.");
        termoAceito[msg.sender] = true;
        numAceitaram++;
    }
    //Função para ver quantidade de carteiras que estão associadas ao contrato.
    function quantCarteira() public {
        require(carteira.length < maxPessoas, "Numero maximo de carteiras atingido.");
        Carteiras memory novaCarteira = Carteiras(msg.sender);
        carteira.push(novaCarteira);
        quantiUsuario += 1;
    }
    //Função para retornar quantidade de usuários
    function quantUsuarios() public view returns (uint) {
        return quantiUsuario;
    }
    //Função para retornar data da criação do contrato
    function dataInicialCriacao() public view returns (uint) {
        return dataInicio;
    }
    // A segunda regra de negócio selecionada como fundamental para o contrato é expressa na funcionalidade que adiciona ou remover um novo usuário.
    function adicionarUsuario() public {
        require(quantiUsuario < maxPessoas, "O numero maximo de usuarios ja foi atingido.");
        quantiUsuario++;
    }
    function removerUsuario(address usuario) public donoUnico {
        for (uint i = 0; i < carteira.length; i++) {
            if (carteira[i].carteiraUsuario == usuario) {
                // Remove a carteira do usuário da lista de carteiras anteriormente instanciada.
                delete carteira[i];
                // Atualiza o número de usuários após a remoção.
                quantiUsuario--;
                break;
            }
        }
    }
    // Verifica a viabilidade e status do contrato, com a possibilidade de três estados.
    function viabilidadeContrato() public view returns (uint) {
        if (quantiUsuario >= minPessoas && block.timestamp <= dataValidade && quantiUsuario <= maxPessoas) {
            return 1; // Contrato Ativo;
        } else if (quantiUsuario < minPessoas && block.timestamp <= dataValidade) {
            return 2; // Contrato em Progresso;
        } else if (block.timestamp > dataValidade || quantiUsuario < minPessoas) {
            return 3; // Contrato Inativo;
        } else {
            revert("Erro ao verificar o contrato");
        }
    }
    // Em seguida, observa-se como regra de negócio essencial para o contrato a renovação do mesmo, próximo a sua data de vencimento.
    function renovarContrato(uint _novaDataValidade) public donoUnico {
        require(_novaDataValidade > block.timestamp, "A data de validade deve ser apos a antes instanciada.");
        // Armazena os usuários que não renovaram o contrato.
        uint[] memory indicesRemover = new uint[](quantiUsuario);
        uint quantRemover = 0;
        // Verifica na quantidade geral de usuários se todos realmente renovaram.
        for (uint i = 0; i < quantiUsuario; i++) {
            if (!termoAceito[usuarios[i]]) {
                indicesRemover[quantRemover] = i;
                quantRemover++;
            }
        }
        // Remove os usuários que não aceitaram a renovação do contrato.
        for (uint i = 0; i < quantRemover; i++) {
            removerUsuario(usuarios[indicesRemover[i]]);
        }
        // Verifica se a quantidade de usuários é compatível com o mínimo e o máximo definidos.
        require(quantiUsuario >= minPessoas && quantiUsuario <= maxPessoas, "A quantidade de usuarios nao e compativel com o minimo e o maximo definidos no contrato.");
        dataValidade = _novaDataValidade;
    }
        // A função para indenizar os usuários é tida como uma das funcionalidades mais importantes do contrato, visto que, dado que a sinistralidade aconteceu, o cálculo da idenização deve ser feito corretamente para não afetar as outras partes do contrato.
        // 1. Todo o saldo atual do participante que solicitou indenização deve consumido nesse processo, restando saldo zero para ele ao final.
        // 2. O restante do valor X a ser indenizado será dividido por todos os demais participantes, proporcionalmente ao saldo de cada um, e consequentemente, ao valor efetivamente protegido de cada um.
       function indenizar() public {
            // Verifica se o usuário tem saldo suficiente para a indenização.
            require(saldo[msg.sender] > 0, "Voce nao tem saldo suficiente para ser indenizado.");
            // Verifica o status do contrato como ativo.
            uint saldoAnterior = saldo[msg.sender];
            uint saldoTotalIndenizacao = saldoTotal - saldoAnterior;
            uint quantUsuariosIndenizar = quantiUsuario - 1; // Exclui o usuário que está solicitando a indenização dos que ainda podem fazer o pedido.
            uint valorIndenizacao = saldoAnterior + saldoTotalIndenizacao / quantUsuariosIndenizar; // Valor que cada usuário receberá com base no aporte inicial.
            uint percentualIndenizacao;
            for (uint i = 0; i < quantiUsuario; i++) {
                if (saldo[usuarios[i]] > 0) {
                    percentualIndenizacao = saldo[usuarios[i]] * 100 / saldoTotalIndenizacao;// Calcula o percentual de indenização de cada usuário.
                    uint valorUsuario = valorIndenizacao * percentualIndenizacao / 100;
                    saldo[usuarios[i]] -= valorUsuario; // Atualiza o saldo que o usuário possui.
        }
    }
    saldo[msg.sender] = 0;
    }
    // Para o funcionamento do contrato, os usuário precisam depositar o saldo necessário para cobrir a idenização. Por tanto, essa função corresponde a uma regra de negócio essencial.
    function depositarSaldo() public payable {
        require(msg.value > 0, "O valor do deposito deve ser maior que zero.");
        saldo[msg.sender] += msg.value;
        saldoContrato += msg.value;
    }
    // Função para retornar o saldo de um usuário.
    function saldoUsuario(address usuario) public view returns (uint) {
        return saldo[usuario];
    }
    // Função para retornar o saldo total do contrato.
    function saldoTotalContrato() public view returns (uint) {
        return totalContrato;
    }
    // Após a indenização, o usuário precisa repor a reserva para cobrir outras possíveis sinistralidade. Essa função corresponde a uma funcionalidade essencial para a manutenção do ecossistema contratual.
    function reposicaoReserva(address usuario) public payable{
        require(totalContrato == 0, "A reserva do contrato precisa ser reposta");
        saldoContrato = saldo[usuario];
        totalContrato = msg.value;

    }

    
       
}
