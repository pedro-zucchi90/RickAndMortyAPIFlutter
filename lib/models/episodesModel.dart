import 'infoModel.dart';

class EpisodesModel {
  final int id;
  final String name;
  final String air_date;
  final String episode;
  final List<String> characters;
  final String url;
  final String created;

  EpisodesModel({
    required this.id,
    required this.name,
    required this.air_date,
    required this.episode,
    required this.characters,
    required this.url,
    required this.created,
  });

  factory EpisodesModel.fromJson(Map<String, dynamic> json) {
    return EpisodesModel(
      id: json['id'],
      name: json['name'] ?? '',
      air_date: json['air_date'] ?? '',
      episode: json['episode'] ?? '',
      characters: List<String>.from(json['characters'] ?? []),
      url: json['url'] ?? '',
      created: json['created'] ?? '',
    );
  }
}

class EpisodesInfoModel {
  final Infomodel info;
  final List<EpisodesModel> results;

  EpisodesInfoModel({
    required this.info,
    required this.results,
  });

  factory EpisodesInfoModel.fromJson(Map<String, dynamic> json) {
    return EpisodesInfoModel(
      info: Infomodel.fromJson(json['info']),
      results: (json['results'])
          .map((e) => EpisodesModel.fromJson(e))
          .toList(),
    );
  }
}
