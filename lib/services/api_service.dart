import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/dance_group.dart';

/// Error with a friendly message we can show in the UI.
/// fieldErrors holds the per-field messages from a 422 response.
class ApiException implements Exception {
  ApiException(this.message, {this.fieldErrors = const {}});

  final String message;
  final Map<String, String> fieldErrors;

  @override
  String toString() => message;
}

/// All CRUD calls to our PHP REST API.
class ApiService {
  static const Map<String, String> _jsonHeaders = {
    'Content-Type': 'application/json; charset=utf-8',
    'Accept': 'application/json',
  };

  final Uri _groupsUrl = Uri.parse(AppConfig.groupsUrl);

  /// dance_groups.php?id=5
  Uri _urlWithId(int id) =>
      _groupsUrl.replace(queryParameters: {'id': '$id'});

  // READ all
  Future<List<DanceGroup>> getGroups() async {
    final data = await _send(
      () => http.get(_groupsUrl, headers: {'Accept': 'application/json'}),
    );
    return (data as List)
        .map((item) => DanceGroup.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // CREATE
  Future<DanceGroup> createGroup(DanceGroup group) async {
    final data = await _send(
      () => http.post(
        _groupsUrl,
        headers: _jsonHeaders,
        body: jsonEncode(group.toJson()),
      ),
    );
    return DanceGroup.fromJson(data as Map<String, dynamic>);
  }

  // UPDATE (PUT, or POST + "_method": "PUT" as a fallback)
  Future<DanceGroup> updateGroup(DanceGroup group) async {
    final url = _urlWithId(group.id!);
    final data = await _send(() {
      if (AppConfig.useMethodOverride) {
        final body = {...group.toJson(), '_method': 'PUT'};
        return http.post(url, headers: _jsonHeaders, body: jsonEncode(body));
      }
      return http.put(url, headers: _jsonHeaders, body: jsonEncode(group.toJson()));
    });
    return DanceGroup.fromJson(data as Map<String, dynamic>);
  }

  // DELETE (DELETE, or POST + "_method": "DELETE" as a fallback)
  Future<void> deleteGroup(int id) async {
    final url = _urlWithId(id);
    await _send(() {
      if (AppConfig.useMethodOverride) {
        return http.post(
          url,
          headers: _jsonHeaders,
          body: jsonEncode({'_method': 'DELETE'}),
        );
      }
      return http.delete(url, headers: {'Accept': 'application/json'});
    });
  }

  /// Runs a request with a 15s timeout, reads the JSON envelope
  /// { success, message, data } and returns "data".
  /// Throws ApiException with a friendly message on any problem.
  Future<dynamic> _send(Future<http.Response> Function() request) async {
    final http.Response response;
    try {
      response = await request().timeout(AppConfig.requestTimeout);
    } on TimeoutException {
      throw ApiException(
        'The server took too long to answer. Is XAMPP running?',
      );
    } on http.ClientException {
      throw ApiException(
        'Cannot reach the server at ${AppConfig.apiBaseUrl}. '
        'Check the URL and your network.',
      );
    } on Exception {
      throw ApiException('Network error. Please try again.');
    }

    final Map<String, dynamic> body;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) throw const FormatException();
      body = decoded;
    } on FormatException {
      throw ApiException(
        'The server sent an invalid response (HTTP ${response.statusCode}).',
      );
    }

    final ok = response.statusCode >= 200 && response.statusCode < 300;
    if (ok && body['success'] == true) {
      return body['data'];
    }

    // 422 = validation failed: data holds { "field": "message" }.
    final fieldErrors = <String, String>{};
    if (response.statusCode == 422 && body['data'] is Map) {
      (body['data'] as Map).forEach((key, value) {
        fieldErrors['$key'] = '$value';
      });
    }
    throw ApiException(
      body['message'] as String? ??
          'Request failed (HTTP ${response.statusCode}).',
      fieldErrors: fieldErrors,
    );
  }
}
