import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sportswander/UI/booking.dart';
import 'package:sportswander/UI/info.dart';
import 'package:sportswander/UI/map.dart';
import 'package:sportswander/UI/news.dart';
import 'package:sportswander/UI/weather.dart';
import 'package:unicons/unicons.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    MapScreen(),
    ReservationScreen(
      hotels: [],
      stadiums: [],
      restaurants: [],
      sportsPlaces: [],
      location: LatLng(0, 0),
    ),
    WeatherScreen(),
    NewsScreen(),
    InfoScreen(),
  ];

  InterstitialAd? _interstitialAd;

  // Ad unit ID for test purposes
  final adUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712' // Replace with your actual ad unit ID
      : 'ca-app-pub-3940256099942544/8691691433';

  @override
  void initState() {
    super.initState();
    loadInterstitialAd(); // Load interstitial ad when the widget initializes
  }

  @override
  void dispose() {
    disposeInterstitialAd(); // Dispose of interstitial ad when the widget is disposed
    super.dispose();
  }

  // Loads an interstitial ad
  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('Interstitial ad loaded: $ad');
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial ad failed to load: $error');
        },
      ),
    );
  }

  // Method to show the loaded interstitial ad
  void showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
    } else {
      debugPrint('InterstitialAd is not loaded yet.');
    }
  }

  // Method to dispose of the interstitial ad
  void disposeInterstitialAd() {
    _interstitialAd?.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Show interstitial ad when user navigates to a different screen
      if (index != 0) {
        showInterstitialAd();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 232, 226, 226),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.shifting,
          landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book),
              label: 'Bookings',
            ),
            BottomNavigationBarItem(
              icon: Icon(UniconsLine.cloud_sun),
              label: 'Weather',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.article),
              label: 'News',
            ),
            BottomNavigationBarItem(
              icon: Icon(UniconsLine.info_circle),
              label: 'Info',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Color.fromARGB(255, 255, 176, 7),
          selectedLabelStyle: TextStyle(fontFamily: 'MadimiOne', fontSize: 14),
          unselectedLabelStyle:
              TextStyle(fontFamily: 'MadimiOne', fontSize: 14),
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
