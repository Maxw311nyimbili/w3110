// lib/core/widgets/side_menu.dart
// Naiia Premium Sidebar — refined visual hierarchy, animated selection.

import 'package:cap_project/app/cubit/navigation_cubit.dart';
import 'package:cap_project/app/view/app_router.dart';
import 'package:cap_project/core/theme/app_colors.dart';
import 'package:cap_project/core/theme/app_text_styles.dart';
import 'package:cap_project/core/util/responsive_utils.dart';
import 'package:cap_project/features/auth/cubit/cubit.dart';
import 'package:cap_project/features/chat/cubit/chat_cubit.dart';
import 'package:cap_project/features/chat/cubit/chat_state.dart';
import 'package:cap_project/features/landing/widgets/welcome_drawer.dart';
import 'package:cap_project/core/widgets/brand_logo.dart';
import 'package:cap_project/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({super.key});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final authState = context.read<AuthCubit>().state;
        if (authState.status == AuthStatus.authenticated) {
          context.read<ChatCubit>().loadHistory();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthCubit, AuthState>(
          listenWhen: (prev, curr) =>
              prev.status == AuthStatus.authenticated &&
              curr.status == AuthStatus.unauthenticated,
          listener: (context, state) {
            context.read<ChatCubit>().clearLocalHistorySessions();
            context.read<ChatCubit>().startNewSession();
          },
        ),
        BlocListener<AuthCubit, AuthState>(
          listenWhen: (prev, curr) =>
              prev.status != AuthStatus.authenticated &&
              curr.status == AuthStatus.authenticated,
          listener: (context, state) {
            context.read<ChatCubit>().loadHistory();
          },
        ),
      ],
      child: BlocBuilder<NavigationCubit, NavigationState>(
        builder: (context, navState) {
          final authState = context.watch<AuthCubit>().state;
          final isAuthenticated = authState.status == AuthStatus.authenticated;
          final isDesktop = ResponsiveUtils.isDesktop(context);
          final isCollapsed = isDesktop && navState.isDesktopSidebarCollapsed;
          final activeTab = navState.activeTab;

          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;

          // Sidebar = backgroundPanel — one step lighter than canvas,
          // same step relationship as darkElevated on darkCanvas.
          // (Dark: #192638 on #0D1520 | Light: #ECE7DB on #E4DDD0)
          // All warm ivory family → monochromatic, no colour clash.
          final sidebarBg = isDark
              ? AppColors.darkElevated
              : AppColors.backgroundPanel;

          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: sidebarBg,
              border: Border(
                right: BorderSide(
                  color: isDark
                      ? Colors.white.withOpacity(0.06)
                      : AppColors.borderLight.withOpacity(0.9),
                  width: isDark ? 1 : 1.2,
                ),
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context, isCollapsed, isDesktop, isDark),
                  Expanded(
                    child: _buildNavList(
                      context,
                      isCollapsed,
                      activeTab,
                      isAuthenticated,
                      isDark,
                    ),
                  ),
                  _buildFooter(context, isCollapsed, authState, isDark),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader(
    BuildContext context,
    bool isCollapsed,
    bool isDesktop,
    bool isDark,
  ) {
    final labelColor = isDark ? AppColors.darkTextPrimary : AppColors.ink;
    final toggleColor =
        (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)
            .withOpacity(0.6);

    if (isCollapsed) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(child: _ToggleButton(color: toggleColor)),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 10),
      child: Row(
        children: [
          const BrandLogo(size: 36, isBreathing: false),
          const SizedBox(width: 10),
          Text(
            'NAIIA',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 22,
              fontWeight: FontWeight.w300,
              color: AppColors.slateBlue,
              letterSpacing: 4,
            ),
          ),
          const Spacer(),
          if (isDesktop) _ToggleButton(color: toggleColor),
        ],
      ),
    );
  }

  // ── Nav list ───────────────────────────────────────────────────────────────
  Widget _buildNavList(
    BuildContext context,
    bool isCollapsed,
    AppTab activeTab,
    bool isAuthenticated,
    bool isDark,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isCollapsed ? 10 : 8,
        vertical: 8,
      ),
      child: Column(
        crossAxisAlignment: isCollapsed
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          // New Thread — always first, prominent
          _NavItem(
            icon: Icons.add_rounded,
            label: AppLocalizations.of(context).newThread,
            isPrimary: true,
            isCollapsed: isCollapsed,
            isActive: false,
            isDark: isDark,
            onTap: () {
              context.read<NavigationCubit>().setTab(AppTab.chat);
              context.read<ChatCubit>().startNewSession();
            },
          ),

          const SizedBox(height: 6),
          if (!isCollapsed) _Divider(),
          const SizedBox(height: 6),

          // Navigation
          if (!isCollapsed)
            _SectionLabel(
              AppLocalizations.of(context).navigate,
              isDark: isDark,
            ),
          _NavItem(
            icon: Icons.chat_bubble_outline_rounded,
            label: AppLocalizations.of(context).askNaiia,
            isCollapsed: isCollapsed,
            isActive: activeTab == AppTab.chat,
            isDark: isDark,
            onTap: () => context.read<NavigationCubit>().setTab(AppTab.chat),
          ),
          _NavItem(
            icon: Icons.document_scanner_outlined,
            label: AppLocalizations.of(context).medScanner,
            isCollapsed: isCollapsed,
            isActive: activeTab == AppTab.scanner,
            isDark: isDark,
            onTap: () => context.read<NavigationCubit>().setTab(AppTab.scanner),
          ),
          _NavItem(
            icon: Icons.people_outline_rounded,
            label: AppLocalizations.of(context).community,
            isCollapsed: isCollapsed,
            isActive: activeTab == AppTab.forum,
            isDark: isDark,
            onTap: () => context.read<NavigationCubit>().setTab(AppTab.forum),
          ),

          // Conversation history
          if (!isCollapsed && isAuthenticated) ...[
            const SizedBox(height: 6),
            _Divider(),
            const SizedBox(height: 6),
            _SectionLabel(
              AppLocalizations.of(context).historyLabel,
              isDark: isDark,
            ),
            _ConversationsSection(isCollapsed: isCollapsed, isDark: isDark),
          ],
        ],
      ),
    );
  }

  // ── Footer ─────────────────────────────────────────────────────────────────
  Widget _buildFooter(
    BuildContext context,
    bool isCollapsed,
    AuthState authState,
    bool isDark,
  ) {
    final isAuthenticated = authState.status == AuthStatus.authenticated;

    if (isCollapsed) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Center(
          child: isAuthenticated
              ? _RailAvatar(user: authState.user, isDark: isDark)
              : IconButton(
                  icon: Icon(
                    Icons.login_rounded,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () => WelcomeDrawer.show(context),
                  tooltip: AppLocalizations.of(context).signIn,
                ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(8, 4, 8, 12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.04)
            : AppColors.borderLight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : AppColors.borderLight,
          width: 0.75,
        ),
      ),
      child: isAuthenticated
          ? _AuthFooter(user: authState.user, isDark: isDark)
          : _GuestFooter(isDark: isDark),
    );
  }
}

