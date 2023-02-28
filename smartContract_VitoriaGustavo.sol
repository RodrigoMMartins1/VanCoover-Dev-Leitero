//pedido para entrar no contrato 
pragma solidity ^0.8.17;
contract ContratoCoover {
    //estrutura de dados para armazenar as informações necessários para entrar em um contrato
    struct entrarContrato {
        bytes32 hashImei; //retorna o valor do hash do IMEI (32 dígitos)
        uint valorCelular; // valor referente ao celular do usuário
        bool possuiCarteira; //se o usuário possui carteira no Metamask
    }

// função que recebe e retorna as informações do backend (sem armazenamento no contrato, apenas na memória)
    function retornarEntrarContrato(bytes32 hashImei, uint valorCelular, bool possuiCarteira) public pure returns (entrarContrato memory) {
        return entrarContrato(hashImei, valorCelular, possuiCarteira);
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
