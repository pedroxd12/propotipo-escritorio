// lib/data/models/service_model.dart
class ServiceModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final int duration; // en minutos
  final List<String> imagePaths;

  const ServiceModel({
    required this.id,
    required this.name,
    this.description = '',
    this.price = 0.0,
    this.duration = 0,
    this.imagePaths = const [],
  });

  ServiceModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    int? duration,
    List<String>? imagePaths,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      duration: duration ?? this.duration,
      imagePaths: imagePaths ?? this.imagePaths,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'duration': duration,
      'imagePaths': imagePaths,
    };
  }

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      duration: json['duration'] as int? ?? 0,
      imagePaths: (json['imagePaths'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? const [],
    );
  }
}