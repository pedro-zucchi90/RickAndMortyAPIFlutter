import 'package:flutter/material.dart';
import '../services/service.dart';
import '../models/locationModel.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationList extends StatefulWidget {
  @override
  _LocationListState createState() => _LocationListState();
}

class _LocationListState extends State<LocationList> {
  List<LocationModel> _locations = [];
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;

  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _fetchLocations();
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
    _searchLocations();
  }

  Future<void> _fetchLocations() async {
    if (_isLoading || !_hasMore) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await http.get(Uri.parse('https://rickandmortyapi.com/api/location?page=$_currentPage'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final info = data['info'];
        final List<LocationModel> novasLocais = (data['results'] as List<dynamic>)
            .map((item) => LocationModel.fromJson(item))
            .toList();

        setState(() {
          _totalPages = info['pages'];
          if (novasLocais.isEmpty) {
            _hasMore = false;
          } else {
            _locations.addAll(novasLocais);
            _currentPage++;
            _hasMore = _currentPage <= _totalPages;
          }
        });
      } else {
        setState(() {
          _error = 'Erro ao carregar locais';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar locais';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshLocations() async {
    setState(() {
      _locations = [];
      _currentPage = 1;
      _hasMore = true;
      _error = null;
      _totalPages = 1;
      _isSearching = false;
      _searchQuery = '';
      _searchController.clear();
    });
    await _fetchLocations();
  }

  Future<void> _searchLocations() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _locations = [];
        _currentPage = 1;
        _hasMore = true;
        _error = null;
        _totalPages = 1;
        _isSearching = false;
      });
      await _fetchLocations();
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _isSearching = true;
      _hasMore = false;
    });

    try {
      final response = await http.get(Uri.parse('https://rickandmortyapi.com/api/location/?name=$query'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<LocationModel> locaisPesquisados = (data['results'])
            .map((item) => LocationModel.fromJson(item))
            .toList();

        setState(() {
          _locations = locaisPesquisados;
          _error = null;
        });
      } else {
        setState(() {
          _locations = [];
          _error = 'Nenhum local encontrado.';
        });
      }
    } catch (e) {
      setState(() {
        _locations = [];
        _error = 'Erro ao pesquisar locais';
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
        title: Text('Lista de Locais'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Pesquisar local',
                hintText: 'Digite o nome do local',
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
                : _locations.isEmpty && _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: _refreshLocations,
                        child: ListView.builder(
                          itemCount: _locations.length + (!_isSearching && _hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index < _locations.length) {
                              final location = _locations[index];
                              return Card(
                                margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                child: ListTile(
                                  title: Text(location.name),
                                  subtitle: Text('${location.type} - ${location.dimension}'),
                                  trailing: Icon(Icons.arrow_forward_ios),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LocationDetailScreen(location: location),
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
                                          onPressed: _fetchLocations,
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

class LocationDetailScreen extends StatelessWidget {
  final LocationModel location;

  const LocationDetailScreen({Key? key, required this.location}) : super(key: key);

  Future<List<Map<String, dynamic>>> fetchResidents(List<String> urls) async {
    List<Map<String, dynamic>> residents = [];
    for (String url in urls) {
      try {
        final response = await LocationService().fetchResident(url);
        if (response != null) {
          residents.add({
            'name': response['name'],
            'image': response['image'],
          });
        }
      } catch (e) {
        residents.add({
          'name': 'Desconhecido',
          'image': null,
        });
      }
    }
    return residents;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(location.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Nome: ${location.name}',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'Tipo: ${location.type}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Dimensão: ${location.dimension}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'URL: ${location.url}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Criado em: ${location.created}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Residentes (${location.residents.length}):',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchResidents(location.residents),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Erro ao carregar residentes');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('Nenhum residente encontrado');
                }
                final residents = snapshot.data!;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: residents.length,
                  itemBuilder: (context, index) {
                    final resident = residents[index];
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        resident['image'] != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  resident['image'],
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
                          resident['name'] ?? 'Desconhecido',
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