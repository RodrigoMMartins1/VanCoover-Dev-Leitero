//pedido para entrar no contrato 
pragma solidity ^0.8.17;

contract ContratoCoover {
    //estrutura de dados para armazenar as informações necessários para entrar em um contrato
    struct entrarContrato {
        IMEI; //retorna o valor do hash do IMEI (32 dígitos)
        uint valorAtivo; // valor referente ao celular do usuário
        carteiraUsuario; //se o usuário possui carteira no Metamask
    }

// função que recebe e retorna as informações do backend (sem armazenamento no contrato, apenas na memória)
    function retornarEntrarContrato(_IMEI, uint _valorAtivo, _carteiraUsuario) public pure returns (entrarContrato memory) {
        return entrarContrato(_IMEI, _valorAtivo, _carteiraUsuario);
    }
// função para retornar o valor do depósito inicial de um usuário a partir do valor do aparelho a ser segurado, acrescido do valor da taxa administrativa.
    function primeiroDeposito(uint _taxAdmin, uint _valorAtivo){
        uint depositoInicial; //variável que irá armazenar o valor a ser depositado
        
        depositoInicial = (_valorAtivo * 0.05) + _taxAdmin;// Deposito inicial = cobertura(5% do valor do celular) + tax admin
        //fórmula para extrair 5% do valor total do aparelho segurado, acrescentando a taxa administrativa
        
        return depositoInicial;
        //retornando o valor do depósito inicial que deve ser realizado
    }

    //Estrutura que contém o endereço da carteira do usuário e um valor booleano para representar a confirmação da renovação do usuário.
    struct Usuario {
    address carteiraUsuario;
    bool confirmaRenovacao;
    }

    //Função para aceitação de renovação do contrato a partir dos usuários
    function aceitarRenovação(bool escolha) public {
    //Declara variável booleana usuarioJaConfirmiu e instancia como FALSE
    bool usuarioJaConfirmou = false;
    //Loop para passar por cada elemento no array carteira
    for (uint i = 0; i < carteira.length; i++) {
        //verifica se o endereço da carteira do usuário no array é igual ao endereço do usuário que está chamando a função.
        if (carteira[i].carteiraUsuario == msg.sender) {
            //Define a confirmação do usuário do usuário atual no array como a escolha fornecida na chamada da função.
            carteira[i].confirmaRenovacao = escolha;
            //verificar se o usuário atual já escolheu a confirmação
            usuarioJaConfirmou = true;
            //Comando para sair do loop atual assim que o encontrar usuário e registrar escolha 
            break;
        }
    }

}


