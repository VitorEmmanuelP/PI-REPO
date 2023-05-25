class BusData {
  String motorista;
  String id;
  String destino;
  String idPrefeitura;
  String modelo;
  String placa;
  String numero_vagas;

  BusData({
    required this.motorista,
    required this.id,
    required this.destino,
    required this.idPrefeitura,
    required this.modelo,
    required this.placa,
    required this.numero_vagas,
  });

  factory BusData.fromJson(Map<String, dynamic> json) {
    return BusData(
      motorista: json['motorista'],
      id: json['id'],
      destino: json['destino'],
      idPrefeitura: json['idPrefeitura'],
      modelo: json['modelo'],
      placa: json['placa'],
      numero_vagas: json['numero_vagas'],
    );
  }

  Map<String, dynamic> toJson() => {
        'motorista': motorista,
        'id': id,
        'destino': destino,
        'idPrefeitura': idPrefeitura,
        'modelo': modelo,
        'placa': placa,
        'numero_vagas': numero_vagas
      };
}
