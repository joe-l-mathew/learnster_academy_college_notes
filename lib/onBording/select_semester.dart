import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:learnster_academy_notes/onBording/select_university.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../subject.dart';

ValueNotifier<List<String>> univList = ValueNotifier([]);
String selectuniv = "Click here to select";
ValueNotifier<String> selectedCourse = ValueNotifier("");

class SelectSemester extends StatefulWidget {
  const SelectSemester({Key? key}) : super(key: key);

  @override
  _SelectSemesterState createState() => _SelectSemesterState();
}

class _SelectSemesterState extends State<SelectSemester> {
  @override
  void initState() {
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
              showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                        elevation: 10,
                        title: const Text("Edit your course"),
                        content: const Text(
                            "Do you want to edit your default University and course?"),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(ctx).pop();
                            },
                            child: const Text("no"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (builder) => SelectUniversity()),
                                  (route) => false);
                            },
                            child: const Text("Yes"),
                          ),
                        ],
                      ));
            },
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: ValueListenableBuilder(
          valueListenable: selectedCourse,
          builder: (context, String value, child) => Text(
            value,
            style: TextStyle(color: Colors.black),
          ),
        ),
      ),
      body: SafeArea(
          child: Center(
        child: ValueListenableBuilder(
          valueListenable: univList,
          builder: (context, List value, child) => Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Image.asset(
                "assets/study.png",
                height: 175,
              ),
              const Text(
                "Select Semester",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              univList.value.isEmpty
                  ? const CircularProgressIndicator()
                  : TextButton(
                      onPressed: () {
                        showModalBottomSheet(
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(15))
                                //the rounded corner is created here

                                ),
                            context: context,
                            builder: (builder) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListView.separated(
                                    separatorBuilder:
                                        (BuildContext context, int index) =>
                                            const Divider(),
                                    itemCount: value.length,
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                          leading: Text(value[index]),
                                          onTap: () {
                                            setState(() {
                                              selectuniv = value[index];
                                            });
                                            Navigator.pop(context);
                                          });
                                    }),
                              );
                            });
                      },
                      child: Text(
                        selectuniv,
                        style: const TextStyle(fontSize: 20),
                      )),
              ElevatedButton(
                  onPressed: () {
                    saveUniv(selectuniv, context);
                  },
                  child: const Text("Finish"))
            ],
          ),
        ),
      )),
    );
  }
}

Future<void> listExample() async {
  await Hive.initFlutter();
  // SharedPreferences prefs = await SharedPreferences.getInstance();
  var box = await Hive.openBox('studentdata');

  selectedCourse.value = box.get("course");

  //Add root to semesters
  firebase_storage.ListResult result = await firebase_storage
      .FirebaseStorage.instance
      .ref("/${box.get('university')}/${box.get('course')}")
      .listAll();

  for (var ref in result.prefixes) {
    univList.value.add(ref.name);
  }
  // print(univList.value);
  univList.notifyListeners();
}

showMyBottom(BuildContext context, List value) {
  return showModalBottomSheet(
      context: context,
      builder: (builder) {
        return ListView.builder(
            itemCount: value.length,
            itemBuilder: (context, index) {
              return ListTile(
                  leading: Text(value[index]),
                  onTap: () {
                    selectuniv = value[index];
                    Navigator.pop(context);
                  });
            });
      });
}

saveUniv(selectuniv, context) async {
  if (selectuniv == "Click here to select") {
    const snackBar = SnackBar(
      content: Text('Please select a semester'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  } else {
    await Hive.initFlutter();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var box = await Hive.openBox('studentdata');
    box.put("semester", selectuniv.toString());
    prefs.setBool("isCompleted", true);

    return Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (builder) => SelectSubject()),
        (route) => false);

    // return Navigator.pushReplacement(context,
    //     MaterialPageRoute(builder: (builder) {
    //   return const SelectSubject();
    // }));
  }
}
