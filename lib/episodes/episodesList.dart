import 'package:flutter/material.dart';
import '../services/service.dart';
import '../models/episodesModel.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class EpisodesList extends StatefulWidget {
  @override
  _EpisodesListState createState() => _EpisodesListState();
}

class _EpisodesListState extends State<EpisodesList> {
  late Future<List<EpisodesModel>> episodesFuture;

  @override
  void initState() {
    super.initState();
    episodesFuture = EpisodeService().fetchEpisodes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Episódios'),
      ),
      body: FutureBuilder<List<EpisodesModel>>(
        future: episodesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar episódios'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Nenhum episódio encontrado'));
          }
          final episodes = snapshot.data!;
          return ListView.builder(
            itemCount: episodes.length,
            itemBuilder: (context, index) {
              final episode = episodes[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: ListTile(
                  title: Text(episode.name),
                  subtitle: Text('Temporada: ${episode.episode}'),
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
          );
        },
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
        // Se der erro, adiciona um personagem "desconhecido"
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