import 'package:flutter/material.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/reservations_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'custom_sidebar.dart';
import 'dashboard_topbar.dart';

class ReservationsView extends GetView<ReservationsController> {
  const ReservationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
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
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 26),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(),
                            const SizedBox(height: 20),
                            _buildSearchAndFilter(),
                            const SizedBox(height: 16),
                            _buildReservationsTable(),
                          ],
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

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFDBEAFE),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.calendar_today_outlined,
            size: 22,
            color: Color(0xFF0B6BFF),
          ),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Réservations',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 22,
                color: Color(0xFF0F172A),
              ),
            ),
            SizedBox(height: 3),
            Text(
              'Gérez toutes les réservations d\'espaces',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 760;

        final searchField = TextField(
          onChanged: controller.setSearchQuery,
          decoration: InputDecoration(
            hintText: 'Rechercher par espace ou utilisateur...',
            hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
            prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
          ),
        );

        final statusFilter = Container(
          width: isNarrow ? double.infinity : null,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Obx(
            () => DropdownButton<String>(
              value: controller.selectedStatus.value,
              isExpanded: isNarrow,
              underline: const SizedBox(),
              items: ['Tous', 'En attente', 'Confirmé', 'Annulé']
                  .map(
                    (status) => DropdownMenuItem<String>(
                      value: status,
                      child: Text(status),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  controller.changeStatusFilter(value);
                }
              },
            ),
          ),
        );

        if (isNarrow) {
          return Column(
            children: [
              searchField,
              const SizedBox(height: 10),
              statusFilter,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: searchField),
            const SizedBox(width: 10),
            statusFilter,
          ],
        );
      },
    );
  }

  Widget _buildReservationsTable() {
    return Obx(() {
      if (controller.isLoading.value && controller.reservations.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: CircularProgressIndicator(),
          ),
        );
      }

      if (controller.reservations.isEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: const Center(
            child: Text(
              'Aucune réservation trouvée',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ),
        );
      }

      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            _buildTableHeader(),
            ...controller.reservations
                .map((reservation) => _buildTableRow(reservation)),
          ],
        ),
      );
    });
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: const Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Espace',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: Color(0xFF475569)),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Utilisateur',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: Color(0xFF475569)),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Date & Heure',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: Color(0xFF475569)),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Montant',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: Color(0xFF475569)),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Statut',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: Color(0xFF475569)),
            ),
          ),
          SizedBox(
            width: 92,
            child: Text(
              'Actions',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: Color(0xFF475569)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(ReservationModel reservation) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              reservation.spaceName,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              reservation.userName,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              DateFormat('dd/MM/yyyy HH:mm').format(reservation.dateTime),
              style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '${reservation.amount.toStringAsFixed(0)} DT',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: _buildStatusBadge(reservation.status),
          ),
          SizedBox(
            width: 92,
            child: Row(
              children: [
                InkWell(
                  onTap: () =>
                      controller.updateStatus(reservation.id, 'confirmé'),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.check,
                        size: 16, color: Color(0xFF16A34A)),
                  ),
                ),
                const SizedBox(width: 6),
                InkWell(
                  onTap: () => controller.deleteReservation(reservation.id),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.delete_outline,
                        size: 16, color: Color(0xFFDC2626)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final statusLower = status.toLowerCase().replaceAll('_', ' ').trim();

    if (statusLower == 'confirmé' || statusLower == 'confirme') {
      return _statusChip(
        'CONFIRMÉ',
        bgColor: const Color(0xFFDCFCE7),
        textColor: const Color(0xFF16A34A),
      );
    }
    if (statusLower == 'annulé' || statusLower == 'annule') {
      return _statusChip(
        'ANNULÉ',
        bgColor: const Color(0xFFFEE2E2),
        textColor: const Color(0xFFDC2626),
      );
    }

    return _statusChip(
      'EN ATTENTE',
      bgColor: const Color(0xFFFEF3C7),
      textColor: const Color(0xFFB45309),
    );
  }

  Widget _statusChip(String text,
      {required Color bgColor, required Color textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}
