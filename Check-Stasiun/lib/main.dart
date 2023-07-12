import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class Station {
  final String code;
  final String name;
  final String city;
  final String cityName;

  Station({
    required this.code,
    required this.name,
    required this.city,
    required this.cityName,
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<List<Station>> _stationsFuture;
  late List<Station> _stations;
  late List<Station> _filteredStations;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _stationsFuture = fetchStations();
  }

  Future<List<Station>> fetchStations() async {
    final response =
        await http.get(Uri.parse('https://booking.kai.id/api/stations2'));

    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      final List<Station> stations = [];

      for (var stationData in responseData) {
        Station station = Station(
          code: stationData['code'],
          name: stationData['name'],
          city: stationData['city'],
          cityName: stationData['cityname'],
        );
        stations.add(station);
      }

      return stations;
    } else {
      throw Exception('Gagal memuat stasiun');
    }
  }

  void filterStations(String keyword) {
    setState(() {
      _filteredStations = _stations.where((station) {
        return station.name.toLowerCase().contains(keyword.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stasiun Indonesia',
      theme: ThemeData(
        primaryColor: Colors.blue,
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.blueAccent),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue,
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'Stasiun Indonesia',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Container(
              margin: EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari stasiun...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onChanged: (value) {
                  filterStations(value);
                },
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Station>>(
                future: _stationsFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    _stations = snapshot.data!;
                    _filteredStations = _stations;

                    if (_searchController.text.isNotEmpty) {
                      _filteredStations = _stations.where((station) {
                        return station.name.toLowerCase().contains(
                              _searchController.text.toLowerCase(),
                            );
                      }).toList();
                    }

                    return ListView.builder(
                      itemCount: _filteredStations.length,
                      itemBuilder: (context, index) {
                        Station station = _filteredStations[index];
                        return Card(
                          elevation: 2.0,
                          margin: EdgeInsets.symmetric(
                            horizontal: 10.0,
                            vertical: 5.0,
                          ),
                          child: ListTile(
                            title: Text(
                              '${station.name} - ${station.cityName}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(station.city),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16.0,
                            ),
                          ),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Terjadi Kesalahan: ${snapshot.error}'),
                    );
                  }

                  return Center(
                    child: CircularProgressIndicator(),
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
