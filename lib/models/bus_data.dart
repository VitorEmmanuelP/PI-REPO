class BusData {
  String motorista;
  String id;
  String destino;
  String idPrefeitura;
  String modelo;
  String placa;
  String numeroVagas;
  String vagasRestantes;
  String profilePic;

  BusData({
    required this.motorista,
    required this.id,
    required this.destino,
    required this.idPrefeitura,
    required this.modelo,
    required this.placa,
    required this.numeroVagas,
    required this.profilePic,
    required this.vagasRestantes,
  });

  factory BusData.fromJson(Map<String, dynamic> json) {
    return BusData(
      motorista: json['motorista'],
      id: json['id'],
      destino: json['destino'],
      idPrefeitura: json['idPrefeitura'],
      modelo: json['modelo'],
      placa: json['placa'],
      numeroVagas: json['numeroVagas'],
      vagasRestantes: json['vagasRestantes'],
      profilePic: json['profilePic'],
    );
  }

  Map<String, dynamic> toJson() => {
        'motorista': motorista,
        'id': id,
        'destino': destino,
        'idPrefeitura': idPrefeitura,
        'modelo': modelo,
        'placa': placa,
        'numeroVagas': numeroVagas,
        'vagasRestantes': vagasRestantes,
        'profilePic': profilePic,
      };
}
