import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// The four main app tabs
enum AppTab { chat, scanner, forum, settings }

class NavigationState {
  const NavigationState({
    this.activeTab = AppTab.chat,
    this.isDesktopSidebarCollapsed = false,
    this.isMobileDrawerOpen = false,
    this.title,
    this.actions,
    this.leading,
  });

  final AppTab activeTab;

  /// Desktop: true = icon rail (72 px), false = full (260 px)
  final bool isDesktopSidebarCollapsed;

  /// Mobile: true = overlay drawer visible
  final bool isMobileDrawerOpen;

  /// Optional page-specific top bar overrides
  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;

  NavigationState copyWith({
    AppTab? activeTab,
    bool? isDesktopSidebarCollapsed,
    bool? isMobileDrawerOpen,
    Widget? title,
    List<Widget>? actions,
    Widget? leading,
    bool clearTitle = false,
    bool clearActions = false,
    bool clearLeading = false,
    bool clearAppBar = false,
  }) {
    return NavigationState(
      activeTab: activeTab ?? this.activeTab,
      isDesktopSidebarCollapsed:
          isDesktopSidebarCollapsed ?? this.isDesktopSidebarCollapsed,
      isMobileDrawerOpen: isMobileDrawerOpen ?? this.isMobileDrawerOpen,
      title: (clearAppBar || clearTitle) ? null : (title ?? this.title),
      actions: (clearAppBar || clearActions) ? null : (actions ?? this.actions),
      leading: (clearAppBar || clearLeading) ? null : (leading ?? this.leading),
    );
  }
}

class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(const NavigationState());

  void setTab(AppTab tab) {
    emit(state.copyWith(activeTab: tab, isMobileDrawerOpen: false, clearAppBar: true));
  }


  void toggleDesktopSidebar() {
    emit(state.copyWith(
      isDesktopSidebarCollapsed: !state.isDesktopSidebarCollapsed,
    ));
  }

  void openMobileDrawer() {
    emit(state.copyWith(isMobileDrawerOpen: true));
  }

  void closeMobileDrawer() {
    emit(state.copyWith(isMobileDrawerOpen: false));
  }

  void updateAppBar({Widget? title, List<Widget>? actions, Widget? leading}) {
    emit(state.copyWith(
      title: title,
      actions: actions,
      leading: leading,
      clearTitle: title == null,
      clearActions: actions == null,
      clearLeading: leading == null,
    ));
  }

  void clearAppBar() {
    emit(state.copyWith(clearAppBar: true));
  }
}
