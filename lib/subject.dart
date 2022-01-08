import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:learnster_academy_notes/display_materials.dart';
import 'package:learnster_academy_notes/onBording/select_semester.dart';
// import 'package:learnster_academy_notes/onBording/select_university.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

ValueNotifier<List<String>> subList = ValueNotifier([]);

Future<void> listExample() async {
  subList.value.clear();
  await Hive.initFlutter();
  var box = await Hive.openBox('studentdata');

  firebase_storage.ListResult result = await firebase_storage
      .FirebaseStorage.instance
      .ref(
          "${box.get("university").toString()}/${box.get("course").toString()}/${box.get("semester").toString()}")
      .listAll();

  // print(
  // "${box.get("university").toString()}/${box.get("course").toString()}/${box.get("semester").toString()}");

  for (var ref in result.prefixes) {
    subList.value.add(ref.name);
  }
  // print(subList.value);
  subList.notifyListeners();
}

class SelectSubject extends StatefulWidget {
  const SelectSubject({Key? key}) : super(key: key);

  @override
  State<SelectSubject> createState() => _SelectSubjectState();
}

class _SelectSubjectState extends State<SelectSubject> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    listExample();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            // color: Colors.black,
            // icon: const Icon(Icons.edit),
            // tooltip: 'Edit your details',
            child: Row(
              children: const [
                Icon(
                  (Icons.edit),
                ),
                // Text("Change semester"),
              ],
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (builder) => const SelectSemester()));

              // showDialog(
              //     context: context,
              //     builder: (ctx) => AlertDialog(
              //           elevation: 10,
              //           title: const Text("Edit your subjects"),
              //           content:
              //               const Text("Do you want to edit your subjects?"),
              //           actions: <Widget>[
              //             TextButton(
              //               onPressed: () {
              //                 Navigator.of(ctx).pop();
              //               },
              //               child: const Text("no"),
              //             ),
              //             TextButton(
              //               onPressed: () {
              //                 Navigator.push(
              //                     context,
              //                     MaterialPageRoute(
              //                         builder: (builder) =>
              //                             const SelectSemester()));
              //                     // (route) => false);
              //               },
              //               child: const Text("Yes"),
              //             ),
              //           ],
              //         ));
            },
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Your subjects",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: subList,
        builder: (context, List value, child) => SafeArea(
            child: subList.value.isEmpty
                ? const LinearProgressIndicator()
                : ListView.separated(
                    itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (builder) => DisplayMaterial(
                                  subName: value[index],
                                ),
                              ),
                            ),
                            leading: Text(
                              "${value[index]}",
                              style: const TextStyle(
                                  fontSize: 17, color: Colors.black),
                            ),
                          ),
                        ),
                    separatorBuilder: (BuildContext context, int index) =>
                        Divider(
                          color: Colors.grey[350],
                        ),
                    itemCount: subList.value.length)),
      ),
    );
  }
}
