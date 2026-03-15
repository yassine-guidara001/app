import 'package:flutter/material.dart';
import 'package:flutter_getx_app/app/modules/home/modules/plan/floor%20plan%20data.dart';
import 'package:flutter_svg/flutter_svg.dart';

class InteractiveFloorPlan extends StatefulWidget {
  final void Function(String spaceId, String label, Offset globalPosition)
      onSpaceTapped;
  final String? selectedSpaceId;

  const InteractiveFloorPlan({
    super.key,
    required this.onSpaceTapped,
    this.selectedSpaceId,
  });

  @override
  State<InteractiveFloorPlan> createState() => _InteractiveFloorPlanState();
}

class _InteractiveFloorPlanState extends State<InteractiveFloorPlan> {
  String? _hoveredSpaceId;
  Offset? _hoverLocalPosition;

  FloorSpaceZone? _zoneAt(Offset canvasPt, Size canvas) {
    final svgPt = Offset(
      canvasPt.dx / canvas.width * FloorPlanData.svgWidth,
      canvasPt.dy / canvas.height * FloorPlanData.svgHeight,
    );
    for (final z in FloorPlanData.zones) {
      if (z.containsPoint(svgPt)) return z;
    }
    return null;
  }

  Rect _svgRectToCanvas(Rect r, Size canvas) => Rect.fromLTWH(
        r.left / FloorPlanData.svgWidth * canvas.width,
        r.top / FloorPlanData.svgHeight * canvas.height,
        r.width / FloorPlanData.svgWidth * canvas.width,
        r.height / FloorPlanData.svgHeight * canvas.height,
      );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final size = Size(constraints.maxWidth, constraints.maxHeight);

      return GestureDetector(
        onTapDown: (d) {
          final z = _zoneAt(d.localPosition, size);
          if (z != null) {
            final rb = context.findRenderObject() as RenderBox;
            widget.onSpaceTapped(
                z.spaceId, z.label, rb.localToGlobal(d.localPosition));
          }
        },
        child: MouseRegion(
          onHover: (e) {
            final z = _zoneAt(e.localPosition, size);
            setState(() {
              _hoveredSpaceId = z?.spaceId;
              _hoverLocalPosition = e.localPosition;
            });
          },
          onExit: (_) => setState(() {
            _hoveredSpaceId = null;
            _hoverLocalPosition = null;
          }),
          cursor: _hoveredSpaceId != null
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── 1. SVG affiché tel quel, aucun effet ────────────────
              SvgPicture.asset(
                'assets/plan.svg',
                fit: BoxFit.fill,
                placeholderBuilder: (_) => const Center(
                  child: CircularProgressIndicator(
                      color: Color(0xFF22C55E), strokeWidth: 2),
                ),
              ),

              // ── 2. Overlay UNIQUEMENT sur hover/sélection ───────────
              CustomPaint(
                painter: _HoverPainter(
                  zones: FloorPlanData.zones,
                  canvasSize: size,
                  hoveredId: _hoveredSpaceId,
                  selectedId: widget.selectedSpaceId,
                  svgRectToCanvas: (r) => _svgRectToCanvas(r, size),
                ),
              ),

              // ── 3. Tooltip ──────────────────────────────────────────
              if (_hoveredSpaceId != null && _hoverLocalPosition != null)
                _buildTooltip(size),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTooltip(Size size) {
    final zone =
        FloorPlanData.zones.firstWhere((z) => z.spaceId == _hoveredSpaceId);
    final pos = _hoverLocalPosition!;
    const w = 170.0, h = 34.0;
    double left = (pos.dx - w / 2).clamp(4.0, size.width - w - 4);
    double top = pos.dy + 14;
    if (top + h > size.height - 4) top = pos.dy - h - 8;

    return Positioned(
      left: left,
      top: top,
      child: IgnorePointer(
        child: Container(
          width: w,
          height: h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(7),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 3))
            ],
          ),
          child: Text(zone.label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis),
        ),
      ),
    );
  }
}

// ── Painter : RIEN en mode normal, overlay seulement au hover/sélection ──────

class _HoverPainter extends CustomPainter {
  final List<FloorSpaceZone> zones;
  final Size canvasSize;
  final String? hoveredId, selectedId;
  final Rect Function(Rect) svgRectToCanvas;

  const _HoverPainter({
    required this.zones,
    required this.canvasSize,
    required this.hoveredId,
    required this.selectedId,
    required this.svgRectToCanvas,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final z in zones) {
      final isH = z.spaceId == hoveredId;
      final isS = z.spaceId == selectedId;

      // Ne rien dessiner si ni hover ni sélection
      if (!isH && !isS) continue;

      final r = svgRectToCanvas(z.rect);
      final rr = RRect.fromRectAndRadius(r, const Radius.circular(4));

      if (isS) {
        // Sélectionné : vert semi-transparent
        canvas.drawRRect(rr,
            Paint()
              ..color = const Color(0xFF22C55E).withOpacity(0.3)
              ..style = PaintingStyle.fill);
        canvas.drawRRect(rr,
            Paint()
              ..color = const Color(0xFF22C55E)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3);
      } else if (isH) {
        // Hover : overlay sombre (comme capture 3)
        canvas.drawRRect(rr,
            Paint()
              ..color = const Color(0xFF0F172A).withOpacity(0.45)
              ..style = PaintingStyle.fill);
        canvas.drawRRect(rr,
            Paint()
              ..color = const Color(0xFF38BDF8)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.5);
      }
    }
  }

  @override
  bool shouldRepaint(_HoverPainter o) =>
      o.hoveredId != hoveredId || o.selectedId != selectedId;
}