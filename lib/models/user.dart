class User {
  final String id;
  final String nomeCompleto;
  final String email;
  final String? fotoUrl;
  final UserType tipo;

  User({
    required this.id,
    required this.nomeCompleto,
    required this.email,
    this.fotoUrl,
    required this.tipo,
  });
}

enum UserType { paciente, profissional }

class Paciente extends User {
  final String cpf;
  final String endereco;
  final DateTime dataNascimento;

  Paciente({
    required super.id,
    required super.nomeCompleto,
    required super.email,
    super.fotoUrl,
    required this.cpf,
    required this.endereco,
    required this.dataNascimento,
  }) : super(tipo: UserType.paciente);
}

class ProfissionalSaude extends User {
  final String crm;
  final String cpf;

  ProfissionalSaude({
    required super.id,
    required super.nomeCompleto,
    required super.email,
    super.fotoUrl,
    required this.crm,
    required this.cpf,
  }) : super(tipo: UserType.profissional);
}