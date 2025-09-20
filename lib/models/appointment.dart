class Appointment {
  final String id;
  final DateTime data;
  final String medico;
  final String especialidade;
  final String local;
  final String pacienteId;
  final bool cancelado;

  Appointment({
    required this.id,
    required this.data,
    required this.medico,
    required this.especialidade,
    required this.local,
    required this.pacienteId,
    this.cancelado = false,
  });

  Appointment copyWith({
    String? id,
    DateTime? data,
    String? medico,
    String? especialidade,
    String? local,
    String? pacienteId,
    bool? cancelado,
  }) {
    return Appointment(
      id: id ?? this.id,
      data: data ?? this.data,
      medico: medico ?? this.medico,
      especialidade: especialidade ?? this.especialidade,
      local: local ?? this.local,
      pacienteId: pacienteId ?? this.pacienteId,
      cancelado: cancelado ?? this.cancelado,
    );
  }
}