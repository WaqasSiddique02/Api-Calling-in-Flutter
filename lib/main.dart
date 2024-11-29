import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multi-Feature App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    MovieSearchPage(),
    WeatherAppPage(),
    OSMFlutterMap(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.movie),
            label: 'Movies',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud),
            label: 'Weather',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
        ],
      ),
    );
  }
}

// OMDB Movie Search Page
class MovieSearchPage extends StatefulWidget {
  @override
  _MovieSearchPageState createState() => _MovieSearchPageState();
}

class _MovieSearchPageState extends State<MovieSearchPage> {
  final TextEditingController _controller = TextEditingController();
  final String _movieApiKey = 'a7757013';
  List<dynamic> _movies = [];
  bool _isLoading = false;
  String _error = '';

  Future<void> searchMovies(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = '';
      _movies = [];
    });

    final url =
        Uri.parse('https://www.omdbapi.com/?s=$query&apikey=$_movieApiKey');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['Response'] == 'True') {
          setState(() {
            _movies = data['Search'];
          });
        } else {
          setState(() {
            _error = data['Error'];
          });
        }
      } else {
        setState(() {
          _error = 'Error fetching data';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
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
        title: const Text('OMDB Movie Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Search Movies',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => searchMovies(_controller.text),
                ),
              ),
              onSubmitted: searchMovies,
            ),
            SizedBox(height: 10),
            if (_isLoading) CircularProgressIndicator(),
            if (_error.isNotEmpty)
              Text(
                _error,
                style: TextStyle(color: Colors.red),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: _movies.length,
                itemBuilder: (context, index) {
                  final movie = _movies[index];
                  return ListTile(
                    leading: Image.network(
                      movie['Poster'],
                      width: 50,
                      height: 75,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.broken_image, size: 50),
                    ),
                    title: Text(movie['Title']),
                    subtitle: Text('Year: ${movie['Year']}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Weather App Page
class WeatherAppPage extends StatefulWidget {
  @override
  _WeatherAppPageState createState() => _WeatherAppPageState();
}

class _WeatherAppPageState extends State<WeatherAppPage> {
  final String _weatherApiKey = '912f22ada26bfe69d487b48e12879dfd';
  String islamabadWeather = '16° C';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchIslamabadWeather();
  }

  Future<void> fetchIslamabadWeather() async {
    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=Islamabad&units=metric&appid=$_weatherApiKey');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          islamabadWeather =
              "${data['main']['temp'].toStringAsFixed(1)} °C, ${data['weather'][0]['description']}";
          isLoading = false;
        });
      } else {
        setState(() {
          islamabadWeather = 'Failed to fetch weather.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        islamabadWeather = 'Error fetching weather.';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather App',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade300, Colors.blue.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                isLoading
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : Column(
                        children: [
                          Icon(
                            Icons.cloud,
                            size: 80,
                            color: Colors.white,
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Islamabad Weather',
                            style: TextStyle(
                                fontSize: 28,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Text(
                            islamabadWeather,
                            style: TextStyle(
                              fontSize: 22,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OSMFlutterMap extends StatefulWidget {
  const OSMFlutterMap({super.key});

  @override
  State<OSMFlutterMap> createState() => _OSMFlutterMapState();
}

class _OSMFlutterMapState extends State<OSMFlutterMap> {
  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: const MapOptions(),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
        ),
      ],
    );
  }
}
