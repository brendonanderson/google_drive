import 'package:google_drive/domain/fake_data.dart';

class FakeDataService {
  List<FakeData> getDataFromDatabase() {
    return List.generate(10, (index) => index)
        .map((e) => FakeData(e, 'First$e', 'Last$e', 'fakeemail$e@email.com'))
        .toList();
  }
}
