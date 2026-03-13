import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/views/custom_sidebar.dart';
import 'package:flutter_getx_app/app/modules/home/contollers/views/dashboard_topbar.dart';
import 'package:flutter_getx_app/app/modules/home/modules/plan/models/space_model.dart';
import 'package:flutter_getx_app/app/modules/reservation/views/reservation_modal.dart';

class ReservationPage extends StatefulWidget {
  const ReservationPage({super.key});

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  static const Color _spaceHoverFill = Color(0x6634D399);
  static const Color _spaceHoverBorder = Color(0xFF34D399);
  static const Duration _hoverAnimationDuration = Duration(milliseconds: 180);

  static const Map<int, List<_RegionSegment>> _customRegions = {
    // Espace 11: forme principale + petite extension droite
    11: [
      _RegionSegment(left: 245, top: 8, width: 395, height: 175),
      _RegionSegment(left: 640, top: 110, width: 58, height: 73),
    ],
  };

  SpaceModel? _hoveredSpace;

  String _slugify(String value) {
    const Map<String, String> accents = {
      'à': 'a',
      'â': 'a',
      'ä': 'a',
      'é': 'e',
      'è': 'e',
      'ê': 'e',
      'ë': 'e',
      'î': 'i',
      'ï': 'i',
      'ô': 'o',
      'ö': 'o',
      'ù': 'u',
      'û': 'u',
      'ü': 'u',
      'ç': 'c',
    };

    String normalized = value.toLowerCase().trim();
    accents.forEach((k, v) {
      normalized = normalized.replaceAll(k, v);
    });

    normalized = normalized.replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    normalized = normalized.replaceAll(RegExp(r'^-+|-+$'), '');
    return normalized;
  }

