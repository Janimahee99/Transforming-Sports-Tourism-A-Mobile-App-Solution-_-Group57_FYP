import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sportswander/UI/drawer.dart';
import 'package:sportswander/UI/place_details.dart';

class ReservationScreen extends StatefulWidget {
  final LatLng location;

  ReservationScreen({
    Key? key,
    required this.location,
    required this.hotels,
    required this.stadiums,
    required this.restaurants,
    required this.sportsPlaces,
  }) : super(key: key);

  final List<PlacesSearchResult> hotels;
  final List<PlacesSearchResult> stadiums;
  final List<PlacesSearchResult> restaurants;
  final List<PlacesSearchResult> sportsPlaces;

  @override
  _ReservationScreenState createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  bool _isDataLoaded = false;
  @override
  void initState() {
    super.initState();
    if (!_isDataLoaded) {
      fetchData();
    }
  }

  Future<void> fetchData() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      LatLng currentLocation = LatLng(position.latitude, position.longitude);

      final apiKey =
          'AIzaSyBThdwS_PQ3CP6gOveuOlcVQ-M2FX55YjY'; // Replace with your API key
      final baseUrl =
          'https://maps.googleapis.com/maps/api/place/nearbysearch/json';
      final radius = 5000; // 5 km
      final types = [
        'lodging',
        'stadium',
        'restaurant',
        'gym'
      ]; // Types of places you want to search for

      widget.hotels.clear();
      widget.stadiums.clear();
      widget.restaurants.clear();
      widget.sportsPlaces.clear();

      for (var type in types) {
        final url =
            '$baseUrl?location=${currentLocation.latitude},${currentLocation.longitude}&radius=$radius&type=$type&key=$apiKey';

        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final results = data['results'] as List<dynamic>;
          print(results);
          if (results != null && results.isNotEmpty) {
            switch (type) {
              case 'lodging':
                widget.hotels.addAll(results
                    .map((result) => PlacesSearchResult.fromJson(result))
                    .toList());
                break;
              case 'stadium':
                widget.stadiums.addAll(results
                    .map((result) => PlacesSearchResult.fromJson(result))
                    .toList());
                break;
              case 'restaurant':
                widget.restaurants.addAll(results
                    .map((result) => PlacesSearchResult.fromJson(result))
                    .toList());
                break;
              case 'gym':
                widget.sportsPlaces.addAll(results
                    .map((result) => PlacesSearchResult.fromJson(result))
                    .toList());
                break;
              default:
                break;
            }
          }
        } else {
          print('Failed to fetch data. Status code: ${response.statusCode}');
          print('Response body: ${response.body}');
          throw Exception('Failed to load data');
        }
      }
    } catch (e) {
      print('Error getting current location: $e');
    }

    setState(() {
      _isDataLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 232, 226, 226),
        drawer: ProfileDrawer(),
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 232, 226, 226),
          title: Text('Nearby Places',
              style: TextStyle(
                  fontFamily: "MadimiOne",
                  color: Colors.grey[800],
                  fontWeight: FontWeight.bold,
                  fontSize: 30)),
          bottom: TabBar(
            labelColor: Colors.amber,
            indicatorColor: Colors.amber,
            labelStyle: TextStyle(
                fontFamily: "MadimiOne", fontSize: 16, color: Colors.grey[700]),
            indicatorSize: TabBarIndicatorSize.label,
            isScrollable: true,
            tabs: [
              Tab(
                text: 'Hotels',
              ),
              Tab(text: 'Stadiums'),
              Tab(text: 'Restaurants'),
              Tab(text: 'Sports Places'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildPlaceList(widget.hotels),
            _buildPlaceList(widget.stadiums),
            _buildPlaceList(widget.restaurants),
            _buildPlaceList(widget.sportsPlaces),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceList(List<PlacesSearchResult> places) {
    return ListView.builder(
      itemCount: places.length,
      itemBuilder: (context, index) {
        final place = places[index];
        return ListTile(
          title: Text(
            place.name ?? 'Unknown',
            style: TextStyle(
              fontFamily: "MadimiOne",
              fontSize: 18,
              color: Colors.grey[800],
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                place.vicinity ?? 'Unknown',
                style: TextStyle(
                  fontFamily: "MadimiOne",
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber),
                  Text(
                    '${place.rating ?? 'N/A'}',
                    style: TextStyle(fontFamily: "MadimiOne"),
                  ),
                ],
              ),
            ],
          ),
          leading: ClipRRect(
            borderRadius:
                BorderRadius.circular(10), // Adjust the value as needed
            child: place.photos != null && place.photos!.isNotEmpty
                ? Image.network(
                    _buildPhotoUrl(place.photos![0].photoReference!),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey,
                    child: Center(child: Icon(Icons.photo)),
                  ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlaceDetailsScreen(place: place),
              ),
            );
          },
        );
      },
    );
  }

  String _buildPhotoUrl(String photoReference) {
    final apiKey =
        'AIzaSyBThdwS_PQ3CP6gOveuOlcVQ-M2FX55YjY'; // Replace with your API key
    return 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoReference&key=$apiKey';
  }
}
