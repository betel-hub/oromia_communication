class Tender {
  final int id;
  final String title;
  final String description;
  final DateTime deadline;
  final String? documentUrl;

  Tender({
    required this.id,
    required this.title,
    required this.description,
    required this.deadline,
    this.documentUrl,
  });

  factory Tender.fromJson(Map<String, dynamic> json) {
    return Tender(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      deadline: DateTime.tryParse(json['deadline'] ?? '') ?? DateTime.now(),
      documentUrl: json['document_url'],
    );
  }
}