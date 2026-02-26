import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NavigationState {
  final bool isSidebarCollapsed;
  final Widget? title;
  final List<Widget>? actions;
  final String? currentRoute;

  const NavigationState({
    this.isSidebarCollapsed = false,
    this.title,
    this.actions,
    this.currentRoute,
  });

  NavigationState copyWith({
    bool? isSidebarCollapsed,
    Widget? title,
    List<Widget>? actions,
    String? currentRoute,
    bool clearAppBar = false,
  }) {
    return NavigationState(
      isSidebarCollapsed: isSidebarCollapsed ?? this.isSidebarCollapsed,
      title: clearAppBar ? null : (title ?? this.title),
      actions: clearAppBar ? null : (actions ?? this.actions),
      currentRoute: currentRoute ?? this.currentRoute,
    );
  }
}

class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(const NavigationState());

  void toggleSidebar() {
    emit(state.copyWith(isSidebarCollapsed: !state.isSidebarCollapsed));
  }

  void setSidebarCollapsed(bool collapsed) {
    emit(state.copyWith(isSidebarCollapsed: collapsed));
  }

  void updateAppBar({Widget? title, List<Widget>? actions}) {
    emit(state.copyWith(
      title: title,
      actions: actions,
      clearAppBar: false,
    ));
  }

  void setRoute(String? route) {
    emit(state.copyWith(currentRoute: route));
  }

  void clearAppBar() {
    emit(state.copyWith(clearAppBar: true));
  }
}
