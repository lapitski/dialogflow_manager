import 'package:flutter/material.dart';
import 'package:dialogflow_manager/dialogflow_manager.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Map<dynamic, dynamic> intent = {
    "displayName": "hello-world-intent",
    "priority": 500000,
    "trainingPhrases": [
      {
        "type": "EXAMPLE",
        "parts": [
          {"text": "hello"}
        ]
      }
    ],
    "messages": [
      {
        "text": {
          "text": ["Hello World!"]
        }
      }
    ]
  };
  //TODO: need to enter your projet name
  final String projectName = 'projectName';
  //TODO: need a path to your json file which added to assets
  final String assetPath = 'assets/project-name.json';

  Future<void> postItent() async {
    var manager = DialogflowManager();
    AuthGoogle authGoogle = await AuthGoogle(fileJson: assetPath).build();
    var resp = await manager.postItent(
        authGoogle: authGoogle, intent: intent, projectName: projectName);
    if (resp['error'] == null) {
      print('intent uploaded');
    } else {
      print('error: ${resp['error']['message']}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dialogflow_manager Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
          appBar: AppBar(
            title: Text('Dialogflow_manager Demo'),
          ),
          body: Center(
            child: RaisedButton(
              onPressed: () {
                postItent();
              },
              child: Text('Add intent'),
            ),
          )),
    );
  }
}
