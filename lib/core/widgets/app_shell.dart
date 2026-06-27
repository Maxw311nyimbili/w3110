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
import 'package:cap_project/features/rating/rating.dart';
import 'package:cap_project/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveUtils.isDesktop(context);

    return BlocListener<RatingCubit, RatingState>(
      listenWhen: (prev, curr) =>
          curr.status == RatingStatus.showing &&
          prev.status != RatingStatus.showing,
      listener: (context, state) {
        showRatingDialog(context);
      },
      child: BlocBuilder<NavigationCubit, NavigationState>(
        builder: (context, navState) {
          if (isDesktop) {
            return _DesktopShell(navState: navState);
          }
          return _MobileShell(navState: navState);
        },
      ),
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

    // Resolve Title
    final title =
        navState.title ?? _getDefaultTitle(context, navState.activeTab);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Row(
        children: [
          // ── Sidebar (Persistent) ──
          AnimatedContainer(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeInOutCubic,
            width: isCollapsed ? 72 : 260,
            clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(),
            child: const SideMenu(),
          ),

          // ── Main Content Area (Header + Body) ──
          Expanded(
            child: Column(
              children: [
                // Clean Header (only shown if title/actions exist)
                if (title != null ||
                    (navState.actions != null && navState.actions!.isNotEmpty))
                  Container(
                    height: 64,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      border: Border(
                        bottom: BorderSide(
                          color: isDark
                              ? Colors.white.withOpacity(0.05)
                              : AppColors.borderLight,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        if (navState.leading != null) ...[
                          navState.leading!,
                          const SizedBox(width: 8),
                        ],
                        if (title != null)
                          DefaultTextStyle(
                            style:
                                (theme.textTheme.titleLarge ??
                                        theme.textTheme.headlineSmall ??
                                        const TextStyle())
                                    .copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18,
                                    ),
                            child: title,
                          ),
                        const Spacer(),
                        if (navState.actions != null) ...navState.actions!,
                      ],
                    ),
                  ),

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

  Widget? _getDefaultTitle(BuildContext context, AppTab tab) {
    switch (tab) {
      case AppTab.chat:
        // Desktop sidebar already shows the NAIIA logo + wordmark —
        // returning null suppresses the header bar entirely on chat.
        return null;
      case AppTab.scanner:
        return const Text('Scanner');
      case AppTab.forum:
        return const Text('Community');
      case AppTab.settings:
        return const Text('Settings');
    }
  }
}

// ── Mobile ────────────────────────────────────────────────────────────────────

class _MobileShell extends StatelessWidget {
  const _MobileShell({required this.navState});
  final NavigationState navState;

  @override
  Widget build(BuildContext context) {
    final title =
        navState.title ?? _getDefaultTitle(context, navState.activeTab);

    return Scaffold(
      // Keep state using IndexedStack via _ContentArea
      appBar: AppBar(
        title: title,
        leading: navState.leading,
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
      // SelectionArea removed from mobile — it adds text-selection hit-testing
      // overhead to every touch event on the entire content area. On iOS/Android
      // users long-press individual Text widgets to select; wrapping the whole
      // screen is unnecessary and measurably hurts scroll/gesture performance.
      body: _ContentArea(activeTab: navState.activeTab),
    );
  }

  Widget? _getDefaultTitle(BuildContext context, AppTab tab) {
    switch (tab) {
      case AppTab.chat:
        return null; // sidebar drawer already has NAIIA logo + wordmark
      case AppTab.scanner:
        return const Text('Scanner');
      case AppTab.forum:
        return const Text('Community');
      case AppTab.settings:
        return const Text('Settings');
    }
  }
}

// ── Content area ──────────────────────────────────────────────────────────────
//
// IndexedStack keeps all four pages alive in the widget tree so their scroll
// positions, camera state, and cubit state survive tab switches.
//
// IMPORTANT: do NOT add a key to IndexedStack — a key would cause Flutter to
// rebuild the stack (and destroy all child state) on every tab change.

class _ContentArea extends StatelessWidget {
  const _ContentArea({required this.activeTab});
  final AppTab activeTab;

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: activeTab.index,
      children: const [
        ChatPage(),
        AuthGuard(child: MedScannerPage()),
        AuthGuard(child: ForumListPage()),
        AuthGuard(child: SettingsPage()),
      ],
    );
  }
}
