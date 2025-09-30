import 'package:flutter/material.dart';
import '../services/service.dart';
import '../models/characterModels.dart';
import '../models/infoModel.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CharactersList extends StatefulWidget {
  @override
  _CharactersListState createState() => _CharactersListState();
}

class _CharactersListState extends State<CharactersList> {
  List<CharacterModel> _characters = [];
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchCharacters();
  }

  Future<void> _fetchCharacters() async {
    if (_isLoading || !_hasMore) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      // Fazendo a requisição manualmente para obter o InfoModel
      final response = await http.get(Uri.parse('https://rickandmortyapi.com/api/character?page=$_currentPage'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final info = Infomodel.fromJson(data['info']);
        final List<CharacterModel> novosPersonagens = (data['results'] as List)
            .map((item) => CharacterModel.fromJson(item))
            .toList();

        setState(() {
          _totalPages = info.pages;
          if (novosPersonagens.isEmpty) {
            _hasMore = false;
          } else {
            _characters.addAll(novosPersonagens);
            _currentPage++;
            _hasMore = _currentPage <= _totalPages;
          }
        });
      } else {
        setState(() {
          _error = 'Erro ao carregar personagens';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar personagens';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshCharacters() async {
    setState(() {
      _characters.clear();
      _currentPage = 1;
      _hasMore = true;
      _error = null;
      _totalPages = 1;
    });
    await _fetchCharacters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Personagens'),
      ),
      body: _error != null
          ? Center(child: Text(_error!))
          : _characters.isEmpty && _isLoading
              ? Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _refreshCharacters,
                  child: ListView.builder(
                    itemCount: _characters.length + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < _characters.length) {
                        final personagem = _characters[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          child: ListTile(
                            leading: Image.network(
                              personagem.image,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                            title: Text(personagem.name),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CharacterDetailScreen(character: personagem),
                                ),
                              );
                            },
                          ),
                        );
                      } else {
                        // Botão "Carregar mais"
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: _isLoading
                                ? CircularProgressIndicator()
                                : ElevatedButton(
                                    onPressed: _fetchCharacters,
                                    child: Text('Carregar mais'),
                                  ),
                          ),
                        );
                      }
                    },
                  ),
                ),
    );
  }
}

class CharacterDetailScreen extends StatelessWidget {
  final CharacterModel character;

  const CharacterDetailScreen({Key? key, required this.character}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(character.name),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                character.image,
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Nome: ${character.name}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Status: ${character.status}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 4),
            Text('Espécie: ${character.species}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 4),
            Text('Tipo: ${character.type.isNotEmpty ? character.type : "Desconhecido"}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 4),
            Text('Gênero: ${character.gender}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 4),
            Text('Origem: ${character.origin.name}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 4),
            Text('Localização: ${character.location.name}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 4),
            Text('Episódios: ${character.episode.length}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 4),
            Text('URL: ${character.url}', style: TextStyle(fontSize: 16, color: Colors.blue)),
            SizedBox(height: 4),
            Text('Criado em: ${character.created}', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}