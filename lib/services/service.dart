import '../models/characterModels.dart';
import '../models/episodesModel.dart';
import '../models/locationModel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String baseUrl = 'https://rickandmortyapi.com/api/';

class APIService{

  Future<List<CharacterModel>> fetchCharacters({int page = 1}) async {
    final response = await http.get(Uri.parse('${baseUrl}character?page=$page'));
    if (response.statusCode == 200) {
      final List<dynamic> data = (jsonDecode(response.body)['results']);
      return data.map((item) => CharacterModel(
        id: item['id'],
        name: item['name'],
        status: item['status'],
        species: item['species'],
        type: item['type'],
        gender: item['gender'],
        origin: Origin(
          name: item['origin']['name'],
          url: item['origin']['url'],
        ),
        location: Location(
          name: item['location']['name'],
          url: item['location']['url'],
        ),
        image: item['image'],
        episode: List<String>.from(item['episode']),
        url: item['url'],
        created: item['created'],
      )).toList();
    } else {
      throw Exception('Falha ao carregar personagens');
    }
  }
}

class EpisodeService{

  Future<List<EpisodesModel>> fetchEpisodes() async {
    final response = await http.get(Uri.parse('${baseUrl}episode'));
    if (response.statusCode == 200) {
      final List<dynamic> data = (jsonDecode(response.body)['results']);
      return data.map((item) => EpisodesModel(
        id: item['id'],
        name: item['name'],
        air_date: item['air_date'],
        episode: item['episode'],
        characters: List<String>.from(item['characters']),
        url: item['url'],
        created: item['created'],
      )).toList();
    } else {
      throw Exception('Falha ao carregar episódios');
    }
  }
}

class LocationService{

  Future<List<LocationModel>> fetchLocations() async {
    final response = await http.get(Uri.parse('${baseUrl}location'));
    if (response.statusCode == 200) {
      final List<dynamic> data = (jsonDecode(response.body)['results']);
      return data.map((item) => LocationModel(
        id: item['id'],
        name: item['name'],
        type: item['type'],
        dimension: item['dimension'],
        residents: List<String>.from(item['residents']),
        url: item['url'],
        created: item['created'],
      )).toList();
    } else {
      throw Exception('Falha ao carregar localizações');
    }
  }
}