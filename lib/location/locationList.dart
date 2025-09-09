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
  late Future<List<LocationModel>> locationsFuture;

  @override
  void initState() {
    super.initState();
    locationsFuture = LocationService().fetchLocations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Locais'),
      ),
      body: FutureBuilder<List<LocationModel>>(
        future: locationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar locais'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Nenhum local encontrado'));
          }
          final locations = snapshot.data!;
          return ListView.builder(
            itemCount: locations.length,
            itemBuilder: (context, index) {
              final location = locations[index];
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
            },
          );
        },
      ),
    );
  }
}

class LocationDetailScreen extends StatefulWidget {
  final LocationModel location;

  const LocationDetailScreen({Key? key, required this.location}) : super(key: key);

  @override
  _LocationDetailScreenState createState() => _LocationDetailScreenState();
}

class _LocationDetailScreenState extends State<LocationDetailScreen> {
  late Future<List<Map<String, dynamic>>> residentesFuture;

  @override
  void initState() {
    super.initState();
    residentesFuture = fetchResidentes(widget.location.residents);
  }

  Future<List<Map<String, dynamic>>> fetchResidentes(List<String> urls) async {
    List<Map<String, dynamic>> residentes = [];
    for (String url in urls) {
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          residentes.add({
            'name': data['name'],
            'image': data['image'],
          });
        }
      } catch (e) {
        // Se der erro, adiciona um residente "desconhecido"
        residentes.add({
          'name': 'Desconhecido',
          'image': null,
        });
      }
    }
    return residentes;
  }

  @override
  Widget build(BuildContext context) {
    final location = widget.location;
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
              future: residentesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Erro ao carregar residentes');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('Nenhum residente encontrado');
                }
                final residentes = snapshot.data!;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: residentes.length,
                  itemBuilder: (context, index) {
                    final residente = residentes[index];
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        residente['image'] != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  residente['image'],
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
                          residente['name'] ?? 'Desconhecido',
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