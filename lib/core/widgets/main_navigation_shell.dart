import 'package:cap_project/app/cubit/navigation_cubit.dart';
import 'package:cap_project/core/util/responsive_utils.dart';
import 'package:cap_project/core/widgets/side_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A shared shell that provides a consistent navigation experience across screens.
///
/// On Desktop (>1024px), it shows a retractable SideMenu.
/// On Mobile/Tablet (<1024px), it uses a Drawer.
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

    if (isDesktop) {
      return BlocBuilder<NavigationCubit, NavigationState>(
        builder: (context, navState) {
          final isCollapsed = navState.isSidebarCollapsed;

          return Scaffold(
            body: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOutCubic,
                  width: isCollapsed ? 72 : 250,
                  child: const SideMenu(),
                ),
                Expanded(
                  child: Scaffold(
                    appBar: AppBar(
                      leading: IconButton(
                        icon: _PanelToggleIcon(isCollapsed: isCollapsed),
                        onPressed: () =>
                            context.read<NavigationCubit>().toggleSidebar(),
                        tooltip: isCollapsed ? 'Expand Sidebar' : 'Collapse Sidebar',
                      ),
                      title: title,
                      actions: actions,
                      centerTitle: true,
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                    ),
                    body: child,
                    floatingActionButton: floatingActionButton,
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    // Mobile/Tablet layout with Drawer
    return Scaffold(
      appBar: AppBar(
        title: title,
        actions: actions,
        centerTitle: true,
        elevation: 0,
      ),
      drawer: const Drawer(
        child: SideMenu(),
      ),
      body: child,
      floatingActionButton: floatingActionButton,
    );
  }
}

/// Custom sidebar toggle icon — mimics the "panel-left" icon
/// (outlined rectangle with the left panel portion highlighted).
class _PanelToggleIcon extends StatelessWidget {
  const _PanelToggleIcon({required this.isCollapsed});

  final bool isCollapsed;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).iconTheme.color ?? Colors.black;
    return CustomPaint(
      size: const Size(22, 22),
      painter: _PanelIconPainter(
        color: color,
        panelOnLeft: isCollapsed,
      ),
    );
  }
}

class _PanelIconPainter extends CustomPainter {
  const _PanelIconPainter({required this.color, required this.panelOnLeft});

  final Color color;
  final bool panelOnLeft;

  @override
  void paint(Canvas canvas, Size size) {
    const double r = 2.5;
    final outerRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.75, 0.75, size.width - 1.5, size.height - 1.5),
      const Radius.circular(r),
    );

    // Outer border
    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(outerRect, borderPaint);

    // Panel fill — left third when collapsed, right when expanded
    final double panelWidth = size.width * 0.36;
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    if (panelOnLeft) {
      // Filled left panel (sidebar hidden — show it as a hint)
      final panelRect = RRect.fromRectAndCorners(
        Rect.fromLTWH(1.5, 1.5, panelWidth - 0.75, size.height - 3),
        topLeft: const Radius.circular(r - 1),
        bottomLeft: const Radius.circular(r - 1),
      );
      canvas.drawRRect(panelRect, fillPaint);
    } else {
      // Filled left panel (sidebar open — consistent look)
      final panelRect = RRect.fromRectAndCorners(
        Rect.fromLTWH(1.5, 1.5, panelWidth - 0.75, size.height - 3),
        topLeft: const Radius.circular(r - 1),
        bottomLeft: const Radius.circular(r - 1),
      );
      canvas.drawRRect(panelRect, fillPaint);
    }

    // Divider line between panel and content
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
  bool shouldRepaint(_PanelIconPainter old) =>
      old.color != color || old.panelOnLeft != panelOnLeft;
}
