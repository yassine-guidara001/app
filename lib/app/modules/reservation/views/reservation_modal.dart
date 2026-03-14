import 'package:flutter/material.dart';
import 'package:flutter_getx_app/app/modules/reservation/controllers/reservation_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ReservationModal extends StatefulWidget {
  const ReservationModal({
    super.key,
    required this.spaceSlug,
    required this.spaceDisplayName,
  });

  final String spaceSlug;
  final String spaceDisplayName;

  @override
  State<ReservationModal> createState() => _ReservationModalState();
}

class _ReservationModalState extends State<ReservationModal> {
  static const Color _cardBg = Color(0xFFF3F4F6);
  static const Color _line = Color(0xFFE5E7EB);
  static const Color _text = Color(0xFF111827);
  static const Color _subtle = Color(0xFF6B7280);
  static const Color _primary = Color(0xFF10B981);

  late final ReservationController _controller;
  late final TextEditingController _participantsController;
  bool _fullDay = false;

  final List<TimeOfDay> _slots = List.generate(
    20,
    (i) => TimeOfDay(hour: 8 + (i ~/ 2), minute: i.isEven ? 0 : 30),
  );

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<ReservationController>()
        ? Get.find<ReservationController>()
        : Get.put(ReservationController());

    _controller.resetForm();
    _controller.updateStartTime(const TimeOfDay(hour: 9, minute: 0));
    _controller.updateEndTime(const TimeOfDay(hour: 18, minute: 0));
    _controller.updateParticipants(1);

