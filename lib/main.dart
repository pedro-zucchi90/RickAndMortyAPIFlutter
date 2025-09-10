import 'package:flutter/material.dart';
import 'characters/charactersList.dart';
import 'episodes/episodesList.dart';
import 'location/locationList.dart' as location;

void main() {
  runApp(MaterialApp(
    title: 'Rick and Morty App',
    home: HomeScreen(),
    )
  );
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Image.asset('../assets/images/app-icon.png'),
        title: Text('Home Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 100.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CharactersList()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  backgroundColor: Colors.white,
                  elevation: 4,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'images/characters.png',
                      width: 160,
                      height: 160,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Characters',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 100.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EpisodesList(),
                    )
                  );  
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  backgroundColor: Colors.white,
                  elevation: 4,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'images/episodes.png',
                      width: 160,
                      height: 160,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Episodes',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 100.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => location.LocationList(),
                    )
                  );  
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  backgroundColor: Colors.white,
                  elevation: 4,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'images/locations.png',
                      width: 160,
                      height: 160,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Locations',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EpisodesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Second Screen'),
      ),
      body: Center(
        child: Text('Bem-vindo à tela de Episodios, betinha'),
      ),
    );
  }
}

class LocationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Second Screen'),
      ),
      body: Center(
        child: Text('Bem-vindo à tela de locais, betinha'),
      ),
    );
  }
}