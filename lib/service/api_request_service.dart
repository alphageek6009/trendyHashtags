import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class api_request_service {
  static Future<void> query(String search) async {
    final prefs = await SharedPreferences.getInstance();
    String url = "https://www.instagram.com/explore/tags/$search/";
    print("inside ...................... " + url);
    var response = await http.get(Uri.parse(url));
    // Check if response is success
    if (response.statusCode >= 200 && response.statusCode < 300) {
      var document = parse(response.body);
      var scriptElements = document.getElementsByTagName("script");
      var payloadString = "";
      List<String> links = [];

      for (var element in scriptElements) {
        if (element.innerHtml.isNotEmpty &&
            element.innerHtml.startsWith("window._sharedData =")) {
          payloadString = element.innerHtml;
          break;
        }
      }

      if (payloadString.isNotEmpty) {
        payloadString = payloadString
            .substring(0, payloadString.length - 1)
            .replaceFirst("window._sharedData", "")
            .replaceFirst("=", "");
        var payload = jsonDecode(payloadString);

        List tagPage = payload['entry_data']['TagPage'];
        if (tagPage != null && tagPage.length > 0) {
          print('tagpage');
          List edges = tagPage[0]['graphql']['hashtag']['edge_hashtag_to_media']
              ['edges'];
          if (edges != null && edges.isNotEmpty) {
            for (var link in edges) {
              print(link['node']['shortcode']);
              links.add('https://www.instagram.com' +
                  '/p/' +
                  link['node']['shortcode'] +
                  '/');
            }
          }
        }
        if (links.isNotEmpty) await saveTrendingHashtags(links, prefs);
      }
    } else {
      print("Query failed: ${response.body} (${response.statusCode})");
      return null;
    }

    prefs.getKeys().forEach((element) {
      int c = prefs.getInt(element);
      print("hashtag name " + element + "count " + c.toString());
    });
  }

  static Future<void> saveTrendingHashtags(
      List<String> links, SharedPreferences prefs) async {
    links.forEach((element) async {
      var response = await http.get(Uri.parse(element));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        var document = parse(response.body);
        var scriptElements = document.getElementsByTagName("script");
        var payloadString = "";
        for (var element in scriptElements) {
          if (element.innerHtml.isNotEmpty &&
              element.innerHtml.startsWith("window._sharedData =")) {
            payloadString = element.innerHtml;
            break;
          }
        }
        if (payloadString.isNotEmpty) {
          payloadString = payloadString
              .substring(0, payloadString.length - 1)
              .replaceFirst("window._sharedData", "")
              .replaceFirst("=", "");
          var payload = jsonDecode(payloadString);
          List postPage = payload['entry_data']['PostPage'];
          if (postPage != null && postPage.isNotEmpty) {
            List edges = postPage[0]['graphql']['shortcode_media']
                ['edge_media_to_caption']['edges'];
            if (edges != null && edges.isNotEmpty) {
              String text = edges[0]['node']['text'];
              if (text.isNotEmpty) {
                for (var hashtag in text.split(' ')) {
                  if (hashtag.startsWith('#')) {
                    print(hashtag);
                    int counter = prefs.getInt(hashtag) ?? 0;
                    prefs.setInt(hashtag, counter);
                  }
                }
              }
            }
          }
        }
      }
    });
  }
}
