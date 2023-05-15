class PayloadPix {
  String idPayloadFormatIndicator = '00';
  String idMerchantAccountInformation = '26';
  String idMerchantAccountInformationGui = '00';
  String idMerchantAccountInformationKey = '01';
  String idMerchantAccountInformationDescription = '02';
  String idMerchantCategoryCode = '52';
  String idTransactionCurrency = '53';
  String idTransactionAmount = '54';
  String idCountryCode = '58';
  String idMerchantName = '59';
  String idMerchantCity = '60';
  String idAdditionalDataFieldTemplate = '62';
  String idAdditionalDataFieldTemplateTxId = '05';
  String idCrc16 = '63';

  String pixKey;
  String description;
  String merchantCity;
  String amount;
  String txId;
  String merchantName;

  PayloadPix({
    required this.pixKey,
    required this.description,
    required this.merchantName,
    required this.merchantCity,
    required this.amount,
    required this.txId,
  });

  String getValue(String id, String value) {
    String size = value.length.toString().padLeft(2, '0');

    return id + size + value;
  }

  String getMerchantAccountInformation() {
    String gui = getValue(idMerchantAccountInformationGui, 'br.gov.bcb.pix');

    String key = getValue(idMerchantAccountInformationKey, pixKey);

    String descriptiona = (description.isNotEmpty)
        ? getValue(idMerchantAccountInformationDescription, description)
        : '';

    return getValue(idMerchantAccountInformation, gui + key + descriptiona);
  }

  getAdditionalDataFieldTemplate() {
    final tidd = getValue(idAdditionalDataFieldTemplateTxId, txId);

    return getValue(idAdditionalDataFieldTemplate, tidd);
  }

  String getCRC16(String payload) {
    // Adiciona dados gerais no payload
    payload += '$idCrc16' '04';

    // Dados definidos pelo BACEN
    int polinomio = 0x1021;
    int resultado = 0xFFFF;

    // Checksum
    int length = payload.length;
    if (length > 0) {
      for (int offset = 0; offset < length; offset++) {
        resultado ^= (payload.codeUnitAt(offset) << 8);
        for (int bitwise = 0; bitwise < 8; bitwise++) {
          if ((resultado & 0x8000) != 0) {
            resultado = ((resultado << 1) ^ polinomio) & 0xFFFF;
          } else {
            resultado = (resultado << 1) & 0xFFFF;
          }
        }
      }
    }

    // Retorna código CRC16 de 4 caracteres

    return '$idCrc16' '04${resultado.toRadixString(16).toUpperCase()}';
  }

  String getPayload() {
    String payload = getValue(idPayloadFormatIndicator, '01') +
        getMerchantAccountInformation() +
        getValue(idMerchantCategoryCode, '0000') +
        getValue(idTransactionCurrency, '986') +
        getValue(idTransactionAmount, amount) +
        getValue(idCountryCode, 'BR') +
        getValue(idMerchantName, merchantName) +
        getValue(idMerchantCity, merchantCity) +
        getAdditionalDataFieldTemplate();

    return payload + getCRC16(payload);
  }
}