// ─── Toggle button ─────────────────────────────────────────────────────────────

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: InkWell(
        borderRadius: BorderRadius.circular(7),
        onTap: () => context.read<NavigationCubit>().toggleDesktopSidebar(),
        child: Center(child: _SidebarIcon(color: color)),
      ),
    );
  }
}

class _SidebarIcon extends StatelessWidget {
  const _SidebarIcon({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 19,
      height: 15,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 5,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: color, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label, {required this.isDark});
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
          color: (isDark ? AppColors.darkTextTertiary : AppColors.textTertiary),
        ),
      ),
    );
  }
}

// ─── Subtle divider ────────────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 0.5,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: isDark ? Colors.white.withOpacity(0.06) : AppColors.borderLight,
    );
  }
}

// ─── Nav item — with animated active indicator ─────────────────────────────────

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isCollapsed,
    required this.isActive,
    required this.isDark,
    required this.onTap,
    this.isPrimary = false,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final bool isCollapsed;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;
  final bool isPrimary;
  final Widget? trailing;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    final Color iconColor;
    final Color labelColor;
    final FontWeight labelWeight;

    if (widget.isPrimary) {
      iconColor = primary;
      labelColor = primary;
      labelWeight = FontWeight.w700;
    } else if (widget.isActive) {
      iconColor = primary;
      labelColor = widget.isDark ? AppColors.darkTextPrimary : AppColors.ink;
      labelWeight = FontWeight.w600;
    } else {
      final base = widget.isDark
          ? AppColors.darkTextSecondary
          : AppColors.textSecondary;
      iconColor = _hovered ? primary.withOpacity(0.8) : base;
      labelColor = _hovered ? primary.withOpacity(0.8) : base;
      labelWeight = FontWeight.w500;
    }

    // LayoutBuilder drives show/hide label based on the ACTUAL rendered width,
    // not just the isCollapsed flag.  The flag flips instantly while the sidebar
    // AnimatedContainer takes 320 ms to reach its target — that race caused the
    // overflow.  By watching real constraints we react smoothly on both expand
    // and collapse without any timing dependency on the flag.
    return LayoutBuilder(
      builder: (context, constraints) {
        // Show the label only when there is genuinely enough room for it.
        // 88 px gives ~56 px of text space after icon + spacer + padding.
        final showLabel = !widget.isCollapsed && constraints.maxWidth >= 88;

        if (!showLabel) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Tooltip(
              message: widget.label,
              preferBelow: false,
              child: MouseRegion(
                onEnter: (_) => setState(() => _hovered = true),
                onExit: (_) => setState(() => _hovered = false),
                child: GestureDetector(
                  onTap: widget.onTap,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    width: 48,
                    height: 44,
                    decoration: BoxDecoration(
                      color: widget.isPrimary
                          ? primary.withOpacity(widget.isDark ? 0.14 : 0.09)
                          : widget.isActive
                          ? primary.withOpacity(0.12)
                          : _hovered
                          ? primary.withOpacity(0.07)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Center(
                      child: Icon(widget.icon, size: 20, color: iconColor),
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 1),
          child: MouseRegion(
            onEnter: (_) => setState(() => _hovered = true),
            onExit: (_) => setState(() => _hovered = false),
            child: GestureDetector(
              onTap: widget.onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                clipBehavior: Clip.hardEdge,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: widget.isPrimary
                      ? primary.withOpacity(widget.isDark ? 0.14 : 0.09)
                      : widget.isActive
                      ? primary.withOpacity(0.10)
                      : _hovered
                      ? primary.withOpacity(0.05)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: widget.isPrimary
                      ? Border.all(
                          color: primary.withOpacity(
                            widget.isDark ? 0.22 : 0.18,
                          ),
                          width: 0.75,
                        )
                      : widget.isActive
                      ? Border.all(
                          color: primary.withOpacity(0.18),
                          width: 0.75,
                        )
                      : null,
                ),
                child: Row(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: Icon(
                        widget.icon,
                        key: ValueKey(iconColor),
                        size: 18,
                        color: iconColor,
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 180),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: labelColor,
                          fontWeight: labelWeight,
                          fontSize: 13.5,
                        ),
                        child: Text(
                          widget.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    if (widget.trailing != null) ...[
                      const SizedBox(width: 6),
                      widget.trailing!,
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Conversations section ─────────────────────────────────────────────────────

class _ConversationsSection extends StatefulWidget {
  const _ConversationsSection({
    required this.isCollapsed,
    required this.isDark,
  });
  final bool isCollapsed;
  final bool isDark;

  @override
  State<_ConversationsSection> createState() => _ConversationsSectionState();
}

class _ConversationsSectionState extends State<_ConversationsSection> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    if (widget.isCollapsed) {
      return _NavItem(
        icon: Icons.history_rounded,
        label: AppLocalizations.of(context).conversationsLabel,
        isCollapsed: true,
        isActive: false,
        isDark: widget.isDark,
        onTap: () => context.read<NavigationCubit>().setTab(AppTab.chat),
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
              label: AppLocalizations.of(context).recentLabel,
              isCollapsed: false,
              isActive: false,
              isDark: widget.isDark,
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              trailing: Icon(
                _isExpanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                size: 15,
                color: widget.isDark
                    ? AppColors.darkTextTertiary
                    : AppColors.textTertiary,
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              child: _isExpanded
                  ? Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 4,
                        top: 2,
                        bottom: 6,
                      ),
                      child: chatState.isLoadingHistory
                          ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Center(
                                child: SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.5,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary.withOpacity(0.5),
                                  ),
                                ),
                              ),
                            )
                          : sessions.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                AppLocalizations.of(context).noConversationsYet,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: widget.isDark
                                      ? AppColors.darkTextTertiary
                                      : AppColors.textTertiary,
                                ),
                              ),
                            )
                          : Column(
                              children: sessions
                                  .take(8)
                                  .map<Widget>(
                                    (session) => _SessionTile(
                                      session: session,
                                      isDark: widget.isDark,
                                      onTap: () {
                                        context.read<NavigationCubit>().setTab(
                                          AppTab.chat,
                                        );
                                        context.read<ChatCubit>().loadSession(
                                          session.sessionId,
                                        );
                                      },
                                    ),
                                  )
                                  .toList(),
                            ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        );
      },
    );
  }
}

class _SessionTile extends StatefulWidget {
  const _SessionTile({
    required this.session,
    required this.isDark,
    required this.onTap,
  });
  final HistorySession session;
  final bool isDark;
  final VoidCallback onTap;

  @override
  State<_SessionTile> createState() => _SessionTileState();
}

class _SessionTileState extends State<_SessionTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;
    final hoverBg = widget.isDark
        ? Colors.white.withOpacity(0.05)
        : AppColors.slateBlue.withOpacity(0.05);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          clipBehavior: Clip.hardEdge,
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
          decoration: BoxDecoration(
            color: _hovered ? hoverBg : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(
            children: [
              Icon(
                Icons.chat_bubble_outline_rounded,
                size: 12,
                color: textColor.withOpacity(0.5),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.session.firstMessage,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: textColor,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (_hovered)
                GestureDetector(
                  onTap: () => _showDeleteConfirmation(context),
                  child: Icon(
                    Icons.close_rounded,
                    size: 13,
                    color: textColor.withOpacity(0.5),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(context).deleteConversationTitle),
        content: Text(AppLocalizations.of(context).deleteConversationBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ChatCubit>().deleteSession(widget.session.sessionId);
            },
            child: Text(
              AppLocalizations.of(context).delete,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Authenticated footer ──────────────────────────────────────────────────────

class _AuthFooter extends StatelessWidget {
  const _AuthFooter({required this.user, required this.isDark});
  final dynamic user;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final name = (user?.displayName as String?) ?? 'User';
    final initials = name
        .trim()
        .split(' ')
        .take(2)
        .map<String>((p) => p.isEmpty ? '' : p[0].toUpperCase())
        .join();
    final primary = Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: () => context.read<NavigationCubit>().setTab(AppTab.settings),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primary.withOpacity(0.22),
                    primary.withOpacity(0.10),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: primary.withOpacity(0.25),
                  width: 1.0,
                ),
              ),
              child: Center(
                child: Text(
                  initials.isEmpty ? 'U' : initials,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.ink,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    AppLocalizations.of(context).settings,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.settings_outlined,
              size: 15,
              color:
                  (isDark ? AppColors.darkTextTertiary : AppColors.textTertiary)
                      .withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Guest footer ──────────────────────────────────────────────────────────────

class _GuestFooter extends StatelessWidget {
  const _GuestFooter({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => WelcomeDrawer.show(context),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Icon(
              Icons.login_rounded,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 10),
            Text(
              'Sign In',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Rail avatar (collapsed footer) ───────────────────────────────────────────

class _RailAvatar extends StatelessWidget {
  const _RailAvatar({required this.user, required this.isDark});
  final dynamic user;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final name = (user?.displayName as String?) ?? 'U';
    final initials = name
        .trim()
        .split(' ')
        .take(2)
        .map<String>((p) => p.isEmpty ? '' : p[0].toUpperCase())
        .join();
    final primary = Theme.of(context).colorScheme.primary;

    return Tooltip(
      message: name,
      child: InkWell(
        onTap: () => context.read<NavigationCubit>().setTab(AppTab.settings),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primary.withOpacity(0.22),
                primary.withOpacity(0.10),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: primary.withOpacity(0.25),
              width: 1.0,
            ),
          ),
          child: Center(
            child: Text(
              initials.isEmpty ? 'U' : initials,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
