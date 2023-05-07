import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import '../models/story.dart';

class StoryService {
  final String _baseUrl = 'https://hacker-news.firebaseio.com/v0';
  Dio dio = Dio();
  int request = 0;

  Future<List<int>> fetchTopStories() async {
    try {
      final startTime = DateTime.now();

      final response = await dio.get('$_baseUrl/topstories.json');

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      request++;

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.data.toString());
        return jsonResponse.cast<int>();
      } else {
        throw Exception('Failed to load top stories');
      }
    } catch (e) {
      log("message $e");
      throw Exception('Failed to load top stories');
    }
  }

  Future<Story> fetchStory(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/item/$id.json'));

    if (response.statusCode == 200) {
      return Story.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load story');
    }
  }
}
