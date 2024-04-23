import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:sportswander/UI/drawer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({Key? key}) : super(key: key);

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  late String _uid = FirebaseAuth.instance.currentUser!.uid;
  late List<Article> articles = [];
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  int activeMenuIndex = 0;
  Future<void> fetchArticles(String query) async {
    final response = await http.get(
      Uri.parse(
          'https://newsdata.io/api/1/news?apikey=pub_39701bd702c6c299b8440a77fc96ca954d83b&q=$query&language=en&category=sports'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(response.body);
      final results = data['results'];
      List<Article> fetchedArticles = [];
      for (var result in results) {
        final article = Article.fromJson(result);
        fetchedArticles.add(article);
      }
      setState(() {
        articles = fetchedArticles;
      });

      // Show notification for new articles
      if (articles.isNotEmpty) {
        final article = articles.first;
        await showNotification(article.title, article.url);
      }
    } else {
      throw Exception('Failed to load articles');
    }
  }

  Future<void> showNotification(String title, String url) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'SportsWander News',
      title,
      platformChannelSpecifics,
      payload: url,
    );
  }

  @override
  void initState() {
    super.initState();

    fetchFirstSport();
    initializeNotifications();
    Timer.periodic(Duration(minutes: 600), (timer) {
      fetchFirstSport();
    });
  }

  Future<void> fetchFirstSport() async {
    try {
      final sports = await fetchSelectedSports();
      if (sports.isNotEmpty) {
        fetchArticles(sports.first);
      } else {
        print('No sports found');
      }
    } catch (e) {
      print('Error fetching first sport: $e');
    }
  }

  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    // Set up a callback for when the notification is tapped
    // Note: Ensure you're importing the latest version of flutter_local_notifications
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 232, 226, 226),
      drawer: ProfileDrawer(),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Color.fromARGB(255, 232, 226, 226),
            title: Text(
              'News',
              style: TextStyle(
                color: Colors.grey[800],
                fontFamily: "MadimiOne",
                fontWeight: FontWeight.bold,
                fontSize: 30.0,
              ),
            ),
            pinned: true, // Keeps the app bar visible at the top
            floating: true, // Allows the app bar to hide when scrolling down
            snap: true, // Makes the app bar snap into view when scrolling down
            // Add any additional properties to customize the app bar
          ),
          // Sliver padding to push the content below the app bar
          SliverPadding(
            padding: EdgeInsets.all(8.0),
            sliver: FutureBuilder<List<String>>(
              future: fetchSelectedSports(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SliverToBoxAdapter(
                    child: CircularProgressIndicator(
                      color: Colors.amber,
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return SliverToBoxAdapter(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Text('No sports found'),
                  );
                }
                return SliverToBoxAdapter(
                  child: SizedBox(
                    height: 30, // Adjust the height according to your UI
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                activeMenuIndex = index;
                              });
                              fetchArticles(snapshot.data![index]);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: index == activeMenuIndex
                                    ? Colors.amber
                                    : null,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 4),
                              child: Text(
                                snapshot.data![index],
                                style: TextStyle(
                                  color: index == activeMenuIndex
                                      ? Colors.white
                                      : null,
                                  fontFamily: "MadimiOne",
                                  fontSize: 14.0,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          // Sliver list to contain the articles
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return GestureDetector(
                  onTap: () {
                    _launchURL(articles[index].url);
                  },
                  child: Card(
                    surfaceTintColor: Colors.amber,
                    elevation: 4,
                    margin: EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(
                          articles[index].imageUrl ?? '',
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                articles[index].title,
                                style: TextStyle(
                                  fontFamily: "MadimiOne",
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Published: ${articles[index].published}',
                                style: TextStyle(
                                  fontFamily: "MadimiOne",
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              childCount: articles.length,
            ),
          ),
        ],
      ),
    );
  }

  Future<List<String>> fetchSelectedSports() async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> userData =
          await FirebaseFirestore.instance
              .collection('userData')
              .doc(_uid)
              .get();
      return List<String>.from(userData.data()!['selectedSports']);
    } catch (e) {
      print('Error fetching selected sports: $e');
      return []; // Return empty list in case of error
    }
  }

  Future<void> _launchURL(String? url) async {
    if (url != null && url.isNotEmpty) {
      try {
        final encodedUrl = Uri.encodeFull(url);
        if (await canLaunchUrlString(encodedUrl)) {
          await launchUrlString(encodedUrl);
        } else {
          throw Exception('Could not launch $encodedUrl');
        }
      } catch (e) {
        print('Error launching URL: $e');
      }
    } else {
      print('Invalid URL: $url');
    }
  }
}

class Article {
  final String id;
  final String title;
  final DateTime published;
  final String? imageUrl;
  final String url;

  Article({
    required this.id,
    required this.title,
    required this.published,
    required this.url,
    this.imageUrl,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['article_id'],
      title: json['title'],
      published: DateTime.parse(json['pubDate']),
      url: json['link'], // Assuming the 'link' field holds the article URL
      imageUrl: json['image_url'],
    );
  }
}
