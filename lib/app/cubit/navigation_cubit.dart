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
  });

  final AppTab activeTab;

  /// Desktop: true = icon rail (72 px), false = full (260 px)
  final bool isDesktopSidebarCollapsed;

  /// Mobile: true = overlay drawer visible
  final bool isMobileDrawerOpen;

  /// Optional page-specific top bar overrides
  final Widget? title;
  final List<Widget>? actions;

  NavigationState copyWith({
    AppTab? activeTab,
    bool? isDesktopSidebarCollapsed,
    bool? isMobileDrawerOpen,
    Widget? title,
    List<Widget>? actions,
    bool clearAppBar = false,
  }) {
    return NavigationState(
      activeTab: activeTab ?? this.activeTab,
      isDesktopSidebarCollapsed:
          isDesktopSidebarCollapsed ?? this.isDesktopSidebarCollapsed,
      isMobileDrawerOpen: isMobileDrawerOpen ?? this.isMobileDrawerOpen,
      title: clearAppBar ? null : (title ?? this.title),
      actions: clearAppBar ? null : (actions ?? this.actions),
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

  void updateAppBar({Widget? title, List<Widget>? actions}) {
    emit(state.copyWith(title: title, actions: actions));
  }

  void clearAppBar() {
    emit(state.copyWith(clearAppBar: true));
  }
}
