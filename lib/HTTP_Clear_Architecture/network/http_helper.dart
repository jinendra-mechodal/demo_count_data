import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HttpHelper {
  // GET API HANDLE
  Future<dynamic> get({required String url, bool isRequireAuthorization = false}) async {
    Map<String, String> apiHeaders = {"Content-type": "application/json"};

    if (isRequireAuthorization) {
      apiHeaders["Authorization"] = "Bearer userBearerToken";
    }

    try {
      final apiResponse = await http.get(Uri.parse(url), headers: apiHeaders);

      printValue(tag: "API GET URL: ", value: url);
      printValue(tag: "API Headers: ", value: apiHeaders);
      printValue(tag: "API RESPONSE: ", value: apiResponse.body);

      return _returnResponse(response: apiResponse);
    } on SocketException {
      throw Exception('No Internet connection');
    } catch (e) {
      throw Exception('Failed to fetch data: $e');
    }
  }

  // POST API HANDLE
  Future<dynamic> post({required String url, required Map<String, dynamic> body, bool isRequireAuthorization = false}) async {
    Map<String, String> apiHeaders = {"Content-type": "application/json"};

    if (isRequireAuthorization) {
      apiHeaders["Authorization"] = "Bearer userBearerToken";
    }

    try {
      final apiResponse = await http.post(Uri.parse(url), headers: apiHeaders, body: json.encode(body));

      printValue(tag: "API POST URL: ", value: url);
      printValue(tag: "API Headers: ", value: apiHeaders);
      printValue(tag: "API BODY: ", value: body);
      printValue(tag: "API RESPONSE: ", value: apiResponse.body);

      return _returnResponse(response: apiResponse);
    } on SocketException {
      throw Exception('No Internet connection');
    } catch (e) {
      throw Exception('Failed to post data: $e');
    }
  }

  // PUT API HANDLE
  Future<dynamic> put({required String url, required Map<String, dynamic> body, bool isRequireAuthorization = false}) async {
    Map<String, String> apiHeaders = {"Content-type": "application/json"};

    if (isRequireAuthorization) {
      apiHeaders["Authorization"] = "Bearer userBearerToken";
    }

    try {
      final apiResponse = await http.put(Uri.parse(url), headers: apiHeaders, body: json.encode(body));

      printValue(tag: "API PUT URL: ", value: url);
      printValue(tag: "API Headers: ", value: apiHeaders);
      printValue(tag: "API BODY: ", value: body);
      printValue(tag: "API RESPONSE: ", value: apiResponse.body);

      return _returnResponse(response: apiResponse);
    } on SocketException {
      throw Exception('No Internet connection');
    } catch (e) {
      throw Exception('Failed to update data: $e');
    }
  }

  // DELETE API HANDLE
  Future<dynamic> delete({required String url, bool isRequireAuthorization = false}) async {
    Map<String, String> apiHeaders = {"Content-type": "application/json"};

    if (isRequireAuthorization) {
      apiHeaders["Authorization"] = "Bearer userBearerToken";
    }

    try {
      final apiResponse = await http.delete(Uri.parse(url), headers: apiHeaders);

      printValue(tag: "API DELETE URL: ", value: url);
      printValue(tag: "API Headers: ", value: apiHeaders);
      printValue(tag: "API RESPONSE: ", value: apiResponse.body);

      return _returnResponse(response: apiResponse);
    } on SocketException {
      throw Exception('No Internet connection');
    } catch (e) {
      throw Exception('Failed to delete data: $e');
    }
  }
}

dynamic _returnResponse({required http.Response response}) {
  switch (response.statusCode) {
    case 200:
      return json.decode(response.body);
    case 201:
      return json.decode(response.body);
    case 204:
      return null; // No content
    case 400:
      throw Exception('Bad Request: ${response.body}');
    case 401:
      throw Exception('Unauthorized: ${response.body}');
    case 403:
      throw Exception('Forbidden: ${response.body}');
    case 404:
      throw Exception('Not Found: ${response.body}');
    case 500:
      throw Exception('Internal Server Error: ${response.body}');
    case 502:
      throw Exception('Bad Gateway: ${response.body}');
    case 503:
      throw Exception('Service Unavailable: ${response.body}');
    default:
      throw Exception('Unexpected error: ${response.statusCode}, ${response.body}');
  }
}

void printValue({required String tag, required dynamic value}) {
  print('$tag$value');
}
