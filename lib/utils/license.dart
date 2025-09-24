import 'dart:convert';

class License {
  //Cryption
  String encryptData(String clearData, String keyWord) {
    String tempKeyWord = List.generate(
      (clearData.length / keyWord.length).ceil() + 1,
      (index) => keyWord,
    ).join();
    String encryptedData = "";

    for (int i = 0; i < clearData.length; i++) {
      var dataCharToDecimal = clearData[i].codeUnitAt(0);
      var keyCharToDecimal = tempKeyWord[i].codeUnitAt(0);

      if (dataCharToDecimal + keyCharToDecimal < 127) {
        encryptedData += String.fromCharCode(
          dataCharToDecimal + keyCharToDecimal,
        );
      } else {
        encryptedData += String.fromCharCode(
          dataCharToDecimal + keyCharToDecimal - 96,
        );
      }
    }
    return base64.encode(utf8.encode(encryptedData));
  }

  String decryptData(String encryptedBase64Data, String keyWord) {
    String decodedData = utf8.decode(base64.decode(encryptedBase64Data));

    String tempKeyWord = List.generate(
      (decodedData.length / keyWord.length).ceil() + 1,
      (index) => keyWord,
    ).join();

    String decryptedData = "";

    for (int i = 0; i < decodedData.length; i++) {
      var dataCharToDecimal = decodedData[i].codeUnitAt(0);
      var keyCharToDecimal = tempKeyWord[i].codeUnitAt(0);

      if (dataCharToDecimal - keyCharToDecimal > 31) {
        decryptedData += String.fromCharCode(
          dataCharToDecimal - keyCharToDecimal,
        );
      } else {
        decryptedData += String.fromCharCode(
          96 + dataCharToDecimal - keyCharToDecimal,
        );
      }
    }
    return decryptedData;
  }
}
