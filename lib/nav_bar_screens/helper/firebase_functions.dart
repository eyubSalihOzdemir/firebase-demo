import 'package:firebase_storage/firebase_storage.dart';

// function to get list of all items in a folder (firebase storage)
Future<ListResult> getListResult(String folder) async {
  final storageRef = FirebaseStorage.instance.ref();
  final imagesRef = storageRef.child('$folder/');
  var result = await imagesRef.listAll();
  //print("result: ${result.items.length}");

  return result;
}

// function to get an individual item's download url in a folder (firebase storage)
Future<String?> getItemUrl(folder, index) async {
  var result = await getListResult(folder);
  var gotString = await result.items.elementAt(index).getDownloadURL();
  return gotString;
}

// function to get all sounds url's at the same time (firebase storage)
//
// this was necessary because nested FutureBuilders used in the sounds_screen.dart
// second FutureBuilder was using the "index" from ListView.builder in it's future call function
// and second FutureBuilder's build function was firing more than it should.
// it's fixed by getting all the sound url's at once before calling second FutureBuilder, and using ListView.builder's "index"
// property in the second FutureBuilder to iterate through that list.
Future<List> getSondUrlList() async {
  List<String> songUrls = [];
  var result = await getListResult('sounds');
  for (var item in result.items) {
    songUrls.add(await item.getDownloadURL());
  }

  return songUrls;
}
