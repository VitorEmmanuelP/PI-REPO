class PrefeituraData {
  String nome;
  String senha;
  String id;
  String status;
  String prefeituraNome;

  PrefeituraData({
    required this.nome,
    required this.senha,
    required this.id,
    required this.status,
    required this.prefeituraNome,
  });

  factory PrefeituraData.fromJson(Map<String, dynamic> json) {
    return PrefeituraData(
        nome: json['nome'],
        senha: json['senha'],
        id: json['id'],
        status: json['status'],
        prefeituraNome: json['prefeituraNome']);
  }

  Map<String, dynamic> toJson() => {
        'nome': nome,
        'senha': senha,
        'id': id,
        'status': status,
        'prefeituraNome': prefeituraNome,
      };
}
