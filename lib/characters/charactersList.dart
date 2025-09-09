import 'package:flutter/material.dart';
import '../services/service.dart';
import '../models/characterModels.dart';

class Characterslist extends StatefulWidget {
  @override
  _CharacterslistState createState() => _CharacterslistState();
}

class _CharacterslistState extends State<Characterslist> {
  late Future<List<CharacterModel>> _charactersFuture;

  @override
  void initState() {
    super.initState();
    _charactersFuture = APIService().fetchCharacters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Personagens'),
      ),
      body: FutureBuilder<List<CharacterModel>>(
        future: _charactersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar personagens'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Nenhum personagem encontrado'));
          }
          final characters = snapshot.data!;
          return ListView.builder(
            itemCount: characters.length,
            itemBuilder: (context, index) {
              final character = characters[index];
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
            },
          );
        }
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