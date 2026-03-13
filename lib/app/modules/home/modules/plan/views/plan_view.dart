import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/space_model.dart';
import '../controllers/plan_controller.dart';
import 'widgets/reservation_modal.dart';

class PlanView extends StatelessWidget {
  const PlanView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PlanController());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Plan du Coworking',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        iconTheme: const IconThemeData(color: Color(0xFF1F2937)),
      ),
      body: Stack(
        children: [
          // Plan SVG avec zones cliquables
          SingleChildScrollView(
            child: Container(
              color: const Color(0xFFF9FAFB),
              child: Center(
                child: Stack(
                  children: [
                    // SVG du plan
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Image.asset(
                        'assets/plan_original.png',
                        width: 1200,
                        height: 800,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                        errorBuilder: (BuildContext context, _, __) {
                          return Container(
                            width: 1200,
                            height: 800,
                            color: const Color(0xFFE5E7EB),
                            child: const Center(
                              child: Text(
                                'Chargement du plan...',
                                style: TextStyle(color: Color(0xFF9CA3AF)),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Zones cliquables pour chaque espace
                    ...planSpaces.map(
                      (space) => Positioned(
                        left: space.left,
                        top: space.top,
                        child: GestureDetector(
                          onTap: () {
                            controller.selectSpace(space);
                            _showReservationModal(context, controller);
                          },
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: Container(
                              width: space.width,
                              height: space.height,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border.all(
                                  color: Colors.transparent,
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Modale de réservation overlay
          _ReservationModalOverlay(controller: controller),
        ],
      ),
    );
  }

  void _showReservationModal(BuildContext context, PlanController controller) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) => const ReservationModal(),
    );
  }
}

class _ReservationModalOverlay extends StatelessWidget {
  const _ReservationModalOverlay({required this.controller});

  final PlanController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.isReservationModalOpen.value) {
        return const SizedBox();
      }
      return GestureDetector(
        onTap: () => controller.closeReservationModal(),
        child: Container(color: Colors.transparent),
      );
    });
  }
}
