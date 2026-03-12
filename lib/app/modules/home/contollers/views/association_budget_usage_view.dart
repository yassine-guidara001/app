import 'package:flutter/material.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/association_budget_controller.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/views/custom_sidebar.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/views/dashboard_topbar.dart';
import 'package:get/get.dart';

class AssociationBudgetUsageView extends GetView<AssociationBudgetController> {
  const AssociationBudgetUsageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDCE5F1),
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
                        padding: const EdgeInsets.fromLTRB(22, 20, 22, 26),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1180),
                            child: Obx(
                              () => _BudgetLayout(
                                isLoading: controller.isLoading.value,
                                errorMessage: controller.errorMessage.value,
                                currentBalance: controller.totalBalance,
                                currency: controller.currency,
                              ),
                            ),
                          ),
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
}

class _BudgetLayout extends StatelessWidget {
  const _BudgetLayout({
    required this.isLoading,
    required this.errorMessage,
    required this.currentBalance,
    required this.currency,
  });

  final bool isLoading;
  final String errorMessage;
  final double currentBalance;
  final String currency;

  static const double _maxHours = 200;

  @override
  Widget build(BuildContext context) {
    const consumedHours = 0.0;
    const savings = 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        if (errorMessage.isNotEmpty) ...[
          const SizedBox(height: 14),
          _ErrorBanner(message: errorMessage),
        ],
        const SizedBox(height: 18),
        _buildTopCards(
          currentBalance: currentBalance,
          consumedHours: consumedHours,
          maxHours: _maxHours,
          savings: savings,
          currency: currency,
          isLoading: isLoading,
        ),
        const SizedBox(height: 22),
        _buildBottomPanels(context),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 900;

    const titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BUDGET & UTILISATION',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w900,
            color: Color(0xFF020617),
            height: 0.95,
            letterSpacing: -0.9,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Gérez vos fonds et suivez la consommation d\'heures de votre association.',
          style: TextStyle(
            color: Color(0xFF556176),
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );

    final actionButton = ElevatedButton.icon(
      onPressed: () {
        Get.snackbar(
          'Budget',
          'Ajustement du solde bientot disponible.',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
      icon: const Icon(Icons.add, size: 18),
      label: const Text('AJUSTER LE SOLDE'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0B6BFF),
        foregroundColor: Colors.white,
        elevation: 6,
        shadowColor: const Color(0x3A0B6BFF),
        padding: EdgeInsets.symmetric(
          horizontal: isNarrow ? 14 : 18,
          vertical: 12,
        ),
        textStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );

    if (isNarrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleBlock,
          const SizedBox(height: 14),
          actionButton,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(child: titleBlock),
        const SizedBox(width: 12),
        actionButton,
      ],
    );
  }

  Widget _buildTopCards({
    required double currentBalance,
    required double consumedHours,
    required double maxHours,
    required double savings,
    required String currency,
    required bool isLoading,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isStacked = constraints.maxWidth < 1080;

        final cardOne = _MetricCard(
          label: 'SOLDE ACTUEL',
          value: '${_formatMoney(currentBalance)} $currency',
          subtitle: 'Fonds disponibles pour vos réservations',
          icon: Icons.account_balance_wallet_outlined,
          iconColor: const Color(0xFF0B6BFF),
          iconBackground: const Color(0xFFE7F0FF),
          shapeBackground: const Color(0xFFDDE8F9),
          isLoading: isLoading,
        );

        final cardTwo = _MetricCard(
          label: 'CONSOMMATION',
          value: '${consumedHours.toStringAsFixed(0)}h',
          valueTail: '/${maxHours.toStringAsFixed(0)}h',
          subtitle: null,
          icon: Icons.schedule_outlined,
          iconColor: const Color(0xFF1E73FF),
          iconBackground: const Color(0xFFE8F0FF),
          shapeBackground: const Color(0xFFDCE8FA),
          progress: maxHours <= 0 ? 0 : (consumedHours / maxHours).clamp(0, 1),
          isLoading: isLoading,
        );

        final cardThree = _MetricCard(
          label: 'ECONOMIES',
          value: '${_formatMoney(savings)} $currency',
          subtitle: 'Grâce aux tarifs préférentiels Sunspace',
          icon: Icons.bar_chart_rounded,
          iconColor: const Color(0xFF16A34A),
          iconBackground: const Color(0xFFDDF7E8),
          shapeBackground: const Color(0xFFD8F0E1),
          isLoading: isLoading,
        );

        if (isStacked) {
          return Column(
            children: [
              cardOne,
              const SizedBox(height: 12),
              cardTwo,
              const SizedBox(height: 12),
              cardThree,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: cardOne),
            const SizedBox(width: 14),
            Expanded(child: cardTwo),
            const SizedBox(width: 14),
            Expanded(child: cardThree),
          ],
        );
      },
    );
  }

