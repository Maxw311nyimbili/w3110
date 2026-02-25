import 'package:flutter_bloc/flutter_bloc.dart';

class NavigationState {
  final bool isSidebarCollapsed;

  const NavigationState({this.isSidebarCollapsed = false});

  NavigationState copyWith({bool? isSidebarCollapsed}) {
    return NavigationState(
      isSidebarCollapsed: isSidebarCollapsed ?? this.isSidebarCollapsed,
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
}
