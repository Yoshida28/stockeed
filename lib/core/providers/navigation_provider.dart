import 'package:flutter_riverpod/flutter_riverpod.dart';

class NavigationState {
  final int currentIndex;
  final bool isNavbarCollapsed;

  const NavigationState({
    required this.currentIndex,
    required this.isNavbarCollapsed,
  });

  NavigationState copyWith({
    int? currentIndex,
    bool? isNavbarCollapsed,
  }) {
    return NavigationState(
      currentIndex: currentIndex ?? this.currentIndex,
      isNavbarCollapsed: isNavbarCollapsed ?? this.isNavbarCollapsed,
    );
  }
}

class NavigationNotifier extends StateNotifier<NavigationState> {
  NavigationNotifier()
      : super(const NavigationState(currentIndex: 0, isNavbarCollapsed: false));

  void setCurrentIndex(int index) {
    state = state.copyWith(currentIndex: index);
  }

  void toggleNavbarCollapse() {
    state = state.copyWith(isNavbarCollapsed: !state.isNavbarCollapsed);
  }

  void setNavbarCollapsed(bool collapsed) {
    state = state.copyWith(isNavbarCollapsed: collapsed);
  }
}

final navigationProvider =
    StateNotifierProvider<NavigationNotifier, NavigationState>((ref) {
  return NavigationNotifier();
});
