import '../models/characterModels.dart';
import '../models/episodesModel.dart';
import '../models/locationModel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String baseUrl = 'https://rickandmortyapi.com/api/';

class APIService {
  Future<List<CharacterModel>> fetchCharacters({int page = 1}) async {
    final response = await http.get(Uri.parse('${baseUrl}character?page=$page'));
    if (response.statusCode == 200) {
      final List<dynamic> data = (jsonDecode(response.body)['results']);
      return data
          .map((item) => CharacterModel.fromJson(item))
          .toList();
    } else {
      throw Exception('Falha ao carregar personagens');
    }
  }
}

class EpisodeService {
  Future<List<EpisodesModel>> fetchEpisodes() async {
    final response = await http.get(Uri.parse('${baseUrl}episode'));
    if (response.statusCode == 200) {
      final List<dynamic> data = (jsonDecode(response.body)['results']);
      return data
          .map((item) => EpisodesModel.fromJson(item))
          .toList();
    } else {
      throw Exception('Falha ao carregar episódios');
    }
  }
}

class LocationService {
  Future<List<LocationModel>> fetchLocations() async {
    final response = await http.get(Uri.parse('${baseUrl}location'));
    if (response.statusCode == 200) {
      final List<dynamic> data = (jsonDecode(response.body)['results']);
      return data
          .map((item) => LocationModel.fromJson(item))
          .toList();
    } else {
      throw Exception('Falha ao carregar localizações');
    }
  }

  Future<Map<String, dynamic>?> fetchResident(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}