class UserData {
  String nome;
  String cpf;
  String? profilePic;
  String data;
  String curso;
  String faculdade;
  String telefone;
  String senha;
  String status;
  String id;
  String idPrefeitura;
  String idOnibus;
  String token;
  String qrCode;

  UserData({
    required this.nome,
    required this.cpf,
    required this.profilePic,
    required this.data,
    required this.curso,
    required this.faculdade,
    required this.telefone,
    required this.senha,
    required this.status,
    required this.id,
    required this.idPrefeitura,
    required this.idOnibus,
    required this.token,
    required this.qrCode,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
        nome: json['nome'],
        cpf: json['cpf'],
        profilePic: json['profilePic'],
        data: json['data'],
        curso: json['curso'],
        faculdade: json['faculdade'],
        telefone: json['telefone'],
        senha: json['senha'],
        status: json['status'],
        id: json['id'],
        idPrefeitura: json['idPrefeitura'],
        idOnibus: json['idOnibus'],
        token: json['token'],
        qrCode: json['qrCode']);
  }

  Map<String, dynamic> toJson() => {
        'nome': nome,
        'cpf': cpf,
        'profilePic': profilePic,
        'data': data,
        'curso': curso,
        'faculdade': faculdade,
        'telefone': telefone,
        'senha': senha,
        'status': status,
        'id': id,
        'idPrefeitura': idPrefeitura,
        'idOnibus': idOnibus,
        'token': token,
        'qrCode': qrCode
      };
}
