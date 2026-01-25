import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class TabState {
  final List<String> openTabIds;
  final String activeTabId;

  TabState({required this.openTabIds, required this.activeTabId});

  TabState copyWith({List<String>? openTabIds, String? activeTabId}) {
    return TabState(
      openTabIds: openTabIds ?? this.openTabIds,
      activeTabId: activeTabId ?? this.activeTabId,
    );
  }
}

class TabsNotifier extends Notifier<TabState> {
  final _uuid = const Uuid();

  @override
  TabState build() {
    // Inicialmente un tab vacío
    final initialTabId = _uuid.v4();
    return TabState(openTabIds: [initialTabId], activeTabId: initialTabId);
  }

  String addTab({String? tabId}) {
    final newId = tabId ?? _uuid.v4();
    state = state.copyWith(
      openTabIds: [...state.openTabIds, newId],
      activeTabId: newId,
    );
    return newId;
  }

  void setActiveTab(String id) {
    if (state.openTabIds.contains(id)) {
      state = state.copyWith(activeTabId: id);
    }
  }

  void closeTab(String id) {
    if (state.openTabIds.length <= 1) {
      // No cerrar la última pestaña, solo resetearla si quisieramos, pero por UX mejor dejarla.
      // O quizás crear una nueva vacía.
      // Comportamiento Chrome: Cierra ventana. Aquí: No permitimos vacio.
      return;
    }

    final newTabs = List<String>.from(state.openTabIds)..remove(id);
    String newActive = state.activeTabId;

    if (state.activeTabId == id) {
      // Si cerramos la activa, activar la anterior (o la última)
      newActive = newTabs.last;
    }

    state = state.copyWith(openTabIds: newTabs, activeTabId: newActive);
  }
}

final tabsProvider = NotifierProvider<TabsNotifier, TabState>(TabsNotifier.new);
