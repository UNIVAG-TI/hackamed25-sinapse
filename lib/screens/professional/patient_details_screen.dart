import 'package:flutter/material.dart';
import 'package:sinapse/services/data_service.dart';
import 'package:sinapse/models/user.dart';
import 'package:sinapse/models/exam.dart';
import 'package:sinapse/models/diagnosis.dart';
import 'package:sinapse/models/appointment.dart';
import 'package:sinapse/screens/professional/diagnosis_management_screen.dart';

class PatientDetailsScreen extends StatefulWidget {
  final Paciente patient;

  const PatientDetailsScreen({super.key, required this.patient});

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  List<Exam> _exams = [];
  Diagnosis? _diagnosis;
  DateTime? _ultimaConsulta;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final exams = await DataService.getExamsByPaciente(widget.patient.id);
      final diagnosis = await DataService.getDiagnosisByPaciente(widget.patient.id);
      final appts = await DataService.getAppointmentsByPaciente(widget.patient.id);

      // Define a última consulta como a mais recente no passado
      DateTime? ultima;
      final now = DateTime.now();
      for (final a in appts) {
        if (a.data.isBefore(now) || a.data.isAtSameMomentAs(now)) {
          if (ultima == null || a.data.isAfter(ultima)) {
            ultima = a.data;
          }
        }
      }
      
      setState(() {
        _exams = exams;
        _diagnosis = diagnosis;
        _ultimaConsulta = ultima;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar dados: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  String _getRiskLevelText(ClassificacaoRisco risco) {
    switch (risco) {
      case ClassificacaoRisco.muitoBaixo:
        return 'Muito Baixo';
      case ClassificacaoRisco.baixo:
        return 'Baixo';
      case ClassificacaoRisco.moderado:
        return 'Moderado';
      case ClassificacaoRisco.alto:
        return 'Alto';
      case ClassificacaoRisco.muitoAlto:
        return 'Muito Alto';
    }
  }

  Color _getRiskColor(ClassificacaoRisco risco) {
    switch (risco) {
      case ClassificacaoRisco.muitoBaixo:
        return Colors.green;
      case ClassificacaoRisco.baixo:
        return Colors.lightGreen;
      case ClassificacaoRisco.moderado:
        return Colors.orange;
      case ClassificacaoRisco.alto:
        return Colors.deepOrange;
      case ClassificacaoRisco.muitoAlto:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final age = DateTime.now().year - widget.patient.dataNascimento.year;
    final String? latestDxSummary = _diagnosis != null
        ? (_diagnosis!.doencasCronicas.isNotEmpty
            ? _diagnosis!.doencasCronicas.first
            : (_diagnosis!.doencasPrevias.isNotEmpty
                ? _diagnosis!.doencasPrevias.first
                : null))
        : null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.patient.nomeCompleto.split(' ').first),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Informações do Paciente
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                child: Icon(
                                  Icons.person,
                                  size: 30,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.patient.nomeCompleto,
                                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '$age anos • ${widget.patient.cpf}',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow(Icons.email, widget.patient.email),
                          const SizedBox(height: 8),
                          _buildInfoRow(Icons.location_on, widget.patient.endereco),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            Icons.cake,
                            '${widget.patient.dataNascimento.day.toString().padLeft(2, '0')}/${widget.patient.dataNascimento.month.toString().padLeft(2, '0')}/${widget.patient.dataNascimento.year}',
                          ),
                          if (_ultimaConsulta != null) ...[
                            const SizedBox(height: 8),
                            _buildInfoRow(
                              Icons.event_available,
                              'Última consulta: '
                                  '${_ultimaConsulta!.day.toString().padLeft(2, '0')}/'
                                  '${_ultimaConsulta!.month.toString().padLeft(2, '0')}/'
                                  '${_ultimaConsulta!.year}',
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Classificação de Risco (visível apenas para profissionais)
                  if (_diagnosis != null) ...[
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getRiskColor(_diagnosis!.classificacaoFinal).withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.warning,
                                    color: _getRiskColor(_diagnosis!.classificacaoFinal),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Classificação de Risco',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _getRiskColor(_diagnosis!.classificacaoFinal),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      _getRiskLevelText(_diagnosis!.classificacaoFinal),
                                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (latestDxSummary != null) ...[
                                Text(
                                  'Diagnóstico mais recente: $latestDxSummary',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 8),
                              ],
                              Text(
                                'Última atualização: ${_diagnosis!.dataAtualizacao.day.toString().padLeft(2, '0')}/${_diagnosis!.dataAtualizacao.month.toString().padLeft(2, '0')}/${_diagnosis!.dataAtualizacao.year}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Ações Rápidas
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DiagnosisManagementScreen(
                                patient: widget.patient,
                                diagnosis: _diagnosis,
                              ),
                            ),
                          ).then((_) => _loadData()),
                          icon: const Icon(Icons.medical_information),
                          label: Text(_diagnosis == null ? 'Criar Diagnóstico' : 'Gerenciar Diagnóstico'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Exames
                  Text(
                    'Últimas Consultas e Exames',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  if (_exams.isEmpty)
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Icon(
                              Icons.description_outlined,
                              size: 48,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhum exame cadastrado',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Este paciente ainda não enviou nenhum exame.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._exams.map((exam) => ExamCard(exam: exam)).toList(),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ),
      ],
    );
  }
}

class ExamCard extends StatelessWidget {
  final Exam exam;

  const ExamCard({super.key, required this.exam});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          child: Icon(
            Icons.description,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
        title: Text(exam.nome),
        subtitle: Text(
          '${exam.dataExame.day.toString().padLeft(2, '0')}/${exam.dataExame.month.toString().padLeft(2, '0')}/${exam.dataExame.year}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.download),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Iniciando download do exame...')),
            );
          },
        ),
      ),
    );
  }
}