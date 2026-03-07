import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_getx_app/app/data/models/space_model.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/views/custom_sidebar.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/views/dashboard_topbar.dart';
import 'package:flutter_getx_app/app/modules/spaces/controllers/spaces_controller.dart';

class StudentSpacesView extends StatefulWidget {
  const StudentSpacesView({super.key});

  @override
  State<StudentSpacesView> createState() => _StudentSpacesViewState();
}

class _StudentSpacesViewState extends State<StudentSpacesView> {
  late final SpaceController controller;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    controller = Get.find<SpaceController>();
    // Always refresh data when opening "Espaces d'etude".
    if (!controller.loading.value) {
      controller.loadSpaces(forceRefresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF0F8),
      body: Row(
        children: [
          const CustomSidebar(),
          Expanded(
            child: Column(
              children: [
                const DashboardTopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeroCard(),
                        const SizedBox(height: 18),
                        _buildSearchBar(),
                        const SizedBox(height: 22),
                        _buildSpacesGrid(),
                      ],
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

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 28),
      decoration: BoxDecoration(
        color: const Color(0xFFDDE8F8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD0DDF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFBFD6F8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'COWORKING & STUDY',
              style: TextStyle(
                color: Color(0xFF1664FF),
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(height: 14),
          RichText(
            text: const TextSpan(
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 44,
                height: 1.08,
                fontWeight: FontWeight.w800,
              ),
              children: [
                TextSpan(text: 'Trouvez '),
                TextSpan(
                  text: "l'espace ideal",
                  style: TextStyle(color: Color(0xFF1664FF)),
                ),
                TextSpan(text: ' pour vos etudes'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Reservez des bureaux premium, des salles de reunion ou des postes de travail equipes.',
            style: TextStyle(
              color: Color(0xFF475569),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Profitez de nos abonnements mensuels avantageux.',
            style: TextStyle(
              color: Color(0xFF475569),
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 650),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFDCE4EF)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x140F172A),
                blurRadius: 20,
                offset: Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.search, size: 20, color: Color(0xFF6B7280)),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Rechercher un espace (nom, type, etage...)',
                    hintStyle: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpacesGrid() {
    return Obx(() {
      if (controller.loading.value && controller.spaces.isEmpty) {
        return const SizedBox(
          height: 250,
          child: Center(child: CircularProgressIndicator()),
        );
      }

      final query = _searchQuery.trim().toLowerCase();
      final filtered = controller.spaces.where((space) {
        if (query.isEmpty) return true;
        final haystack = [
          space.name,
          space.type ?? '',
          space.location ?? '',
          space.floor ?? '',
        ].join(' ').toLowerCase();
        return haystack.contains(query);
      }).toList();

      if (filtered.isEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFDCE4EF)),
          ),
          child: const Center(
            child: Text(
              'Aucun espace trouve',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }

      return LayoutBuilder(
        builder: (context, constraints) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 0.80,
            ),
            itemBuilder: (context, index) => _SpaceCard(space: filtered[index]),
          );
        },
      );
    });
  }
}

class _SpaceCard extends StatelessWidget {
  const _SpaceCard({required this.space});

  final Space space;

  @override
  Widget build(BuildContext context) {
    final type = (space.type == null || space.type!.trim().isEmpty)
        ? 'Espace'
        : space.type!.trim();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD9E2EE)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: Row(
              children: [
                _tinyChip(
                    type, const Color(0xFFF8FAFC), const Color(0xFF334155)),
                const SizedBox(width: 8),
                _tinyChip('Abonnement', const Color(0xFF1664FF), Colors.white),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 0),
            height: 148,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFF3F4F6),
              border: Border(
                top: BorderSide(color: Color(0xFFE5E7EB)),
                bottom: BorderSide(color: Color(0xFFE5E7EB)),
              ),
            ),
            child: const Icon(Icons.apartment_outlined,
                size: 40, color: Color(0xFFBDBDBD)),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    space.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF020617),
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 14, color: Color(0xFF3B82F6)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _locationLabel(space),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _statBox(
                          'CAPACITE',
                          '${space.capacity} pers.',
                          false,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _statBox(
                          'PAR MOIS',
                          _monthlyLabel(space),
                          true,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Divider(height: 18, color: Color(0xFFE2E8F0)),
                  Row(
                    children: [
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                              ),
                              children: [
                                TextSpan(text: _hourlyLabel(space)),
                                const TextSpan(
                                  text: ' / heure',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Get.snackbar(
                            'Reservation',
                            'Reservation pour ${space.name} (bientot disponible)',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1664FF),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Reserver',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.chevron_right, size: 16),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tinyChip(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _statBox(String title, String value, bool highlighted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: highlighted ? const Color(0xFFEEF5FF) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              highlighted ? const Color(0xFFBFDBFE) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: highlighted
                  ? const Color(0xFF2563EB)
                  : const Color(0xFF64748B),
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: highlighted
                    ? const Color(0xFF2563EB)
                    : const Color(0xFF0F172A),
                fontSize: 22,
                fontWeight: FontWeight.w800,
                height: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _locationLabel(Space s) {
    final location = (s.location ?? '').trim();
    final floor = (s.floor ?? '').trim();

    if (location.isEmpty && floor.isEmpty) return 'xxxx';
    if (location.isEmpty) return floor;
    if (floor.isEmpty) return location;
    return '$location - $floor';
  }

  static String _currencyCode(String currency) {
    final normalized = currency.trim().toUpperCase();
    if (normalized == 'TND') return 'DT';
    return normalized.isEmpty ? 'DT' : normalized;
  }

  static String _hourlyLabel(Space s) {
    final code = _currencyCode(s.currency);
    if (s.hourlyRate <= 0) return '-- $code';
    return '${s.hourlyRate.toStringAsFixed(0)} $code';
  }

  static String _monthlyLabel(Space s) {
    final code = _currencyCode(s.currency);
    if (s.monthlyRate <= 0) return '-- $code';
    return '${s.monthlyRate.toStringAsFixed(0)} $code';
  }
}
