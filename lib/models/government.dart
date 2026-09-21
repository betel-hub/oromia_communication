class RegionalSector {
  final int id;
  final String name;
  final String description;
  final String? phone;
  final String? email;

  RegionalSector({
    required this.id,
    required this.name,
    required this.description,
    this.phone,
    this.email,
  });

  factory RegionalSector.fromJson(Map<String, dynamic> json) {
    return RegionalSector(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      phone: json['phone'],
      email: json['email'],
    );
  }
}

class GovRegion {
  final int id;
  final String name;
  final String type; // zone | woreda | city | sub_city | kebele
  final int? parentId;
  final int childCount;

  GovRegion({
    required this.id,
    required this.name,
    required this.type,
    this.parentId,
    this.childCount = 0,
  });

  factory GovRegion.fromJson(Map<String, dynamic> json) {
    return GovRegion(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      type: json['type'] ?? 'zone',
      parentId: json['parent_id'],
      childCount: json['child_count'] ?? 0,
    );
  }

  String get typeDisplayName {
    switch (type) {
      case 'zone':
        return 'Zone';
      case 'woreda':
        return 'Woreda';
      case 'city':
        return 'City';
      case 'sub_city':
        return 'Sub-City';
      case 'kebele':
        return 'Kebele';
      default:
        return type;
    }
  }

  String get childTypeLabel {
    switch (type) {
      case 'zone':
        return 'Woredas';
      case 'woreda':
        return 'Kebeles';
      case 'city':
        return 'Sub-Cities';
      case 'sub_city':
        return 'Kebeles';
      default:
        return '';
    }
  }
}