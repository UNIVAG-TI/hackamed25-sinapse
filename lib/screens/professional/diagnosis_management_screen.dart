import 'package:flutter/material.dart';
import 'package:sinapse/services/auth_service.dart';
import 'package:sinapse/services/data_service.dart';
import 'package:sinapse/models/user.dart';
import 'package:sinapse/models/diagnosis.dart';

class DiagnosisManagementScreen extends StatefulWidget {
  final Paciente patient;
  final Diagnosis? diagnosis;

  const DiagnosisManagementScreen({
    super.key,
    required this.patient,
    this.diagnosis,
  });

  @override
  State<DiagnosisManagementScreen> createState() =>
      _DiagnosisManagementScreenState();
}

class _DiagnosisManagementScreenState extends State<DiagnosisManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _doencasPreviasController = TextEditingController();
  final _examesController = TextEditingController();
  final _idadeController = TextEditingController();
  final _doencasCronicasController = TextEditingController();
  final _hereditariedadeController = TextEditingController();
  final _geneticaController = TextEditingController();
  final _acessoServicoSaudeController = TextEditingController();

  RiscoMortalidade _riscoMortalidade = RiscoMortalidade.baixo;
  ClassificacaoRisco _classificacaoRisco = ClassificacaoRisco.baixo;

  List<DiagnosisHistory> _history = [];
  bool _isLoading = false;
  bool _isLoadingHistory = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeForm();
    _loadHistory();
  }

  void _initializeForm() {
    if (widget.diagnosis != null) {
      final d = widget.diagnosis!;
      _doencasPreviasController.text = d.doencasPrevias.join(', ');
      _examesController.text = d.examesObjetivoDiagnostico.join(', ');
      _idadeController.text = d.idade.toString();
      _doencasCronicasController.text = d.doencasCronicas.join(', ');
      _hereditariedadeController.text = d.hereditariedade ?? '';
      _geneticaController.text = d.genetica ?? '';
      _acessoServicoSaudeController.text = d.acessoServicoSaude;
      _riscoMortalidade = d.riscoMortalidade;
      _classificacaoRisco = d.classificacaoFinal;
    } else {
      final age = DateTime.now().year - widget.patient.dataNascimento.year;
      _idadeController.text = age.toString();
    }
  }

  Future<void> _loadHistory() async {
    if (widget.diagnosis == null) return;

    setState(() => _isLoadingHistory = true);

    try {
      final history =
          await DataService.getDiagnosisHistory(widget.diagnosis!.id);
      setState(() {
        _history = history;
        _isLoadingHistory = false;
      });
    } catch (e) {
      setState(() => _isLoadingHistory = false);
    }
  }

  Future<void> _saveDiagnosis() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final professional = AuthService.currentUser as ProfissionalSaude;

      final diagnosis = Diagnosis(
        id: widget.diagnosis?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        pacienteId: widget.patient.id,
        profissionalId: professional.id,
        dataAtualizacao: DateTime.now(),
        doencasPrevias: _doencasPreviasController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        riscoMortalidade: _riscoMortalidade,
        examesObjetivoDiagnostico: _examesController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        idade: int.parse(_idadeController.text),
        doencasCronicas: _doencasCronicasController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        hereditariedade: _hereditariedadeController.text.isNotEmpty
            ? _hereditariedadeController.text
            : null,
        genetica: _geneticaController.text.isNotEmpty
            ? _geneticaController.text
            : null,
        acessoServicoSaude: _acessoServicoSaudeController.text,
        classificacaoFinal: _classificacaoRisco,
      );

      await DataService.updateDiagnosis(diagnosis);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.diagnosis == null
                ? 'Diagnóstico criado com sucesso!'
                : 'Diagnóstico atualizado com sucesso!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.diagnosis == null
            ? 'Criar Diagnóstico'
            : 'Gerenciar Diagnóstico'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Dados Clínicos'),
            Tab(text: 'Histórico'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDiagnosisForm(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildDiagnosisForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informações do Paciente
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Paciente: ${widget.patient.nomeCompleto}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'CPF: ${widget.patient.cpf}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.7),
                          ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Formulário
            TextFormField(
              controller: _doencasPreviasController,
              decoration: InputDecoration(
                labelText: 'Doenças Prévias',
                hintText: 'Hipertensão, Diabetes, etc. (separadas por vírgula)',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              maxLines: 2,
            ),

            const SizedBox(height: 16),

            Text(
              "Gravidade do quadro atual",
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: RiscoMortalidade.values.map((risk) {
                return FilterChip(
                  selected: _riscoMortalidade == risk,
                  label: Text(_getRiscoMortalidadeText(risk)),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _riscoMortalidade = risk);
                    }
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _examesController,
              decoration: InputDecoration(
                hintText: 'Hemograma, ECG, etc. (separados por vírgula)',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              maxLines: 2,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _idadeController,
              decoration: InputDecoration(
                labelText: 'Idade',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Campo obrigatório';
                }
                if (int.tryParse(value) == null) {
                  return 'Digite um número válido';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _doencasCronicasController,
              decoration: InputDecoration(
                labelText: 'Doenças Crônicas',
                hintText: 'Hipertensão Arterial, etc. (separadas por vírgula)',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              maxLines: 2,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _hereditariedadeController,
              decoration: InputDecoration(
                labelText: 'Hereditariedade (opcional)',
                hintText: 'Histórico familiar relevante',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              maxLines: 2,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _geneticaController,
              decoration: InputDecoration(
                labelText: 'Genética (opcional)',
                hintText: 'Alterações genéticas conhecidas',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              maxLines: 2,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _acessoServicoSaudeController,
              decoration: InputDecoration(
                labelText: 'Acesso ao Serviço de Saúde',
                hintText: 'Distância da UPA/UBS, meios de transporte, etc.',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Campo obrigatório';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            Text(
              'Classificação Final de Risco',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ClassificacaoRisco.values.map((risk) {
                return FilterChip(
                  selected: _classificacaoRisco == risk,
                  label: Text(_getClassificacaoRiscoText(risk)),
                  selectedColor: _getRiskColor(risk).withValues(alpha: 0.3),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _classificacaoRisco = risk);
                    }
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveDiagnosis,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(
                        widget.diagnosis == null
                            ? 'Criar Diagnóstico'
                            : 'Atualizar Diagnóstico',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (widget.diagnosis == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Crie o diagnóstico primeiro para ver o histórico.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_isLoadingHistory) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_history.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Nenhum histórico de alterações encontrado.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final historyEntry = _history[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.history,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            title: Text(historyEntry.nomeProfissional),
            subtitle: Text(
              '${historyEntry.alteracoes}\n${historyEntry.dataAlteracao.day.toString().padLeft(2, '0')}/${historyEntry.dataAlteracao.month.toString().padLeft(2, '0')}/${historyEntry.dataAlteracao.year} às ${historyEntry.dataAlteracao.hour.toString().padLeft(2, '0')}:${historyEntry.dataAlteracao.minute.toString().padLeft(2, '0')}',
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  String _getRiscoMortalidadeText(RiscoMortalidade risco) {
    switch (risco) {
      case RiscoMortalidade.baixo:
        return 'Baixo';
      case RiscoMortalidade.moderado:
        return 'Moderado';
      case RiscoMortalidade.alto:
        return 'Alto';
      case RiscoMortalidade.muitoAlto:
        return 'Muito Alto';
    }
  }

  String _getClassificacaoRiscoText(ClassificacaoRisco risco) {
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
  void dispose() {
    _tabController.dispose();
    _doencasPreviasController.dispose();
    _examesController.dispose();
    _idadeController.dispose();
    _doencasCronicasController.dispose();
    _hereditariedadeController.dispose();
    _geneticaController.dispose();
    _acessoServicoSaudeController.dispose();
    super.dispose();
  }
}
