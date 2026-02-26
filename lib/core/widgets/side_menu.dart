// lib/core/widgets/side_menu.dart
// Persistent sidebar — uses NavigationCubit.setTab() for navigation.
// No Navigator.push → no page transitions.

import 'package:cap_project/app/cubit/navigation_cubit.dart';
import 'package:cap_project/app/view/app_router.dart';
import 'package:cap_project/core/theme/app_colors.dart';
import 'package:cap_project/core/theme/app_text_styles.dart';
import 'package:cap_project/core/util/responsive_utils.dart';
import 'package:cap_project/features/auth/cubit/cubit.dart';
import 'package:cap_project/features/chat/cubit/chat_cubit.dart';
import 'package:cap_project/features/chat/cubit/chat_state.dart';
import 'package:cap_project/features/landing/widgets/welcome_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({super.key});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  @override
  void initState() {
    super.initState();
    // Load real conversation history as soon as the sidebar is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ChatCubit>().loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, NavigationState>(
      builder: (context, navState) {
        final isDesktop = ResponsiveUtils.isDesktop(context);
        final isCollapsed = isDesktop && navState.isDesktopSidebarCollapsed;
        final activeTab = navState.activeTab;

        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final sidebarBg =
            isDark ? AppColors.darkBackgroundSurface : const Color(0xFFF0F2F5);

        return Container(
          width: double.infinity,
          height: double.infinity,
          color: sidebarBg,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context, isCollapsed, isDesktop),
                Expanded(child: _buildNavList(context, isCollapsed, activeTab)),
                _buildFooter(context, isCollapsed),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(
    BuildContext context,
    bool isCollapsed,
    bool isDesktop,
  ) {
    final toggleColor = Theme.of(context)
            .textTheme
            .bodySmall
            ?.color
            ?.withOpacity(0.55) ??
        Colors.black54;

    if (isCollapsed) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Center(
          child: _ToggleButton(color: toggleColor),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 4, 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/logo.png',
              width: 38,
              height: 38,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Thanzi',
            style: AppTextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).textTheme.bodyLarge?.color,
              letterSpacing: -0.4,
            ),
          ),
          const Spacer(),
          if (isDesktop) _ToggleButton(color: toggleColor),
        ],
      ),
    );
  }

  // ── Nav list ──────────────────────────────────────────────────────────────
  Widget _buildNavList(
    BuildContext context,
    bool isCollapsed,
    AppTab activeTab,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment:
            isCollapsed ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          // New thread
          if (!isCollapsed) _SectionLabel('Library'),
          _NavItem(
            icon: Icons.add_rounded,
            label: 'New Thread',
            isPrimary: true,
            isCollapsed: isCollapsed,
            isActive: false,
            onTap: () {
              context.read<NavigationCubit>().setTab(AppTab.chat);
              // Clear the chat so a new session starts
              context.read<ChatCubit>().startNewSession();
            },
          ),
          const SizedBox(height: 8),

          // Main navigation
          if (!isCollapsed) _SectionLabel('Discover'),
          _NavItem(
            icon: Icons.document_scanner_outlined,
            label: 'Med Scanner',
            isCollapsed: isCollapsed,
            isActive: activeTab == AppTab.scanner,
            onTap: () {
              context.read<NavigationCubit>().setTab(AppTab.scanner);
            },
          ),
          _NavItem(
            icon: Icons.forum_outlined,
            label: 'Community',
            isCollapsed: isCollapsed,
            isActive: activeTab == AppTab.forum,
            onTap: () {
              context.read<NavigationCubit>().setTab(AppTab.forum);
            },
          ),

          // Conversations / History
          const SizedBox(height: 8),
          if (!isCollapsed) _SectionLabel('Conversations'),
          _ConversationsSection(isCollapsed: isCollapsed),
        ],
      ),
    );
  }

  // ── Footer ────────────────────────────────────────────────────────────────
  Widget _buildFooter(BuildContext context, bool isCollapsed) {
    final authState = context.watch<AuthCubit>().state;
    final user = authState.user;
    final isAuthenticated = authState.status == AuthStatus.authenticated;

    if (isCollapsed) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Center(
          child: isAuthenticated
              ? _RailAvatar(user: user)
              : IconButton(
                  icon: const Icon(Icons.login_rounded, size: 20),
                  color: AppColors.brandDarkTeal,
                  onPressed: () => WelcomeDrawer.show(context),
                  tooltip: 'Sign In',
                ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: isAuthenticated
          ? _AuthFooter(user: user)
          : const _GuestFooter(),
    );
  }
}

// ─── Toggle button ────────────────────────────────────────────────────────────

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: () => context.read<NavigationCubit>().toggleDesktopSidebar(),
        child: Center(
          child: Icon(Icons.menu_rounded, size: 18, color: color),
        ),
      ),
    );
  }
}

// ─── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.color
                  ?.withOpacity(0.45),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.9,
              fontSize: 10,
            ),
      ),
    );
  }
}

