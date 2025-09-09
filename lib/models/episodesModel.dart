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
    required this.characters,
    required this.episode,
    required this.url,
    required this.created,
  });
}

