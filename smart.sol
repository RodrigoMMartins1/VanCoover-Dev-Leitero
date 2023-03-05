pragma solidity ^0.8.18;
contract ContratoCoover {
    // Variáveis fundamentais para a manipulação dos conteúdos dentro das funções.
    uint public valorAtivo;
    uint public saldoUsuario;
    uint public saldoContrato;
    uint public quantiUsuario;
    uint public dataInicio;
    uint public dataValidade;
    uint public minPessoas = 5;
    uint public maxPessoas = 50;
    uint public duracaoDias;
    uint public valorCobertura;
    uint public totalContrato;
    string private IMEI;
    uint public taxAdmin;
    uint public hashBo;
    string[] private listaIMEIs;
    address private _admin;


    // Struct definido para armazenar os dados das carteiras associadas ao contrato, tendo como membro os endereços das carteiras.
    struct Usuario {
        address carteira;
        string IMEI;
        string bo;
    }

    }
    struct Carteiras {
        address carteiraUsuario;
    }
    // Armazena-se as carteiras em um array público para serem lidas como a variável carteira.
    Carteiras[]  carteira;


    // Armazena-se as carteiras em um array público para serem lidas como a variável carteira.
    Usuario[]  usuarios;
    // Mapeamento do número de carteiras que estão associadas ao contrato.
    mapping(address => bool)  termoAceito;
    uint  numAceitaram;
    // Mapeamento do valor inteiro, dentro do endereço indicado, para identificação do saldo pertecente ao contrato.
    mapping (address => uint)  saldo;
    uint  saldoTotal;

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

        usuarios.push(Usuario(_carteira, _imei));
        saldoContrato += precoCelular;
}
}
