import 'package:flutter/material.dart';
import 'package:flutter_getx_app/app/data/models/training_session_model.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/professional_formations_controller.dart';
import 'package:get/get.dart';

class ProfessionalFormationsPage
    extends GetView<ProfessionalFormationsController> {
  const ProfessionalFormationsPage({super.key});

  static const Color _bg = Color(0xFFF1F5F9);
  static const Color _card = Color(0xFFFFFFFF);
  static const Color _border = Color(0xFFE2E8F0);
  static const Color _text = Color(0xFF111827);
  static const Color _muted = Color(0xFF6B7280);
  static const Color _primary = Color(0xFF0B6BFF);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bg,
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildSearch(),
          const SizedBox(height: 16),
          _buildTabs(),
          const SizedBox(height: 16),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Obx(() {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.school_outlined, color: _primary, size: 30),
                    SizedBox(width: 8),
                    Text(
                      'Formations Continues',
                      style: TextStyle(
                        color: _text,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Inscrivez-vous aux sessions de formation disponibles pour développer vos compétences.',
                  style: TextStyle(color: _muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _StatCard(
            value: controller.mySessions.length.toString(),
            label: 'Mes inscriptions',
            highlighted: true,
          ),
          const SizedBox(width: 10),
          _StatCard(
            value: controller.availableSessions.length.toString(),
            label: 'Disponibles',
          ),
        ],
      );
    });
  }

  Widget _buildSearch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: TextField(
        onChanged: controller.setSearch,
        decoration: const InputDecoration(
          hintText: 'Rechercher une formation, un cours, un formateur...',
          hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
          prefixIcon: Icon(Icons.search, size: 18, color: Color(0xFF9CA3AF)),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Obx(() {
      final selected = controller.tabIndex.value;
      return Row(
        children: [
          _TabButton(
            label: 'Sessions disponibles',
            badge: controller.availableSessions.length,
            selected: selected == 0,
            onTap: () => controller.tabIndex.value = 0,
          ),
          const SizedBox(width: 10),
          _TabButton(
            label: 'Mes formations',
            badge: controller.mySessions.length,
            selected: selected == 1,
            onTap: () => controller.tabIndex.value = 1,
          ),
        ],
      );
    });
  }

  Widget _buildContent() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.errorMessage.value.trim().isNotEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_outlined,
                  size: 40, color: Color(0xFF94A3B8)),
              const SizedBox(height: 8),
              Text(
                controller.errorMessage.value,
                textAlign: TextAlign.center,
                style: const TextStyle(color: _muted),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: controller.loadData,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Réessayer'),
              ),
            ],
          ),
        );
      }

      final isAvailableTab = controller.tabIndex.value == 0;
      final rows = isAvailableTab
          ? controller.filteredAvailableSessions
          : controller.filteredMySessions;

      if (rows.isEmpty) {
        return const Center(
          child: Text(
            'Aucune session à afficher',
            style: TextStyle(color: Color(0xFF94A3B8)),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.loadData(withLoader: false),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final columns = width >= 1200
                ? 3
                : width >= 820
                    ? 2
                    : 1;
            final cardWidth = (width - ((columns - 1) * 16)) / columns;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                children: rows
                    .map((session) => SizedBox(
                          width: cardWidth,
                          child: _SessionCard(
                            session: session,
                            isAvailable: isAvailableTab,
                            isSubmitting: controller.isSubmitting.value,
                            onPrimaryTap: isAvailableTab
                                ? () => controller.enrollInSession(session)
                                : null,
                            onLeaveTap: !isAvailableTab
                                ? () => controller.leaveSession(session)
                                : null,
                          ),
                        ))
                    .toList(),
              ),
            );
          },
        ),
      );
    });
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final bool highlighted;

  const _StatCard({
    required this.value,
    required this.label,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84,
      height: 72,
      decoration: BoxDecoration(
        color: highlighted ? const Color(0xFFEAF2FF) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color:
              highlighted ? const Color(0xFFBCD7FF) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              color: highlighted
                  ? const Color(0xFF0B6BFF)
                  : const Color(0xFF111827),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final int badge;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.badge,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEAF2FF) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? const Color(0xFFBCD7FF) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: const Color(0xFF111827),
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: const Color(0xFF0B6BFF),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$badge',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final TrainingSession session;
  final bool isAvailable;
  final bool isSubmitting;
  final VoidCallback? onPrimaryTap;
  final VoidCallback? onLeaveTap;

  const _SessionCard({
    required this.session,
    required this.isAvailable,
    required this.isSubmitting,
    this.onPrimaryTap,
    this.onLeaveTap,
  });

  @override
  Widget build(BuildContext context) {
    final participantsText =
        '${session.participants.length} / ${session.maxParticipants} participants';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  session.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFF86EFAC)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_open_rounded,
                        size: 12, color: Color(0xFF16A34A)),
                    const SizedBox(width: 4),
                    Text(
                      session.type.label,
                      style: const TextStyle(
                        color: Color(0xFF16A34A),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.school_outlined,
                  size: 14, color: Color(0xFF64748B)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  session.courseLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF64748B)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 14, color: Color(0xFF60A5FA)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _formatDate(session.startDate),
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                  ),
                ),
              ),
              const Icon(Icons.access_time, size: 14, color: Color(0xFF60A5FA)),
              const SizedBox(width: 6),
              Text(
                _formatTimeRange(session.startDate, session.endDate),
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.people_outline,
                  size: 14, color: Color(0xFF60A5FA)),
              const SizedBox(width: 6),
              Text(
                participantsText,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            (session.notes?.trim().isNotEmpty ?? false)
                ? session.notes!.trim()
                : 'Aucune note',
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontStyle: FontStyle.italic,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          if (isAvailable)
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                height: 34,
                child: ElevatedButton(
                  onPressed: !isSubmitting ? onPrimaryTap : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B6BFF),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('S\'inscrire'),
                ),
              ),
            )
          else ...[
            InkWell(
              onTap: () {
                if ((session.meetingLink?.trim().isNotEmpty ?? false)) {
                  Get.snackbar('Lien de session', session.meetingLink!.trim());
                  return;
                }
                Get.snackbar(
                  'Information',
                  'Aucun lien de session disponible pour le moment',
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFBCD7FF)),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: Color(0xFF2563EB),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Rejoindre la session en ligne',
                      style: TextStyle(
                        color: Color(0xFF2563EB),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 14,
                      color: Color(0xFF16A34A),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Inscrit',
                      style: TextStyle(
                        color: Color(0xFF16A34A),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                SizedBox(
                  height: 30,
                  child: OutlinedButton.icon(
                    onPressed: !isSubmitting ? onLeaveTap : null,
                    icon: const Icon(
                      Icons.cancel_outlined,
                      size: 14,
                    ),
                    label: const Text('Se desinscrire'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      side: const BorderSide(color: Color(0xFFFCA5A5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime? value) {
    if (value == null) return '-';

    const months = <String>[
      'jan',
      'fev',
      'mar',
      'avr',
      'mai',
      'jun',
      'jul',
      'aou',
      'sep',
      'oct',
      'nov',
      'dec',
    ];

    final d = value.day.toString().padLeft(2, '0');
    final month = months[value.month - 1];
    return '$d $month ${value.year}';
  }

  String _formatTimeRange(DateTime? start, DateTime? end) {
    String hhmm(DateTime? value) {
      if (value == null) return '--:--';
      final h = value.hour.toString().padLeft(2, '0');
      final m = value.minute.toString().padLeft(2, '0');
      return '$h:$m';
    }

    return '${hhmm(start)} - ${hhmm(end)}';
  }
}
