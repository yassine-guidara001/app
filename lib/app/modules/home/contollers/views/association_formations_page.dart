import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_getx_app/app/data/models/training_session_model.dart';
import 'package:flutter_getx_app/app/data/services/training_sessions_api.dart';

class AssociationFormationsPage extends StatefulWidget {
  const AssociationFormationsPage({super.key});

  @override
  State<AssociationFormationsPage> createState() =>
      _AssociationFormationsPageState();
}

class _AssociationFormationsPageState extends State<AssociationFormationsPage> {
  static const String _associationOriginTag = '[origin:association]';

  final TrainingSessionsApi _api = TrainingSessionsApi();
  final Map<String, String> _localRecurrenceByKey = <String, String>{};

  List<TrainingSession> _sessions = <TrainingSession>[];
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadSessionsOnMenuOpen();
  }

  Future<void> _loadSessionsOnMenuOpen() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final sessions = await _api.getCurrentInstructorSessions();
      if (!mounted) return;

      setState(() {
        _sessions = sessions;
        _localRecurrenceByKey.clear();
        for (final session in sessions) {
          final recurrence = _extractRecurrenceFromNotes(session.notes);
          if (recurrence != null) {
            _localRecurrenceByKey[_sessionKey(session)] = recurrence;
          }
        }
      });
    } catch (e) {
      if (!mounted) return;
      _showSnack('Erreur: ${_cleanError(e)}');
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 18),
          _buildSearchBar(),
          const SizedBox(height: 18),
          if (_isLoading)
            const SizedBox(
              height: 260,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_filteredSessions.isEmpty)
            _buildEmptyState(context)
          else
            _buildSessionsList(),
        ],
      ),
    );
  }

  List<TrainingSession> get _filteredSessions {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return _sessions;

    return _sessions.where((session) {
      final recurrence = _resolveRecurrence(session) ?? '';
      final content = <String>[
        session.title,
        session.type.label,
        session.status.label,
        session.notes ?? '',
        recurrence,
      ].join(' ').toLowerCase();
      return content.contains(q);
    }).toList();
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Organiser des Formations',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w800,
                fontSize: 40,
                height: 1,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Créez des parcours d\'apprentissage personnalisés pour les membres de votre association.',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 14,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 40,
          child: ElevatedButton.icon(
            onPressed: () => _showSessionDialog(context),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Nouveau Parcours'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0B6BFF),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: const InputDecoration(
          hintText: 'Rechercher une formation...',
          hintStyle: TextStyle(
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
          isDense: true,
          prefixIcon: Icon(Icons.search, size: 18, color: Color(0xFF94A3B8)),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return CustomPaint(
      painter: const _DashedRoundedRectPainter(
        color: Color(0xFFD6DEE8),
        radius: 12,
        dash: 5,
        gap: 4,
      ),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 330),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE2ECFA),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.menu_book_outlined,
                    size: 26,
                    color: Color(0xFF3B82F6),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Aucun parcours en cours',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.w800,
                    fontSize: 34,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Votre liste de formations est vide. Commencez par\nplanifier une nouvelle session pour vos membres.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: () => _showSessionDialog(context),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Planifier mon premier parcours'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B6BFF),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSessionsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _filteredSessions
          .map((session) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildSessionCard(session),
              ))
          .toList(),
    );
  }

  Widget _buildSessionCard(TrainingSession session) {
    final recurrence = _resolveRecurrence(session);

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 190,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFFBFD7FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.menu_book_outlined,
                        size: 22,
                        color: Color(0xFF0B6BFF),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 14, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    session.title.toUpperCase(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFF0F172A),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 22,
                                      height: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: [
                                      _chip(
                                        session.type.label.toUpperCase(),
                                        background: const Color(0xFFF3E8FF),
                                        textColor: const Color(0xFF7C3AED),
                                      ),
                                      if (recurrence != null)
                                        _chip(
                                          'RÉCURRENT',
                                          background: const Color(0xFFDCFCE7),
                                          textColor: const Color(0xFF16A34A),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              children: [
                                _chip(
                                  session.status.label.toUpperCase(),
                                  background: const Color(0xFFFFEDD5),
                                  textColor: const Color(0xFFEA580C),
                                ),
                                const SizedBox(height: 8),
                                IconButton(
                                  onPressed: () => _deleteSession(session),
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 16,
                                    color: Color(0xFF6B7280),
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 18,
                                    minHeight: 18,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                  splashRadius: 16,
                                  tooltip: 'Supprimer',
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 14,
                              color: Color(0xFF6B7280),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _formatDateTime(session.startDate),
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        if (recurrence != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Répétition ${recurrence.toLowerCase()}',
                            style: const TextStyle(
                              color: Color(0xFF16A34A),
                              fontSize: 11,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.people_outline,
                              size: 14,
                              color: Color(0xFF3B82F6),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '${session.participants.length} / ${session.maxParticipants} membres',
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12,
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.description_outlined,
                              size: 13,
                              color: Color(0xFF3B82F6),
                            ),
                            const SizedBox(width: 5),
                            const Text(
                              '1 session',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip(
    String text, {
    required Color background,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w700,
          fontSize: 9,
          height: 1,
        ),
      ),
    );
  }

  Future<void> _deleteSession(TrainingSession session) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Supprimer la session'),
              content: Text('Confirmer la suppression de "${session.title}" ?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Supprimer'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmed) return;

    try {
      await _api.deleteSession(
        id: session.id,
        documentId: session.documentId,
      );
      if (!mounted) return;
      setState(() {
        _sessions.removeWhere((item) =>
            item.id == session.id ||
            (session.documentId.trim().isNotEmpty &&
                item.documentId.trim() == session.documentId.trim()));
        _localRecurrenceByKey.remove(_sessionKey(session));
      });
      _showSnack('Session supprimée');
    } catch (e) {
      if (!mounted) return;
      _showSnack('Erreur: ${_cleanError(e)}');
    }
  }

  void _showSessionDialog(BuildContext context) {
    final sessionTitleController = TextEditingController();
    final maxParticipantsController = TextEditingController(text: '20');
    final meetingLinkController =
        TextEditingController(text: 'https://zoom.us/...');
    final notesController = TextEditingController();

    DateTime? startDate;
    DateTime? endDate;
    DateTime? recurrenceEndDate;
    String selectedType = 'En ligne';
    String selectedRecurrence = 'Aucune';
    bool isSaving = false;
    var isDialogOpen = true;

    Future<void> pickDateTime(ValueChanged<DateTime> onPicked) async {
      final now = DateTime.now();
      final date = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: DateTime(now.year - 1),
        lastDate: DateTime(now.year + 5),
      );
      if (date == null) return;

      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(now),
      );
      if (time == null) return;

      onPicked(DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      ));
    }

    Future<void> pickDate(ValueChanged<DateTime> onPicked) async {
      final now = DateTime.now();
      final date = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: DateTime(now.year - 1),
        lastDate: DateTime(now.year + 5),
      );
      if (date == null) return;
      onPicked(date);
    }

    showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: const Color(0x6B0F172A),
      builder: (dialogContext) {
        final maxDialogHeight = MediaQuery.of(dialogContext).size.height * 0.9;
        return Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          backgroundColor: const Color(0xFFF8FAFC),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: ConstrainedBox(
            constraints:
                BoxConstraints(maxWidth: 440, maxHeight: maxDialogHeight),
            child: StatefulBuilder(
              builder: (context, setDialogState) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Nouvelle Session / Parcours',
                              style: TextStyle(
                                color: Color(0xFF111827),
                                fontWeight: FontWeight.w800,
                                fontSize: 17,
                                height: 1,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(
                              Icons.close,
                              size: 16,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Planifiez une nouvelle session de formation pour vos membres.',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _associationLabel('Titre de la session'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: sessionTitleController,
                        decoration: _associationInputDecoration(
                            'Ex: Masterclass Q&A React'),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _associationLabel('Type'),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  value: selectedType,
                                  items: const [
                                    DropdownMenuItem(
                                        value: 'En ligne',
                                        child: Text('En ligne')),
                                    DropdownMenuItem(
                                        value: 'Présentiel',
                                        child: Text('Présentiel')),
                                    DropdownMenuItem(
                                        value: 'Hybride',
                                        child: Text('Hybride')),
                                  ],
                                  onChanged: (value) {
                                    if (value == null) return;
                                    setDialogState(() => selectedType = value);
                                  },
                                  decoration: _associationInputDecoration(null),
                                  style: const TextStyle(
                                    color: Color(0xFF334155),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _associationLabel('Max Participants'),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: maxParticipantsController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: _associationInputDecoration('20'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _associationLabel('Début'),
                                const SizedBox(height: 6),
                                InkWell(
                                  onTap: () async {
                                    await pickDateTime((picked) {
                                      setDialogState(() => startDate = picked);
                                    });
                                  },
                                  child: InputDecorator(
                                    decoration: _associationInputDecoration(
                                      'jj/mm/aaaa --:--',
                                      suffixIcon: const Icon(
                                        Icons.calendar_today_outlined,
                                        size: 14,
                                        color: Color(0xFF94A3B8),
                                      ),
                                    ),
                                    child: Text(
                                      startDate == null
                                          ? 'jj/mm/aaaa --:--'
                                          : _formatDateTime(startDate),
                                      style: TextStyle(
                                        color: startDate == null
                                            ? const Color(0xFF9CA3AF)
                                            : const Color(0xFF334155),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _associationLabel('Fin'),
                                const SizedBox(height: 6),
                                InkWell(
                                  onTap: () async {
                                    await pickDateTime((picked) {
                                      setDialogState(() => endDate = picked);
                                    });
                                  },
                                  child: InputDecorator(
                                    decoration: _associationInputDecoration(
                                      'jj/mm/aaaa --:--',
                                      suffixIcon: const Icon(
                                        Icons.calendar_today_outlined,
                                        size: 14,
                                        color: Color(0xFF94A3B8),
                                      ),
                                    ),
                                    child: Text(
                                      endDate == null
                                          ? 'jj/mm/aaaa --:--'
                                          : _formatDateTime(endDate),
                                      style: TextStyle(
                                        color: endDate == null
                                            ? const Color(0xFF9CA3AF)
                                            : const Color(0xFF334155),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Divider(height: 1, color: Color(0xFFE2E8F0)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _associationLabel('Récurrence'),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  value: selectedRecurrence,
                                  items: const [
                                    DropdownMenuItem(
                                        value: 'Aucune', child: Text('Aucune')),
                                    DropdownMenuItem(
                                        value: 'Hebdomadaire',
                                        child: Text('Hebdomadaire')),
                                    DropdownMenuItem(
                                        value: 'Mensuelle',
                                        child: Text('Mensuelle')),
                                  ],
                                  onChanged: (value) {
                                    if (value == null) return;
                                    setDialogState(
                                        () => selectedRecurrence = value);
                                  },
                                  decoration: _associationInputDecoration(null),
                                  style: const TextStyle(
                                    color: Color(0xFF334155),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _associationLabel('Fin de récurrence'),
                                const SizedBox(height: 6),
                                InkWell(
                                  onTap: () async {
                                    await pickDate((picked) {
                                      setDialogState(() {
                                        recurrenceEndDate = picked;
                                      });
                                    });
                                  },
                                  child: InputDecorator(
                                    decoration: _associationInputDecoration(
                                      'jj/mm/aaaa',
                                      suffixIcon: const Icon(
                                        Icons.calendar_today_outlined,
                                        size: 14,
                                        color: Color(0xFF94A3B8),
                                      ),
                                    ),
                                    child: Text(
                                      recurrenceEndDate == null
                                          ? 'jj/mm/aaaa'
                                          : _formatDateOnly(recurrenceEndDate),
                                      style: TextStyle(
                                        color: recurrenceEndDate == null
                                            ? const Color(0xFF9CA3AF)
                                            : const Color(0xFF334155),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _associationLabel('Lien de réunion (si en ligne)'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: meetingLinkController,
                        decoration: _associationInputDecoration(
                          'https://zoom.us/...',
                          prefixIcon: const Icon(
                            Icons.link,
                            size: 14,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _associationLabel('Notes & Objectifs'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: notesController,
                        minLines: 3,
                        maxLines: 3,
                        decoration: _associationInputDecoration(
                            'Notes pour les participants...'),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: isSaving
                                ? null
                                : () => Navigator.of(dialogContext).pop(),
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFFF1F5F9),
                              foregroundColor: const Color(0xFF475569),
                              minimumSize: const Size(0, 34),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Annuler',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: isSaving
                                ? null
                                : () async {
                                    final title =
                                        sessionTitleController.text.trim();
                                    if (title.isEmpty) {
                                      _showSnack('Le titre est obligatoire');
                                      return;
                                    }

                                    final maxParticipants = int.tryParse(
                                            maxParticipantsController.text) ??
                                        20;

                                    setDialogState(() {
                                      isSaving = true;
                                    });

                                    try {
                                      final recurrenceMeta = selectedRecurrence ==
                                              'Aucune'
                                          ? ''
                                          : '[recurrence:$selectedRecurrence]';
                                      final notesText =
                                          notesController.text.trim();
                                      final payloadNotes = _buildSessionNotes(
                                        recurrenceMeta: recurrenceMeta,
                                        notesText: notesText,
                                      );

                                      final payload = TrainingSession(
                                        id: 0,
                                        documentId: '',
                                        title: title,
                                        courseAssociated: null,
                                        courseLabel: 'Non spécifié',
                                        type:
                                            SessionTypeX.fromAny(selectedType),
                                        maxParticipants: maxParticipants,
                                        startDate: startDate,
                                        endDate: endDate,
                                        meetingLink: meetingLinkController.text
                                                .trim()
                                                .isEmpty
                                            ? null
                                            : meetingLinkController.text.trim(),
                                        notes: payloadNotes,
                                        status: SessionStatus.planned,
                                        participants: const [],
                                        createdAt: null,
                                      );

                                      final created =
                                          await _api.createSession(payload);
                                      if (!mounted) return;

                                      final normalizedCreated =
                                          _withAssociationOrigin(created);

                                      final recurrence =
                                          _extractRecurrenceFromNotes(
                                        normalizedCreated.notes,
                                      );

                                      setState(() {
                                        _sessions = [
                                          normalizedCreated,
                                          ..._sessions,
                                        ];
                                        if (recurrence != null) {
                                          _localRecurrenceByKey[_sessionKey(
                                              normalizedCreated)] = recurrence;
                                        }
                                      });

                                      if (mounted) {
                                        isDialogOpen = false;
                                        Navigator.of(dialogContext).pop();
                                        _showSnack('Session créée avec succès');
                                      }
                                    } catch (e) {
                                      _showSnack('Erreur: ${_cleanError(e)}');
                                    } finally {
                                      if (mounted && isDialogOpen) {
                                        setDialogState(() {
                                          isSaving = false;
                                        });
                                      }
                                    }
                                  },
                            icon: const Icon(Icons.event_available_outlined,
                                size: 14),
                            label: Text(isSaving
                                ? 'Enregistrement...'
                                : 'Planifier la session'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0B6BFF),
                              foregroundColor: Colors.white,
                              minimumSize: const Size(0, 34),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 14),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    ).whenComplete(() {
      isDialogOpen = false;
      sessionTitleController.dispose();
      maxParticipantsController.dispose();
      meetingLinkController.dispose();
      notesController.dispose();
    });
  }

  InputDecoration _associationInputDecoration(
    String? hintText, {
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Color(0xFF9CA3AF),
        fontSize: 12,
      ),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      filled: true,
      fillColor: Colors.white,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF93C5FD)),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
    );
  }

  Widget _associationLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF334155),
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
    );
  }

  String _sessionKey(TrainingSession session) {
    final doc = session.documentId.trim();
    if (doc.isNotEmpty) return doc;
    return 'id:${session.id}';
  }

  String? _resolveRecurrence(TrainingSession session) {
    final key = _sessionKey(session);
    final local = _localRecurrenceByKey[key];
    if (local != null && local.trim().isNotEmpty) return local;
    return _extractRecurrenceFromNotes(session.notes);
  }

  String? _extractRecurrenceFromNotes(String? notes) {
    if (notes == null || notes.trim().isEmpty) return null;
    final match =
        RegExp(r'\[recurrence:(.*?)\]', caseSensitive: false).firstMatch(notes);
    final value = match?.group(1)?.trim();
    if (value == null || value.isEmpty) return null;
    return value;
  }

  TrainingSession _withAssociationOrigin(TrainingSession session) {
    final notes = (session.notes ?? '').trim();
    if (notes.toLowerCase().contains(_associationOriginTag)) {
      return session;
    }

    final merged = notes.isEmpty
        ? _associationOriginTag
        : '$_associationOriginTag\n$notes';
    return session.copyWith(notes: merged);
  }

  String? _buildSessionNotes({
    required String recurrenceMeta,
    required String notesText,
  }) {
    final chunks = <String>[_associationOriginTag];
    if (recurrenceMeta.trim().isNotEmpty) {
      chunks.add(recurrenceMeta.trim());
    }
    if (notesText.trim().isNotEmpty) {
      chunks.add(notesText.trim());
    }

    final merged = chunks.join('\n').trim();
    return merged.isEmpty ? null : merged;
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) return '-';
    const months = <String>[
      'janv',
      'févr',
      'mars',
      'avr',
      'mai',
      'juin',
      'juil',
      'août',
      'sept',
      'oct',
      'nov',
      'déc',
    ];

    final day = value.day;
    final month = months[value.month - 1];
    final h = value.hour.toString().padLeft(2, '0');
    final m = value.minute.toString().padLeft(2, '0');

    return '$day $month à $h:$m';
  }

  String _formatDateOnly(DateTime? value) {
    if (value == null) return '-';
    final d = value.day.toString().padLeft(2, '0');
    final m = value.month.toString().padLeft(2, '0');
    final y = value.year;
    return '$d/$m/$y';
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '').trim();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _DashedRoundedRectPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double dash;
  final double gap;

  const _DashedRoundedRectPainter({
    required this.color,
    required this.radius,
    required this.dash,
    required this.gap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final path = Path()..addRRect(rrect);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = (distance + dash).clamp(0.0, metric.length).toDouble();
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRoundedRectPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.radius != radius ||
        oldDelegate.dash != dash ||
        oldDelegate.gap != gap;
  }
}