  Widget _buildBottomPanels(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 1120;

        final monthly = _LargePanel(
          child: Column(
            children: const [
              _PanelHeader(
                title: 'ACTIVITÉ MENSUELLE',
                trailing: _PeriodDropdown(),
              ),
              SizedBox(height: 18),
              Expanded(child: _MonthlyPlaceholder()),
            ],
          ),
        );

        final journal = _LargePanel(
          child: Column(
            children: const [
              _PanelHeader(
                title: 'JOURNAL FINANCIER',
                trailing: _SeeAllAction(),
              ),
              SizedBox(height: 20),
              Expanded(child: _JournalPlaceholder()),
            ],
          ),
        );

        if (stacked) {
          return Column(
            children: [
              SizedBox(height: 370, child: monthly),
              const SizedBox(height: 14),
              SizedBox(height: 370, child: journal),
            ],
          );
        }

        return SizedBox(
          height: 370,
          child: Row(
            children: [
              Expanded(flex: 50, child: monthly),
              const SizedBox(width: 14),
              Expanded(flex: 50, child: journal),
            ],
          ),
        );
      },
    );
  }

  static String _formatMoney(double value) {
    return value.toStringAsFixed(3).replaceAll('.', ',');
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.shapeBackground,
    this.valueTail,
    this.subtitle,
    this.progress,
    required this.isLoading,
  });

  final String label;
  final String value;
  final String? valueTail;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final Color shapeBackground;
  final double? progress;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 188,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFCFD8E5)),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -26,
            right: -26,
            child: Container(
              width: 98,
              height: 98,
              decoration: BoxDecoration(
                color: shapeBackground,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Positioned(
            right: 20,
            top: 20,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, size: 19, color: iconColor),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF9AA4B2),
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 28),
                isLoading
                    ? Container(
                        width: 150,
                        height: 22,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8EDF6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            value,
                            style: const TextStyle(
                              color: Color(0xFF020617),
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                              height: 0.95,
                              letterSpacing: -0.8,
                            ),
                          ),
                          if (valueTail != null)
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 4, bottom: 5),
                              child: Text(
                                valueTail!,
                                style: const TextStyle(
                                  color: Color(0xFFA1A8B3),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                const Spacer(),
                if (progress != null) ...[
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBEEF4),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B6BFF),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  Text(
                    subtitle ?? '',
                    style: const TextStyle(
                      color: Color(0xFF9AA4B2),
                      fontStyle: FontStyle.italic,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LargePanel extends StatelessWidget {
  const _LargePanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFCFD8E5)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 18),
      child: child,
    );
  }
}

class _PanelHeader extends StatelessWidget {
  const _PanelHeader({required this.title, required this.trailing});

  final String title;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF020617),
              fontSize: 34,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              height: 1,
              letterSpacing: -0.7,
            ),
          ),
        ),
        trailing,
      ],
    );
  }
}

class _PeriodDropdown extends StatefulWidget {
  const _PeriodDropdown();

  @override
  State<_PeriodDropdown> createState() => _PeriodDropdownState();
}

class _PeriodDropdownState extends State<_PeriodDropdown> {
  static const List<String> _options = ['DERNIERS 3 MOIS', 'ANNÉE 2026'];
  String _selected = 'ANNÉE 2026';

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      initialValue: _selected,
      onSelected: (value) => setState(() => _selected = value),
      offset: const Offset(0, 42),
      color: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      constraints: const BoxConstraints(minWidth: 190),
      itemBuilder: (_) => _options.map((option) {
        final isSelected = option == _selected;
        return PopupMenuItem<String>(
          value: option,
          padding: EdgeInsets.zero,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF0B6BFF) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              option,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF020617),
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.9,
              ),
            ),
          ),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F3F7),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFDCE0E8)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _selected,
              style: const TextStyle(
                color: Color(0xFF020617),
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.9,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: Color(0xFF020617),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeeAllAction extends StatelessWidget {
  const _SeeAllAction();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.filter_list_alt, size: 16, color: Color(0xFF111827)),
        SizedBox(width: 6),
        Text(
          'Tout voir',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _MonthlyPlaceholder extends StatelessWidget {
  const _MonthlyPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        Row(
          children: const [
            Expanded(
              child: Center(
                child: Text(
                  'JAN',
                  style: TextStyle(
                    color: Color(0xFFB0B8C3),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  'FEV',
                  style: TextStyle(
                    color: Color(0xFFB0B8C3),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  'MAR',
                  style: TextStyle(
                    color: Color(0xFFB0B8C3),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _JournalPlaceholder extends StatelessWidget {
  const _JournalPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand();
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 18, color: Color(0xFFB91C1C)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFF991B1B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
