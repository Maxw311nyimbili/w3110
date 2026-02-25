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
        height: 52,
        child: Row(
          children: [
            IconButton(
              icon: _PanelToggleIcon(isOpen: isSidebarOpen),
              onPressed: () =>
                  context.read<NavigationCubit>().toggleSidebar(),
              tooltip: isSidebarOpen ? 'Close Sidebar' : 'Open Sidebar',
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

// ─── Panel toggle icon ───────────────────────────────────────────────────────

class _PanelToggleIcon extends StatelessWidget {
  const _PanelToggleIcon({required this.isOpen});

  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).iconTheme.color ?? Colors.black;
    return CustomPaint(
      size: const Size(22, 22),
      painter: _PanelIconPainter(color: color),
    );
  }
}

class _PanelIconPainter extends CustomPainter {
  const _PanelIconPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const double r = 2.5;
    final outerRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.75, 0.75, size.width - 1.5, size.height - 1.5),
      const Radius.circular(r),
    );

    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(outerRect, borderPaint);

    final double panelWidth = size.width * 0.36;
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final panelRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(1.5, 1.5, panelWidth - 0.75, size.height - 3),
      topLeft: const Radius.circular(r - 1),
      bottomLeft: const Radius.circular(r - 1),
    );
    canvas.drawRRect(panelRect, fillPaint);

    final dividerPaint = Paint()
      ..color = color
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(panelWidth, 1.5),
      Offset(panelWidth, size.height - 1.5),
      dividerPaint,
    );
  }

  @override
  bool shouldRepaint(_PanelIconPainter old) => old.color != color;
}
