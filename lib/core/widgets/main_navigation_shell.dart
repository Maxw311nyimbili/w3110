import 'package:cap_project/core/util/responsive_utils.dart';
import 'package:cap_project/core/widgets/side_menu.dart';
import 'package:flutter/material.dart';

/// A shared shell that provides a consistent navigation experience across screens.
/// 
/// On Desktop (>1024px), it shows a fixed SideMenu.
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
      return Scaffold(
        body: Row(
          children: [
            const SideMenu(),
            Expanded(
              child: Scaffold(
                appBar: title != null || actions != null
                    ? AppBar(
                        title: title,
                        actions: actions,
                        centerTitle: true,
                        elevation: 0,
                        backgroundColor: Colors.transparent,
                      )
                    : null,
                body: child,
                floatingActionButton: floatingActionButton,
              ),
            ),
          ],
        ),
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
