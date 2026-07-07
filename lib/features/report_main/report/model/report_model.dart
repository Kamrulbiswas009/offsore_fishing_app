class FishingReport {
  final String? id;
  final String title;
  final String timeAgo;
  final String depth;
  final String zone;
  final String technique;
  final String bait;
  final String? note;
  final int confirms;
  final String? author;
  final String type;

  FishingReport({
    this.id,
    required this.title,
    required this.timeAgo,
    required this.depth,
    required this.zone,
    required this.technique,
    required this.bait,
    this.note,
    required this.confirms,
    this.author,
    this.type = 'public',
  });
}