// ─── Nav item ─────────────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isCollapsed,
    required this.isActive,
    required this.onTap,
    this.isPrimary = false,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final bool isCollapsed;
  final bool isActive;
  final VoidCallback onTap;
  final bool isPrimary;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final mutedColor =
        Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.75);
    final primaryColor = Theme.of(context).colorScheme.primary;

    final Color iconColor;
    final Color labelColor;
    final FontWeight labelWeight;

    if (isPrimary) {
      iconColor = primaryColor;
      labelColor = primaryColor;
      labelWeight = FontWeight.w700;
    } else if (isActive) {
      iconColor = AppColors.brandDarkTeal;
      labelColor = textColor ?? AppColors.textPrimary;
      labelWeight = FontWeight.w600;
    } else {
      iconColor = mutedColor ?? AppColors.textSecondary;
      labelColor = mutedColor ?? AppColors.textSecondary;
      labelWeight = FontWeight.w400;
    }

    if (isCollapsed) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Tooltip(
          message: label,
          preferBelow: false,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 48,
              height: 44,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.brandDarkTeal.withOpacity(0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: Icon(icon, size: 20, color: iconColor)),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.brandDarkTeal.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: labelColor,
                    fontWeight: labelWeight,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Conversations section (real history from ChatCubit) ──────────────────────

class _ConversationsSection extends StatefulWidget {
  const _ConversationsSection({required this.isCollapsed});
  final bool isCollapsed;

  @override
  State<_ConversationsSection> createState() => _ConversationsSectionState();
}

class _ConversationsSectionState extends State<_ConversationsSection> {
  bool _isExpanded = true; // auto-expanded so conversations are visible

  @override
  Widget build(BuildContext context) {
    if (widget.isCollapsed) {
      return _NavItem(
        icon: Icons.history_rounded,
        label: 'Conversations',
        isCollapsed: true,
        isActive: false,
        onTap: () {
          context.read<NavigationCubit>().setTab(AppTab.chat);
        },
      );
    }

    return BlocBuilder<ChatCubit, ChatState>(
      buildWhen: (prev, curr) =>
          prev.historySessions != curr.historySessions ||
          prev.isLoadingHistory != curr.isLoadingHistory,
      builder: (context, chatState) {
        final sessions = chatState.historySessions;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _NavItem(
              icon: Icons.history_rounded,
              label: 'Conversations',
              isCollapsed: false,
              isActive: false,
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              trailing: Icon(
                _isExpanded
                    ? Icons.expand_less_rounded
                    : Icons.expand_more_rounded,
                size: 16,
                color: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.color
                    ?.withOpacity(0.5),
              ),
            ),
            if (_isExpanded)
              Padding(
                padding:
                    const EdgeInsets.only(left: 20, right: 8, top: 4, bottom: 8),
                child: chatState.isLoadingHistory
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Center(
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      )
                    : sessions.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'No conversations yet',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color
                                        ?.withOpacity(0.5),
                                  ),
                            ),
                          )
                        : Column(
                            children: sessions.take(8).map((session) {
                              return _SessionTile(
                                session: session,
                                onTap: () {
                                  context
                                      .read<NavigationCubit>()
                                      .setTab(AppTab.chat);
                                  context
                                      .read<ChatCubit>()
                                      .loadSession(session.sessionId);
                                },
                              );
                            }).toList(),
                          ),
              ),
          ],
        );
      },
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session, required this.onTap});
  final HistorySession session;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        child: Row(
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 13,
              color: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.color
                  ?.withOpacity(0.5),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                session.firstMessage,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 13,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Authenticated footer ─────────────────────────────────────────────────────

class _AuthFooter extends StatelessWidget {
  const _AuthFooter({required this.user});
  final dynamic user;

  @override
  Widget build(BuildContext context) {
    final name = (user?.displayName as String?) ?? 'User';
    final initials = name
        .trim()
        .split(' ')
        .take(2)
        .map((p) => p.isEmpty ? '' : p[0].toUpperCase())
        .join();

    return InkWell(
      onTap: () => context.read<NavigationCubit>().setTab(AppTab.settings),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.brandDarkTeal.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.brandDarkTeal.withOpacity(0.3),
                ),
              ),
              child: Center(
                child: Text(
                  initials.isEmpty ? 'U' : initials,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.brandDarkTeal,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Profile & Settings',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.color
                              ?.withOpacity(0.55),
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.settings_outlined,
              size: 16,
              color: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.color
                  ?.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Guest footer ─────────────────────────────────────────────────────────────

class _GuestFooter extends StatelessWidget {
  const _GuestFooter();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sign in to save your chats',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => WelcomeDrawer.show(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandDarkTeal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: const Text('Sign In', style: TextStyle(fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Rail avatar (collapsed footer) ──────────────────────────────────────────

class _RailAvatar extends StatelessWidget {
  const _RailAvatar({required this.user});
  final dynamic user;

  @override
  Widget build(BuildContext context) {
    final name = (user?.displayName as String?) ?? 'U';
    final initials = name
        .trim()
        .split(' ')
        .take(2)
        .map((p) => p.isEmpty ? '' : p[0].toUpperCase())
        .join();

    return Tooltip(
      message: name,
      child: InkWell(
        onTap: () => context.read<NavigationCubit>().setTab(AppTab.settings),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.brandDarkTeal.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.brandDarkTeal.withOpacity(0.3)),
          ),
          child: Center(
            child: Text(
              initials.isEmpty ? 'U' : initials,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.brandDarkTeal,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
