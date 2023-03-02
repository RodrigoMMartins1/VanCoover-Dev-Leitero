// Função para validar o IMEI
    function validarIMEI(string memory _imei) private pure returns (bool) {
        // implementar a lógica de validação do IMEI aqui
        bytes memory imeiBytes = bytes(_imei);
            if (imeiBytes.length != 15) {
        return false;
    }

        uint sum = 0;

    for (uint i = 0; i < 15; i++) {
        uint digit = uint8(bytes(imeiBytes)[i]) - 48;

        if (i % 1 == 0) {
            digit *= 2;
        }

        sum += digit / 10 + digit % 10;
    }

        return sum % 10 == 0;

}

// transformar o imei em hash

 function imeiHash(string[] memory imeis) private pure returns (bytes32) {
    bytes32 hash = 0x0;
    for (uint256 i = 0; i < imeis.length; i++) {
        bytes memory imeiBytes = bytes(imeis[i]);
        bytes32 imeiHash = keccak256(imeiBytes);
        hash = keccak256(abi.encodePacked(hash, imeiHash));
    }
    return hash;