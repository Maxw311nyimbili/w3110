// lib/core/widgets/app_shell.dart
//
// Persistent app shell — sidebar + content area.

import 'package:cap_project/app/cubit/navigation_cubit.dart';
import 'package:cap_project/core/util/responsive_utils.dart';
import 'package:cap_project/core/widgets/side_menu.dart';
import 'package:cap_project/core/widgets/auth_guard.dart';
import 'package:cap_project/features/auth/auth.dart';
import 'package:cap_project/features/auth/view/settings_page.dart';
import 'package:cap_project/features/chat/chat.dart';
import 'package:cap_project/features/forum/forum.dart';
import 'package:cap_project/features/medscanner/medscanner.dart';
import 'package:cap_project/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveUtils.isDesktop(context);

    return BlocBuilder<NavigationCubit, NavigationState>(
      builder: (context, navState) {
        if (isDesktop) {
          return _DesktopShell(navState: navState);
        }
        return _MobileShell(navState: navState);
      },
    );
  }
}

// ── Desktop ───────────────────────────────────────────────────────────────────

class _DesktopShell extends StatelessWidget {
  const _DesktopShell({required this.navState});

  final NavigationState navState;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isCollapsed = navState.isDesktopSidebarCollapsed;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Row(
        children: [
          // ── Sidebar (Persistent) ──
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            width: isCollapsed ? 72 : 260,
            child: const SideMenu(),
          ),

          // ── Main Content Area (Header + Body) ──
          Expanded(
            child: Column(
              children: [
                // Clean Header (only shown if title/actions exist)
                if (navState.title != null ||
                    (navState.actions != null && navState.actions!.isNotEmpty))
                  Container(
                    height: 64,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        border: Border(
                          bottom: BorderSide(
                            color: isDark ? Colors.white.withOpacity(0.05) : AppColors.borderLight,
                            width: 0.5,
                          ),
                        ),
                      ),
                    child: Row(
                      children: [
                        if (navState.title != null)
                          DefaultTextStyle(
                            style: theme.textTheme.titleLarge!.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                            child: navState.title!,
                          ),
                        const Spacer(),
                        if (navState.actions != null) ...navState.actions!,
                      ],
                    ),
                  ),

                // Content body with transitions
                Expanded(
                  child: _ContentArea(activeTab: navState.activeTab),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mobile ────────────────────────────────────────────────────────────────────

class _MobileShell extends StatelessWidget {
  const _MobileShell({required this.navState});
  final NavigationState navState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Keep state using IndexedStack via _ContentArea
      appBar: AppBar(
        title: navState.title,
        actions: navState.actions,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      // Flutter's built-in drawer handles scrim + slide animation correctly
      drawer: const Drawer(
        width: 280,
        child: SideMenu(),
      ),
      body: _ContentArea(activeTab: navState.activeTab),
    );
  }
}

// ── Content area (IndexedStack keeps state, AnimatedSwitcher fades between tabs) ──

class _ContentArea extends StatelessWidget {
  const _ContentArea({required this.activeTab});
  final AppTab activeTab;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: IndexedStack(
        key: ValueKey(activeTab),
        index: activeTab.index,
        children: const [
          ChatPage(),
          AuthGuard(child: MedScannerPage()),
          AuthGuard(child: ForumListPage()),
          AuthGuard(child: SettingsPage()),
        ],
      ),
    );
  }
}
