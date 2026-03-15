import 'package:flutter/material.dart';
import 'package:flutter_getx_app/app/modules/home/modules/plan/models/Reservation%20modal.dart';
import 'package:flutter_getx_app/app/modules/spaces/views/widgets/Interactive%20floor%20plan.dart';
import 'package:flutter_getx_app/services/r%C3%A9servation_api_service.dart';
import 'package:get/get.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/home_controller.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/views/custom_sidebar.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/views/dashboard_topbar.dart';

class ReserverEspaceScreen extends GetView<HomeController> {
  const ReserverEspaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EDF4),
      body: Row(
        children: [
          const CustomSidebar(),
          const Expanded(
            child: Column(
              children: [
                DashboardTopBar(),
                Expanded(child: _PlanContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanContent extends StatefulWidget {
  const _PlanContent();

  @override
  State<_PlanContent> createState() => _PlanContentState();
}

class _PlanContentState extends State<_PlanContent>
    with SingleTickerProviderStateMixin {
  final ReservationApiService _apiService = ReservationApiService();
  String? _selectedSpaceId;
  bool _isLoadingSpace = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
    _fadeIn = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _onSpaceTapped(
      String spaceId, String label, Offset globalPos) async {
    if (_isLoadingSpace) return;
    setState(() {
      _selectedSpaceId = spaceId;
      _isLoadingSpace = true;
    });
    try {
      final space = await _apiService.fetchSpace(spaceId);
      if (!mounted) return;
      final result = await ReservationModal.show(
        context,
        space: space,
        apiService: _apiService,
      );
      if (result == true) {
        setState(() => _selectedSpaceId = null);
        _snack('Réservation effectuée !', const Color(0xFF22C55E),
            Icons.check_circle);
      } else {
        setState(() => _selectedSpaceId = null);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _selectedSpaceId = null);
        _snack('Impossible de charger l\'espace.', const Color(0xFFEF4444),
            Icons.error_outline);
      }
    } finally {
      if (mounted) setState(() => _isLoadingSpace = false);
    }
  }

  void _snack(String msg, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Expanded(
            child:
                Text(msg, style: const TextStyle(fontWeight: FontWeight.w500))),
      ]),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 3),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeIn,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Titre ──────────────────────────────────────────────────
            const Text('Réserver un Espace',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.3)),
            const SizedBox(height: 4),
            const Text(
                'Sélectionnez un espace sur le plan pour effectuer votre réservation.',
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
            const SizedBox(height: 18),

            // ── Plan — Expanded pour prendre TOUT l'espace restant ─────
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFD4DCE6)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4)),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: Stack(fit: StackFit.expand, children: [
                    // ── Plan SVG interactif ────────────────────────────
                    InteractiveFloorPlan(
                      onSpaceTapped: _onSpaceTapped,
                      selectedSpaceId: _selectedSpaceId,
                    ),
                    // ── Légende ────────────────────────────────────────
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: _Legend(),
                    ),
                    // ── Loading ────────────────────────────────────────
                    if (_isLoadingSpace)
                      Container(
                        color: Colors.white.withOpacity(0.6),
                        child: const Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFF22C55E), strokeWidth: 2.5),
                        ),
                      ),
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: const Row(mainAxisSize: MainAxisSize.min, children: [
        _Dot(color: Color(0xFF22C55E), label: 'Disponible'),
        SizedBox(width: 14),
        _Dot(color: Color(0xFF38BDF8), label: 'Sélectionné'),
        SizedBox(width: 14),
        _Dot(color: Color(0xFF94A3B8), label: 'Indisponible'),
      ]),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  final String label;
  const _Dot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 5),
      Text(label,
          style:
              const TextStyle(fontSize: 11.5, color: Color(0xFF475569))),
    ]);
  }
}