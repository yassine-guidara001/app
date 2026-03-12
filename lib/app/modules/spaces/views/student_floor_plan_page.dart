import 'package:flutter/material.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/views/custom_sidebar.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/views/dashboard_topbar.dart';

class StudentFloorPlanPage extends StatelessWidget {
  const StudentFloorPlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool compact = MediaQuery.of(context).size.width < 980;

    return Scaffold(
      backgroundColor: const Color(0xFFEAF0F8),
      body: compact ? _buildCompactLayout() : _buildDesktopLayout(),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        const CustomSidebar(),
        Expanded(child: _buildMainContent()),
      ],
    );
  }

  Widget _buildCompactLayout() {
    return _buildMainContent();
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        const DashboardTopBar(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1320),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFDCE6F3)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x120F172A),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(18),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.map_outlined,
                            size: 58,
                            color: Color(0xFF94A3B8),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Module plan supprime',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF334155),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Les fichiers et l\'integration du plan ont ete retires.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
