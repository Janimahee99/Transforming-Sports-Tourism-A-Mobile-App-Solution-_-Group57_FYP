import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class PlaceDetailsScreen extends StatefulWidget {
  final PlacesSearchResult place;

  const PlaceDetailsScreen({Key? key, required this.place}) : super(key: key);

  @override
  _PlaceDetailsScreenState createState() => _PlaceDetailsScreenState();
}

class _PlaceDetailsScreenState extends State<PlaceDetailsScreen> {
  late Future<PlaceDetails> _placeDetailsFuture;

  @override
  void initState() {
    super.initState();
    _placeDetailsFuture = fetchPlaceDetails(widget.place.placeId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 232, 226, 226),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 232, 226, 226),
        title: Text(
          'Place Details',
          style: TextStyle(
            color: Colors.grey[800],
            fontFamily: "MadimiOne",
            fontSize: 28,
          ),
        ),
      ),
      body: FutureBuilder<PlaceDetails>(
        future: _placeDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.red, size: 50),
                  SizedBox(height: 10),
                  Text(
                    'Error Occurred',
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.red,
                        fontFamily: "MadimiOne"),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                    onPressed: () {
                      // Retry fetching place details
                      setState(() {
                        _placeDetailsFuture =
                            fetchPlaceDetails(widget.place.placeId);
                      });
                    },
                    child: Text(
                      'Retry',
                      style: TextStyle(
                          color: Colors.white, fontFamily: "MadimiOne"),
                    ),
                  ),
                ],
              ),
            );
          } else {
            final placeDetails = snapshot.data!;
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      placeDetails.name ?? '',
                      style: TextStyle(
                          color: Colors.grey[700],
                          fontFamily: "MadimiOne",
                          fontSize: 25),
                    ),
                  ),
                  SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: placeDetails.photos.map((photo) {
                        return Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                                10), // Adjust the radius as needed
                            child: Image.network(
                              photo.photoReference,
                              height:
                                  placeDetails.photos.length == 1 ? 400 : 300,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 16),
                  if (placeDetails.formattedAddress != null)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Address: ',
                          style: TextStyle(
                              color: Colors.grey[800],
                              fontFamily: "MadimiOne",
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                            width:
                                8), // Add some spacing between "Address" and the address content
                        Expanded(
                          child: Text(
                            '${placeDetails.formattedAddress}',
                            style: TextStyle(
                              color: Colors.grey[
                                  700], // Change this color to your desired color
                              fontFamily: "MadimiOne",
                              fontSize: 18,
                            ),
                            overflow: TextOverflow
                                .visible, // Handle overflow with ellipsis
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: 8),
                  if (placeDetails.rating != null)
                    Row(
                      children: [
                        Text(
                          'Rating: ',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontFamily: "MadimiOne",
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(Icons.star, color: Colors.amber),
                        Text(
                          '${placeDetails.rating}',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontFamily: "MadimiOne",
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      if (placeDetails.website != null)
                        ElevatedButton.icon(
                          onPressed: () {
                            // Handle website button press
                            _launchURL(placeDetails.website!);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                          ),
                          icon: Icon(Icons.public,
                              color: Colors
                                  .white), // Global icon for website button
                          label: Text('Website',
                              style: TextStyle(color: Colors.white)),
                        ),
                      SizedBox(width: 8),
                      if (placeDetails.formattedPhoneNumber != null)
                        ElevatedButton.icon(
                          onPressed: () {
                            // Handle phone button press
                            _callNumber(placeDetails.formattedPhoneNumber!);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                          ),
                          icon: Icon(Icons.phone,
                              color:
                                  Colors.white), // Global icon for call button
                          label: Text('Call',
                              style: TextStyle(color: Colors.white)),
                        ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Opening Hours',
                    style: TextStyle(
                        color: Colors.grey[800],
                        fontFamily: "MadimiOne",
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${placeDetails.openingHours!.openNow ? 'Open now' : 'Closed now'}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: "MadimiOne",
                      color: placeDetails.openingHours!.openNow
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _getTodayOpeningHours(
                        placeDetails.openingHours!.weekdayText),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: "MadimiOne",
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Reviews',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: "MadimiOne",
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Divider(
                    color: Colors.grey[400],
                  ),
                  if (placeDetails.reviews.isNotEmpty)
                    // Inside the Column's children
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: placeDetails.reviews.map((review) {
                        // Calculate the number of filled stars
                        int filledStars = (review.rating ?? 0).toInt();

                        // Calculate the remaining fraction of the rating to determine if a half star is needed
                        int remainingFraction =
                            (review.rating ?? 0) - filledStars;
                        bool hasHalfStar = remainingFraction >= 0.5;

                        // Calculate the number of unfilled stars
                        int unfilledStars =
                            5 - filledStars - (hasHalfStar ? 1 : 0);

                        // Create a list of star icons based on the rating value
                        List<Widget> starWidgets =
                            List.generate(filledStars, (index) {
                          return Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 18,
                          );
                        });

                        // Add a half star if needed
                        if (hasHalfStar) {
                          starWidgets.add(Icon(
                            Icons.star_half,
                            color: Colors.amber,
                            size: 18,
                          ));
                        }

                        // Add remaining unfilled stars
                        starWidgets
                            .addAll(List.generate(unfilledStars, (index) {
                          return Icon(
                            Icons.star_border,
                            color: Colors.amber,
                            size: 18,
                          );
                        }));

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Author: ',
                                    style: TextStyle(
                                      color: Colors.grey[
                                          800], // Change this color to your desired color
                                      fontFamily: "MadimiOne",
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '${review.authorName ?? 'Anonymous'}',
                                    style: TextStyle(
                                      color: Colors.grey[
                                          700], // Change this color to your desired color
                                      fontFamily: "MadimiOne",
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              review.text ?? 'No review text available',
                              style: TextStyle(
                                color: Colors.grey[900],
                                fontFamily: "MadimiOne",
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  'Rating: ',
                                  style: TextStyle(
                                    color: Colors.grey[
                                        800], // Change this color to your desired color
                                    fontFamily: "MadimiOne",
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Row(
                                  children: starWidgets,
                                ),
                                SizedBox(
                                    width:
                                        4), // Add some spacing between rating and stars
                              ],
                            ),
                            Divider(
                              color: Colors.grey[400],
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Future<PlaceDetails> fetchPlaceDetails(String placeId) async {
    const apiKey = 'AIzaSyBThdwS_PQ3CP6gOveuOlcVQ-M2FX55YjY';
    const baseUrl = 'https://maps.googleapis.com/maps/api/place/details/json';
    final url =
        '$baseUrl?place_id=$placeId&fields=name,formatted_address,formatted_phone_number,website,rating,reviews,photos,opening_hours&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final result = data['result'];

        // Print the response data for debugging
        print('Response data: $result');

        // Extract reviews
        final List<Review> reviews = (result['reviews'] as List)
            .map((reviewJson) => Review.fromJson(reviewJson))
            .toList();

        // Extract photos
        final List<String> photoReferences = [];
        if (result['photos'] != null) {
          photoReferences.addAll((result['photos'] as List).map((photoJson) =>
              'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${photoJson['photo_reference']}&key=$apiKey'));
        }

        // Extract opening hours
        final List<String> weekdayText = [];
        if (result['opening_hours'] != null &&
            result['opening_hours']['weekday_text'] != null) {
          weekdayText
              .addAll(result['opening_hours']['weekday_text'].cast<String>());
        }

        // Create PlaceDetails object
        return PlaceDetails(
          name: result['name'],
          placeId: placeId,
          formattedAddress: result['formatted_address'],
          formattedPhoneNumber: result['formatted_phone_number'],
          website: result['website'],
          rating: result['rating']?.toDouble(),
          reviews: reviews,
          photos: photoReferences
              .map((reference) =>
                  Photo(photoReference: reference, height: 100, width: 100))
              .toList(),
          openingHours: OpeningHoursDetail(
            openNow: result['opening_hours'] != null
                ? result['opening_hours']['open_now'] ?? false
                : false,
            weekdayText: weekdayText,
          ),
        );
      } else {
        throw Exception('Failed to load place details: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching place details: $error');
      throw Exception('Failed to load place details');
    }
  }

  String _getTodayOpeningHours(List<String> weekdayText) {
    // Check if weekdayText is empty
    if (weekdayText.isEmpty) {
      return 'Opening hours not available';
    }

    // Get current day
    final now = DateTime.now();
    final currentDayIndex = now.weekday - 1; // Weekday index starts from 1

    // Check if currentDayIndex is within the range of weekdayText
    if (currentDayIndex < 0 || currentDayIndex >= weekdayText.length) {
      return 'Opening hours not available';
    }

    // Extract opening hours for the current day
    final todayOpeningHours = weekdayText[currentDayIndex];

    return todayOpeningHours;
  }

  // Function to launch website URL
  void _launchURL(String url) async {
    // Check if the URL is valid
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  // Function to call phone number
  void _callNumber(String phoneNumber) async {
    // Check if the phone number is valid
    if (await canLaunchUrlString('tel:$phoneNumber')) {
      await launchUrlString('tel:$phoneNumber');
    } else {
      throw 'Could not call $phoneNumber';
    }
  }
}

// PlaceDetails, Review, Photo, OpeningHoursDetail, and OpeningHoursPeriod classes

class PlaceDetails {
  final String? name;
  final String? placeId;
  final String? formattedAddress;
  final String? formattedPhoneNumber;
  final String? website;
  final double? rating;
  final List<Review> reviews;
  final List<Photo> photos;
  final OpeningHoursDetail? openingHours;

  PlaceDetails({
    this.name,
    this.placeId,
    this.formattedAddress,
    this.formattedPhoneNumber,
    this.website,
    this.rating,
    this.reviews = const [],
    this.photos = const [],
    this.openingHours,
  });
}

class Review {
  final String? authorName;
  final int? rating;
  final String? text;

  Review({this.authorName, this.rating, this.text});

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      authorName: json['author_name'],
      rating: json['rating'],
      text: json['text'],
    );
  }
}

class Photo {
  final String photoReference;
  final int height;
  final int width;

  Photo(
      {required this.photoReference,
      required this.height,
      required this.width});
}

class OpeningHoursDetail {
  final bool openNow;
  final List<String> weekdayText;

  OpeningHoursDetail({required this.openNow, required this.weekdayText});
}
