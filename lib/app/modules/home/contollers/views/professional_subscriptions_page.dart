import 'package:flutter/material.dart';

class ProfessionalSubscriptionsPage extends StatefulWidget {
  const ProfessionalSubscriptionsPage({super.key});

  @override
  State<ProfessionalSubscriptionsPage> createState() =>
      _ProfessionalSubscriptionsPageState();
}

class _ProfessionalSubscriptionsPageState
    extends State<ProfessionalSubscriptionsPage> {
  bool _annualBilling = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF1F5F9),
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
      child: Column(
        children: [
          _buildHero(),
          const SizedBox(height: 22),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final contentWidth =
                    constraints.maxWidth > 1020 ? 1020.0 : constraints.maxWidth;
                final columns = contentWidth >= 980
                    ? 3
                    : contentWidth >= 660
                        ? 2
                        : 1;
                final cardWidth =
                    (contentWidth - ((columns - 1) * 18)) / columns;

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        width: contentWidth,
                        child: Wrap(
                          spacing: 18,
                          runSpacing: 18,
                          alignment: WrapAlignment.center,
                          children: [
                            SizedBox(
                              width: cardWidth,
                              child: _PlanCard(
                                name: 'Starter',
                                subtitle:
                                    'Ideal pour les freelances et independants',
                                monthlyPrice: 49,
                                annualBilling: _annualBilling,
                                icon: Icons.bolt,
                                iconColor: const Color(0xFF3B82F6),
                                headerTint: const Color(0xFFF8FAFC),
                                borderColor: const Color(0xFFE2E8F0),
                                highlighted: false,
                                buttonLabel: 'Choisir Starter',
                                buttonPrimary: false,
                                features: const [
                                  '5 jours/mois d\'acces coworking',
                                  '2 heures de salle de reunion',
                                  'Acces Wi-Fi haut debit',
                                  'Espace cafe inclus',
                                  'Adresse postale professionnelle',
                                ],
                                bonus: const ['Support par email'],
                                accent: const Color(0xFF3B82F6),
                              ),
                            ),
                            SizedBox(
                              width: cardWidth,
                              child: _PlanCard(
                                name: 'Business',
                                subtitle:
                                    'Ideal pour les professionnels actifs',
                                monthlyPrice: 129,
                                annualBilling: _annualBilling,
                                icon: Icons.business_center_rounded,
                                iconColor: const Color(0xFF2563EB),
                                headerTint: const Color(0xFFF5F9FF),
                                borderColor: const Color(0xFF93C5FD),
                                highlighted: true,
                                badgeText: 'Populaire',
                                buttonLabel: 'Choisir Business',
                                buttonPrimary: true,
                                features: const [
                                  'Acces illimite coworking',
                                  '10 heures de salle de reunion',
                                  'Acces Wi-Fi haut debit',
                                  'Cafe & boissons illimites',
                                  'Adresse postale professionnelle',
                                  'Casier personnel securise',
                                  'Impression (100 pages/mois)',
                                ],
                                bonus: const [
                                  'Support prioritaire',
                                  'Acces formations continues',
                                ],
                                accent: const Color(0xFF2563EB),
                              ),
                            ),
                            SizedBox(
                              width: cardWidth,
                              child: _PlanCard(
                                name: 'Premium',
                                subtitle: 'L\'experience coworking complete',
                                monthlyPrice: 249,
                                annualBilling: _annualBilling,
                                icon: Icons.workspace_premium_outlined,
                                iconColor: const Color(0xFFF59E0B),
                                headerTint: const Color(0xFFFFF7ED),
                                borderColor: const Color(0xFFE2E8F0),
                                highlighted: false,
                                badgeText: 'Meilleure valeur',
                                badgeColor: const Color(0xFFF59E0B),
                                buttonLabel: 'Choisir Premium',
                                buttonPrimary: false,
                                features: const [
                                  'Acces illimite 24h/24 7j/7',
                                  'Salles de reunion illimitees',
                                  'Wi-Fi fibre dediee',
                                  'Cafe, the & snacks illimites',
                                  'Adresse postale + domiciliation',
                                  'Bureau prive dedie',
                                  'Impression illimitee',
                                  'Acces a tous les equipements',
                                ],
                                bonus: const [
                                  'Support VIP dedie',
                                  'Acces formations continues',
                                  'Invites gratuits (2/mois)',
                                  'Parking inclus',
                                ],
                                accent: const Color(0xFFF59E0B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 18,
                        runSpacing: 8,
                        children: [
                          _GuaranteeItem(label: 'Paiement 100% securise'),
                          _GuaranteeItem(label: 'Sans engagement'),
                          _GuaranteeItem(label: 'Annulation a tout moment'),
                          _GuaranteeItem(
                              label: 'Facture mensuelle automatique'),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 820),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF2FF),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, size: 12, color: Color(0xFF2563EB)),
                SizedBox(width: 6),
                Text(
                  'Abonnements Professionnels',
                  style: TextStyle(
                    color: Color(0xFF2563EB),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Choisissez votre espace de travail',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w800,
              fontSize: 48,
              height: 1.08,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Des formules flexibles adaptees a votre activite. Changez ou annulez a tout\nmoment.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF64748B),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 10),
          _buildBillingToggle(),
        ],
      ),
    );
  }

  Widget _buildBillingToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Mensuel',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: () {
            setState(() {
              _annualBilling = !_annualBilling;
            });
          },
          borderRadius: BorderRadius.circular(999),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            width: 36,
            height: 20,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: _annualBilling
                  ? const Color(0xFFBBF7D0)
                  : const Color(0xFFD1D5DB),
              borderRadius: BorderRadius.circular(999),
            ),
            alignment:
                _annualBilling ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'Annuel',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFDCFCE7),
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Text(
            '-17%',
            style: TextStyle(
              color: Color(0xFF16A34A),
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final int monthlyPrice;
  final bool annualBilling;
  final IconData icon;
  final Color iconColor;
  final Color headerTint;
  final Color borderColor;
  final bool highlighted;
  final String? badgeText;
  final Color? badgeColor;
  final String buttonLabel;
  final bool buttonPrimary;
  final List<String> features;
  final List<String> bonus;
  final Color accent;

  const _PlanCard({
    required this.name,
    required this.subtitle,
    required this.monthlyPrice,
    required this.annualBilling,
    required this.icon,
    required this.iconColor,
    required this.headerTint,
    required this.borderColor,
    required this.highlighted,
    this.badgeText,
    this.badgeColor,
    required this.buttonLabel,
    required this.buttonPrimary,
    required this.features,
    required this.bonus,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final displayedPrice =
        annualBilling ? ((monthlyPrice * 12 * 0.83).round()) : monthlyPrice;

    return Container(
      constraints: const BoxConstraints(minHeight: 580, maxHeight: 580),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: highlighted ? 1.4 : 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            decoration: BoxDecoration(
              color: headerTint,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Icon(icon, color: iconColor, size: 16),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.w800,
                          fontSize: 30,
                          height: 0.95,
                        ),
                      ),
                    ),
                    if (badgeText != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeColor ?? const Color(0xFF0B6BFF),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          badgeText!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 9.5,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 10.5,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$displayedPrice',
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.w900,
                        fontSize: 40,
                        height: 0.9,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'DT / ${annualBilling ? 'an' : 'mois'}',
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Column(
                children: [
                  ...features.map(
                    (item) => _FeatureRow(
                      text: item,
                      color: accent,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Divider(height: 1, color: Color(0xFFE5E7EB)),
                  const SizedBox(height: 6),
                  ...bonus.map(
                    (item) => _FeatureRow(
                      text: item,
                      color: accent,
                      bonus: true,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 38,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonPrimary
                            ? const Color(0xFF0B6BFF)
                            : const Color(0xFFE5E7EB),
                        foregroundColor: buttonPrimary
                            ? Colors.white
                            : const Color(0xFF111827),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        buttonLabel,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
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
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String text;
  final Color color;
  final bool bonus;

  const _FeatureRow({
    required this.text,
    required this.color,
    this.bonus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            bonus ? Icons.star_border_rounded : Icons.check_rounded,
            size: bonus ? 13 : 14,
            color: bonus ? color.withValues(alpha: 0.92) : color,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color:
                    bonus ? const Color(0xFF64748B) : const Color(0xFF334155),
                fontSize: 12,
                fontWeight: bonus ? FontWeight.w500 : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuaranteeItem extends StatelessWidget {
  final String label;

  const _GuaranteeItem({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check, size: 15, color: Color(0xFF22C55E)),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
