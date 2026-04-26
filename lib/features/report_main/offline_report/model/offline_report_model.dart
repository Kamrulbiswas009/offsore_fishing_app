class OfflineReportModel {
  final String id;
  final String species;
  final String? subSpecies;
  final String timeAgo;
  final String depth;
  final String zone;
  final String technique;
  final String bait;
  final String? note;
  final int confirms;
  final String? author;
  final bool isVerified;

  OfflineReportModel({
    required this.id,
    required this.species,
    this.subSpecies,
    required this.timeAgo,
    required this.depth,
    required this.zone,
    required this.technique,
    required this.bait,
    this.note,
    required this.confirms,
    this.author,
    this.isVerified = true,
  });
}