import 'dart:async';
import 'dart:convert';

import 'package:google_drive/domain/fake_data.dart';
import 'package:google_drive/service/client_service.dart';
import 'package:google_drive/service/fake_data_service.dart';
import 'package:googleapis/drive/v3.dart';

class DriveService {
  static const String FOLDER_NAME = 'GoogleDriveTest';

  //this scope only lets this app access what it has created.
  final scopes = [DriveApi.DriveFileScope];
  final FakeDataService fakeDataService = FakeDataService();

  Future<String> exportData() async {
    DriveApi driveApi = DriveApi(await ClientService().getClient(scopes));

    // use this to find out if there is space available
    // About about = await driveApi.about.get($fields: 'storageQuota');
    // if (about.storageQuota.usage >= about.storageQuota.limit) {
    //throw an error?
    // }

    String folderId = await getFolderId(FOLDER_NAME, driveApi);

    //this is metadata about the file
    File file = File();
    file.description = 'Test File';
    file.name = 'testfile.csv';
    //it will be created within a folder
    file.parents = [folderId];

    //simulate pulling data from a database
    List<FakeData> results = fakeDataService.getDataFromDatabase();

    //create data in a stream to be written to the file
    int dataLength = 0;
    StreamController<List<int>> sc = StreamController();
    results.forEach((element) {
      List<int> data = utf8.encode(
          '${element.id},${element.firstName},${element.lastName},${element.emailAddress}\n');
      dataLength += data.length;
      sc.sink.add(data);
    });
    sc.close();

    Media media = Media(sc.stream, dataLength);
    //create the file with our data
    await driveApi.files.create(file, uploadMedia: media);
    return file.name;
  }

  Future<String> getFolderId(String folderName, DriveApi driveApi) async {
    //filter files based on name and type (folder)
    FileList fileList = await driveApi.files.list(
      $fields: 'files/name,files/id',
      q: "mimeType='application/vnd.google-apps.folder' and name='$folderName'",
    );
    //see if our folder is in the list
    for (File element in fileList.files) {
      if (element.name == folderName) {
        //it is, so return the id
        return element.id;
      }
    }

    //folder doesn't exist, so create it
    String folderId = await createFolder(driveApi);
    return folderId;
  }

  Future<String> createFolder(DriveApi driveApi) async {
    File folder = new File();
    folder.name = FOLDER_NAME;
    folder.mimeType = 'application/vnd.google-apps.folder';
    File result = await driveApi.files.create(folder, $fields: 'id');
    return result.id;
  }
}
