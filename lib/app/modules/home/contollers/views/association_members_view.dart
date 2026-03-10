import 'package:flutter/material.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/views/custom_sidebar.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/views/dashboard_topbar.dart';

class AssociationMembersView extends StatefulWidget {
  const AssociationMembersView({super.key});

  @override
  State<AssociationMembersView> createState() => _AssociationMembersViewState();
}

class _AssociationMembersViewState extends State<AssociationMembersView> {
  int _selectedFilter = 0;

  static const Color _bg = Color(0xFFEAF0F8);
  static const Color _border = Color(0xFFE2E8F0);
  static const Color _title = Color(0xFF0F172A);
  static const Color _muted = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Row(
        children: [
          const CustomSidebar(),
          Expanded(
            child: Column(
              children: [
                const DashboardTopBar(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'MEMBRES',
                          style: TextStyle(
                            color: _title,
                            fontWeight: FontWeight.w800,
                            fontSize: 38,
                            height: 1,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Gestion des membres de l\'association',
                          style: TextStyle(
                            color: _muted,
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                label: 'TOTAL',
                                value: '0',
                                valueColor: Color(0xFF0F172A),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: _StatCard(
                                label: 'ADMINS',
                                value: '0',
                                valueColor: Color(0xFFA855F7),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: _StatCard(
                                label: 'MEMBRES',
                                value: '0',
                                valueColor: Color(0xFF3B82F6),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 44,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: _border),
                                ),
                                child: const TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Rechercher par nom ou email...',
                                    hintStyle: TextStyle(
                                      color: Color(0xFF94A3B8),
                                      fontSize: 13,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.search,
                                      size: 16,
                                      color: Color(0xFF94A3B8),
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            _FilterChip(
                              label: 'TOUS',
                              selected: _selectedFilter == 0,
                              onTap: () => setState(() => _selectedFilter = 0),
                            ),
                            const SizedBox(width: 6),
                            _FilterChip(
                              label: 'ADMINS',
                              selected: _selectedFilter == 1,
                              onTap: () => setState(() => _selectedFilter = 1),
                            ),
                            const SizedBox(width: 6),
                            _FilterChip(
                              label: 'MEMBRES',
                              selected: _selectedFilter == 2,
                              onTap: () => setState(() => _selectedFilter = 2),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _border),
                            ),
                            child: const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.error_outline_rounded,
                                    color: Color(0xFFF59E0B),
                                    size: 42,
                                  ),
                                  SizedBox(height: 14),
                                  Text(
                                    'Association non configuree',
                                    style: TextStyle(
                                      color: _title,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 32,
                                      height: 1,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Creez d\'abord une association depuis la page Budget.',
                                    style: TextStyle(
                                      color: _muted,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
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
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 42,
              height: 0.9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0B6BFF) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF475569),
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
