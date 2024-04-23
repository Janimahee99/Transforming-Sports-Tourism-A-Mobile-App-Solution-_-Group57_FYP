import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sportswander/UI/booking.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  Set<Marker> _markers = {};
  LatLng _currentPosition = LatLng(0, 0); // Default initial position

  GoogleMapsPlaces _places = GoogleMapsPlaces(
    apiKey:
        'AIzaSyBThdwS_PQ3CP6gOveuOlcVQ-M2FX55YjY', // Replace with your API key
  );

  LatLng? _selectedPlacePosition;
  List<PlacesSearchResult> _hotelResults = [];
  List<PlacesSearchResult> _stadiumResults = [];
  List<PlacesSearchResult> _restaurantResults = [];
  List<PlacesSearchResult> _sportsPlacesResults = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation().then((currentPosition) {
      setState(() {
        _currentPosition = currentPosition;
      });
      _goToCurrentLocation(currentPosition);
      _addMarker(currentPosition, BitmapDescriptor.hueRed, 'Current Location');
      _getNearbyPlaces(currentPosition);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 14.0,
            ),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            markers: _markers,
            onTap: (LatLng position) {
              setState(() {
                _selectedPlacePosition = position;
              });
            },
          ),
          Positioned(
            bottom: 16.0,
            right: 180.0,
            child: FloatingActionButton(
              backgroundColor: Colors.amber.shade700.withOpacity(0.8),
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReservationScreen(
                      hotels: _hotelResults,
                      stadiums: _stadiumResults,
                      restaurants: _restaurantResults,
                      sportsPlaces: _sportsPlacesResults,
                      location: _currentPosition, // Pass current location
                    ),
                  ),
                );
              },
              child: Icon(
                Icons.hotel,
                color: Colors.white,
              ), // Change icon to whatever you prefer
            ),
          ),
          Positioned(
            bottom: 16.0,
            left: 220.0,
            child: FloatingActionButton.extended(
              onPressed: () {
                _showLegend();
              },
              backgroundColor: Colors.amber.shade700.withOpacity(0.8),
              label: const Text(
                'Legend',
                style: TextStyle(color: Colors.white, fontFamily: "MadimiOne"),
              ),
              icon: const Icon(
                Icons.info_outline,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _goToCurrentLocation(LatLng currentPosition) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: currentPosition,
        zoom: 14.0,
      ),
    ));
  }

  void _addMarker(LatLng position, double markerHue, String title) {
    _markers.add(
      Marker(
        markerId: MarkerId(title),
        position: position,
        icon: BitmapDescriptor.defaultMarkerWithHue(markerHue),
        infoWindow: InfoWindow(
          title: title,
          snippet: 'Lat: ${position.latitude}, Lng: ${position.longitude}',
        ),
      ),
    );
  }

  Future<void> _getNearbyPlaces(LatLng currentPosition) async {
    final double radius = 5000; // 5 kilometers radius

    try {
      // Search for stadiums
      PlacesSearchResponse responseStadiums =
          await _places.searchNearbyWithRadius(
        Location(lat: currentPosition.latitude, lng: currentPosition.longitude),
        radius,
        type: 'stadium',
      );
      _addPlacesMarkers(responseStadiums.results, BitmapDescriptor.hueViolet);

      // Search for hotels
      PlacesSearchResponse responseHotels =
          await _places.searchNearbyWithRadius(
        Location(lat: currentPosition.latitude, lng: currentPosition.longitude),
        radius,
        type: 'lodging',
      );
      _addPlacesMarkers(responseHotels.results, BitmapDescriptor.hueYellow);

      // Search for restaurants
      PlacesSearchResponse responseRestaurants =
          await _places.searchNearbyWithRadius(
        Location(lat: currentPosition.latitude, lng: currentPosition.longitude),
        radius,
        type: 'restaurant',
      );
      _addPlacesMarkers(
          responseRestaurants.results, BitmapDescriptor.hueOrange);

      // Search for sports places
      PlacesSearchResponse responseSportsPlaces =
          await _places.searchNearbyWithRadius(
        Location(lat: currentPosition.latitude, lng: currentPosition.longitude),
        radius,
        type: 'sport',
      );
      _addPlacesMarkers(responseSportsPlaces.results, BitmapDescriptor.hueBlue);
    } catch (error) {
      print('Error fetching nearby places: $error');
    }
  }

  void _addPlacesMarkers(List<PlacesSearchResult>? places, double markerHue) {
    if (places == null) return;

    for (var place in places) {
      if (place.geometry != null && place.geometry?.location != null) {
        LatLng position = LatLng(
          place.geometry!.location.lat,
          place.geometry!.location.lng,
        );
        _addMarker(position, markerHue, place.name ?? 'Unknown Place');

        // Add fetched places to the respective lists based on their type
        switch (place.types?.first) {
          case 'lodging':
            _hotelResults.add(place);
            break;
          case 'stadium':
            _stadiumResults.add(place);
            break;
          case 'restaurant':
            _restaurantResults.add(place);
            break;
          case 'sport':
            _sportsPlacesResults.add(place);
            break;
          default:
            break;
        }
      }
    }
    setState(() {});
  }

  Future<LatLng> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return LatLng(position.latitude, position.longitude);
  }

  void _showLegend() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Legend'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.pin_drop_rounded, color: Colors.blue),
                title: Text('Stadiums'),
              ),
              ListTile(
                leading: Icon(Icons.pin_drop_rounded, color: Colors.yellow),
                title: Text('Hotels'),
              ),
              ListTile(
                leading: Icon(Icons.pin_drop_rounded, color: Colors.orange),
                title: Text('Restaurants'),
              ),
              ListTile(
                leading: Icon(Icons.pin_drop_rounded, color: Colors.blue),
                title: Text('Sports Places'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
