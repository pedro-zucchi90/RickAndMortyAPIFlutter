import 'package:flutter/material.dart';
import '../models/characterModels.dart';
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

  // Adicionando variáveis para pesquisa
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;


  @override
  void initState() {
    super.initState();
    _fetchCharacters();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim();
    });
    // Chama a busca a cada caractere digitado
    _searchCharacters();
  }

  Future<void> _fetchCharacters() async {
    if (_isLoading || !_hasMore) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await http.get(Uri.parse('https://rickandmortyapi.com/api/character?page=$_currentPage'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final info = data['info'] as Map<String, dynamic>;
        final List<CharacterModel> novosPersonagens = (data['results'] as List)
            .map((item) => CharacterModel.fromJson(item))
            .toList();

        setState(() {
          _totalPages = info['pages'] ?? 0;
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

  // Função para pesquisar personagens
  Future<void> _searchCharacters() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _characters.clear();
        _currentPage = 1;
        _hasMore = true;
        _error = null;
        _totalPages = 1;
        _isSearching = false;
      });
      await _fetchCharacters();
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _isSearching = true;
      _hasMore = false;
    });

    try {
      final response = await http.get(Uri.parse('https://rickandmortyapi.com/api/character/?name=$query'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<CharacterModel> personagensPesquisados = (data['results'] as List)
            .map((item) => CharacterModel.fromJson(item))
            .toList();

        setState(() {
          _characters = personagensPesquisados;
          _error = null;
        });
      } else {
        setState(() {
          _characters = [];
          _error = 'Nenhum personagem encontrado.';
        });
      }
    } catch (e) {
      setState(() {
        _characters = [];
        _error = 'Erro ao pesquisar personagens';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Personagens'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Pesquisar personagem',
                hintText: 'Digite o nome do personagem',
                prefixIcon: Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          FocusScope.of(context).unfocus();
                        },
                      )
                    : null,
                border: OutlineInputBorder(),
              ),
              // Atualiza a cada caractere digitado
              onChanged: (value) {
                _onSearchChanged();
              },
              onSubmitted: (value) {
                _onSearchChanged();
              },
            ),
          ),
          Expanded(
            child: _error != null
                ? Center(child: Text(_error!))
                : _characters.isEmpty && _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: _refreshCharacters,
                        child: ListView.builder(
                          itemCount: _characters.length + (!_isSearching && _hasMore ? 1 : 0),
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
          ),
        ],
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