import 'package:flutter/material.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/home_controller.dart';
import 'package:flutter_getx_app/app/routes/app_routes.dart';
import 'package:get/get.dart';

import 'custom_sidebar.dart';
import 'dashboard_topbar.dart';

class DashboardView extends GetView<HomeController> {
  const DashboardView({super.key});

  static const List<_StatData> _stats = <_StatData>[
    _StatData(
      title: 'Espaces Totaux',
      value: '24',
      subtitle: '+2 ce mois',
      icon: Icons.apartment_rounded,
      iconColor: Color(0xFF1F6FEB),
    ),
    _StatData(
      title: 'Réservations Actives',
      value: '156',
      subtitle: '+12% vs mois dernier',
      icon: Icons.calendar_month_outlined,
      iconColor: Color(0xFFF59E0B),
    ),
    _StatData(
      title: 'Cours Publiés',
      value: '18',
      subtitle: '+4 ajoutés récemment',
      icon: Icons.menu_book_rounded,
      iconColor: Color(0xFF16A34A),
    ),
    _StatData(
      title: 'Utilisateurs Actifs',
      value: '892',
      subtitle: '+43 cette semaine',
      icon: Icons.groups_2_outlined,
      iconColor: Color(0xFFA855F7),
    ),
  ];

  static const List<_ActivityData> _activities = <_ActivityData>[
    _ActivityData(
      title: 'Bureau Premium',
      client: 'Alice Martin',
      date: '2026-01-28',
      status: 'Confirmé',
    ),
    _ActivityData(
      title: 'Salle de Réunion',
      client: 'Bob Durant',
      date: '2026-01-29',
      status: 'Confirmé',
    ),
    _ActivityData(
      title: 'Espace Coworking',
      client: 'Carol Smith',
      date: '2026-01-29',
      status: 'En attente',
    ),
    _ActivityData(
      title: 'Studio Privé',
      client: 'David Johnson',
      date: '2026-01-29',
      status: 'Confirmé',
    ),
  ];

  static const List<_PopularCourseData> _popularCourses = <_PopularCourseData>[
    _PopularCourseData(
      title: 'Démarrage avec Next.js',
      students: 240,
      rating: 4.8,
    ),
    _PopularCourseData(
      title: 'Design UI/UX',
      students: 412,
      rating: 4.9,
    ),
    _PopularCourseData(
      title: 'Maîtriser TypeScript',
      students: 189,
      rating: 4.7,
    ),
  ];

