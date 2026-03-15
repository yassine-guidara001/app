import 'package:flutter/material.dart';
import 'package:flutter_getx_app/services/r%C3%A9servation_api_service.dart';
import 'package:intl/intl.dart';
import '../models/space_model.dart';

class ReservationModal extends StatefulWidget {
  final SpaceModel space;
  final ReservationApiService apiService;

  const ReservationModal({
    super.key,
    required this.space,
    required this.apiService,
  });

  static Future<bool?> show(
    BuildContext context, {
    required SpaceModel space,
    required ReservationApiService apiService,
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => ReservationModal(space: space, apiService: apiService),
    );
  }

  @override
  State<ReservationModal> createState() => _ReservationModalState();
}

class _ReservationModalState extends State<ReservationModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // Form state
  DateTime _selectedDate = DateTime.now();
  bool _fullDay = false;
  String? _startTime;
  String? _endTime;
  int _participants = 1;
  bool _isLoading = false;
  List<Map<String, dynamic>> _existingReservations = [];
  String? _errorMessage;

  final List<String> _timeSlots = [
    '09:00', '09:30', '10:00', '10:30', '11:00', '11:30',
    '12:00', '12:30', '13:00', '13:30', '14:00', '14:30',
    '15:00', '15:30', '16:00', '16:30', '17:00', '17:30',
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
    _loadReservations();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadReservations() async {
    try {
      final res = await widget.apiService.fetchReservationsForDate(
        spaceId: widget.space.id,
        date: _selectedDate,
      );
      setState(() => _existingReservations = res);
    } catch (_) {
      // silently fail – show empty
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      locale: const Locale('fr'),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF22C55E),
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _startTime = null;
        _endTime = null;
        _existingReservations = [];
      });
      _loadReservations();
    }
  }

  bool _isTimeSlotBooked(String time) {
    for (final res in _existingReservations) {
      final attrs = res['attributes'] ?? res;
      final start = attrs['startTime'] ?? '';
      final end = attrs['endTime'] ?? '';
      if (start.isNotEmpty && end.isNotEmpty) {
        if (time.compareTo(start) >= 0 && time.compareTo(end) < 0) return true;
      }
      if (attrs['fullDay'] == true) return true;
    }
    return false;
  }

  bool get _canSubmit {
    if (_participants < 1 || _participants > widget.space.maxPersons) return false;
    if (_fullDay) return true;
    if (_startTime == null || _endTime == null) return false;
    return _startTime!.compareTo(_endTime!) < 0;
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final reservation = ReservationModel(
        spaceId: widget.space.id,
        date: _selectedDate,
        startTime: _fullDay ? null : _startTime,
        endTime: _fullDay ? null : _endTime,
        fullDay: _fullDay,
        participants: _participants,
      );
      await widget.apiService.createReservation(reservation);
      if (mounted) {
        Navigator.of(context).pop(true);
        _showSuccessSnackbar();
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _showSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Réservation de "${widget.space.name}" effectuée avec succès !',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF22C55E),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820, maxHeight: 640),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 32,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: _buildBody(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 20, 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.space.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 12,
                  children: [
                    _InfoChip(
                      icon: Icons.group_outlined,
                      label: 'Max ${widget.space.maxPersons} personnes',
                    ),
                    _InfoChip(
                      icon: Icons.access_time_outlined,
                      label: '${widget.space.pricePerHour.toStringAsFixed(0)} TND/h',
                    ),
                    _InfoChip(
                      icon: Icons.calendar_today_outlined,
                      label: '${widget.space.pricePerDay.toStringAsFixed(0)} TND/jour',
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, size: 20),
            style: IconButton.styleFrom(
              foregroundColor: const Color(0xFF64748B),
              backgroundColor: const Color(0xFFF8FAFC),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Left column ──────────────────────────────────
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildSection('Description', _buildDescription()),
              if (widget.space.equipments.isNotEmpty) ...[
                const SizedBox(height: 20),
                _buildSection('Équipements disponibles', _buildEquipments()),
              ],
              const SizedBox(height: 20),
              _buildSection('Nombre de participants *', _buildParticipants()),
            ],
          ),
        ),
        const SizedBox(width: 28),
        // ── Right column ─────────────────────────────────
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildSection('Sélectionner une date', _buildCalendar()),
              const SizedBox(height: 20),
              _buildSection('Sélectionner l\'horaire', _buildTimeSelector()),
              const SizedBox(height: 16),
              _buildSection('Emploi du temps du Aujourd\'hui', _buildTimeline()),
              const SizedBox(height: 20),
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Color(0xFFDC2626), fontSize: 13),
                  ),
                ),
              _buildSubmitButton(),
              const SizedBox(height: 4),
              const Text(
                '* tous les champs sont obligatoires',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 14,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }

  Widget _buildDescription() {
    final desc = widget.space.description;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        desc.isEmpty ? 'Aucune description disponible.' : desc,
        style: TextStyle(
          fontSize: 13,
          color: desc.isEmpty ? const Color(0xFF94A3B8) : const Color(0xFF475569),
          fontStyle: desc.isEmpty ? FontStyle.italic : FontStyle.normal,
        ),
      ),
    );
  }

  Widget _buildEquipments() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.space.equipments.map((e) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFDCFCE7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF86EFAC)),
          ),
          child: Text(
            '${e.name} (${e.price.toStringAsFixed(0)} TND)',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF166534),
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildParticipants() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            initialValue: _participants.toString(),
            keyboardType: TextInputType.number,
            onChanged: (v) {
              final val = int.tryParse(v);
              if (val != null) setState(() => _participants = val.clamp(1, widget.space.maxPersons));
            },
            decoration: InputDecoration(
              hintText: 'Nombre de participants',
              hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFCBD5E1)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF22C55E), width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendar() {
    return _CompactCalendar(
      selectedDate: _selectedDate,
      onDateSelected: (d) {
        setState(() {
          _selectedDate = d;
          _startTime = null;
          _endTime = null;
        });
        _loadReservations();
      },
    );
  }

  Widget _buildTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Full day checkbox
        GestureDetector(
          onTap: () => setState(() => _fullDay = !_fullDay),
          child: Row(
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: Checkbox(
                  value: _fullDay,
                  onChanged: (v) => setState(() => _fullDay = v ?? false),
                  activeColor: const Color(0xFF22C55E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Réserver toute la journée (09:00 - 18:00)',
                style: TextStyle(fontSize: 12.5, color: Color(0xFF475569)),
              ),
            ],
          ),
        ),
        if (!_fullDay) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _TimeDropdown(
                  label: 'Heure de début',
                  value: _startTime,
                  slots: _timeSlots,
                  disabledSlots: _timeSlots.where(_isTimeSlotBooked).toSet(),
                  onChanged: (v) => setState(() => _startTime = v),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TimeDropdown(
                  label: 'Heure de fin',
                  value: _endTime,
                  slots: _timeSlots,
                  disabledSlots: _timeSlots.where(_isTimeSlotBooked).toSet(),
                  onChanged: (v) => setState(() => _endTime = v),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildTimeline() {
    if (_existingReservations.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Text(
          'Aucune réservation pour cette date',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12.5,
            color: Color(0xFF94A3B8),
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }
    return Column(
      children: _existingReservations.map((r) {
        final attrs = r['attributes'] ?? r;
        final start = attrs['startTime'] ?? '';
        final end = attrs['endTime'] ?? '';
        final isFullDay = attrs['fullDay'] == true;
        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFFED7AA)),
          ),
          child: Row(
            children: [
              const Icon(Icons.schedule, size: 14, color: Color(0xFFEA580C)),
              const SizedBox(width: 6),
              Text(
                isFullDay ? 'Toute la journée' : '$start → $end',
                style: const TextStyle(fontSize: 12.5, color: Color(0xFF9A3412)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: _canSubmit && !_isLoading ? _submit : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF22C55E),
          disabledBackgroundColor: const Color(0xFFE2E8F0),
          foregroundColor: Colors.white,
          disabledForegroundColor: const Color(0xFF94A3B8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : const Text(
                'Réserver l\'Espace',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
      ),
    );
  }
}

// ─── Supporting widgets ────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: const Color(0xFF64748B)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
      ],
    );
  }
}

class _CompactCalendar extends StatefulWidget {
  final DateTime selectedDate;
  final void Function(DateTime) onDateSelected;

  const _CompactCalendar({
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<_CompactCalendar> createState() => _CompactCalendarState();
}

class _CompactCalendarState extends State<_CompactCalendar> {
  late DateTime _viewMonth;

  static const _weekdays = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
  static const _months = [
    'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
    'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre',
  ];

  @override
  void initState() {
    super.initState();
    _viewMonth = DateTime(widget.selectedDate.year, widget.selectedDate.month);
  }

  List<DateTime?> get _calendarDays {
    final firstDay = DateTime(_viewMonth.year, _viewMonth.month, 1);
    // Monday-based week (1=Mon, 7=Sun)
    final startOffset = (firstDay.weekday - 1) % 7;
    final daysInMonth = DateTime(_viewMonth.year, _viewMonth.month + 1, 0).day;
    final cells = <DateTime?>[];
    for (int i = 0; i < startOffset; i++) cells.add(null);
    for (int d = 1; d <= daysInMonth; d++) {
      cells.add(DateTime(_viewMonth.year, _viewMonth.month, d));
    }
    while (cells.length % 7 != 0) cells.add(null);
    return cells;
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final days = _calendarDays;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          // Month navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavBtn(
                icon: Icons.chevron_left,
                onTap: () => setState(() => _viewMonth = DateTime(_viewMonth.year, _viewMonth.month - 1)),
              ),
              Text(
                '${_months[_viewMonth.month - 1]} ${_viewMonth.year}',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
              ),
              _NavBtn(
                icon: Icons.chevron_right,
                onTap: () => setState(() => _viewMonth = DateTime(_viewMonth.year, _viewMonth.month + 1)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Weekday headers
          Row(
            children: _weekdays.map((d) => Expanded(
              child: Center(
                child: Text(
                  d,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 4),
          // Day grid
          ...List.generate(days.length ~/ 7, (row) {
            return Row(
              children: List.generate(7, (col) {
                final d = days[row * 7 + col];
                if (d == null) return const Expanded(child: SizedBox(height: 32));
                final isSelected = d.year == widget.selectedDate.year &&
                    d.month == widget.selectedDate.month &&
                    d.day == widget.selectedDate.day;
                final isToday = d.year == today.year &&
                    d.month == today.month &&
                    d.day == today.day;
                final isPast = d.isBefore(DateTime(today.year, today.month, today.day));
                return Expanded(
                  child: GestureDetector(
                    onTap: isPast ? null : () => widget.onDateSelected(d),
                    child: Container(
                      height: 32,
                      margin: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF22C55E)
                            : isToday
                                ? const Color(0xFFDCFCE7)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${d.day}',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: isSelected || isToday ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected
                              ? Colors.white
                              : isPast
                                  ? const Color(0xFFCBD5E1)
                                  : isToday
                                      ? const Color(0xFF166534)
                                      : const Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            );
          }),
          // Selected date label
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              children: [
                Text(
                  DateFormat('EEEE d MMMM yyyy', 'fr').format(widget.selectedDate),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF166534),
                  ),
                ),
                const Text(
                  "Aujourd'hui",
                  style: TextStyle(fontSize: 10.5, color: Color(0xFF4ADE80)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: const Color(0xFF64748B)),
      ),
    );
  }
}

class _TimeDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> slots;
  final Set<String> disabledSlots;
  final void Function(String?) onChanged;

  const _TimeDropdown({
    required this.label,
    required this.value,
    required this.slots,
    required this.disabledSlots,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      hint: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFFCBD5E1))),
      isExpanded: true,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF22C55E), width: 1.5),
        ),
      ),
      style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
      items: slots.map((t) {
        final booked = disabledSlots.contains(t);
        return DropdownMenuItem(
          value: t,
          enabled: !booked,
          child: Row(
            children: [
              Text(
                t,
                style: TextStyle(
                  fontSize: 13,
                  color: booked ? const Color(0xFFCBD5E1) : const Color(0xFF1E293B),
                ),
              ),
              if (booked) ...[
                const SizedBox(width: 4),
                const Text('(réservé)', style: TextStyle(fontSize: 10, color: Color(0xFFCBD5E1))),
              ],
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}