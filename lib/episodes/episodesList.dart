import 'package:flutter/material.dart';
import '../services/service.dart';
import '../models/episodesModel.dart';
import '../models/infoModel.dart';

class EpisodesList extends StatefulWidget {
  @override
  _EpisodesListState createState() => _EpisodesListState();
}

class _EpisodesListState extends State<EpisodesList> {
  final EpisodeService _episodeService = EpisodeService();
  final APIService _apiService = APIService();

  List<EpisodesModel> _episodes = [];
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;

  // Variáveis para pesquisa
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  // Timer para debounce (não usado, mas pode ser implementado)
  Future<void>? _searchFuture;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchEpisodes();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim();
    });
    _searchEpisodes();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMore && !_isSearching) {
        _fetchEpisodes();
      }
    }
  }

  Future<void> _fetchEpisodes() async {
    if (_isLoading || !_hasMore) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      // Usando o service para buscar episódios paginados
      final response = await _episodeService.fetchEpisodesPaginated(_currentPage);
      setState(() {
        _episodes.addAll(response['episodes']);
        _totalPages = response['totalPages'];
        if (_currentPage >= _totalPages || response['episodes'].isEmpty) {
          _hasMore = false;
        } else {
          _currentPage++;
          _hasMore = _currentPage <= _totalPages;
        }
      });
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
      _isSearching = false;
      _searchQuery = '';
      _searchController.clear();
    });
    await _fetchEpisodes();
  }

  // Função para pesquisar episódios
  Future<void> _searchEpisodes() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _episodes.clear();
        _currentPage = 1;
        _hasMore = true;
        _error = null;
        _totalPages = 1;
        _isSearching = false;
      });
      await _fetchEpisodes();
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _isSearching = true;
      _hasMore = false; // Não paginar durante busca
    });

    try {
      final episodiosPesquisados = await _episodeService.searchEpisodesByName(query);
      setState(() {
        _episodes = episodiosPesquisados;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _episodes = [];
        _error = 'Nenhum episódio encontrado.';
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
        title: Text('Lista de Episódios'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Pesquisar episódio',
                hintText: 'Digite o nome do episódio',
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
                : _episodes.isEmpty && _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: _refreshEpisodes,
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: _episodes.length + (!_isSearching && _hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index < _episodes.length) {
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
                            } else {
                              // Botão "Carregar mais" (não exibe durante busca)
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: _isLoading
                                      ? CircularProgressIndicator()
                                      : ElevatedButton(
                                          onPressed: _fetchEpisodes,
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

class EpisodeDetailScreen extends StatefulWidget {
  final EpisodesModel episode;

  const EpisodeDetailScreen({Key? key, required this.episode}) : super(key: key);

  @override
  _EpisodeDetailScreenState createState() => _EpisodeDetailScreenState();
}

class _EpisodeDetailScreenState extends State<EpisodeDetailScreen> {
  late Future<List<Map<String, dynamic>>> charactersFuture;
  final APIService _apiService = APIService();

  @override
  void initState() {
    super.initState();
    charactersFuture = fetchCharacters(widget.episode.characters);
  }

  Future<List<Map<String, dynamic>>> fetchCharacters(List<String> urls) async {
    List<Map<String, dynamic>> characters = [];
    for (String url in urls) {
      try {
        final data = await _apiService.fetchCharacterByUrl(url);
        if (data != null) {
          characters.add({
            'name': data['name'],
            'image': data['image'],
          });
        }
      } catch (e) {
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

