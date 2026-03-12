import 'package:flutter/material.dart';
import 'package:flutter_getx_app/app/modules/reservation/controllers/reservation_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// Modal de réservation affiché lors du clic sur un espace
class ReservationModal extends StatelessWidget {
  final String spaceSlug;

  const ReservationModal({
    super.key,
    required this.spaceSlug,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ReservationController());

    // Charger les données de l'espace
    controller.loadSpaceBySlug(spaceSlug);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 700),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(controller),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.selectedSpace.value == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 48, color: Color(0xFFEF4444)),
                        const SizedBox(height: 16),
                        Text(
                          controller.errorMessage.value.isNotEmpty
                              ? controller.errorMessage.value
                              : 'Espace non trouvé',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: _buildContent(controller),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ReservationController controller) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF3B82F6),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          const Icon(Icons.event_seat, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Obx(() {
              final space = controller.selectedSpace.value;
              return Text(
                space?.name ?? 'Réservation d\'espace',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              );
            }),
          ),
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.close, color: Colors.white),
            tooltip: 'Fermer',
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ReservationController controller) {
    final space = controller.selectedSpace.value!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Informations de l'espace
        _buildSpaceInfo(space),
        const SizedBox(height: 24),

        // Équipements
        _buildEquipments(controller),
        const SizedBox(height: 24),

        // Sélection de date
        _buildDatePicker(controller),
        const SizedBox(height: 20),

        // Sélection horaire
        _buildTimePickers(controller),
        const SizedBox(height: 20),

        // Nombre de participants
        _buildParticipantsSelector(controller, space.capacity),
        const SizedBox(height: 20),

        // Notes (optionnel)
        _buildNotesField(controller),
        const SizedBox(height: 24),

        // Résumé et coût
        _buildSummary(controller),
        const SizedBox(height: 24),

        // Message d'erreur
        Obx(() {
          if (controller.errorMessage.value.isNotEmpty) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Color(0xFFEF4444)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      controller.errorMessage.value,
                      style: const TextStyle(
                        color: Color(0xFFDC2626),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        }),

        // Bouton de réservation
        _buildReserveButton(controller),
      ],
    );
  }

  Widget _buildSpaceInfo(space) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildInfoChip(
                icon: Icons.people_outline,
                label: 'Capacité: ${space.capacity}',
              ),
              const SizedBox(width: 12),
              _buildInfoChip(
                icon: Icons.location_on_outlined,
                label: space.location ?? 'Non spécifié',
              ),
            ],
          ),
          if (space.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              space.description,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF3B82F6)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF334155),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipments(ReservationController controller) {
    return Obx(() {
      final equipments = controller.equipments;

      if (equipments.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Équipements disponibles',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: equipments.map((equipment) {
              return Chip(
                avatar: const Icon(Icons.devices, size: 18),
                label: Text(equipment.name),
                backgroundColor: const Color(0xFFDCFCE7),
                labelStyle: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF166534),
                ),
              );
            }).toList(),
          ),
        ],
      );
    });
  }

  Widget _buildDatePicker(ReservationController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date de réservation',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        Obx(() {
          final date = controller.selectedDate.value;
          final formatted =
              DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(date);

          return InkWell(
            onTap: () async {
              final picked = await Get.dialog<DateTime>(
                DatePickerDialog(
                  initialDate: date,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                ),
              );

              if (picked != null) {
                controller.updateSelectedDate(picked);
              }
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFCBD5E1)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 20, color: Color(0xFF3B82F6)),
                  const SizedBox(width: 12),
                  Text(
                    formatted,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF334155),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTimePickers(ReservationController controller) {
    return Row(
      children: [
        Expanded(
          child: _buildTimePicker(
            label: 'Heure de début',
            controller: controller,
            isStartTime: true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildTimePicker(
            label: 'Heure de fin',
            controller: controller,
            isStartTime: false,
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker({
    required String label,
    required ReservationController controller,
    required bool isStartTime,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        Obx(() {
          final time = isStartTime
              ? controller.startTime.value
              : controller.endTime.value;
          final formatted = time.format(Get.context!);

          return InkWell(
            onTap: () async {
              final picked = await showTimePicker(
                context: Get.context!,
                initialTime: time,
              );

              if (picked != null) {
                if (isStartTime) {
                  controller.updateStartTime(picked);
                } else {
                  controller.updateEndTime(picked);
                }
              }
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFCBD5E1)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time,
                      size: 20, color: Color(0xFF3B82F6)),
                  const SizedBox(width: 12),
                  Text(
                    formatted,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF334155),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildParticipantsSelector(
      ReservationController controller, int maxCapacity) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nombre de participants',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        Obx(() {
          final count = controller.participants.value;

          return Row(
            children: [
              IconButton(
                onPressed: count > 1
                    ? () => controller.updateParticipants(count - 1)
                    : null,
                icon: const Icon(Icons.remove_circle_outline),
                color: const Color(0xFF3B82F6),
              ),
              Container(
                width: 60,
                padding: const EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              IconButton(
                onPressed: count < maxCapacity
                    ? () => controller.updateParticipants(count + 1)
                    : null,
                icon: const Icon(Icons.add_circle_outline),
                color: const Color(0xFF3B82F6),
              ),
              const SizedBox(width: 8),
              Text(
                '/ $maxCapacity max',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildNotesField(ReservationController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notes (optionnel)',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          maxLines: 3,
          onChanged: (value) => controller.updateNotes(value),
          decoration: InputDecoration(
            hintText: 'Ajoutez des notes pour votre réservation...',
            hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummary(ReservationController controller) {
    return Obx(() {
      final duration = controller.durationInHours;
      final cost = controller.estimatedCost;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F9FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFBAE6FD)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Durée',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${duration.toStringAsFixed(1)}h',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0369A1),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'Coût estimé',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${cost.toStringAsFixed(2)} TND',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0369A1),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildReserveButton(ReservationController controller) {
    return Obx(() {
      final isLoading = controller.isLoading.value;

      return SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: isLoading
              ? null
              : () async {
                  final success = await controller.submitReservation();

                  if (success) {
                    Get.back();
                    Get.snackbar(
                      'Succès',
                      'Votre réservation a été créée avec succès',
                      backgroundColor: const Color(0xFF10B981),
                      colorText: Colors.white,
                      snackPosition: SnackPosition.TOP,
                      duration: const Duration(seconds: 3),
                    );
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3B82F6),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Réserver l\'espace',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      );
    });
  }
}
