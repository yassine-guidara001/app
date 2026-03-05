import 'package:flutter/material.dart';
import 'package:flutter_getx_app/app/data/models/course_model.dart';
import 'package:flutter_getx_app/app/data/services/courses_api.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/views/custom_sidebar.dart';
import 'package:flutter_getx_app/models/assignment_model.dart';
import 'package:flutter_getx_app/services/assignments_api.dart';
import 'package:flutter_getx_app/views/assignments/assignment_details_page.dart';
import 'package:get/get.dart';

class StudentCourseAccessPage extends StatefulWidget {
  final Course course;
  final int initialTab;

  const StudentCourseAccessPage({
    super.key,
    required this.course,
    this.initialTab = 0,
  });

  @override
  State<StudentCourseAccessPage> createState() =>
      _StudentCourseAccessPageState();
}

class _StudentCourseAccessPageState extends State<StudentCourseAccessPage> {
  static const Color _bg = Color(0xFFF1F5F9);
  static const Color _border = Color(0xFFE2E8F0);
  static const Color _primary = Color(0xFF1D6FF2);

  final AssignmentsApi _assignmentsApi = AssignmentsApi();
  final CoursesApi _coursesApi = CoursesApi();
  final TextEditingController _searchCtrl = TextEditingController();

  late int _activeTab;
  bool _isLoadingAssignments = false;
  bool _isLoadingCourseData = false;
  String _assignmentsError = '';
  List<Assignment> _todoAssignments = <Assignment>[];
  Course? _loadedCourse;

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialTab.clamp(0, 1);

    // Charger les données du cours au démarrage
    _loadCourseData();

    if (_activeTab == 1) {
      _loadTodoAssignments();
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCourseData() async {
    setState(() {
      _isLoadingCourseData = true;
    });

    try {
      // Récupérer les détails complets du cours
      if (widget.course.id > 0) {
        final courseDetails = await _coursesApi.getCourseById(widget.course.id);
        if (!mounted) return;
        setState(() {
          _loadedCourse = courseDetails;
        });
      }
    } catch (e) {
      // Ignorer les erreurs, utiliser les données initiales du cours
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCourseData = false;
        });
      }
    }
  }

  Future<void> _loadTodoAssignments() async {
    setState(() {
      _isLoadingAssignments = true;
      _assignmentsError = '';
    });

    try {
      // 1. Récupérer les assignments du cours
      final result = await _assignmentsApi.getAssignmentsForCourse(
        courseId: widget.course.id > 0 ? widget.course.id : null,
        courseDocumentId: widget.course.documentId.trim().isNotEmpty
            ? widget.course.documentId.trim()
            : null,
        onlyTodo: true,
      );

      result.sort((a, b) => a.dueDate.compareTo(b.dueDate));

      // 2. Pour chaque assignment, récupérer les submissions
      for (final assignment in result) {
        if (assignment.id > 0) {
          // Faire une requête GET séparée pour chaque assignment
          await _assignmentsApi.getSubmissionsForAssignment(assignment.id);
        }
      }

      if (!mounted) return;
      setState(() {
        _todoAssignments = result;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _assignmentsError = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingAssignments = false;
        });
      }
    }
  }

  void _switchTab(int tab) {
    if (_activeTab == tab) return;

    setState(() {
      _activeTab = tab;
    });

    if (tab == 1 && _todoAssignments.isEmpty && !_isLoadingAssignments) {
      _loadTodoAssignments();
    }
  }

  List<Assignment> get _visibleAssignments {
    final query = _searchCtrl.text.trim().toLowerCase();
    if (query.isEmpty) return _todoAssignments;

    return _todoAssignments.where((assignment) {
      return assignment.title.toLowerCase().contains(query) ||
          assignment.instructions.toLowerCase().contains(query);
    }).toList();
  }

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
                _buildTopBar(),
                Expanded(
                  child: Column(
                    children: [
                      _buildHeader(context),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: const BoxDecoration(
                                  border: Border(
                                    top: BorderSide(color: _border),
                                    right: BorderSide(color: _border),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    _buildTabs(),
                                    Expanded(
                                      child: _activeTab == 0
                                          ? _buildLessonsPlaceholder()
                                          : _buildAssignmentsPanel(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              width: 210,
                              decoration: const BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: _border),
                                ),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.fromLTRB(16, 18, 16, 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 3,
                                          backgroundColor: Color(0xFF2563EB),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'PROGRESSION',
                                          style: TextStyle(
                                            color: Color(0xFF111827),
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ],
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
        border: Border(bottom: BorderSide(color: _border)),
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
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios_new,
                size: 14, color: Color(0xFF6B7280)),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            splashRadius: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.course.title,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'SESSION ACTIVE',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 10,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          const Text(
            'Instructeur',
            style: TextStyle(
              color: Color(0xFF111827),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFE5F0FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBFD7FF)),
            ),
            child: Text(
              widget.course.level,
              style: const TextStyle(
                color: Color(0xFF2563EB),
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      height: 44,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: _border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => _switchTab(0),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(
                    right: const BorderSide(color: _border),
                    bottom: BorderSide(
                      color: _activeTab == 0
                          ? const Color(0xFF2563EB)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: const Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.menu_book_outlined,
                          size: 14, color: Color(0xFF111827)),
                      SizedBox(width: 6),
                      Text(
                        'Leçons',
                        style: TextStyle(
                          color: Color(0xFF111827),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => _switchTab(1),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: _activeTab == 1
                          ? const Color(0xFF2563EB)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.assignment_outlined,
                          size: 14, color: Color(0xFF111827)),
                      const SizedBox(width: 6),
                      const Text(
                        'Devoirs',
                        style: TextStyle(
                          color: Color(0xFF111827),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF2FF),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${_todoAssignments.length}',
                          style: const TextStyle(
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonsPlaceholder() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.menu_book_outlined, size: 56, color: Color(0xFFD1D5DB)),
          SizedBox(height: 16),
          Text(
            'Prêt à apprendre ?',
            style: TextStyle(
              color: Color(0xFF111827),
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Sélectionnez votre première leçon dans le menu\nlatéral pour débuter ce cours.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentsPanel() {
    if (_isLoadingAssignments) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_assignmentsError.trim().isNotEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_outlined,
                size: 42, color: Color(0xFF94A3B8)),
            const SizedBox(height: 8),
            Text(
              _assignmentsError,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _loadTodoAssignments,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    final rows = _visibleAssignments;

    if (rows.isEmpty) {
      return const Center(
        child: Text(
          'Aucun devoir à faire',
          style: TextStyle(color: Color(0xFF94A3B8)),
        ),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: _border)),
          ),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Rechercher un devoir...',
              prefixIcon: const Icon(Icons.search, size: 18),
              isDense: true,
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _border),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(14),
            itemCount: rows.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, index) {
              final assignment = rows[index];
              return _buildAssignmentCard(assignment);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAssignmentCard(Assignment assignment) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0F172A),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEAF2FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.assignment_outlined,
                      color: Color(0xFF1D6FF2), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        assignment.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF111827),
                          fontWeight: FontWeight.w700,
                          fontSize: 28,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'A rendre le ${_formatDate(assignment.dueDate)}',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${assignment.maxPoints} Points Max',
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 90,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: _border,
          ),
          SizedBox(
            width: 160,
            height: 44,
            child: ElevatedButton(
              onPressed: () {
                Get.to(() => AssignmentDetailsPage(assignment: assignment));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send_outlined, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Soumettre',
                    style: TextStyle(fontWeight: FontWeight.w700),
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
