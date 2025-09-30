import 'package:flutter/material.dart';
import '../services/service.dart';
import '../models/episodesModel.dart';
import '../models/infoModel.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class EpisodesList extends StatefulWidget {
  @override
  _EpisodesListState createState() => _EpisodesListState();
}

class _EpisodesListState extends State<EpisodesList> {
  List<EpisodesModel> _episodes = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;
  int _totalPages = 1;

  @override
  void initState() {
    super.initState();
    _fetchEpisodes();
  }

  Future<void> _fetchEpisodes() async {
    if (_isLoading || !_hasMore) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await http.get(Uri.parse('https://rickandmortyapi.com/api/episode?page=$_currentPage'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final info = Infomodel.fromJson(data['info']);
        final List<dynamic> results = data['results'];
        final novosEpisodios = results.map((item) => EpisodesModel.fromJson(item)).toList();

        setState(() {
          _episodes.addAll(novosEpisodios.cast<EpisodesModel>());
          _totalPages = info.pages;
          if (_currentPage >= _totalPages) {
            _hasMore = false;
          } else {
            _currentPage++;
          }
        });
      } else {
        setState(() {
          _error = 'Erro ao carregar episódios';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar episódios';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshEpisodes() async {
    setState(() {
      _episodes.clear();
      _currentPage = 1;
      _hasMore = true;
      _error = null;
      _totalPages = 1;
    });
    await _fetchEpisodes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Episódios'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshEpisodes,
        child: _error != null
            ? Center(child: Text(_error!))
            : _episodes.isEmpty && _isLoading
                ? Center(child: CircularProgressIndicator())
                : _episodes.isEmpty
                    ? Center(child: Text('Nenhum episódio encontrado'))
                    : ListView.builder(
                        itemCount: _episodes.length + (_hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _episodes.length) {
                            _fetchEpisodes();
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          final episode = _episodes[index];
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                            child: ListTile(
                              title: Text(episode.name),
                              subtitle: Text('Temporada/Episódio: ${episode.episode}'),
                              trailing: Icon(Icons.arrow_forward_ios),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EpisodeDetailScreen(episode: episode),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}

class EpisodeDetailScreen extends StatefulWidget {
  final EpisodesModel episode;

  const EpisodeDetailScreen({Key? key, required this.episode}) : super(key: key);

  @override
  _EpisodeDetailScreenState createState() => _EpisodeDetailScreenState();
}

class _EpisodeDetailScreenState extends State<EpisodeDetailScreen> {
  late Future<List<Map<String, dynamic>>> charactersFuture;

  @override
  void initState() {
    super.initState();
    charactersFuture = fetchCharacters(widget.episode.characters);
  }

  Future<List<Map<String, dynamic>>> fetchCharacters(List<String> urls) async {
    List<Map<String, dynamic>> characters = [];
    for (String url in urls) {
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          characters.add({
            'name': data['name'],
            'image': data['image'],
          });
        }
      } catch (e) {
        // Se der erro, adiciona um personagem "Desconhecido"
        characters.add({
          'name': 'Desconhecido',
          'image': null,
        });
      }
    }
    return characters;
  }

  @override
  Widget build(BuildContext context) {
    final episode = widget.episode;
    return Scaffold(
      appBar: AppBar(
        title: Text(episode.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Nome: ${episode.name}',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'Temporada/Episódio: ${episode.episode}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Data de exibição: ${episode.air_date}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'URL: ${episode.url}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Criado em: ${episode.created}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Personagens:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: charactersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Erro ao carregar personagens');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('Nenhum personagem encontrado');
                }
                final characters = snapshot.data!;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: characters.length,
                  itemBuilder: (context, index) {
                    final character = characters[index];
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        character['image'] != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  character['image'],
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.person, size: 60, color: Colors.grey[600]),
                              ),
                        SizedBox(height: 8),
                        Text(
                          character['name'] ?? 'Desconhecido',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}