import 'package:flutter_riverpod/flutter_riverpod.dart';

// State notifier for managing expansion state of menu sections
class SelfServiceExpansionNotifier extends StateNotifier<Map<String, bool>> {
  SelfServiceExpansionNotifier() : super({});

  // Toggle a specific section's expansion state
  void toggleSection(String sectionKey) {
    state = {...state, sectionKey: !(state[sectionKey] ?? false)};
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

// Provider for the expansion state
final selfServiceExpansionProvider =
    StateNotifierProvider<SelfServiceExpansionNotifier, Map<String, bool>>(
      (ref) => SelfServiceExpansionNotifier(),
    );

// Optional: Provider for getting specific section expansion state
final sectionExpansionProvider = Provider.family<bool, String>((
  ref,
  sectionKey,
) {
  final expansionState = ref.watch(selfServiceExpansionProvider);
  return expansionState[sectionKey] ?? false;
});

// Optional: Provider for getting expanded sections count
final expandedSectionsCountProvider = Provider<int>((ref) {
  final expansionState = ref.watch(selfServiceExpansionProvider);
  return expansionState.values.where((expanded) => expanded).length;
});

// final selfServiceExpansionProvider =
//     NotifierProvider<SectionExpansionNotifier, Map<String, bool>>(
//       SectionExpansionNotifier.new,
//     );
//
// class SectionExpansionNotifier extends Notifier<Map<String, bool>> {
//   @override
//   Map<String, bool> build() {
//     //TODO do this from the api loading, make all the section true!
//     return {};
//   }
//
//   void toggleSection(String key) {
//     state = {...state, key: !(state[key] ?? true)};
//   }
// }
