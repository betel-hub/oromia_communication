class Tender {
  final int id;
  final String title;
  final String description;
  final DateTime deadline;
  final String? documentUrl;
  final double fee;
  final bool isFree;

  Tender({
    required this.id,
    required this.title,
    required this.description,
    required this.deadline,
    this.documentUrl,
    this.fee = 0,
    this.isFree = true,
  });

  factory Tender.fromJson(Map<String, dynamic> json) {
    return Tender(
      id: _toInt(json['id'] ?? json['tender_id']),
      title: json['title']?.toString() ?? '',
      description:
          (json['description'] ?? json['summary'] ?? '').toString(),
      deadline: _toDate(
        json['deadline'] ?? json['closing_date'] ?? json['created_at'],
      ),
      documentUrl:
          (json['document_url'] ?? json['document'] ?? '').toString(),
      fee: _toDouble(json['fee'] ?? json['amount']),
      isFree: json['is_free'] == true || _toDouble(json['fee']) == 0,
    );
  }

  int get daysLeft => deadline.difference(DateTime.now()).inDays;
  bool get isClosingSoon => daysLeft > 0 && daysLeft <= 3;
}

int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

double _toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

DateTime _toDate(dynamic value) {
  if (value == null) return DateTime.now();
  if (value is String) {
    return DateTime.tryParse(value) ?? DateTime.now();
  }
  return DateTime.now();
}