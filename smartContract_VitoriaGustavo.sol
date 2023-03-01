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
}

// pragma solidity ^0.8.17;
// contract ContratoCoover2 {
//     //estrutura de dados para armazenar as informações necessários para entrar em um contrato
//     struct entrarContrato2 {
//         bytes32 hashImei; //retorna o valor do hash do IMEI (32 dígitos)
//         uint valorCelular; // valor referente ao celular do usuário
//         bool possuiCarteira; //se o usuário possui carteira no Metamask
//     }

// // função que recebe e retorna as informações do backend (sem armazenamento no contrato, apenas na memória)
//     function retornarEntrarContrato2(bytes32 hashImei, uint valorCelular, bool possuiCarteira) public pure returns (entrarContrato2 memory) {
//         return entrarContrato2({
//             hashImei: hashImei,
//             valorCelular: valorCelular,
//             possuiCarteira: possuiCarteira

//         });
//     }
// }


