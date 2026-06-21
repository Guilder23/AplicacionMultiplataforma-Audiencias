import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../models/audiencia.dart';
import '../providers/audiencia_provider.dart';
import '../widgets/ui_components.dart';
import 'audiencia_form_screen.dart';

class AudienciaDetailScreen extends StatelessWidget {
  const AudienciaDetailScreen({super.key, required this.audienciaId});

  final int audienciaId;

  static const List<String> _statuses = [
    'Programada',
    'En curso',
    'Concluida',
    'Suspendida',
    'Reprogramada',
  ];

  static const List<String> _motivos = [
    'Incomparecencia',
    'Falta de notificacion',
    'Problemas tecnicos',
    'Solicitud de las partes',
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AudienciaProvider>(
      builder: (context, provider, _) {
        Audiencia? audiencia;
        for (final item in provider.audiencias) {
          if (item.id == audienciaId) {
            audiencia = item;
            break;
          }
        }

        if (audiencia == null) {
          return const Scaffold(
            body: Center(
              child: Text('La audiencia no se encuentra disponible'),
            ),
          );
        }

        final currentAudiencia = audiencia;
        final statusColor = _statusColor(currentAudiencia.estado);
        final dateFormat = DateFormat('dd MMMM, yyyy', 'es');
        final timeFormat = DateFormat('HH:mm');

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
                        const Expanded(
                          child: Text(
                            'Detalle de Audiencia',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        PopupMenuButton<String>(
                          color: Colors.white,
                          icon: const Icon(
                            Icons.more_vert_rounded,
                            color: Colors.white,
                          ),
                          onSelected: (value) async {
                            if (value == 'editar') {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (_) => AudienciaFormScreen(
                                        audiencia: currentAudiencia,
                                      ),
                                ),
                              );
                            } else if (value == 'estado') {
                              await _showStatusDialog(
                                context,
                                currentAudiencia,
                              );
                            } else if (value == 'eliminar') {
                              await _confirmDelete(context, currentAudiencia);
                            }
                          },
                          itemBuilder:
                              (_) => const [
                                PopupMenuItem(
                                  value: 'editar',
                                  child: Text('Editar'),
                                ),
                                PopupMenuItem(
                                  value: 'estado',
                                  child: Text('Cambiar estado'),
                                ),
                                PopupMenuItem(
                                  value: 'eliminar',
                                  child: Text('Eliminar'),
                                ),
                              ],
                        ),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(18),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            currentAudiencia.tipoProceso,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'NUREJ: ${currentAudiencia.nurej}',
                                            style: const TextStyle(
                                              color: AppColors.mutedText,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    currentAudiencia.estado,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(18),
                                child: Column(
                                  children: [
                                    _DetailRow(
                                      icon: Icons.calendar_today_outlined,
                                      label: 'Fecha',
                                      value: dateFormat.format(
                                        currentAudiencia.fechaHora,
                                      ),
                                    ),
                                    _DetailRow(
                                      icon: Icons.access_time_rounded,
                                      label: 'Hora',
                                      value: timeFormat.format(
                                        currentAudiencia.fechaHora,
                                      ),
                                    ),
                                    _DetailRow(
                                      icon: Icons.meeting_room_outlined,
                                      label: 'Sala',
                                      value: currentAudiencia.sala,
                                    ),
                                    _DetailRow(
                                      icon: Icons.person_outline_rounded,
                                      label: 'Juez',
                                      value: currentAudiencia.juez,
                                    ),
                                    _DetailRow(
                                      icon: Icons.groups_outlined,
                                      label: 'Demandante',
                                      value: currentAudiencia.demandante,
                                    ),
                                    _DetailRow(
                                      icon: Icons.group_outlined,
                                      label: 'Demandado',
                                      value: currentAudiencia.demandado,
                                    ),
                                    _DetailRow(
                                      icon: Icons.gavel_rounded,
                                      label: 'Tipo de audiencia',
                                      value: currentAudiencia.tipoAudiencia,
                                    ),
                                    _DetailRow(
                                      icon: Icons.note_alt_outlined,
                                      label: 'Observaciones',
                                      value:
                                          currentAudiencia.observaciones.isEmpty
                                              ? 'Sin observaciones'
                                              : currentAudiencia.observaciones,
                                      isLast:
                                          currentAudiencia.motivoSuspension ==
                                          null,
                                    ),
                                    if (currentAudiencia.motivoSuspension !=
                                        null)
                                      _DetailRow(
                                        icon: Icons.warning_amber_rounded,
                                        label: 'Motivo suspension',
                                        value:
                                            currentAudiencia.motivoSuspension!,
                                        isLast: true,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            const Text(
                              'Historial de cambios',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(18),
                                child: Column(
                                  children: [
                                    for (final item
                                        in currentAudiencia.historial.reversed)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 9,
                                              height: 9,
                                              margin: const EdgeInsets.only(
                                                top: 6,
                                              ),
                                              decoration: const BoxDecoration(
                                                color: AppColors.primary,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(child: Text(item)),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomButton(
                                    label: 'Editar',
                                    onPressed: () async {
                                      await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder:
                                              (_) => AudienciaFormScreen(
                                                audiencia: currentAudiencia,
                                              ),
                                        ),
                                      );
                                    },
                                    isSecondary: true,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: CustomButton(
                                    label: 'Cancelar Audiencia',
                                    onPressed:
                                        () => _confirmDelete(
                                          context,
                                          currentAudiencia,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            CustomButton(
                              label: 'Cambiar Estado',
                              onPressed:
                                  () => _showStatusDialog(
                                    context,
                                    currentAudiencia,
                                  ),
                              icon: Icons.swap_horiz_rounded,
                              expanded: true,
                              isSecondary: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, Audiencia audiencia) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Eliminar audiencia'),
            content: const Text(
              'Esta accion eliminara la audiencia seleccionada. Desea continuar?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final success = await context.read<AudienciaProvider>().deleteAudiencia(
      audiencia.id!,
    );

    if (!context.mounted) {
      return;
    }

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo eliminar la audiencia'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Audiencia eliminada correctamente')),
    );
    Navigator.of(context).pop();
  }

  Future<void> _showStatusDialog(
    BuildContext context,
    Audiencia audiencia,
  ) async {
    String selectedStatus = audiencia.estado;
    String selectedMotivo = audiencia.motivoSuspension ?? _motivos.first;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder:
              (context, setState) => AlertDialog(
                title: const Text('Cambiar estado'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      items:
                          _statuses
                              .map(
                                (status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(status),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedStatus = value);
                        }
                      },
                    ),
                    if (selectedStatus == 'Suspendida') ...[
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedMotivo,
                        items:
                            _motivos
                                .map(
                                  (item) => DropdownMenuItem(
                                    value: item,
                                    child: Text(item),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => selectedMotivo = value);
                          }
                        },
                      ),
                    ],
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancelar'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Guardar'),
                  ),
                ],
              ),
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final success = await context.read<AudienciaProvider>().changeStatus(
      audiencia,
      selectedStatus,
      motivoSuspension: selectedStatus == 'Suspendida' ? selectedMotivo : null,
    );

    if (!context.mounted) {
      return;
    }

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo actualizar el estado'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Estado actualizado correctamente')),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Concluida':
        return AppColors.success;
      case 'Suspendida':
        return AppColors.warning;
      case 'Reprogramada':
        return AppColors.info;
      case 'En curso':
        return AppColors.primary;
      default:
        return AppColors.danger;
    }
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border:
            isLast
                ? null
                : const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.mutedText, size: 20),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.mutedText),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