  static const List<_QuickActionData> _quickActions = <_QuickActionData>[
    _QuickActionData(label: 'Espaces', icon: Icons.apartment_outlined),
    _QuickActionData(label: 'Utilisateurs', icon: Icons.group_outlined),
    _QuickActionData(
        label: 'Réservations', icon: Icons.calendar_today_outlined),
    _QuickActionData(label: 'Système', icon: Icons.settings_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Row(
        children: [
          const CustomSidebar(),
          Expanded(
            child: Column(
              children: [
                const DashboardTopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final double width = constraints.maxWidth;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tableau de bord',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Bienvenue intern',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildStatsGrid(width),
                            const SizedBox(height: 16),
                            _buildCenterContent(width),
                            const SizedBox(height: 16),
                            _buildQuickActions(width),
                            const SizedBox(height: 16),
                            _buildBottomStats(width),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(double width) {
    final int crossAxisCount = width >= 1200
        ? 4
        : width >= 900
            ? 2
            : 1;

    final double childAspectRatio = width >= 1200
        ? 2.8
        : width >= 900
            ? 2.6
            : 3.1;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: _stats.length,
      itemBuilder: (context, index) {
        final _StatData item = _stats[index];
        return StatCard(
          title: item.title,
          value: item.value,
          subtitle: item.subtitle,
          icon: item.icon,
          iconColor: item.iconColor,
        );
      },
    );
  }

  Widget _buildCenterContent(double width) {
    final bool desktop = width >= 1100;

    if (!desktop) {
      return Column(
        children: [
          _buildActivitiesCard(),
          const SizedBox(height: 12),
          _buildOptimizationCard(),
          const SizedBox(height: 12),
          _buildPopularCoursesCard(),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: _buildActivitiesCard()),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildOptimizationCard(),
              const SizedBox(height: 12),
              _buildPopularCoursesCard(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivitiesCard() {
    return Card(
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.06),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Activités récentes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Dernières réservations effectuées',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    controller.changeMenu(6, Routes.RESERVATIONS);
                  },
                  icon: const Text('Voir tout'),
                  label: const Icon(Icons.arrow_forward, size: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _activities.length,
              separatorBuilder: (context, index) => const Divider(height: 18),
              itemBuilder: (context, index) {
                final _ActivityData item = _activities[index];
                return ActivityItem(
                  title: item.title,
                  client: item.client,
                  date: item.date,
                  status: item.status,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptimizationCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1664FF), Color(0xFF2684FF)],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1664FF).withOpacity(0.24),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Optimisez votre temps',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Consultez les rapports détaillés pour une gestion plus fine de vos ressources.',
            style: TextStyle(
              color: Color(0xFFE5EEFF),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1458E0),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Paramètres'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularCoursesCard() {
    return Card(
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.06),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cours populaires',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 10),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _popularCourses.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final _PopularCourseData item = _popularCourses[index];
                return _CourseItem(data: item);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(double width) {
    final int crossAxisCount = width >= 1200
        ? 4
        : width >= 700
            ? 2
            : 1;

    final double aspectRatio = width >= 1200 ? 4.2 : 3.6;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 2),
          child: Text(
            'Actions rapides',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _quickActions.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: aspectRatio,
          ),
          itemBuilder: (context, index) {
            final _QuickActionData action = _quickActions[index];
            return QuickActionButton(
              label: action.label,
              icon: action.icon,
              onTap: () {},
            );
          },
        ),
      ],
    );
  }

  Widget _buildBottomStats(double width) {
    final bool stacked = width < 980;
    final Widget revenueCard = const ProgressStatCard(
      title: 'Revenu du mois',
      value: '8 432.50 DT',
      deltaText: '+12.5%',
      progressValue: 0.70,
      progressColor: Color(0xFF22C55E),
      helperText: 'Objectif: 12 000 DT',
      icon: Icons.attach_money_rounded,
    );

    final Widget occupancyCard = const ProgressStatCard(
      title: "Taux d'occupation",
      value: '87%',
      deltaText: '+4.6%',
      progressValue: 0.87,
      progressColor: Color(0xFF2563EB),
      helperText: 'Capacité: 150 / 180',
      icon: Icons.bar_chart_rounded,
    );

    if (stacked) {
      return Column(
        children: [
          revenueCard,
          const SizedBox(height: 10),
          occupancyCard,
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: revenueCard),
        const SizedBox(width: 12),
        Expanded(child: occupancyCard),
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF22C55E),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class ActivityItem extends StatelessWidget {
  const ActivityItem({
    super.key,
    required this.title,
    required this.client,
    required this.date,
    required this.status,
  });

  final String title;
  final String client;
  final String date;
  final String status;

  @override
  Widget build(BuildContext context) {
    final bool isPending = status.toLowerCase() == 'en attente';
    final Color badgeColor =
        isPending ? const Color(0xFFFACC15) : const Color(0xFF22C55E);
    final Color badgeTextColor =
        isPending ? const Color(0xFF854D0E) : const Color(0xFF166534);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Client: $client - $date',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: badgeColor.withOpacity(0.16),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: badgeTextColor,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}

class QuickActionButton extends StatelessWidget {
  const QuickActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: const Color(0xFF475569)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProgressStatCard extends StatelessWidget {
  const ProgressStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.deltaText,
    required this.progressValue,
    required this.progressColor,
    required this.helperText,
    required this.icon,
  });

  final String title;
  final String value;
  final String deltaText;
  final double progressValue;
  final Color progressColor;
  final String helperText;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(icon, color: progressColor, size: 18),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  deltaText,
                  style: TextStyle(
                    color: progressColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  helperText,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 6,
                value: progressValue,
                backgroundColor: const Color(0xFFE2E8F0),
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseItem extends StatelessWidget {
  const _CourseItem({required this.data});

  final _PopularCourseData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFFE2ECFF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.school_outlined,
                size: 16, color: Color(0xFF1D4ED8)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.person_outline,
                        size: 13, color: Color(0xFF64748B)),
                    const SizedBox(width: 2),
                    Text(
                      '${data.students}',
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.star_rounded,
                        size: 13, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 2),
                    Text(
                      '${data.rating}',
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatData {
  const _StatData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
}

class _ActivityData {
  const _ActivityData({
    required this.title,
    required this.client,
    required this.date,
    required this.status,
  });

  final String title;
  final String client;
  final String date;
  final String status;
}

class _PopularCourseData {
  const _PopularCourseData({
    required this.title,
    required this.students,
    required this.rating,
  });

  final String title;
  final int students;
  final double rating;
}

class _QuickActionData {
  const _QuickActionData({required this.label, required this.icon});

  final String label;
  final IconData icon;
}
