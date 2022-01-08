import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:learnster_academy_notes/onBording/select_course.dart';
import 'package:shared_preferences/shared_preferences.dart';

ValueNotifier<List<String>> univList = ValueNotifier([]);
String selectuniv = "Click here to select";

class SelectUniversity extends StatefulWidget {
  const SelectUniversity({Key? key}) : super(key: key);

  @override
  _SelectUniversityState createState() => _SelectUniversityState();
}

class _SelectUniversityState extends State<SelectUniversity> {
  @override
  void initState() {
    univList.value.clear();
    // TODO: implement initState
    super.initState();
    listExample();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                "Select University",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              univList.value.isEmpty
                  ? const CircularProgressIndicator()
                  : TextButton(
                      onPressed: () {
                        showModalBottomSheet(
                            shape:const RoundedRectangleBorder(
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
                        style:const TextStyle(fontSize: 20),
                      )),
              ElevatedButton(
                  onPressed: () {
                    saveUniv(selectuniv, context);
                  },
                  child: const Text("Next"))
            ],
          ),
        ),
      )),
    );
  }
}

Future<void> listExample() async {
  firebase_storage.ListResult result =
      await firebase_storage.FirebaseStorage.instance.ref().listAll();

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
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (selectuniv == "Click here to select") {
    const snackBar = SnackBar(
      content: Text('Please select a university'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  } else {
    await Hive.initFlutter();
    var box = await Hive.openBox('studentdata');
    box.put("university", selectuniv.toString());
    prefs.setBool("isCompleted", false);
    Navigator.push(context, MaterialPageRoute(builder: (builder) {
      return SelectCourse();
    }));
  }
}
