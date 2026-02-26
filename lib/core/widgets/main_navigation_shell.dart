import 'package:cap_project/app/cubit/navigation_cubit.dart';
import 'package:cap_project/core/widgets/side_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Navigation shell that matches the ChatGPT / Claude / Perplexity drawer pattern:
/// - Sidebar overlays the content (does not push/shrink it)
/// - Backdrop scrim dismisses the sidebar on tap
/// - Toggle button always visible in the top-left
class MainNavigationShell extends StatelessWidget {
  const MainNavigationShell({
    required this.child,
    this.title,
    this.actions,
    this.floatingActionButton,
    super.key,
  });

  final Widget child;
  final Widget? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, NavigationState>(
      builder: (context, navState) {
        // isSidebarCollapsed == true means the sidebar is HIDDEN
        final isSidebarOpen = !navState.isSidebarCollapsed;

        return Scaffold(
          floatingActionButton: floatingActionButton,
          body: Stack(
            children: [
              // ── Main content (full width, never pushed) ──────────────────
              Column(
                children: [
                  _TopBar(
                    title: title,
                    actions: actions,
                    isSidebarOpen: isSidebarOpen,
                  ),
                  Expanded(child: child),
                ],
              ),

              // ── Backdrop scrim (tap to close) ─────────────────────────────
              if (isSidebarOpen)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () =>
                        context.read<NavigationCubit>().toggleSidebar(),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      color: Colors.black.withOpacity(0.35),
                    ),
                  ),
                ),

              // ── Sliding sidebar (overlays content) ────────────────────────
              AnimatedPositioned(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeInOutCubic,
                left: isSidebarOpen ? 0 : -280,
                top: 0,
                bottom: 0,
                width: 280,
                child: const SideMenu(),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Top bar ─────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.isSidebarOpen,
    this.title,
    this.actions,
  });

  final bool isSidebarOpen;
  final Widget? title;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: 44,
        child: Row(
          children: [
            // Minimal sidebar toggle — small tap area, no background
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: SizedBox(
                width: 32,
                height: 32,
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(6),
                    hoverColor: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withOpacity(0.08),
                    onTap: () =>
                        context.read<NavigationCubit>().toggleSidebar(),
                    child: Center(
                      child: _SidebarToggleIcon(
                        color: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.color
                                ?.withOpacity(0.55) ??
                            Colors.black54,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (title != null)
              Expanded(child: Center(child: title!))
            else
              const Spacer(),
            if (actions != null) ...actions!,
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}

// ─── Sidebar toggle icon ──────────────────────────────────────────────────────
// Thin, minimal — matches ChatGPT / Claude / Perplexity style

class _SidebarToggleIcon extends StatelessWidget {
  const _SidebarToggleIcon({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(16, 14),
      painter: _SidebarIconPainter(color: color),
    );
  }
}

class _SidebarIconPainter extends CustomPainter {
  const _SidebarIconPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Outer rectangle
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(2),
    );
    canvas.drawRRect(rect, paint);

    // Vertical divider — left panel separator
    final double divX = size.width * 0.38;
    canvas.drawLine(
      Offset(divX, 0),
      Offset(divX, size.height),
      paint,
    );

    // Three small horizontal lines in the left panel (menu hint)
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    final double lx1 = divX * 0.18;
    final double lx2 = divX * 0.82;
    final double spacing = size.height / 4;
    for (var i = 1; i <= 3; i++) {
      canvas.drawLine(
        Offset(lx1, spacing * i),
        Offset(lx2, spacing * i),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(_SidebarIconPainter old) => old.color != color;
}