    _participantsController = TextEditingController(text: '1');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Lance les 2 requetes API via le controller:
      // 1) getSpaceBySlug
      // 2) getEquipmentsBySpaceSlug
      _controller.loadSpaceBySlug(widget.spaceSlug);
    });
  }

  @override
  void dispose() {
    _participantsController.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _onFullDayChanged(bool value) {
    setState(() {
      _fullDay = value;
    });
    if (value) {
      _controller.updateStartTime(const TimeOfDay(hour: 9, minute: 0));
      _controller.updateEndTime(const TimeOfDay(hour: 18, minute: 0));
    }
  }

  bool _isTimeAfter(TimeOfDay a, TimeOfDay b) {
    return (a.hour * 60 + a.minute) > (b.hour * 60 + b.minute);
  }

  bool _isFormValid(int capacity) {
    final start = _controller.startTime.value;
    final end = _controller.endTime.value;
    final participants = _controller.participants.value;
    final timeOk = _isTimeAfter(end, start);
    final participantsOk = participants >= 1 && participants <= capacity;
    return timeOk && participantsOk;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1180, maxHeight: 760),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x26000000),
              blurRadius: 26,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Obx(() {
          if (_controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final space = _controller.selectedSpace.value;
          if (space == null) {
            return _buildErrorState();
          }

          final int capacity = space.capacity > 0 ? space.capacity : 1;
          final bool canSubmit = _isFormValid(capacity);

          return Column(
            children: [
              _buildHeader(space),
              const Divider(height: 1, color: _line),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionCard(
                              title: 'Description',
                              child: Text(
                                (space.description.trim().isEmpty)
                                    ? 'Aucune description disponible.'
                                    : space.description,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: _subtle,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            _sectionCard(
                              title: 'Equipements disponibles',
                              child: _buildEquipmentChips(),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'Nombre de participants *',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: _text,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 44,
                              child: TextField(
                                controller: _participantsController,
                                keyboardType: TextInputType.number,
                                onChanged: (v) {
                                  final parsed = int.tryParse(v);
                                  if (parsed != null) {
                                    final safe = parsed.clamp(1, capacity);
                                    _controller.updateParticipants(safe);
                                    if (safe.toString() != v) {
                                      _participantsController.text =
                                          safe.toString();
                                      _participantsController.selection =
                                          TextSelection.collapsed(
                                        offset:
                                            _participantsController.text.length,
                                      );
                                    }
                                  }
                                },
                                decoration: InputDecoration(
                                  hintText: '1',
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFCBD5E1)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: _primary, width: 1.4),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Capacite maximale: $capacity personne${capacity > 1 ? 's' : ''}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: _subtle,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.calendar_month_outlined,
                                    size: 18, color: _text),
                                SizedBox(width: 6),
                                Text(
                                  'Selectionner une date',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: _text,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: _line),
                              ),
                              child: CalendarDatePicker(
                                initialDate: _controller.selectedDate.value,
                                firstDate: DateTime.now()
                                    .subtract(const Duration(days: 1)),
                                lastDate: DateTime.now()
                                    .add(const Duration(days: 365)),
                                onDateChanged: _controller.updateSelectedDate,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                DateFormat('EEEE d MMMM yyyy', 'fr_FR')
                                    .format(_controller.selectedDate.value),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1D4ED8),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Row(
                              children: [
                                Icon(Icons.watch_later_outlined,
                                    size: 18, color: _text),
                                SizedBox(width: 6),
                                Text(
                                  'Selectionner l\'horaire',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: _text,
                                  ),
                                ),
                              ],
                            ),
                            CheckboxListTile(
                              value: _fullDay,
                              onChanged: (v) => _onFullDayChanged(v ?? false),
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              title: const Text(
                                'Reserver toute la journee (09:00 - 18:00)',
                                style: TextStyle(fontSize: 13, color: _subtle),
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                              activeColor: _primary,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: _timeDropdown(
                                    title: 'Heure de debut',
                                    value: _controller.startTime.value,
                                    enabled: !_fullDay,
                                    onChanged: (v) {
                                      if (v != null)
                                        _controller.updateStartTime(v);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _timeDropdown(
                                    title: 'Heure de fin',
                                    value: _controller.endTime.value,
                                    enabled: !_fullDay,
                                    onChanged: (v) {
                                      if (v != null)
                                        _controller.updateEndTime(v);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Emploi du temps d\'Aujourd\'hui',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: _text,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 12),
                              decoration: BoxDecoration(
                                color: _cardBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Aucune reservation pour cette date',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 13, color: _subtle),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, color: _line),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: (!_controller.isLoading.value && canSubmit)
                            ? () async {
                                final success =
                                    await _controller.submitReservation();
                                if (!mounted) return;
                                if (success) {
                                  Navigator.of(context).pop();
                                  Get.snackbar(
                                    'Succes',
                                    'Votre reservation a ete creee avec succes',
                                    backgroundColor: const Color(0xFF10B981),
                                    colorText: Colors.white,
                                    snackPosition: SnackPosition.TOP,
                                  );
                                }
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canSubmit
                              ? const Color(0xFF9CA3AF)
                              : const Color(0xFFD1D5DB),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: _controller.isLoading.value
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text(
                                'Reserver l\'Espace',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '* Tous les champs sont obligatoires',
                      style: TextStyle(fontSize: 11, color: _subtle),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildHeader(space) {
    final String location =
        (space.location == null || space.location!.trim().isEmpty)
            ? 'xxx'
            : space.location!.trim();

    String rates = '--';
    if (space.hourlyRate > 0 || space.dailyRate > 0) {
      rates =
          '${space.hourlyRate.toStringAsFixed(0)}TND/h - ${space.dailyRate.toStringAsFixed(0)}TND/jour';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.spaceDisplayName.isNotEmpty
                      ? widget.spaceDisplayName
                      : space.name,
                  style: const TextStyle(
                    fontSize: 31,
                    fontWeight: FontWeight.w800,
                    color: _text,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    _metaItem(Icons.people_outline,
                        'Max ${space.capacity} personnes'),
                    _metaItem(Icons.location_on_outlined, location),
                    _metaItem(Icons.euro_outlined, rates),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: _subtle),
          ),
        ],
      ),
    );
  }

  Widget _metaItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: _subtle),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
              fontSize: 12, color: _subtle, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _text,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildEquipmentChips() {
    return Obx(() {
      if (_controller.equipments.isEmpty) {
        return const Text(
          'Aucun equipement associe.',
          style: TextStyle(fontSize: 13, color: _subtle),
        );
      }

      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _controller.equipments.map((e) {
          final String price = e.pricePerDay > 0
              ? ' (${e.pricePerDay.toStringAsFixed(0)}TND/j)'
              : '';
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFD1FAE5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFA7F3D0)),
            ),
            child: Text(
              '${e.name}$price',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF065F46),
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _timeDropdown({
    required String title,
    required TimeOfDay value,
    required bool enabled,
    required ValueChanged<TimeOfDay?> onChanged,
  }) {
    final TimeOfDay safe = _slots.contains(value) ? value : _slots.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _text,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<TimeOfDay>(
          value: safe,
          items: _slots
              .map(
                (t) => DropdownMenuItem<TimeOfDay>(
                  value: t,
                  child: Text(_formatTime(t)),
                ),
              )
              .toList(),
          onChanged: enabled ? onChanged : null,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            filled: true,
            fillColor: enabled ? Colors.white : const Color(0xFFF3F4F6),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Color(0xFFDC2626)),
            const SizedBox(height: 12),
            Text(
              _controller.errorMessage.value.isEmpty
                  ? 'Espace non trouve'
                  : _controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: _subtle),
            ),
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fermer'),
            ),
          ],
        ),
      ),
    );
  }
}
