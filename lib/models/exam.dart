class Exam {
  final String id;
  final String nome;
  final DateTime dataExame;
  final String arquivoUrl;
  final String pacienteId;
  final String? observacoes;

  Exam({
    required this.id,
    required this.nome,
    required this.dataExame,
    required this.arquivoUrl,
    required this.pacienteId,
    this.observacoes,
  });
}