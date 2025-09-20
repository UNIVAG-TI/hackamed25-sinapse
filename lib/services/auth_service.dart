import 'package:sinapse/models/user.dart';

class AuthService {
  static User? _currentUser;
  
  static User? get currentUser => _currentUser;
  
  static final List<Paciente> _pacientes = [
    Paciente(
      id: '1',
      nomeCompleto: 'Maria Silva Santos',
      email: 'maria.silva@email.com',
      cpf: '123.456.789-00',
      endereco: 'Rua das Flores, 123 - Centro, Cuiabá - MT',
      dataNascimento: DateTime(1985, 5, 15),
    ),
    Paciente(
      id: '2',
      nomeCompleto: 'João Carlos Oliveira',
      email: 'joao.carlos@email.com',
      cpf: '987.654.321-00',
      endereco: 'Av. Brasil, 456 - Jardim Aclimação, Cuiabá - MT',
      dataNascimento: DateTime(1978, 10, 22),
    ),
    // Novo paciente de exemplo para o fluxo do Profissional da Saúde
    Paciente(
      id: '5',
      nomeCompleto: 'Ana Clara da Silva',
      email: 'ana.clara@exemplo.com',
      cpf: '123.456.789-00',
      endereco: 'Rua Ipês, 250 - Bosque da Saúde, Cuiabá - MT',
      dataNascimento: DateTime(1995, 3, 12),
    ),
  ];

  static final List<ProfissionalSaude> _profissionais = [
    ProfissionalSaude(
      id: '3',
      nomeCompleto: 'Dr. Carlos Alberto Mendes',
      email: 'carlos.mendes@sinapse.com',
      crm: 'CRM/MT 12345',
      cpf: '111.222.333-44',
    ),
    ProfissionalSaude(
      id: '4',
      nomeCompleto: 'Dra. Ana Paula Rodrigues',
      email: 'ana.rodrigues@sinapse.com',
      crm: 'CRM/MT 67890',
      cpf: '555.666.777-88',
    ),
  ];

  static Future<User?> loginPaciente(String cpf, String senha) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final paciente = _pacientes.firstWhere(
      (p) => p.cpf == cpf,
      orElse: () => throw Exception('CPF não encontrado'),
    );
    
    if (senha == '123456') {
      _currentUser = paciente;
      return paciente;
    }
    
    throw Exception('Senha incorreta');
  }

  static Future<User?> loginProfissional(String crm, String senha) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final profissional = _profissionais.firstWhere(
      (p) => p.crm == crm,
      orElse: () => throw Exception('CRM não encontrado'),
    );
    
    if (senha == '123456') {
      _currentUser = profissional;
      return profissional;
    }
    
    throw Exception('Senha incorreta');
  }

  static Future<void> registerPaciente({
    required String nomeCompleto,
    required String cpf,
    required String endereco,
    required DateTime dataNascimento,
    required String email,
    required String senha,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    
    final novoPaciente = Paciente(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nomeCompleto: nomeCompleto,
      email: email,
      cpf: cpf,
      endereco: endereco,
      dataNascimento: dataNascimento,
    );
    
    _pacientes.add(novoPaciente);
  }

  static Future<void> registerProfissional({
    required String nomeCompleto,
    required String crm,
    required String cpf,
    required String email,
    required String senha,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    
    final novoProfissional = ProfissionalSaude(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nomeCompleto: nomeCompleto,
      email: email,
      crm: crm,
      cpf: cpf,
    );
    
    _profissionais.add(novoProfissional);
  }

  static void logout() {
    _currentUser = null;
  }

  static List<Paciente> getAllPacientes() => List.from(_pacientes);
}