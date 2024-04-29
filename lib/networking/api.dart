// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'package:http/http.dart';

class EventifyAPIs {
  static const String API_URL =
      "https://vrj4dote43.execute-api.us-east-1.amazonaws.com/prod/";

  static const String S3_BUCKET_URL =
      "https://eventifys3media.s3.amazonaws.com/";

  static Future<dynamic> makePostRequest(
      String url, Map<String, dynamic> postBody) async {
    final uri = Uri.parse(url);
    final headers = {'Content-Type': 'application/json'};
    Map<String, dynamic> body = postBody;
    String jsonBody = json.encode(body);
    final encoding = Encoding.getByName('utf-8');
    Response response = await post(
      uri,
      headers: headers,
      body: jsonBody,
      encoding: encoding,
    );

    String responseBody = response.body;
    var result = await json.decode(responseBody);
    return result;
  }

  static Future<dynamic> makeGetRequest(String url) async {
    final uri = Uri.parse(url);
    // final headers = {'Content-Type': 'application/json'};
    // Map<String, dynamic> body = postBody;
    // String jsonBody = json.encode(body);
    // final encoding = Encoding.getByName('utf-8');
    Response response = await get(
      uri,
      // headers: headers,
      // body: jsonBody,
      // encoding: encoding,
    );

    String responseBody = response.body;
    var result = await json.decode(responseBody);
    return result;
  }
}
