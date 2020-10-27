library dialogflow_manager;

import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';

import 'package:http/http.dart' as http;

/// A dialogflow manager.
class DialogflowManager {
  ///Posting intents to dialogflow
  Future<Map> postItent({
    Map<String, dynamic> intent,
    AuthGoogle authGoogle,
    String projectName,
  }) async {
    var url =
        'https://dialogflow.googleapis.com/v2/projects/$projectName/agent/intents';
    Map responce;

    var resp = await http.post(url,
        headers: {
          HttpHeaders.authorizationHeader: "Bearer ${authGoogle.getToken}"
        },
        body: json.encode(intent));
    responce = json.decode(resp.body);
    return responce;
  }

  ///Fetching intents form dialogflow
  Future<Map> fetchItents(
    AuthGoogle authGoogle,
    String projectName,
  ) async {
    var url =
        'https://dialogflow.googleapis.com/v2/projects/$projectName/agent/intents';
    var resp = await http.get(
      url,
      headers: {
        HttpHeaders.authorizationHeader: "Bearer ${authGoogle.getToken}"
      },
    );
    var intents = json.decode(resp.body);
    return intents;
  }
}

/// Google authentication. Need to provide json file.
class AuthGoogle {
  final String fileJson;
  final List<String> scope;
  final String sessionId;
  AuthGoogle(
      {this.fileJson,
      this.scope = const ["https://www.googleapis.com/auth/cloud-platform"],
      this.sessionId = "76543210"});

  String _projectId;
  AccessCredentials _credentials;

  Future<String> getReadJson() async {
    String data = await rootBundle.loadString(this.fileJson);
    return data;
  }

  Future<AuthGoogle> build() async {
    String readJson = await getReadJson();
    Map jsonData = json.decode(readJson);
    var _credentialsResponse = new ServiceAccountCredentials.fromJson(readJson);
    var data = await clientViaServiceAccount(_credentialsResponse, this.scope);
    _projectId = jsonData['project_id'];
    _credentials = data.credentials;
    return this;
  }

  bool get hasExpired {
    return _credentials.accessToken.hasExpired;
  }

  String get getSessionId {
    return sessionId;
  }

  String get getProjectId {
    return _projectId;
  }

  String get getToken {
    return _credentials.accessToken.data;
  }

  Future<http.Response> post(url,
      {Map<String, String> headers, body, Encoding encoding}) async {
    if (!hasExpired) {
      return await http.post(url, headers: headers, body: body);
    } else {
      await build();
      return await http.post(url, headers: headers, body: body);
    }
  }
}
