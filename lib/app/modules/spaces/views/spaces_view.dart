import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_getx_app/app/data/models/space_model.dart';
import 'package:flutter_getx_app/app/modules/spaces/controllers/spaces_controller.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/views/custom_sidebar.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/views/dashboard_topbar.dart';
import 'package:flutter_getx_app/app/modules/spaces/views/create_space_view.dart';
import 'package:flutter_getx_app/app/modules/spaces/views/space_details_view.dart';

class SpacesView extends GetView<SpaceController> {
  SpacesView({super.key});

  final RxString _searchQuery = ''.obs;
  final RxString _statusFilter = 'Tous les statuts'.obs;

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
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 16),
                        _buildFiltersCard(),
                        const SizedBox(height: 16),
                        Expanded(child: _buildSpacesTable()),
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

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Gestion des espaces',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 4),
              Text(
                'Gerez vos espaces de coworking',
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: () async {
            final result = await Get.to(() => const CreateSpaceView());
            if (result == true) {
              await controller.loadSpaces();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1664FF),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Nouvel espace'),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: (value) => _searchQuery.value = value,
            decoration: InputDecoration(
              hintText: 'Rechercher un espace...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 180,
          child: Obx(
            () => DropdownButtonFormField<String>(
              initialValue: _statusFilter.value,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
              items: const [
                'Tous les statuts',
                'Disponible',
                'Occupé',
                'Maintenance',
              ]
                  .map((value) =>
                      DropdownMenuItem(value: value, child: Text(value)))
                  .toList(),
              onChanged: (value) {
                if (value != null) _statusFilter.value = value;
              },
            ),
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          onPressed: controller.loadSpaces,
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }

  Widget _buildFiltersCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: _buildFilters(),
    );
  }

  Widget _buildSpacesTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Obx(() {
        if (controller.loading.value && controller.spaces.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final query = _searchQuery.value.trim().toLowerCase();
        final statusFilter = _statusFilter.value;
        final filtered = controller.spaces.where((space) {
          final matchesQuery =
              query.isEmpty ? true : space.name.toLowerCase().contains(query);
          final matchesStatus = _matchesStatus(space, statusFilter);
          return matchesQuery && matchesStatus;
        }).toList();

        if (filtered.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('Aucun espace trouvé'),
            ),
          );
        }

        return Column(
          children: [
            _buildTableHeader(),
            Expanded(
              child: ListView.separated(
                itemCount: filtered.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                itemBuilder: (context, index) =>
                    _buildSpaceRow(filtered[index]),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: const [
          Expanded(
              flex: 3,
              child: Text('ESPACE',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF64748B)))),
          Expanded(
              flex: 2,
              child: Text('TYPE',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF64748B)))),
          Expanded(
              child: Text('CAPACITÉ',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF64748B)))),
          Expanded(
              child: Text('TARIF/H',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF64748B)))),
          Expanded(
              child: Text('STATUT',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF64748B)))),
          Expanded(
              child: Align(
                  alignment: Alignment.centerRight,
                  child: Text('ACTIONS',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF64748B))))),
        ],
      ),
    );
  }

  Widget _buildSpaceRow(Space space) {
    final location = space.location?.isNotEmpty == true ? space.location! : '—';
    final floor = space.floor?.isNotEmpty == true ? space.floor! : '';
    final locationLine = floor.isNotEmpty
        ? (location == '—' ? floor : '$location ($floor)')
        : location;
    final areaLabel =
        space.area > 0 ? '${space.area.toStringAsFixed(0)} m²' : '';
    final typeLabel = space.type?.isNotEmpty == true ? space.type! : '—';
    final priceLabel = space.hourlyRate > 0
        ? '${space.hourlyRate.toStringAsFixed(0)} ${space.currency}'
        : space.currency;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  space.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 14, color: Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        locationLine,
                        style: const TextStyle(
                            color: Colors.black54, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (areaLabel.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    areaLabel,
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(typeLabel, style: const TextStyle(fontSize: 12)),
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                const Icon(Icons.people_alt_outlined, size: 16),
                const SizedBox(width: 6),
                Text(space.capacity.toString()),
              ],
            ),
          ),
          Expanded(child: Text(priceLabel)),
          Expanded(child: _statusBadge(space.status)),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                    onPressed: () =>
                        Get.to(() => SpaceDetailsView(space: space)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    onPressed: () async {
                      final result =
                          await Get.to(() => CreateSpaceView(space: space));
                      if (result == true) {
                        await controller.loadSpaces();
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        size: 18, color: Colors.red),
                    onPressed: () => controller.delete(space.documentId),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    final displayStatus = _toDisplayStatus(status);
    final normalized = displayStatus.toLowerCase();
    Color color;

    if (normalized.contains('disponible')) {
      color = Colors.green;
    } else if (normalized.contains('occup')) {
      color = Colors.orange;
    } else {
      color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        displayStatus.toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  bool _matchesStatus(Space space, String filter) {
    if (filter == 'Tous les statuts') return true;
    final filterApi = _toApiStatus(filter);
    final spaceApi = _toApiStatus(space.status);
    return spaceApi == filterApi;
  }

  String _toApiStatus(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.contains('disponible') || normalized == 'available') {
      return 'Disponible';
    }
    if (normalized.contains('occup') || normalized == 'occupied') {
      return 'Occupé';
    }
    if (normalized.contains('maintenance') || normalized == 'maintenance') {
      return 'Maintenance';
    }
    return value;
  }

  String _toDisplayStatus(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'available') return 'Disponible';
    if (normalized == 'occupied') return 'Occupé';
    if (normalized == 'maintenance') return 'Maintenance';
    return value;
  }
}
