import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../models/audiencia.dart';
import '../providers/audiencia_provider.dart';
import '../widgets/ui_components.dart';

class AudienciaFormScreen extends StatefulWidget {
  const AudienciaFormScreen({super.key, this.audiencia});

  final Audiencia? audiencia;

  @override
  State<AudienciaFormScreen> createState() => _AudienciaFormScreenState();
}

class _AudienciaFormScreenState extends State<AudienciaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nurejController = TextEditingController();
  final _demandanteController = TextEditingController();
  final _demandadoController = TextEditingController();
  final _observacionesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _tipoProceso = _tiposProceso.first;
  String _tipoAudiencia = _tiposAudiencia.first;
  String _sala = _salas.first;
  String _juez = _jueces.first;
  String _estado = 'Programada';
  String? _motivoSuspension;
  bool _saving = false;

  static const List<String> _tiposProceso = [
    'Divorcio',
    'Asistencia Familiar',
    'Guarda',
    'Regimen de Visitas',
    'Filiacion',
  ];

  static const List<String> _tiposAudiencia = [
    'Conciliacion',
    'Ratificacion',
    'Seguimiento',
    'Evaluacion',
    'Preliminar',
  ];

  static const List<String> _salas = [
    'Sala 1',
    'Sala 2',
    'Sala 3',
    'Sala Virtual',
  ];

  static const List<String> _jueces = [
    'Dra. Jimenez',
    'Dr. Perez',
    'Dra. Salazar',
    'Dr. Quiroga',
  ];

  static const List<String> _estados = [
    'Programada',
    'En curso',
    'Concluida',
    'Suspendida',
    'Reprogramada',
  ];

  static const List<String> _motivosSuspension = [
    'Incomparecencia',
    'Falta de notificacion',
    'Problemas tecnicos',
    'Solicitud de las partes',
  ];

  @override
  void initState() {
    super.initState();
    final audiencia = widget.audiencia;
    if (audiencia != null) {
      _nurejController.text = audiencia.nurej;
      _demandanteController.text = audiencia.demandante;
      _demandadoController.text = audiencia.demandado;
      _observacionesController.text = audiencia.observaciones;
      _selectedDate = audiencia.fechaHora;
      _selectedTime = TimeOfDay.fromDateTime(audiencia.fechaHora);
      _tipoProceso = audiencia.tipoProceso;
      _tipoAudiencia = audiencia.tipoAudiencia;
      _sala = audiencia.sala;
      _juez = audiencia.juez;
      _estado = audiencia.estado;
      _motivoSuspension = audiencia.motivoSuspension;
    }
  }

  @override
  void dispose() {
    _nurejController.dispose();
    _demandanteController.dispose();
    _demandadoController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.audiencia != null;

    return Scaffold(
      body: Container(
        decoration: AppTheme.headerGradient,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        isEditing ? 'Editar Audiencia' : 'Nueva Audiencia',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 16),
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('NUREJ'),
                          _buildTextField(
                            controller: _nurejController,
                            hint: 'Ingrese NUREJ',
                          ),
                          const SizedBox(height: 16),
                          _buildLabel('Tipo de Proceso'),
                          _buildDropdown(
                            value: _tipoProceso,
                            items: _tiposProceso,
                            onChanged:
                                (value) =>
                                    setState(() => _tipoProceso = value!),
                          ),
                          const SizedBox(height: 16),
                          _buildLabel('Tipo de Audiencia'),
                          _buildDropdown(
                            value: _tipoAudiencia,
                            items: _tiposAudiencia,
                            onChanged:
                                (value) =>
                                    setState(() => _tipoAudiencia = value!),
                          ),
                          const SizedBox(height: 16),
                          _buildLabel('Demandante'),
                          _buildTextField(
                            controller: _demandanteController,
                            hint: 'Ingrese demandante',
                          ),
                          const SizedBox(height: 16),
                          _buildLabel('Demandado'),
                          _buildTextField(
                            controller: _demandadoController,
                            hint: 'Ingrese demandado',
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('Fecha'),
                                    _DateSelectorField(
                                      value: DateFormat(
                                        'dd/MM/yyyy',
                                      ).format(_selectedDate),
                                      icon: Icons.calendar_today_outlined,
                                      onTap: _pickDate,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('Hora'),
                                    _DateSelectorField(
                                      value: _selectedTime.format(context),
                                      icon: Icons.access_time_rounded,
                                      onTap: _pickTime,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildLabel('Sala'),
                          _buildDropdown(
                            value: _sala,
                            items: _salas,
                            onChanged:
                                (value) => setState(() => _sala = value!),
                          ),
                          const SizedBox(height: 16),
                          _buildLabel('Juez'),
                          _buildDropdown(
                            value: _juez,
                            items: _jueces,
                            onChanged:
                                (value) => setState(() => _juez = value!),
                          ),
                          const SizedBox(height: 16),
                          _buildLabel('Estado'),
                          _buildDropdown(
                            value: _estado,
                            items: _estados,
                            onChanged:
                                (value) => setState(() => _estado = value!),
                          ),
                          if (_estado == 'Suspendida') ...[
                            const SizedBox(height: 16),
                            _buildLabel('Motivo de Suspension'),
                            _buildDropdown(
                              value:
                                  _motivoSuspension ?? _motivosSuspension.first,
                              items: _motivosSuspension,
                              onChanged:
                                  (value) =>
                                      setState(() => _motivoSuspension = value),
                            ),
                          ],
                          const SizedBox(height: 16),
                          _buildLabel('Observaciones'),
                          TextFormField(
                            controller: _observacionesController,
                            minLines: 4,
                            maxLines: 6,
                            decoration: const InputDecoration(
                              hintText: 'Ingrese observaciones',
                            ),
                          ),
                          const SizedBox(height: 28),
                          CustomButton(
                            label:
                                _saving
                                    ? 'Guardando...'
                                    : isEditing
                                    ? 'Actualizar Audiencia'
                                    : 'Guardar Audiencia',
                            onPressed: _saving ? () {} : _saveAudiencia,
                            expanded: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextFormField(
      controller: controller,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Este campo es obligatorio';
        }
        return null;
      },
      decoration: InputDecoration(hintText: hint),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: items.contains(value) ? value : items.first,
      decoration: const InputDecoration(),
      items:
          items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _saveAudiencia() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_estado == 'Suspendida' &&
        (_motivoSuspension == null || _motivoSuspension!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione un motivo de suspension')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final fechaHora = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final model = Audiencia(
        id: widget.audiencia?.id,
        nurej: _nurejController.text.trim(),
        demandante: _demandanteController.text.trim(),
        demandado: _demandadoController.text.trim(),
        fechaHora: fechaHora,
        tipoProceso: _tipoProceso,
        tipoAudiencia: _tipoAudiencia,
        sala: _sala,
        juez: _juez,
        estado: _estado,
        observaciones: _observacionesController.text.trim(),
        motivoSuspension: _estado == 'Suspendida' ? _motivoSuspension : null,
        historial: widget.audiencia?.historial ?? const [],
      );

      final success = await context.read<AudienciaProvider>().saveAudiencia(
        model,
      );

      if (!mounted) {
        return;
      }

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'No se pudo guardar la audiencia. Verifique su sesion y la conexion con el servidor.',
            ),
            backgroundColor: Colors.red.shade700,
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.audiencia == null
                ? 'Audiencia registrada correctamente'
                : 'Audiencia actualizada correctamente',
          ),
        ),
      );
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo guardar la audiencia: $error'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}

class _DateSelectorField extends StatelessWidget {
  const _DateSelectorField({
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: InputDecoration(
          suffixIcon: Icon(icon, size: 20, color: AppColors.mutedText),
        ),
        child: Text(value),
      ),
    );
  }
}
