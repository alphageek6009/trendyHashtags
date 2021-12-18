import 'dart:convert';
import 'package:http/http.dart';
import 'package:html/parser.dart' show parse;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:trendyhashtags/model/trending_hashtag_response.dart';

import '../util.dart';

class hashtag_serviceimpl {
  static SharedPreferences localStorage;


  static Future<SharedPreferences> init() async {
    if(localStorage == null){
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      return localStorage;
    }
   return localStorage;
  }

  static Future<String> query(
      String keyword, String filter, bool isShared) async {

    localStorage ??= await SharedPreferences.getInstance();

    String hashTags = '';
    final uri = Uri.parse(
        'https://all-hashtag.com/library/contents/ajax_generator.php');
    final headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    Map<String, dynamic> body = {'keyword': keyword, 'filter': filter};
    final encoding = Encoding.getByName('utf-8');
    Response response = await post(
      uri,
      headers: headers,
      body: body,
      encoding: encoding,
    );

    int statusCode = response.statusCode;
    if (statusCode >= 200 && statusCode < 300) {
      var document = parse(response.body);
      var scriptElements = document.getElementsByClassName("copy-hashtags");
      for (var element in scriptElements) {
        if (element.innerHtml.isNotEmpty && element.innerHtml.startsWith("#")) {
          if (isShared) {
            trending_hashtag_response trending_hashtags =
                trending_hashtag_response(element.innerHtml,
                    element.nextElementSibling.firstChild.text, keyword);
            localStorage.setString(
                keyword + '_' + filter, jsonEncode(trending_hashtags.toJson()));
          }
          if (!isShared && filter == 'top') {
            trending_hashtag_response trending_hashtags =
                trending_hashtag_response(element.innerHtml,
                    element.nextElementSibling.firstChild.text, keyword);
            localStorage.setString(
                keyword + '_recent', jsonEncode(trending_hashtags.toJson()));
          }
          hashTags = element.innerHtml;
        }
      }
    }
    return hashTags;
  }

  static showSnackbar(context, text, time, color) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: time),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // <-- Radius
        ),
      ),
    );
  }

 static Future<bool> loadHashTagData() async {
    CustomColors.items.forEach((element) async {
      await hashtag_serviceimpl.query(element.title,'top', true);
      await hashtag_serviceimpl.query(element.title,'random', true);
      await hashtag_serviceimpl.query(element.title,'live', true);
    });
    return true;
  }

}
