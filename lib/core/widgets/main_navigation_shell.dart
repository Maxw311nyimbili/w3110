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
                        icon: Icon(
                          isCollapsed ? Icons.menu_rounded : Icons.menu_open_rounded,
                        ),
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
