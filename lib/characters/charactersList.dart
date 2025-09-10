import 'package:flutter/material.dart';
import '../services/service.dart';
import '../models/characterModels.dart';

class Characterslist extends StatefulWidget {
  @override
  _CharacterslistState createState() => _CharacterslistState();
}

class _CharacterslistState extends State<Characterslist> {
  List<CharacterModel> _characters = [];
  int _paginaAtual = 1;
  bool _carregando = false;
  bool _temMais = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchCharacters();
  }

  Future<void> _fetchCharacters() async {
    if (_carregando || !_temMais) return;
    setState(() {
      _carregando = true;
      _error = null;
    });
    try {
      final newCharacters = await APIService().fetchCharacters(page: _paginaAtual);
      setState(() {
        if (newCharacters.isEmpty) {
          _temMais = false;
        } else {
          _characters.addAll(newCharacters);
          _paginaAtual++;
        }
      });
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar personagens';
      });
    } finally {
      setState(() {
        _carregando = false;
      });
    }
  }

  Future<void> _refreshCharacters() async {
    setState(() {
      _characters.clear();
      _paginaAtual = 1;
      _temMais = true;
      _error = null;
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
          : _characters.isEmpty && _carregando
              ? Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _refreshCharacters,
                  child: ListView.builder(
                    itemCount: _characters.length + (_temMais ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < _characters.length) {
                        final character = _characters[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          child: ListTile(
                            leading: Image.network(
                              character.image,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                            title: Text(character.name),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CharacterDetailScreen(character: character),
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
                            child: _carregando
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