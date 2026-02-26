import 'package:cap_project/app/cubit/navigation_cubit.dart';
import 'package:cap_project/core/util/responsive_utils.dart';
import 'package:cap_project/core/widgets/side_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Responsive navigation shell:
///
/// • Desktop (≥1024 px): persistent side-by-side sidebar.
///   Toggle button cycles between expanded (260 px) and collapsed icon-rail (72 px).
///
/// • Mobile / Tablet (<1024 px): overlay drawer that slides over content.
///   Toggle button opens / closes the drawer with a backdrop scrim.
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
    final isDesktop = ResponsiveUtils.isDesktop(context);

    return BlocBuilder<NavigationCubit, NavigationState>(
      builder: (context, navState) {
        final isCollapsed = navState.isSidebarCollapsed;
        // On mobile "collapsed" means the overlay is closed.
        // On desktop "collapsed" means the rail (72 px) state.
        final isMobileOpen = !isCollapsed; // overlay open on mobile

        if (isDesktop) {
          return _DesktopLayout(
            isCollapsed: isCollapsed,
            title: title,
            actions: actions,
            floatingActionButton: floatingActionButton,
            child: child,
          );
        }

        // ── Mobile / Tablet — overlay drawer ──────────────────────────────
        return Scaffold(
          floatingActionButton: floatingActionButton,
          body: Stack(
            children: [
              // Full-width content
              Column(
                children: [
                  _TopBar(
                    isCollapsed: isCollapsed,
                    isDesktop: false,
                    title: title,
                    actions: actions,
                  ),
                  Expanded(child: child),
                ],
              ),

              // Backdrop scrim
              if (isMobileOpen)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () =>
                        context.read<NavigationCubit>().toggleSidebar(),
                    behavior: HitTestBehavior.opaque,
                    child: Container(color: Colors.black.withOpacity(0.35)),
                  ),
                ),

              // Sliding sidebar
              AnimatedPositioned(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeInOutCubic,
                left: isMobileOpen ? 0 : -280,
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

// ─── Desktop layout ───────────────────────────────────────────────────────────

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({
    required this.isCollapsed,
    required this.child,
    this.title,
    this.actions,
    this.floatingActionButton,
  });

  final bool isCollapsed;
  final Widget child;
  final Widget? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: floatingActionButton,
      body: Row(
        children: [
          // Persistent sidebar — animates between full and rail
          AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOutCubic,
            width: isCollapsed ? 72 : 260,
            child: const SideMenu(),
          ),

          // Main content
          Expanded(
            child: Column(
              children: [
                _TopBar(
                  isCollapsed: isCollapsed,
                  isDesktop: true,
                  title: title,
                  actions: actions,
                ),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Top bar ─────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.isCollapsed,
    required this.isDesktop,
    this.title,
    this.actions,
  });

  final bool isCollapsed;
  final bool isDesktop;
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
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(2),
      ),
      paint,
    );

    // Vertical divider — left panel separator
    final double divX = size.width * 0.38;
    canvas.drawLine(Offset(divX, 0), Offset(divX, size.height), paint);

    // Three small horizontal lines inside the left panel
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
