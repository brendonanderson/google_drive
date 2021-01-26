import 'package:flutter/material.dart';
import 'package:google_drive/service/drive_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        child: SaveFileWidget(),
      ),
    );
  }
}

class SaveFileWidget extends StatefulWidget {
  @override
  _SaveFileWidgetState createState() => _SaveFileWidgetState();
}

class _SaveFileWidgetState extends State<SaveFileWidget> {
  String filename = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Column(
            children: [
              RaisedButton(
                child: Text('Save File'),
                onPressed: () {
                  //change to await/async if you want to
                  //do this synchronously.
                  DriveService().exportData().then((value) {
                    setState(() {
                      filename = value;
                    });
                  });
                },
              ),
              SizedBox(
                height: 40.0,
              ),
              Text(
                filename.length > 0 ? '$filename saved to Google Drive' : '',
                style: TextStyle(fontSize: 20.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
