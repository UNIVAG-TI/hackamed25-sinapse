import 'package:sinapse/models/appointment.dart';
import 'package:sinapse/models/exam.dart';
import 'package:sinapse/models/diagnosis.dart';

class DataService {
  static final List<Appointment> _appointments = [
    Appointment(
      id: '1',
      data: DateTime.now().add(const Duration(days: 3)),
      medico: 'Dr. Carlos Alberto Mendes',
      especialidade: 'Cardiologia',
      local: 'Hospital Santa Rosa - Sala 205',
      pacienteId: '1',
    ),
    Appointment(
      id: '2',
      data: DateTime.now().add(const Duration(days: 7)),
      medico: 'Dra. Ana Paula Rodrigues',
      especialidade: 'Endocrinologia',
      local: 'Clínica Vida Saudável - Consultório 3',
      pacienteId: '1',
    ),
    Appointment(
      id: '3',
      data: DateTime.now().add(const Duration(days: 2)),
      medico: 'Dr. Roberto Silva',
      especialidade: 'Clínico Geral',
      local: 'UBS Centro - Consultório 1',
      pacienteId: '2',
    ),
    // Última consulta de Ana Clara: 15/09/2025
    Appointment(
      id: '4',
      data: DateTime(2025, 9, 15),
      medico: 'Dra. Ana Paula Rodrigues',
      especialidade: 'Cardiologia',
      local: 'Hospital Santa Rosa - Sala 210',
      pacienteId: '5',
    ),
  ];

  static final List<Exam> _exams = [
    Exam(
      id: '1',
      nome: 'Hemograma Completo',
      dataExame: DateTime.now().subtract(const Duration(days: 30)),
      arquivoUrl: 'https://exemplo.com/exames/hemograma_maria.pdf',
      pacienteId: '1',
      observacoes: 'Valores dentro da normalidade',
    ),
    Exam(
      id: '2',
      nome: 'Eletrocardiograma',
      dataExame: DateTime.now().subtract(const Duration(days: 15)),
      arquivoUrl: 'https://exemplo.com/exames/ecg_maria.pdf',
      pacienteId: '1',
    ),
    Exam(
      id: '3',
      nome: 'Raio-X Tórax',
      dataExame: DateTime.now().subtract(const Duration(days: 45)),
      arquivoUrl: 'https://exemplo.com/exames/rx_joao.pdf',
      pacienteId: '2',
      observacoes: 'Pulmões limpos, sem alterações',
    ),
  ];

  static final List<Diagnosis> _diagnoses = [
    Diagnosis(
      id: '1',
      pacienteId: '1',
      profissionalId: '3',
      dataAtualizacao: DateTime.now().subtract(const Duration(days: 10)),
      doencasPrevias: ['Hipertensão', 'Diabetes Tipo 2'],
      riscoMortalidade: RiscoMortalidade.moderado,
      examesObjetivoDiagnostico: ['Hemograma', 'Glicemia', 'ECG'],
      idade: 38,
      doencasCronicas: ['Hipertensão Arterial'],
      hereditariedade: 'Histórico familiar de diabetes',
      genetica: 'Sem alterações genéticas conhecidas',
      acessoServicoSaude: 'Distância: 5km da UBS mais próxima',
      classificacaoFinal: ClassificacaoRisco.moderado,
    ),
    // Diagnóstico mais recente de Ana Clara: Hipertensão Essencial, Classificação: Alto
    Diagnosis(
      id: '2',
      pacienteId: '5',
      profissionalId: '3',
      dataAtualizacao: DateTime.now().subtract(const Duration(days: 1)),
      doencasPrevias: const [],
      riscoMortalidade: RiscoMortalidade.alto,
      examesObjetivoDiagnostico: const ['PA ambulatorial', 'Perfil lipídico'],
      idade: 30,
      doencasCronicas: const ['Hipertensão Essencial'],
      hereditariedade: 'Mãe com hipertensão',
      genetica: 'Sem alterações conhecidas',
      acessoServicoSaude: 'UBS a 3 km, transporte público disponível',
      classificacaoFinal: ClassificacaoRisco.alto,
    ),
  ];

  static final List<DiagnosisHistory> _diagnosisHistory = [
    DiagnosisHistory(
      id: '1',
      diagnosisId: '1',
      profissionalId: '3',
      nomeProfissional: 'Dr. Carlos Alberto Mendes',
      dataAlteracao: DateTime.now().subtract(const Duration(days: 10)),
      alteracoes: 'Diagnóstico inicial criado com classificação de risco moderado',
    ),
    DiagnosisHistory(
      id: '2',
      diagnosisId: '2',
      profissionalId: '3',
      nomeProfissional: 'Dr. Carlos Alberto Mendes',
      dataAlteracao: DateTime.now().subtract(const Duration(days: 1)),
      alteracoes: 'Diagnóstico inicial criado com classificação de risco alto',
    ),
  ];

  static Future<List<Appointment>> getAppointmentsByPaciente(String pacienteId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _appointments.where((a) => a.pacienteId == pacienteId && !a.cancelado).toList();
  }

  static Future<void> cancelAppointment(String appointmentId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _appointments.indexWhere((a) => a.id == appointmentId);
    if (index >= 0) {
      _appointments[index] = _appointments[index].copyWith(cancelado: true);
    }
  }

  static Future<List<Exam>> getExamsByPaciente(String pacienteId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _exams.where((e) => e.pacienteId == pacienteId).toList();
  }

  static Future<void> uploadExam({
    required String nome,
    required String pacienteId,
    required String arquivoUrl,
    String? observacoes,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    final novoExame = Exam(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nome: nome,
      dataExame: DateTime.now(),
      arquivoUrl: arquivoUrl,
      pacienteId: pacienteId,
      observacoes: observacoes,
    );
    _exams.add(novoExame);
  }

  static Future<Diagnosis?> getDiagnosisByPaciente(String pacienteId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      return _diagnoses.firstWhere((d) => d.pacienteId == pacienteId);
    } catch (e) {
      return null;
    }
  }

  static Future<List<DiagnosisHistory>> getDiagnosisHistory(String diagnosisId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _diagnosisHistory.where((h) => h.diagnosisId == diagnosisId).toList();
  }

  static Future<void> updateDiagnosis(Diagnosis diagnosis) async {
    await Future.delayed(const Duration(seconds: 1));
    final index = _diagnoses.indexWhere((d) => d.id == diagnosis.id);
    if (index >= 0) {
      _diagnoses[index] = diagnosis;
    } else {
      _diagnoses.add(diagnosis);
    }
    
    // Adicionar ao histórico
    final historyEntry = DiagnosisHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      diagnosisId: diagnosis.id,
      profissionalId: diagnosis.profissionalId,
      nomeProfissional: 'Dr. Profissional', // Em um app real, buscaria o nome
      dataAlteracao: DateTime.now(),
      alteracoes: 'Diagnóstico atualizado',
    );
    _diagnosisHistory.add(historyEntry);
  }
}