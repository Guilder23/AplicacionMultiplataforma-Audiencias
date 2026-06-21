import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../core/theme/app_theme.dart';
import '../models/audiencia.dart';
import '../providers/audiencia_provider.dart';
import '../widgets/ui_components.dart';
import 'audiencia_detail_screen.dart';
import 'audiencia_form_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardScreen(
        onCreate: _openCreate,
        onNavigate: _changeIndex,
        onOpenAudiencia: _openDetail,
      ),
      AudienciasScreen(onCreate: _openCreate, onOpenAudiencia: _openDetail),
      CalendarioScreen(onOpenAudiencia: _openDetail),
      const EstadisticasScreen(),
      MoreScreen(onCreate: _openCreate),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.gavel_rounded),
            label: 'Audiencias',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_rounded),
            label: 'Calendario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Reportes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz_rounded),
            label: 'Mas',
          ),
        ],
      ),
    );
  }

  void _changeIndex(int index) {
    setState(() => _currentIndex = index);
  }

  Future<void> _openCreate() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AudienciaFormScreen()));
  }

  Future<void> _openDetail(Audiencia audiencia) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AudienciaDetailScreen(audienciaId: audiencia.id!),
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.onCreate,
    required this.onNavigate,
    required this.onOpenAudiencia,
  });

  final VoidCallback onCreate;
  final ValueChanged<int> onNavigate;
  final ValueChanged<Audiencia> onOpenAudiencia;

  @override
  Widget build(BuildContext context) {
    return Consumer<AudienciaProvider>(
      builder: (context, provider, _) {
        final summary = provider.statusSummary;
        final upcoming = provider.upcomingAudiencias.take(3).toList();

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                decoration: AppTheme.headerGradient,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(
                                Icons.balance_rounded,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sistema de Audiencias',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Materia de Familia',
                                    style: TextStyle(
                                      color: Color(0xFFF6D8DD),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                const Icon(
                                  Icons.notifications_none_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                Positioned(
                                  right: -2,
                                  top: -2,
                                  child: Container(
                                    width: 16,
                                    height: 16,
                                    alignment: Alignment.center,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Text(
                                      '2',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        AppSearchBar(
                          hintText: 'Buscar audiencias...',
                          onChanged: provider.updateSearchQuery,
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          label: 'Nueva Audiencia',
                          onPressed: onCreate,
                          icon: Icons.add_rounded,
                          expanded: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  SizedBox(
                    height: 132,
                    child: Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            title: 'Total',
                            value: '${summary['Total'] ?? 0}',
                            icon: Icons.insert_chart_outlined_rounded,
                            highlight: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            title: 'Programadas',
                            value: '${summary['Programada'] ?? 0}',
                            icon: Icons.event_available_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            title: 'Concluidas',
                            value: '${summary['Concluida'] ?? 0}',
                            icon: Icons.task_alt_rounded,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _SectionHeader(
                    title: 'Proximas Audiencias',
                    actionLabel: 'Ver todas',
                    onTap: () => onNavigate(1),
                  ),
                  const SizedBox(height: 12),
                  if (upcoming.isEmpty)
                    const _EmptyState(
                      title: 'No hay audiencias proximas',
                      subtitle: 'Registra una audiencia para verla aqui.',
                    )
                  else
                    ...upcoming.map(
                      (audiencia) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AudienciaCard(
                          audiencia: audiencia,
                          onTap: () => onOpenAudiencia(audiencia),
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  const Text(
                    'Acciones Rapidas',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.calendar_month_rounded,
                          title: 'Calendario',
                          onTap: () => onNavigate(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.bar_chart_rounded,
                          title: 'Reportes',
                          onTap: () => onNavigate(3),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.analytics_outlined,
                          title: 'Estadisticas',
                          onTap: () => onNavigate(3),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.filter_alt_outlined,
                          title: 'Filtros',
                          onTap: () => onNavigate(1),
                        ),
                      ),
                    ],
                  ),
                ]),
              ),
            ),
          ],
        );
      },
    );
  }
}

class AudienciasScreen extends StatefulWidget {
  const AudienciasScreen({
    super.key,
    required this.onCreate,
    required this.onOpenAudiencia,
  });

  final VoidCallback onCreate;
  final ValueChanged<Audiencia> onOpenAudiencia;

  @override
  State<AudienciasScreen> createState() => _AudienciasScreenState();
}

class _AudienciasScreenState extends State<AudienciasScreen> {
  String? _selectedStatus;

  final List<String?> _tabs = const [
    null,
    'Programada',
    'Concluida',
    'Suspendida',
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AudienciaProvider>(
      builder: (context, provider, _) {
        final items = provider.filteredByStatus(_selectedStatus);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Audiencias',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: AppSearchBar(
                        hintText: 'Buscar por NUREJ, partes o fecha',
                        onChanged: provider.updateSearchQuery,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: IconButton(
                        onPressed: widget.onCreate,
                        icon: const Icon(
                          Icons.add_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _tabs.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final tab = _tabs[index];
                      final selected = tab == _selectedStatus;
                      return ChoiceChip(
                        label: Text(tab ?? 'Todas'),
                        selected: selected,
                        onSelected:
                            (_) => setState(() => _selectedStatus = tab),
                        selectedColor: AppColors.primary.withValues(
                          alpha: 0.14,
                        ),
                        labelStyle: TextStyle(
                          color:
                              selected
                                  ? AppColors.primary
                                  : AppColors.mutedText,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child:
                      items.isEmpty
                          ? const _EmptyState(
                            title: 'No se encontraron audiencias',
                            subtitle:
                                'Prueba con otro criterio de busqueda o registra una nueva.',
                          )
                          : ListView.builder(
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final audiencia = items[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: AudienciaCard(
                                  audiencia: audiencia,
                                  onTap:
                                      () => widget.onOpenAudiencia(audiencia),
                                ),
                              );
                            },
                          ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CalendarioScreen extends StatefulWidget {
  const CalendarioScreen({super.key, required this.onOpenAudiencia});

  final ValueChanged<Audiencia> onOpenAudiencia;

  @override
  State<CalendarioScreen> createState() => _CalendarioScreenState();
}

class _CalendarioScreenState extends State<CalendarioScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Consumer<AudienciaProvider>(
      builder: (context, provider, _) {
        final dayItems = provider.audienciasByDate(_selectedDay);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Calendario',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: TableCalendar<Audiencia>(
                      firstDay: DateTime.utc(2023),
                      lastDay: DateTime.utc(2035),
                      focusedDay: _focusedDay,
                      selectedDayPredicate:
                          (day) => isSameDay(_selectedDay, day),
                      calendarFormat: CalendarFormat.month,
                      locale: 'es_ES',
                      eventLoader: provider.audienciasByDate,
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                      ),
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.22),
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        markerDecoration: const BoxDecoration(
                          color: AppColors.danger,
                          shape: BoxShape.circle,
                        ),
                      ),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Audiencias del ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child:
                      dayItems.isEmpty
                          ? const _EmptyState(
                            title: 'No hay audiencias en esta fecha',
                            subtitle:
                                'Selecciona otro dia o registra una nueva audiencia.',
                          )
                          : ListView.builder(
                            itemCount: dayItems.length,
                            itemBuilder: (context, index) {
                              final audiencia = dayItems[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: AudienciaCard(
                                  audiencia: audiencia,
                                  onTap:
                                      () => widget.onOpenAudiencia(audiencia),
                                ),
                              );
                            },
                          ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class EstadisticasScreen extends StatelessWidget {
  const EstadisticasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudienciaProvider>(
      builder: (context, provider, _) {
        final statusSummary = provider.statusSummary;
        final processSummary = provider.processSummary;
        final entries = processSummary.entries.toList();
        final total = entries.fold<int>(0, (sum, item) => sum + item.value);
        final colors = [
          AppColors.primary,
          AppColors.info,
          AppColors.warning,
          AppColors.success,
          AppColors.danger,
        ];

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Estadisticas',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: 'Este mes',
                  items: const [
                    DropdownMenuItem(
                      value: 'Este mes',
                      child: Text('Este mes'),
                    ),
                    DropdownMenuItem(
                      value: 'Ultimos 30 dias',
                      child: Text('Ultimos 30 dias'),
                    ),
                  ],
                  onChanged: (_) {},
                  decoration: const InputDecoration(),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    StatCard(
                      title: 'Total audiencias',
                      value: '${statusSummary['Total'] ?? 0}',
                      icon: Icons.folder_copy_outlined,
                      highlight: true,
                    ),
                    StatCard(
                      title: 'Programadas',
                      value: '${statusSummary['Programada'] ?? 0}',
                      icon: Icons.event_note_rounded,
                    ),
                    StatCard(
                      title: 'Concluidas',
                      value: '${statusSummary['Concluida'] ?? 0}',
                      icon: Icons.verified_rounded,
                    ),
                    StatCard(
                      title: 'Suspendidas',
                      value: '${statusSummary['Suspendida'] ?? 0}',
                      icon: Icons.pause_circle_outline_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Por tipo de proceso',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 220,
                          child: Row(
                            children: [
                              Expanded(
                                child: PieChart(
                                  PieChartData(
                                    sectionsSpace: 2,
                                    centerSpaceRadius: 36,
                                    sections: [
                                      for (var i = 0; i < entries.length; i++)
                                        PieChartSectionData(
                                          color: colors[i % colors.length],
                                          value: entries[i].value.toDouble(),
                                          title:
                                              total == 0
                                                  ? '0%'
                                                  : '${((entries[i].value / total) * 100).round()}%',
                                          radius: 44,
                                          titleStyle: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    for (var i = 0; i < entries.length; i++)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 10,
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 12,
                                              height: 12,
                                              decoration: BoxDecoration(
                                                color:
                                                    colors[i % colors.length],
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                entries[i].key,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              '${entries[i].value}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Estados de audiencias',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          height: 220,
                          child: BarChart(
                            BarChartData(
                              gridData: const FlGridData(show: false),
                              borderData: FlBorderData(show: false),
                              titlesData: FlTitlesData(
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                leftTitles: const AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 28,
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      const labels = [
                                        'Prog.',
                                        'Curso',
                                        'Concl.',
                                        'Susp.',
                                        'Reprog.',
                                      ];
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          labels[value.toInt()],
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              barGroups: [
                                _barGroup(
                                  0,
                                  statusSummary['Programada'] ?? 0,
                                  AppColors.primary,
                                ),
                                _barGroup(
                                  1,
                                  statusSummary['En curso'] ?? 0,
                                  AppColors.info,
                                ),
                                _barGroup(
                                  2,
                                  statusSummary['Concluida'] ?? 0,
                                  AppColors.success,
                                ),
                                _barGroup(
                                  3,
                                  statusSummary['Suspendida'] ?? 0,
                                  AppColors.warning,
                                ),
                                _barGroup(
                                  4,
                                  statusSummary['Reprogramada'] ?? 0,
                                  AppColors.danger,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  BarChartGroupData _barGroup(int x, int value, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: value.toDouble(),
          color: color,
          width: 22,
          borderRadius: BorderRadius.circular(8),
        ),
      ],
    );
  }
}

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key, required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final items = const [
      ('Base local SQLite', Icons.sd_storage_rounded),
      ('Historial de cambios', Icons.history_rounded),
      ('Control de estados', Icons.rule_folder_rounded),
      ('Uso sin internet', Icons.phone_android_rounded),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Panel Administrativo',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              decoration: AppTheme.headerGradient.copyWith(
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.all(20),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sistema de Audiencias',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Aplicacion local para funcionarias judiciales de familia, con enfoque en agenda, control administrativo y estadisticas.',
                    style: TextStyle(color: Color(0xFFF7DEE2), height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(
                        alpha: 0.12,
                      ),
                      child: Icon(item.$2, color: AppColors.primary),
                    ),
                    title: Text(item.$1),
                    trailing: const Icon(Icons.chevron_right_rounded),
                  ),
                ),
              ),
            ),
            const Spacer(),
            CustomButton(
              label: 'Registrar Nueva Audiencia',
              onPressed: onCreate,
              icon: Icons.add_rounded,
              expanded: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onTap,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const Spacer(),
        TextButton(onPressed: onTap, child: Text(actionLabel)),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.inbox_outlined,
              size: 36,
              color: AppColors.mutedText,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.mutedText, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
