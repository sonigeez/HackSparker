import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:hacksparker/src/core/services/network_requester.dart';
import 'package:http/http.dart' as http;
import '../models/story.dart';
import 'package:html/parser.dart' as parser;

class StoryService {
  final String _baseUrl = 'https://hacker-news.firebaseio.com/v0';
  Dio dio = Dio();

  NetworkRequester requester;
  StoryService({required this.requester});

  Future<List<int>> fetchTopStories() async {
    try {
      final response = await dio.get("$_baseUrl/topstories.json");

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

  Future<String> fetchFinalUrl(String initialUrl,
      {int maxRedirects = 5}) async {
    var dio = Dio();
    var redirects = 0;
    var currentUrl = initialUrl;

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        options.followRedirects =
            false; // Disable automatic following of redirects
        handler.next(options);
      },
      onResponse: (response, handler) {
        if (response.statusCode == 301 || response.statusCode == 302) {
          var redirectUrl = response.headers.value('location');
          if (redirectUrl != null) {
            currentUrl = redirectUrl;
            redirects++;
            handler.resolve(response);
          } else {
            handler.reject(DioError(
              error: 'Invalid redirect',
              response: response,
              type: DioErrorType.unknown,
              requestOptions: RequestOptions(),
            ));
          }
        } else {
          handler.next(response);
        }
      },
    ));

    while (redirects < maxRedirects) {
      try {
        var response = await dio.head(currentUrl);

        if (response.statusCode == 301 || response.statusCode == 302) {
          // Handle the redirect
          continue;
        } else {
          break;
        }
      } catch (error) {
        throw Exception('Failed to fetch final URL: $error');
      }
    }

    dio.close();
    return currentUrl;
  }

  Future<Story> fetchStory(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/item/$id.json'));

    if (response.statusCode == 200) {
      Story story = Story.fromJson(
        json.decode(response.body),
      );
      final finalUrl = await fetchFinalUrl(story.url);

      // Fetch HTML content
      final htmlResponse = await dio.get(finalUrl);
      final htmlDocument = parser.parse(htmlResponse.data);

      // Extract description and OG image
      final metaTags = htmlDocument.getElementsByTagName('meta');
      String? description;
      String? ogImage;

      for (var tag in metaTags) {
        final property = tag.attributes['property'];
        final content = tag.attributes['content'];

        if (property == 'og:description') {
          description = content;
        } else if (property == 'og:image') {
          ogImage = content;
        }

        if (description != null && ogImage != null) {
          break;
        }
      }

      // Update story with extracted data
      story.description = description ?? 'No description available';
      log("ogImage $ogImage");
      story.ogImage = ogImage ??
          'https://cdn.dribbble.com/users/3093/screenshots/797096/hn-logo-dribbble-shot.png';

      return story;
    } else {
      throw Exception('Failed to load story');
    }
  }
}
