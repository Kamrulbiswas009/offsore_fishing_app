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
/// Selectable items are marked with an asterisk (*) in the specification and have `isSelectable: true`.
const List<SpeciesNode> speciesHierarchy = [
  // ── Pelagic ──────────────────────────────────────────────────────────────
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
          SpeciesNode(name: 'Yellowfin Tuna', isSelectable: true),
        ],
      ),
      SpeciesNode(name: 'Wahoo', isSelectable: true),
    ],
  ),

  // ── Reef / Bottom ─────────────────────────────────────────────────────────
  SpeciesNode(
    name: 'Reef / Bottom',
    isSelectable: false,
    children: [
      SpeciesNode(
        name: 'Grouper',
        isSelectable: false,
        children: [
          SpeciesNode(name: 'Black Grouper', isSelectable: true),
          SpeciesNode(name: 'Gag Grouper', isSelectable: true),
          SpeciesNode(name: 'Red Grouper', isSelectable: true),
          SpeciesNode(name: 'Scamp Grouper', isSelectable: true),
          SpeciesNode(name: 'Snowy Grouper', isSelectable: true),
          SpeciesNode(name: 'Warsaw Grouper', isSelectable: true),
          SpeciesNode(name: 'Yellow Edge Grouper', isSelectable: true),
        ],
      ),
      SpeciesNode(
        name: 'Jack',
        isSelectable: false,
        children: [
          SpeciesNode(name: 'Amberjack', isSelectable: true),
          SpeciesNode(name: 'Almaco Jack', isSelectable: true),
        ],
      ),
      SpeciesNode(
        name: 'Snapper',
        isSelectable: false,
        children: [
          SpeciesNode(name: 'Cubera Snapper', isSelectable: true),
          SpeciesNode(name: 'Lane Snapper', isSelectable: true),
          SpeciesNode(name: 'Mangrove Snapper', isSelectable: true),
          SpeciesNode(name: 'Mutton Snapper', isSelectable: true),
          SpeciesNode(name: 'Red Snapper', isSelectable: true),
          SpeciesNode(name: 'Vermilion Snapper', isSelectable: true),
          SpeciesNode(name: 'Queen Snapper', isSelectable: true),
          SpeciesNode(name: 'Yellowtail Snapper', isSelectable: true),
        ],
      ),
      SpeciesNode(
        name: 'Tilefish',
        isSelectable: false,
        children: [
          SpeciesNode(name: 'Blueline Tilefish', isSelectable: true),
          SpeciesNode(name: 'Golden Tilefish', isSelectable: true),
        ],
      ),
      SpeciesNode(name: 'Triggerfish', isSelectable: true),
    ],
  ),
];
