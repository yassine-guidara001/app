import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_getx_app/app/data/models/course_model.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/course_controller.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/home_controller.dart';
import 'package:get/get.dart';

import 'custom_sidebar.dart';

class CoursesView extends GetView<CourseController> {
  const CoursesView({super.key});

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
                _buildTopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context),
                        const SizedBox(height: 18),
                        _buildSearchBar(),
                        const SizedBox(height: 16),
                        _buildCoursesTable(context),
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

  Widget _buildTopBar() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 300,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher...',
                hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                isDense: true,
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none,
                color: Color(0xFF475569), size: 20),
          ),
          const CircleAvatar(
            radius: 14,
            backgroundColor: Color(0xFFE2E8F0),
            child: Icon(Icons.person, size: 16, color: Colors.blue),
          ),
          const SizedBox(width: 8),
          const Text(
            'intern',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.menu_book_outlined,
                    color: Color(0xFF2563EB), size: 28),
                SizedBox(width: 10),
                Text(
                  'Mes Formations',
                  style: TextStyle(
                    fontSize: 36,
                    height: 1,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Gérez vos cours, modules et leçons',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 15),
            ),
          ],
        ),
        SizedBox(
          height: 42,
          child: ElevatedButton.icon(
            onPressed: () => _showCourseDialog(context),
            icon: const Icon(Icons.add, size: 18, color: Colors.white),
            label: const Text('Nouveau Cours'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0066D9),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        onChanged: controller.setSearch,
        decoration: InputDecoration(
          hintText: 'Rechercher un cours...',
          hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
          prefixIcon: const Icon(Icons.search, size: 18, color: Colors.grey),
          isDense: true,
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
        ),
      ),
    );
  }

  Widget _buildCoursesTable(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Padding(
            padding: EdgeInsets.all(40),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final courses = controller.filteredCourses;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                children: const [
                  Expanded(flex: 3, child: _HeaderCell('Titre')),
                  Expanded(flex: 2, child: _HeaderCell('Niveau')),
                  Expanded(flex: 2, child: _HeaderCell('Prix')),
                  Expanded(flex: 2, child: _HeaderCell('Statut')),
                  Expanded(flex: 2, child: _HeaderCell('Créé le')),
                  Expanded(flex: 1, child: _HeaderCell('Actions')),
                ],
              ),
            ),
            Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
            if (courses.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 28),
                child: Text(
                  'Aucun cours trouvé',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: courses.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
                itemBuilder: (_, index) =>
                    _buildCourseRow(context, courses[index]),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildCourseRow(BuildContext context, Course course) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              course.title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(course.level,
                style: const TextStyle(color: Color(0xFF475569))),
          ),
          Expanded(
            flex: 2,
            child: Text('${course.price.toStringAsFixed(2)} TND',
                style: const TextStyle(color: Color(0xFF475569))),
          ),
          Expanded(flex: 2, child: _buildStatusBadge(course.status)),
          Expanded(
            flex: 2,
            child: Text(_formatDate(course.createdAt),
                style: const TextStyle(color: Color(0xFF475569))),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: [
                IconButton(
                  onPressed: () => _showCourseDialog(context, course: course),
                  icon: const Icon(Icons.edit_outlined,
                      size: 18, color: Colors.grey),
                ),
                IconButton(
                  onPressed: () => _confirmDelete(course),
                  icon: const Icon(Icons.delete_outline,
                      size: 18, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final isPublished = status.toLowerCase() == 'publié';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isPublished ? const Color(0xFFF0FDF4) : const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              isPublished ? const Color(0xFFDCFCE7) : const Color(0xFFFED7AA),
        ),
      ),
      child: Text(
        status,
        style: TextStyle(
          color:
              isPublished ? const Color(0xFF166534) : const Color(0xFF9A3412),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showCourseDialog(BuildContext context, {Course? course}) {
    final isEdit = course != null;
    final titleController = TextEditingController(text: course?.title ?? '');
    final descriptionController =
        TextEditingController(text: course?.description ?? '');
    final priceController =
        TextEditingController(text: course != null ? '${course.price}' : '0');
    String selectedLevel = course?.level ?? 'Débutant';
    String selectedStatus = course?.status ?? 'Brouillon';

    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: StatefulBuilder(builder: (context, setState) {
            return Container(
              width: 430,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEdit ? 'Modifier le cours' : 'Créer un nouveau cours',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close,
                            size: 16, color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Remplissez les détails ci-dessous pour enregistrer le cours.',
                    style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                  ),
                  const SizedBox(height: 14),
                  const Text('Titre du cours', style: _LabelStyle()),
                  const SizedBox(height: 6),
                  TextField(
                    controller: titleController,
                    decoration: _dialogInputDecoration('Titre du cours...'),
                  ),
                  const SizedBox(height: 10),
                  const Text('Description', style: _LabelStyle()),
                  const SizedBox(height: 6),
                  TextField(
                    controller: descriptionController,
                    maxLines: 2,
                    decoration:
                        _dialogInputDecoration('Description du cours...'),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Niveau', style: _LabelStyle()),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              value: selectedLevel,
                              items: const [
                                DropdownMenuItem(
                                    value: 'Débutant', child: Text('Débutant')),
                                DropdownMenuItem(
                                    value: 'Intermédiaire',
                                    child: Text('Intermédiaire')),
                                DropdownMenuItem(
                                    value: 'Avancé', child: Text('Avancé')),
                              ],
                              onChanged: (v) {
                                if (v != null) {
                                  setState(() => selectedLevel = v);
                                }
                              },
                              decoration: _dialogInputDecoration(null),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Prix (TND)', style: _LabelStyle()),
                            const SizedBox(height: 6),
                            TextField(
                              controller: priceController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: _dialogInputDecoration('0').copyWith(
                                suffixIcon: SizedBox(
                                  width: 26,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          final current = int.tryParse(
                                                  priceController.text
                                                      .trim()) ??
                                              0;
                                          priceController.text =
                                              (current + 10).toString();
                                          setState(() {});
                                        },
                                        child: const Icon(
                                          Icons.keyboard_arrow_up,
                                          size: 14,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          final current = int.tryParse(
                                                  priceController.text
                                                      .trim()) ??
                                              0;
                                          final next = current - 10;
                                          priceController.text =
                                              (next < 0 ? 0 : next).toString();
                                          setState(() {});
                                        },
                                        child: const Icon(
                                          Icons.keyboard_arrow_down,
                                          size: 14,
                                          color: Color(0xFF64748B),
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
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text('Statut', style: _LabelStyle()),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 160,
                    child: DropdownButtonFormField<String>(
                      value: selectedStatus,
                      items: const [
                        DropdownMenuItem(
                            value: 'Brouillon', child: Text('Brouillon')),
                        DropdownMenuItem(
                            value: 'Publié', child: Text('Publié')),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => selectedStatus = v);
                        }
                      },
                      decoration: _dialogInputDecoration(null),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      height: 34,
                      child: ElevatedButton(
                        onPressed: () {
                          final parsedPrice =
                              double.tryParse(priceController.text.trim()) ?? 0;
                          final payload = Course(
                            id: isEdit ? course.id : 0,
                            documentId: isEdit ? course.documentId : '',
                            title: titleController.text.trim(),
                            description: descriptionController.text.trim(),
                            level: selectedLevel,
                            price: parsedPrice,
                            status: selectedStatus,
                            createdAt:
                                isEdit ? course.createdAt : DateTime.now(),
                          );

                          if (isEdit) {
                            controller.editCourse(payload);
                          } else {
                            controller.addCourse(payload);
                          }

                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0066D9),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: Text(
                          isEdit ? 'Mettre à jour' : 'Créer le cours',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  void _confirmDelete(Course course) {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirmation'),
        content: Text('Supprimer le cours "${course.title}" ?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.removeCourse(course);
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  InputDecoration _dialogInputDecoration(String? hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  const _HeaderCell(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        color: Color(0xFF0F172A),
        fontSize: 13,
      ),
    );
  }
}

class _LabelStyle extends TextStyle {
  const _LabelStyle()
      : super(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF111827),
        );
}
