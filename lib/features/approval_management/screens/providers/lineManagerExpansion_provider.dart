import 'package:flutter_riverpod/flutter_riverpod.dart';

// State notifier for managing expansion state of line manager menu sections
class LineManagerExpansionNotifier extends StateNotifier<Map<String, bool>> {
  LineManagerExpansionNotifier() : super({});

  // Toggle a specific section's expansion state
  void toggleSection(String sectionKey) {
    state = {
      ...state,
      sectionKey: !(state[sectionKey] ?? false), // ✅ default is false
    };
  }

  // Expand a specific section
  void expandSection(String sectionKey) {
    state = {...state, sectionKey: true};
  }

  // Collapse a specific section
  void collapseSection(String sectionKey) {
    state = {...state, sectionKey: false};
  }

  // Expand all sections
  void expandAll(List<String> sectionKeys) {
    final Map<String, bool> newState = {};
    for (final key in sectionKeys) {
      newState[key] = true;
    }
    state = {...state, ...newState};
  }

  // Collapse all sections
  void collapseAll(List<String> sectionKeys) {
    final Map<String, bool> newState = {};
    for (final key in sectionKeys) {
      newState[key] = false;
    }
    state = {...state, ...newState};
  }

  // Check if a section is expanded
  bool isExpanded(String sectionKey) {
    return state[sectionKey] ?? false;
  }

  // Get the count of expanded sections
  int get expandedCount {
    return state.values.where((expanded) => expanded).length;
  }

  // Reset all expansion states
  void reset() {
    state = {};
  }
}

// Provider for the line manager expansion state
final lineManagerExpansionProvider =
    StateNotifierProvider<LineManagerExpansionNotifier, Map<String, bool>>(
      (ref) => LineManagerExpansionNotifier(),
    );

// Optional: Provider for getting specific section expansion state
final lineManagerSectionExpansionProvider = Provider.family<bool, String>((
  ref,
  sectionKey,
) {
  final expansionState = ref.watch(lineManagerExpansionProvider);
  return expansionState[sectionKey] ?? false; // ✅ consistent default
});

// Optional: Provider for getting expanded section count
final expandedLineManagerSectionsCountProvider = Provider<int>((ref) {
  final expansionState = ref.watch(lineManagerExpansionProvider);
  return expansionState.values.where((expanded) => expanded).length;
});
