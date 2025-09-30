import 'infoModel.dart';

class LocationModel {
  final int id;
  final String name;
  final String type;
  final String dimension;
  final List<String> residents;
  final String url;
  final String created;

  LocationModel({
    required this.id,
    required this.name,
    required this.type,
    required this.dimension,
    required this.residents,
    required this.url,
    required this.created,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'],
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      dimension: json['dimension'] ?? '',
      residents: List<String>.from(json['residents'] ?? []),
      url: json['url'] ?? '',
      created: json['created'] ?? '',
    );
  }
}

class LocationsInfoModel {
  final Infomodel info;
  final List<LocationModel> results;

  LocationsInfoModel({
    required this.info,
    required this.results,
  });

  factory LocationsInfoModel.fromJson(Map<String, dynamic> json) {
    return LocationsInfoModel(
      info: Infomodel.fromJson(json['info']),
      results: (json['results'] as List)
          .map((e) => LocationModel.fromJson(e))
          .toList(),
    );
  }
}
