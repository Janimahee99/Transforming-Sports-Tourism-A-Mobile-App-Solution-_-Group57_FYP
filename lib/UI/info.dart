import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:sportswander/UI/drawer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class InfoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 232, 226, 226),
      drawer: ProfileDrawer(),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 232, 226, 226),
        title: Text('Info',
            style: TextStyle(
                fontFamily: "MadimiOne",
                fontSize: 30,
                color: Colors.grey[800],
                fontWeight: FontWeight.bold)), // Apply font family
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: Icon(
              Icons.contacts,
              color: Colors.redAccent,
              size: 35,
            ),
            title: Text('Emergency Contacts',
                style: TextStyle(
                    fontFamily: "MadimiOne",
                    color: Colors.grey[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 18)), // Apply font family
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EmergencyContactsPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.eco,
              color: Colors.green,
              size: 35,
            ),
            title: Text('Eco-friendly Instructions',
                style: TextStyle(
                    fontFamily: "MadimiOne",
                    color: Colors.grey[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 18)), // Apply font family
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EcoFriendlyInstructionsPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.star,
              color: Colors.amber,
              size: 35,
            ),
            title: Text('Rate Our App',
                style: TextStyle(
                    fontFamily: "MadimiOne",
                    color: Colors.grey[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 18)), // Apply font family
            onTap: () async {
              final double? ratedAmount = await _showRatingDialog(context);
              if (ratedAmount != null) {
                _setRatedAmount(ratedAmount);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        FeedbackAndSupportPage(rating: ratedAmount),
                  ),
                );
              }
            },
          ),
          ListTile(
            leading: Icon(
              Icons.feedback,
              color: Colors.blueAccent,
              size: 35,
            ),
            title: Text('Feedback and Support',
                style: TextStyle(
                    fontFamily: "MadimiOne",
                    color: Colors.grey[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 18)), // Apply font family
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        FeedbackAndSupportPage(rating: _getRatedAmount())),
              );
            },
          ),
        ],
      ),
    );
  }
}

class EmergencyContactsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Emergency Contacts',
          style: TextStyle(
              fontFamily: "MadimiOne",
              color: Colors.grey[800],
              fontWeight: FontWeight.bold,
              fontSize: 30),
        ),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: Icon(
              Icons.phone,
              color: Colors.orangeAccent,
            ),
            title: Text('Police: 119',
                style: TextStyle(
                    fontFamily: "MadimiOne",
                    color: Colors.grey[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 18)), // Apply font family
            onTap: () {
              _launchPhone('119');
            },
          ),
          ListTile(
            leading: Icon(
              Icons.phone,
              color: Colors.orangeAccent,
            ),
            title: Text('Fire Department: 110',
                style: TextStyle(
                    fontFamily: "MadimiOne",
                    color: Colors.grey[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 18)), // Apply font family
            onTap: () {
              _launchPhone('110');
            },
          ),
          ListTile(
            leading: Icon(
              Icons.phone,
              color: Colors.orangeAccent,
            ),
            title: Text('Ambulance: 1990',
                style: TextStyle(
                    fontFamily: "MadimiOne",
                    color: Colors.grey[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 18)), // Apply font family
            onTap: () {
              _launchPhone('1990');
            },
          ),
          ListTile(
            leading: Icon(
              Icons.phone,
              color: Colors.orangeAccent,
            ),
            title: Text('Hospital: 011-1234567',
                style: TextStyle(
                    fontFamily: "MadimiOne",
                    color: Colors.grey[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 18)), // Apply font family
            onTap: () {
              _launchPhone('0111234567');
            },
          ),
        ],
      ),
    );
  }
}

class EcoFriendlyInstructionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 232, 226, 226),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 232, 226, 226),
        title: Text(
          'Eco-friendly Instructions',
          style: TextStyle(
              fontFamily: "MadimiOne",
              color: Colors.grey[800],
              fontWeight: FontWeight.bold,
              fontSize: 26),
        ),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: Icon(
              Icons.recycling,
              color: Colors.green,
              size: 50,
            ), // Icon for recycling
            title: Text(
              'Recycle paper, plastic, and glass.',
              style: TextStyle(
                  fontFamily: "MadimiOne",
                  color: Colors.grey[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.lightbulb,
              color: Colors.amber,
              size: 50,
            ), // Icon for energy-efficient appliances
            title: Text(
              'Use energy-efficient appliances.',
              style: TextStyle(
                  fontFamily: "MadimiOne",
                  color: Colors.grey[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.opacity,
              color: Colors.blue,
              size: 50,
            ), // Icon for reducing water usage
            title: Text(
              'Reduce water usage by fixing leaks.',
              style: TextStyle(
                  fontFamily: "MadimiOne",
                  color: Colors.grey[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.directions_bus,
              color: Colors.indigo,
              size: 50,
            ), // Icon for using public transportation
            title: Text(
              'Use public transportation or carpool.',
              style: TextStyle(
                  fontFamily: "MadimiOne",
                  color: Colors.grey[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class FeedbackAndSupportPage extends StatelessWidget {
  final double? rating;

  FeedbackAndSupportPage({this.rating});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Feedback and Support',
          style: TextStyle(
              fontFamily: "MadimiOne",
              color: Colors.grey[800],
              fontWeight: FontWeight.bold,
              fontSize: 28),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Rate our app:',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: "MadimiOne"), // Apply font family
            ),
            SizedBox(height: 10),
            Row(
              children: <Widget>[
                Icon(Icons.star, color: Colors.amberAccent),
                SizedBox(width: 5),
                Text(
                  '${rating ?? _getRatedAmount() ?? 'No rating yet'}',
                  style: TextStyle(
                      fontSize: 16,
                      fontFamily: "MadimiOne"), // Apply font family
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'If you have any feedback or need support, please contact us:',
              style: TextStyle(
                  fontSize: 16, fontFamily: "MadimiOne"), // Apply font family
            ),
            SizedBox(height: 10),
            ListTile(
              tileColor: Colors.grey[200],
              leading: Icon(Icons.email, color: Colors.redAccent),
              title: Text('support@example.com',
                  style:
                      TextStyle(fontFamily: "MadimiOne")), // Apply font family
              onTap: () {
                _launchEmail('support@example.com');
              },
            ),
            SizedBox(
              height: 8,
            ),
            ListTile(
              tileColor: Colors.grey[200],
              leading: Icon(
                Icons.phone,
                color: Colors.indigoAccent,
              ),
              title: Text('+1 (123) 456-7890',
                  style:
                      TextStyle(fontFamily: "MadimiOne")), // Apply font family
              onTap: () {
                _launchPhone('+11234567890');
              },
            ),
          ],
        ),
      ),
    );
  }
}

void _launchPhone(String phoneNumber) async {
  String url = 'tel:$phoneNumber';
  if (await canLaunchUrlString(url)) {
    await launchUrlString(url);
  } else {
    throw 'Could not launch $url';
  }
}

void _launchEmail(String emailAddress) async {
  String url = 'mailto:$emailAddress';
  if (await canLaunchUrlString(url)) {
    await launchUrlString(url);
  } else {
    throw 'Could not launch $url';
  }
}

void _setRatedAmount(double ratedAmount) {
  _ratedAmount = ratedAmount;
}

double? _getRatedAmount() {
  return _ratedAmount;
}

double? _ratedAmount;

Future<double?> _showRatingDialog(BuildContext context) async {
  double? rating = 0;
  return await showDialog<double>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Rate Our App'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            RatingBar.builder(
              initialRating: 0,
              minRating: 0,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 40,
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (value) {
                rating = value;
              },
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(rating),
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}
