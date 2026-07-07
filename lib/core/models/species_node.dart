class SpeciesNode {
  final String name;
  final bool isSelectable;
  final List<SpeciesNode> children;

  const SpeciesNode({
    required this.name,
    required this.isSelectable,
    this.children = const [],
  });

  /// Recursively fetches all selectable species names.
  List<String> get allSelectableLeafNames {
    if (isSelectable) {
      return [name];
    }
    return children.expand((child) => child.allSelectableLeafNames).toList();
  }
}

/// The hierarchical tree structure of species options.
/// Non-selectable categories act as directories.
/// Selectable items are marked with an asterisk in the specification and have `isSelectable: true`.
const List<SpeciesNode> speciesHierarchy = [
  SpeciesNode(
    name: 'Pelagic',
    isSelectable: false,
    children: [
      SpeciesNode(name: 'Bonita', isSelectable: true),
      SpeciesNode(name: 'Cobia', isSelectable: true),
      SpeciesNode(name: 'King Mackerel', isSelectable: true),
      SpeciesNode(name: 'Mahi', isSelectable: true),
      SpeciesNode(
        name: 'Marlin',
        isSelectable: false,
        children: [
          SpeciesNode(name: 'Blue Marlin', isSelectable: true),
          SpeciesNode(name: 'White Marlin', isSelectable: true),
        ],
      ),
      SpeciesNode(name: 'Swordfish', isSelectable: true),
      SpeciesNode(name: 'Tripletail', isSelectable: true),
      SpeciesNode(
        name: 'Tuna',
        isSelectable: false,
        children: [
          SpeciesNode(name: 'Blackfin Tuna', isSelectable: true),
          SpeciesNode(name: 'Bluefin Tuna', isSelectable: true),
        ],
      ),
      SpeciesNode(name: 'Yellowfin Tuna', isSelectable: true),
      SpeciesNode(name: 'Wahoo', isSelectable: true),
    ],
  ),
];