  void openReservationModal(BuildContext context, SpaceModel space) {
    final String spaceSlug = _slugify(space.name);

    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (_) => ReservationModal(spaceSlug: spaceSlug),
    );
  }

  void _setHoveredSpace(SpaceModel? space) {
    if (_hoveredSpace?.id == space?.id) {
      return;
    }
    setState(() {
      _hoveredSpace = space;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool compact = MediaQuery.of(context).size.width < 980;

    return Scaffold(
      backgroundColor: const Color(0xFFEAF0F8),
      body: compact ? _buildCompactLayout() : _buildDesktopLayout(),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        const CustomSidebar(),
        Expanded(child: _buildMainContent()),
      ],
    );
  }

  Widget _buildCompactLayout() {
    return _buildMainContent();
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        const DashboardTopBar(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1320),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFDCE6F3)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x120F172A),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: _buildInteractivePlan(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInteractivePlan() {
    const double svgWidth = 2780;
    const double svgHeight = 1974;

    // Référentiel actuel des zones cliquables (à recalibrer ensuite si besoin)
    const double overlayBaseWidth = 1200;
    const double overlayBaseHeight = 800;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth = math.max(320, constraints.maxWidth - 24);
        final double availableHeight =
            math.max(220, constraints.maxHeight - 24);

        // Affiche le plan complet dans la carte (pas de découpe)
        final double fitScale = math.min(
          availableWidth / svgWidth,
          availableHeight / svgHeight,
        );

        final double renderedWidth = svgWidth * fitScale;
        final double renderedHeight = svgHeight * fitScale;

        final double xScale = renderedWidth / overlayBaseWidth;
        final double yScale = renderedHeight / overlayBaseHeight;
        final List<_ScaledSpaceRegion> regions =
          _buildScaledRegions(xScale, yScale);
        final _ScaledSpaceRegion? hoveredRegion = _hoveredSpace == null
          ? null
          : regions
            .where((region) => region.space.id == _hoveredSpace!.id)
            .cast<_ScaledSpaceRegion?>()
            .firstOrNull;

        return Padding(
          padding: const EdgeInsets.all(12),
          child: Center(
            child: SizedBox(
              width: renderedWidth,
              height: renderedHeight,
              child: Stack(
                children: [
                  _buildSvgLayer(renderedWidth, renderedHeight),
                  ...regions.map(
                    (region) => Positioned(
                      left: region.bounds.left,
                      top: region.bounds.top,
                      child: _InteractiveSpaceRegion(
                        width: region.bounds.width,
                        height: region.bounds.height,
                        localSegments: region.localRects,
                        isHovered: _hoveredSpace?.id == region.space.id,
                        hoverFillColor: _spaceHoverFill,
                        hoverBorderColor: _spaceHoverBorder,
                        animationDuration: _hoverAnimationDuration,
                        onHoverChanged: (isInside) {
                          if (isInside) {
                            _setHoveredSpace(region.space);
                          } else if (_hoveredSpace?.id == region.space.id) {
                            _setHoveredSpace(null);
                          }
                        },
                        onTap: () => openReservationModal(context, region.space),
                      ),
                    ),
                  ),
                  if (hoveredRegion != null)
                    _SpaceHoverCard(
                      space: _hoveredSpace!,
                      layout: hoveredRegion.layout,
                      availableWidth: renderedWidth,
                      availableHeight: renderedHeight,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSvgLayer(double width, double height) {
    return Image.asset(
      'assets/plan_original.png',
      width: width,
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      errorBuilder: (_, __, ___) => const Center(
        child: Text(
          'Chargement du plan...',
          style: TextStyle(color: Color(0xFF64748B)),
        ),
      ),
    );
  }

  List<_ScaledSpaceRegion> _buildScaledRegions(double xScale, double yScale) {
    return planSpaces.map((space) {
      final List<_RegionSegment> sourceSegments =
          _customRegions[space.id] ??
              [
                _RegionSegment(
                  left: space.left,
                  top: space.top,
                  width: space.width,
                  height: space.height,
                ),
              ];

      final List<Rect> scaled = sourceSegments
          .map(
            (segment) => Rect.fromLTWH(
              segment.left * xScale,
              segment.top * yScale,
              segment.width * xScale,
              segment.height * yScale,
            ),
          )
          .toList();

      Rect bounds = scaled.first;
      for (final Rect rect in scaled.skip(1)) {
        bounds = bounds.expandToInclude(rect);
      }

      final List<Rect> local = scaled
          .map((rect) => rect.shift(-Offset(bounds.left, bounds.top)))
          .toList();

      return _ScaledSpaceRegion(
        space: space,
        bounds: bounds,
        localRects: local,
      );
    }).toList();
  }
}

class _InteractiveSpaceRegion extends StatelessWidget {
  const _InteractiveSpaceRegion({
    required this.width,
    required this.height,
    required this.localSegments,
    required this.isHovered,
    required this.hoverFillColor,
    required this.hoverBorderColor,
    required this.animationDuration,
    required this.onHoverChanged,
    required this.onTap,
  });

  final double width;
  final double height;
  final List<Rect> localSegments;
  final bool isHovered;
  final Color hoverFillColor;
  final Color hoverBorderColor;
  final Duration animationDuration;
  final ValueChanged<bool> onHoverChanged;
  final VoidCallback onTap;

  Path _buildHitPath() {
    final Path path = Path();
    for (final rect in localSegments) {
      path.addRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      );
    }
    return path;
  }

  @override
  Widget build(BuildContext context) {
    final Path hitPath = _buildHitPath();

    return MouseRegion(
      cursor: isHovered ? SystemMouseCursors.click : SystemMouseCursors.basic,
      opaque: false,
      onEnter: (_) {},
      onExit: (_) => onHoverChanged(false),
      onHover: (event) => onHoverChanged(hitPath.contains(event.localPosition)),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapUp: (details) {
          if (hitPath.contains(details.localPosition)) {
            onTap();
          }
        },
        child: TweenAnimationBuilder<double>(
          duration: animationDuration,
          curve: Curves.easeOutCubic,
          tween: Tween<double>(begin: 0, end: isHovered ? 1 : 0),
          builder: (context, t, _) {
            return CustomPaint(
              size: Size(width, height),
              painter: _SpaceRegionPainter(
                path: hitPath,
                fillColor: Color.lerp(Colors.transparent, hoverFillColor, t)!,
                borderColor:
                    Color.lerp(Colors.transparent, hoverBorderColor, t)!,
                borderWidth: 1.6,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SpaceRegionPainter extends CustomPainter {
  const _SpaceRegionPainter({
    required this.path,
    required this.fillColor,
    required this.borderColor,
    required this.borderWidth,
  });

  final Path path;
  final Color fillColor;
  final Color borderColor;
  final double borderWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (fillColor.alpha > 0) {
      final Paint fill = Paint()
        ..style = PaintingStyle.fill
        ..color = fillColor;
      canvas.drawPath(path, fill);
    }

    if (borderColor.alpha > 0 && borderWidth > 0) {
      final Paint stroke = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth
        ..color = borderColor;
      canvas.drawPath(path, stroke);
    }
  }

  @override
  bool shouldRepaint(covariant _SpaceRegionPainter oldDelegate) {
    return oldDelegate.path != path ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth;
  }
}

class _SpaceHoverCard extends StatelessWidget {
  const _SpaceHoverCard({
    required this.space,
    required this.layout,
    required this.availableWidth,
    required this.availableHeight,
  });

  static const double _cardWidth = 220;
  static const double _cardHeight = 114;
  static const double _cardOffset = 14;

  final SpaceModel space;
  final _SpaceOverlayLayout layout;
  final double availableWidth;
  final double availableHeight;

  @override
  Widget build(BuildContext context) {
    double left = layout.left + layout.width + _cardOffset;
    if (left + _cardWidth > availableWidth - 8) {
      left = layout.left - _cardWidth - _cardOffset;
    }
    left = left.clamp(8, availableWidth - _cardWidth - 8);

    final double top = (layout.top - 6).clamp(8, availableHeight - _cardHeight - 8);

    return Positioned(
      left: left,
      top: top,
      child: IgnorePointer(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: _cardWidth,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A0F172A),
                  blurRadius: 24,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  space.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 10),
                _SpaceInfoRow(label: 'Type', value: space.category),
                const SizedBox(height: 4),
                _SpaceInfoRow(
                  label: 'Capacite',
                  value: '${space.capacity} personne${space.capacity > 1 ? 's' : ''}',
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Text(
                      'Statut: ',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569),
                      ),
                    ),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: space.isAvailable
                            ? const Color(0xFF16A34A)
                            : const Color(0xFFDC2626),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      space.isAvailable ? 'disponible' : 'occupe',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: space.isAvailable
                            ? const Color(0xFF15803D)
                            : const Color(0xFFB91C1C),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SpaceInfoRow extends StatelessWidget {
  const _SpaceInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF475569),
          fontFamily: 'Roboto',
        ),
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpaceOverlayLayout {
  const _SpaceOverlayLayout({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  final double left;
  final double top;
  final double width;
  final double height;
}

class _RegionSegment {
  const _RegionSegment({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  final double left;
  final double top;
  final double width;
  final double height;
}

class _ScaledSpaceRegion {
  const _ScaledSpaceRegion({
    required this.space,
    required this.bounds,
    required this.localRects,
  });

  final SpaceModel space;
  final Rect bounds;
  final List<Rect> localRects;

  _SpaceOverlayLayout get layout => _SpaceOverlayLayout(
        left: bounds.left,
        top: bounds.top,
        width: bounds.width,
        height: bounds.height,
      );
}
