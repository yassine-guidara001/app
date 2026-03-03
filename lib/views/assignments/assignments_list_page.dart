import 'package:flutter/material.dart';
import 'package:flutter_getx_app/controllers/assignments_controller.dart';
import 'package:flutter_getx_app/views/assignments/assignment_details_page.dart';
import 'package:flutter_getx_app/views/assignments/assignment_form_page.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/views/custom_sidebar.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/views/dashboard_topbar.dart';
import 'package:get/get.dart';

class AssignmentsListPage extends GetView<AssignmentsController> {
  const AssignmentsListPage({super.key});

  static const Color _pageBg = Color(0xFFF1F5F9);
  static const Color _border = Color(0xFFE2E8F0);
  static const Color _primary = Color(0xFF1565C0);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: _pageBg,
      body: Row(
        children: [
          CustomSidebar(),
          Expanded(
            child: Column(
              children: [
                DashboardTopBar(),
                Expanded(child: _AssignmentsListContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AssignmentsListContent extends StatefulWidget {
  const _AssignmentsListContent();

  @override
  State<_AssignmentsListContent> createState() =>
      _AssignmentsListContentState();
}

class _AssignmentsListContentState extends State<_AssignmentsListContent> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final controller = Get.find<AssignmentsController>();
    controller.fetchCourses();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AssignmentsController>();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.description_outlined,
                          color: AssignmentsListPage._primary, size: 30),
                      SizedBox(width: 8),
                      Text(
                        'Devoirs',
                        style: TextStyle(
                          fontSize: 40,
                          height: 1.02,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF212121),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Gérez les devoirs et les évaluations',
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xFF757575),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 40,
                child: ElevatedButton.icon(
                  onPressed: () => Get.to(() => const AssignmentFormPage()),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Nouveau Devoir'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AssignmentsListPage._primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AssignmentsListPage._border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Rechercher un devoir...',
                prefixIcon: const Icon(Icons.search, size: 18),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: AssignmentsListPage._border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: AssignmentsListPage._border),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AssignmentsListPage._border),
              ),
              child: Column(
                children: [
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AssignmentsListPage._border),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Expanded(flex: 3, child: _HeadCell('Titre')),
                        Expanded(flex: 2, child: _HeadCell('Cours')),
                        Expanded(flex: 2, child: _HeadCell('Échéance')),
                        Expanded(flex: 2, child: _HeadCell('Points')),
                        Expanded(
                          flex: 1,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: _HeadCell('Actions'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final query = _searchCtrl.text.trim().toLowerCase();
                      final rows = controller.assignments.where((item) {
                        if (query.isEmpty) return true;
                        return item.title.toLowerCase().contains(query) ||
                            item.courseName.toLowerCase().contains(query);
                      }).toList();

                      if (rows.isEmpty &&
                          controller.errorMessage.value.trim().isNotEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.wifi_off_outlined,
                                size: 42,
                                color: Color(0xFF94A3B8),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                controller.errorMessage.value,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF64748B),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 36,
                                child: OutlinedButton.icon(
                                  onPressed: controller.fetchAssignments,
                                  icon: const Icon(Icons.refresh, size: 16),
                                  label: const Text('Réessayer'),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      if (rows.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.inbox_outlined,
                                  size: 42, color: Color(0xFF94A3B8)),
                              SizedBox(height: 10),
                              Text(
                                'Aucun devoir trouvé',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.separated(
                        itemCount: rows.length,
                        separatorBuilder: (_, __) => const Divider(
                          height: 1,
                          thickness: 1,
                          color: AssignmentsListPage._border,
                        ),
                        itemBuilder: (_, index) {
                          final item = rows[index];
                          return Container(
                            height: 56,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    item.title,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    item.courseName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    _formatDate(item.dueDate),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    item.maxPoints.toString(),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          tooltip: 'Voir',
                                          visualDensity: VisualDensity.compact,
                                          constraints: const BoxConstraints(),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                          ),
                                          onPressed: () => Get.to(
                                            () => AssignmentDetailsPage(
                                              assignment: item,
                                            ),
                                          ),
                                          icon: const Icon(
                                            Icons.remove_red_eye_outlined,
                                            color: Color(0xFF6B7280),
                                            size: 17,
                                          ),
                                        ),
                                        IconButton(
                                          tooltip: 'Modifier',
                                          visualDensity: VisualDensity.compact,
                                          constraints: const BoxConstraints(),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                          ),
                                          onPressed: () => Get.to(
                                            () => AssignmentFormPage(
                                              assignment: item,
                                            ),
                                          ),
                                          icon: const Icon(
                                            Icons.edit_outlined,
                                            color: Color(0xFF111827),
                                            size: 17,
                                          ),
                                        ),
                                        IconButton(
                                          tooltip: 'Supprimer',
                                          visualDensity: VisualDensity.compact,
                                          constraints: const BoxConstraints(),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                          ),
                                          onPressed: () {
                                            Get.defaultDialog(
                                              title: 'Confirmer',
                                              middleText:
                                                  'Supprimer ce devoir ?',
                                              textCancel: 'Annuler',
                                              textConfirm: 'Supprimer',
                                              confirmTextColor: Colors.white,
                                              buttonColor:
                                                  const Color(0xFFD32F2F),
                                              onConfirm: () async {
                                                Get.back();
                                                await controller
                                                    .removeAssignment(
                                                  item.id,
                                                );
                                              },
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: Color(0xFFD32F2F),
                                            size: 17,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime value) {
    final d = value.day.toString().padLeft(2, '0');
    final m = value.month.toString().padLeft(2, '0');
    final y = value.year.toString();
    return '$d/$m/$y';
  }
}

class _HeadCell extends StatelessWidget {
  final String text;

  const _HeadCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF111827),
      ),
    );
  }
}
