import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_getx_app/app/data/models/space_model.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/views/custom_sidebar.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/views/dashboard_topbar.dart';
import 'package:get/get.dart';

class StudentSpacePaymentView extends StatefulWidget {
  const StudentSpacePaymentView({
    super.key,
    required this.space,
    required this.plan,
    required this.startDate,
    required this.startTime,
  });

  final Space space;
  final String plan;
  final DateTime startDate;
  final TimeOfDay startTime;

  @override
  State<StudentSpacePaymentView> createState() =>
      _StudentSpacePaymentViewState();
}

class _StudentSpacePaymentViewState extends State<StudentSpacePaymentView> {
  final TextEditingController _cardHolderController =
      TextEditingController(text: '');
  final TextEditingController _cardNumberController =
      TextEditingController(text: '');
  final TextEditingController _expiryController =
      TextEditingController(text: '');
  final TextEditingController _cvcController = TextEditingController(text: '');

  @override
  void dispose() {
    _cardHolderController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF0F8),
      body: Row(
        children: [
          const CustomSidebar(),
          Expanded(
            child: Column(
              children: [
                const DashboardTopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 26, 24, 30),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 940),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildPageTitle(),
                            const SizedBox(height: 20),
                            _buildSteps(),
                            const SizedBox(height: 20),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final compact = constraints.maxWidth < 860;
                                if (compact) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildPaymentCard(),
                                      const SizedBox(height: 16),
                                      _buildBillingSummary(),
                                    ],
                                  );
                                }

                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        flex: 63, child: _buildPaymentCard()),
                                    const SizedBox(width: 18),
                                    Expanded(
                                        flex: 37,
                                        child: _buildBillingSummary()),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildPageTitle() {
    final width = MediaQuery.of(context).size.width;
    final titleSize = width < 900 ? 34.0 : 46.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            InkWell(
              onTap: Get.back,
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.all(6),
                child:
                    Icon(Icons.arrow_back, size: 18, color: Color(0xFF334155)),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Finaliser votre reservation',
              style: TextStyle(
                fontSize: titleSize,
                height: 1.0,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Espace : ${widget.space.name}',
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSteps() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _stepCircleDone(),
          _stepLine(active: true),
          _stepCircle(2, true),
          _stepLine(active: false),
          _stepCircle(3, false),
        ],
      ),
    );
  }

  Widget _stepCircleDone() {
    return Container(
      width: 31,
      height: 31,
      decoration: const BoxDecoration(
        color: Color(0xFF1664FF),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.check_rounded, size: 18, color: Colors.white),
    );
  }

  Widget _stepCircle(int index, bool active) {
    return Container(
      width: 31,
      height: 31,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF1664FF) : const Color(0xFFE2E8F0),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$index',
          style: TextStyle(
            color: active ? Colors.white : const Color(0xFF64748B),
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _stepLine({required bool active}) {
    return Container(
      width: 56,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: active ? const Color(0xFF1664FF) : const Color(0xFFE2E8F0),
    );
  }

  Widget _buildPaymentCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDCE4EF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PAIEMENT SECURISE',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          height: 1.0,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Vos donnees sont cryptees et protegees.',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F1FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    color: Color(0xFF60A5FA),
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('Nom sur la carte'),
                const SizedBox(height: 6),
                _textInput(
                  controller: _cardHolderController,
                  hint: 'Ex. Jean Dupont',
                ),
                const SizedBox(height: 10),
                _label('Numero de carte'),
                const SizedBox(height: 6),
                _textInput(
                  controller: _cardNumberController,
                  hint: '6546 8415 6164 6846',
                  prefix: const Icon(Icons.credit_card,
                      size: 16, color: Color(0xFF64748B)),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(16),
                    _CardNumberFormatter(),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label("Date d'expiration"),
                          const SizedBox(height: 6),
                          _textInput(
                            controller: _expiryController,
                            hint: 'MM/AA',
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                              _ExpiryDateFormatter(),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('CVC'),
                          const SizedBox(height: 6),
                          _textInput(
                            controller: _cvcController,
                            hint: '***',
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(3),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBFCFE),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      _brandMastercard(),
                      const SizedBox(width: 10),
                      _brandVisa(),
                      const Spacer(),
                      const Text(
                        'PAIEMENT CRYPTE SSL 256 BITS',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 9,
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
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                TextButton(
                  onPressed: Get.back,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF0F172A),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text("Modifier l'offre"),
                ),
                const Spacer(),
                SizedBox(
                  width: 236,
                  height: 42,
                  child: ElevatedButton(
                    onPressed: _pay,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF78A8E8),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.credit_card_outlined, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Payer ${_priceLabel()}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
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

  Widget _buildBillingSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DETAILS FACTURATION',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF64748B),
              letterSpacing: 0.6,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          _detailRow('Offre :', _planLabel()),
          const SizedBox(height: 10),
          _detailRow('Duree :', _durationLabel()),
          const SizedBox(height: 10),
          _detailRow('Debut :', _formatLongDate(widget.startDate)),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                'TOTAL',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.w800,
                  fontSize: 32,
                ),
              ),
              const Spacer(),
              Text(
                _priceLabel(),
                style: const TextStyle(
                  color: Color(0xFF1664FF),
                  fontWeight: FontWeight.w800,
                  fontSize: 42,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          textAlign: TextAlign.right,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF0F172A),
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _textInput({
    required TextEditingController controller,
    required String hint,
    Widget? prefix,
    TextAlign textAlign = TextAlign.left,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFFFBFCFE),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: controller,
        textAlign: textAlign,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: const TextStyle(
          color: Color(0xFF0F172A),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: prefix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        ),
      ),
    );
  }

  Widget _brandMastercard() {
    return Row(
      children: [
        SizedBox(
          width: 18,
          height: 12,
          child: Stack(
            children: const [
              Positioned(
                left: 0,
                child: CircleAvatar(
                  radius: 6,
                  backgroundColor: Color(0xFFEA4335),
                ),
              ),
              Positioned(
                right: 0,
                child: CircleAvatar(
                  radius: 6,
                  backgroundColor: Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 4),
        const Text(
          'mastercard',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _brandVisa() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Text(
        'visa',
        style: TextStyle(
          color: Color(0xFF1E40AF),
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  void _pay() {
    Get.snackbar(
      'Paiement',
      'Paiement initie pour ${widget.space.name} (${_priceLabel()})',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      backgroundColor: const Color(0xFF0F172A),
      colorText: Colors.white,
    );
  }

  String _planLabel() {
    if (widget.plan == 'monthly') return 'Abonnement Mensuel';
    return 'Reservation Ponctuelle';
  }

  String _durationLabel() {
    if (widget.plan == 'monthly') return '30 Jours';
    return '1 Heure';
  }

  String _priceLabel() {
    final code = _currencyCode(widget.space.currency);
    final amount = widget.plan == 'monthly'
        ? widget.space.monthlyRate
        : widget.space.hourlyRate;

    if (amount <= 0) return '-- $code';
    return '${amount.toStringAsFixed(0)} $code';
  }

  static String _currencyCode(String currency) {
    final normalized = currency.trim().toUpperCase();
    if (normalized == 'TND') return 'DT';
    return normalized.isEmpty ? 'DT' : normalized;
  }

  String _formatLongDate(DateTime date) {
    const months = [
      'janv',
      'fevr',
      'mars',
      'avr',
      'mai',
      'juin',
      'juil',
      'aout',
      'sept',
      'oct',
      'nov',
      'dec',
    ];

    final day = date.day.toString().padLeft(2, '0');
    final month = months[(date.month - 1).clamp(0, months.length - 1)];
    return '$day $month ${date.year}';
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final trimmed = digits.length > 16 ? digits.substring(0, 16) : digits;

    final buffer = StringBuffer();
    for (var i = 0; i < trimmed.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(trimmed[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final trimmed = digits.length > 4 ? digits.substring(0, 4) : digits;

    var formatted = trimmed;
    if (trimmed.length > 2) {
      formatted = '${trimmed.substring(0, 2)}/${trimmed.substring(2)}';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
