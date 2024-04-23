import 'dart:async';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

class NewsService {
  late final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late List<Article> lastFetchedArticles = []; // Track last fetched articles

  Future<List<Article>> fetchArticles(String query) async {
    final response = await http.get(
      Uri.parse(
          'https://newsdata.io/api/1/news?apikey=pub_39701bd702c6c299b8440a77fc96ca954d83b&q=$query&language=en&category=sports'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data['results'];
      List<Article> fetchedArticles = [];
      for (var result in results) {
        final article = Article.fromJson(result);
        fetchedArticles.add(article);
      }
      return fetchedArticles;
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

  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> fetchAndShowLatestNews(String query) async {
    final latestArticles = await fetchArticles(query);
    if (latestArticles.isNotEmpty) {
      final latestArticle = latestArticles.first;
      await showNotification(latestArticle.title, latestArticle.url);
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
