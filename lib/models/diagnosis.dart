class Diagnosis {
  final String id;
  final String pacienteId;
  final String profissionalId;
  final DateTime dataAtualizacao;
  final List<String> doencasPrevias;
  final RiscoMortalidade riscoMortalidade;
  final List<String> examesObjetivoDiagnostico;
  final int idade;
  final List<String> doencasCronicas;
  final String? hereditariedade;
  final String? genetica;
  final String acessoServicoSaude;
  final ClassificacaoRisco classificacaoFinal;

  Diagnosis({
    required this.id,
    required this.pacienteId,
    required this.profissionalId,
    required this.dataAtualizacao,
    required this.doencasPrevias,
    required this.riscoMortalidade,
    required this.examesObjetivoDiagnostico,
    required this.idade,
    required this.doencasCronicas,
    this.hereditariedade,
    this.genetica,
    required this.acessoServicoSaude,
    required this.classificacaoFinal,
  });
}

enum RiscoMortalidade {
  baixo,
  moderado,
  alto,
  muitoAlto
}

enum ClassificacaoRisco {
  muitoBaixo,
  baixo,
  moderado,
  alto,
  muitoAlto
}

class DiagnosisHistory {
  final String id;
  final String diagnosisId;
  final String profissionalId;
  final String nomeProfissional;
  final DateTime dataAlteracao;
  final String alteracoes;

  DiagnosisHistory({
    required this.id,
    required this.diagnosisId,
    required this.profissionalId,
    required this.nomeProfissional,
    required this.dataAlteracao,
    required this.alteracoes,
  });
}