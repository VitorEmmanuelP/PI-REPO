class PrefeituraData {
  String nome;
  String senha;
  String id;
  String status;

  PrefeituraData(
      {required this.nome,
      required this.senha,
      required this.id,
      required this.status});

  factory PrefeituraData.fromJson(Map<String, dynamic> json) {
    return PrefeituraData(
      nome: json['nome'],
      senha: json['senha'],
      id: json['id'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() => {
        'nome': nome,
        'senha': senha,
        'id': id,
        'status': status,
      };
}
