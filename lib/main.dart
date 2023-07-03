// ignore_for_file: deprecated_member_use, library_private_types_in_public_api

import 'dart:convert' show json;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const EarthquakeApp());
}

class EarthquakeApp extends StatelessWidget {
  const EarthquakeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Earthquake App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          headline6: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 22, 9, 9),
          ),
          subtitle1: TextStyle(
            fontSize: 16,
            color: Color.fromARGB(221, 12, 26, 228),
          ),
        ),
      ),
      home: const EarthquakeListScreen(),
    );
  }
}

class EarthquakeListScreen extends StatefulWidget {
  const EarthquakeListScreen({Key? key}) : super(key: key);

  @override
  _EarthquakeListScreenState createState() => _EarthquakeListScreenState();
}

class _EarthquakeListScreenState extends State<EarthquakeListScreen> {
  List<Earthquake> earthquakes = [];

  Future<void> fetchEarthquakes() async {
    final response = await http.get(
      Uri.parse(
          'https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/2.5_day.geojson'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final features = data['features'];

      setState(() {
        earthquakes = features
            .map<Earthquake>((json) => Earthquake.fromJson(json))
            .toList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchEarthquakes();
  }

  void rearrangeRows() {
    setState(() {
      earthquakes.shuffle();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Earthquakes'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: rearrangeRows,
            child: const Text('Rearrange Rows'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: earthquakes.length,
              itemBuilder: (ctx, index) => ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EarthquakeDetailsScreen(
                        earthquake: earthquakes[index],
                      ),
                    ),
                  );
                },
                leading: const Icon(Icons.public, color: Colors.blue),
                title: Text(
                  earthquakes[index].place,
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                subtitle: Text(
                  'Magnitude: ${earthquakes[index].magnitude}',
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EarthquakeDetailsScreen extends StatelessWidget {
  final Earthquake earthquake;

  const EarthquakeDetailsScreen({Key? key, required this.earthquake})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Earthquake Details'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date: ${earthquake.date}',
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(height: 8),
            Text(
              'Details: ${earthquake.details}',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Location: ${earthquake.location}',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Magnitude: ${earthquake.magnitude}',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                // Handle link tap
              },
              child: Text(
                'Link: ${earthquake.link}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Earthquake {
  final String place;
  final double magnitude;
  final String date;
  final String details;
  final String location;
  final String link;

  Earthquake({
    required this.place,
    required this.magnitude,
    required this.date,
    required this.details,
    required this.location,
    required this.link,
  });

  factory Earthquake.fromJson(Map<String, dynamic> json) {
    final properties = json['properties'];
    final place = properties['place'];
    final magnitude = properties['mag'].toDouble();
    final date =
        DateTime.fromMillisecondsSinceEpoch(properties['time']).toString();
    final details = properties['title'];
    final location = properties['place'];
    const link = 'www.moredetails.com';

    return Earthquake(
      place: place,
      magnitude: magnitude,
      date: date,
      details: details,
      location: location,
      link: link,
    );
  }
}
