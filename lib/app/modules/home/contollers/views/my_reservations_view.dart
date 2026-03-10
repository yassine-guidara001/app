import 'package:flutter/material.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/reservations_controller.dart';
import 'package:flutter_getx_app/app/routes/app_routes.dart';
import 'package:get/get.dart';

import 'custom_sidebar.dart';
import 'dashboard_topbar.dart';

class MyReservationsView extends GetView<ReservationsController> {
  const MyReservationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF0F8),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final showSidebar = constraints.maxWidth >= 1080;

          return Row(
            children: [
              if (showSidebar) const CustomSidebar(),
              Expanded(
                child: Column(
                  children: [
                    const DashboardTopBar(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(22, 22, 22, 28),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1040),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildHero(context),
                                const SizedBox(height: 24),
                                _buildSectionTitle(),
                                const SizedBox(height: 14),
                                _buildSearchRow(),
                                const SizedBox(height: 14),
                                _buildReservationsPanel(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final compact = width < 1280;
    final titleSize = width < 720 ? 34.0 : (compact ? 44.0 : 52.0);
    final subtitleSize = width < 720 ? 15.0 : (compact ? 18.0 : 23.0);

    return Obx(
      () => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(28, 26, 28, 24),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF5FF),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFFD2E3FF)),
        ),
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCEAFE),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle,
                                size: 8, color: Color(0xFF0B6BFF)),
                            SizedBox(width: 6),
                            Text(
                              'ESPACE PERSONNEL',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                                color: Color(0xFF0B6BFF),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Bienvenue, intern',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: titleSize,
                          fontWeight: FontWeight.w800,
                          height: 0.95,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Retrouvez ici toutes vos reservations et gerez votre planning en toute simplicite.',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: subtitleSize,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildActionButtons(wrap: compact),
                    ],
                  ),
                ),
                if (!compact) ...[
                  const SizedBox(width: 20),
                  _buildCalendarGraphic(),
                ],
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildStatCard(
                  icon: Icons.calendar_today_outlined,
                  label: 'TOTAL',
                  value: controller.totalCount,
                  valueColor: const Color(0xFF0F172A),
                ),
                _buildStatCard(
                  icon: Icons.check_circle_outline,
                  label: 'CONFIRMEES',
                  value: controller.confirmedCount,
                  cardColor: const Color(0xFFE6F7EF),
                  iconColor: const Color(0xFF10B981),
                  valueColor: const Color(0xFF059669),
                ),
                _buildStatCard(
                  icon: Icons.timelapse_outlined,
                  label: 'EN ATTENTE',
                  value: controller.pendingCount,
                  cardColor: const Color(0xFFFFF4E8),
                  iconColor: const Color(0xFFF59E0B),
                  valueColor: const Color(0xFFEA580C),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons({required bool wrap}) {
    final children = [
      OutlinedButton.icon(
        onPressed: controller.loadReservations,
        icon: const Icon(Icons.refresh, size: 18),
        label: const Text('Actualiser'),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF334155),
          side: const BorderSide(color: Color(0xFFC8D9F3)),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      ElevatedButton.icon(
        onPressed: () => Get.toNamed(Routes.STUDENT_SPACES),
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Nouvelle Reservation'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0B6BFF),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
    ];

    if (wrap) {
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: children,
      );
    }

    return Row(children: [children[0], const SizedBox(width: 10), children[1]]);
  }

  Widget _buildCalendarGraphic() {
    return Container(
      width: 170,
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFFDCEAFE),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Icon(
        Icons.calendar_month_rounded,
        size: 72,
        color: Color(0xFF9ABDEB),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required int value,
    Color cardColor = Colors.white,
    Color iconColor = const Color(0xFF64748B),
    Color valueColor = const Color(0xFF0F172A),
  }) {
    return Container(
      width: 210,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD7E3F7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(height: 8),
          Text(
            '$value',
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.w800,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontWeight: FontWeight.w700,
              fontSize: 11,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle() {
    return const Row(
      children: [
        SizedBox(
          width: 4,
          height: 30,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0xFF0B6BFF),
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
          ),
        ),
        SizedBox(width: 12),
        Text(
          'MES RESERVATIONS',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 31,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchRow() {
    return TextField(
      onChanged: controller.setSearchQuery,
      decoration: InputDecoration(
        hintText: 'Rechercher un espace...',
        prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFDEE8F7)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFDEE8F7)),
        ),
      ),
    );
  }

  Widget _buildReservationsPanel() {
    return Obx(() {
      if (controller.isLoading.value) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 48),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFD8E4F5)),
          ),
          child: const Center(child: CircularProgressIndicator()),
        );
      }

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 36),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5FC),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFDCE6F6)),
        ),
        child: const Text(
          'Aucune de vos prochaines sessions ne correspond a votre recherche.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 17,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    });
  }
}
