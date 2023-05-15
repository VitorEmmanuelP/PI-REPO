class BusData {
  String motorista;
  String id;
  String destino;
  String idPrefeitura;
  String modelo;
  String placa;

  BusData({
    required this.motorista,
    required this.id,
    required this.destino,
    required this.idPrefeitura,
    required this.modelo,
    required this.placa,
  });

  factory BusData.fromJson(Map<String, dynamic> json) {
    return BusData(
      motorista: json['motorista'],
      id: json['id'],
      destino: json['destino'],
      idPrefeitura: json['idPrefeitura'],
      modelo: json['modelo'],
      placa: json['placa'],
    );
  }

  Map<String, dynamic> toJson() => {
        'motorista': motorista,
        'id': id,
        'destino': destino,
        'idPrefeitura': idPrefeitura,
        'modelo': modelo,
        'placa': placa,
      };
}
