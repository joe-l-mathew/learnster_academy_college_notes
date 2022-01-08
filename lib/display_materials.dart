import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

ValueNotifier<List<String>> subList = ValueNotifier([]);
List<String> urls = [];

Future<void> listExample(String subName) async {
  subList.value.clear();
  urls.clear();
  await Hive.initFlutter();
  var box = await Hive.openBox('studentdata');

  firebase_storage.ListResult result = await firebase_storage
      .FirebaseStorage.instance
      .ref(
          "${box.get("university").toString()}/${box.get("course").toString()}/${box.get("semester").toString()}/$subName")
      .listAll();
  // result.items.forEach((firebase_storage.Reference ref) {

  // });

  // ignore: avoid_function_literals_in_foreach_calls
  result.items.forEach((firebase_storage.Reference ref) async {
    urls.add(await ref.getDownloadURL());
    subList.value.add(ref.name.substring(0, ref.name.length - 4));
    subList.notifyListeners();
  });
}

class DisplayMaterial extends StatefulWidget {
  final String subName;

  const DisplayMaterial({Key? key, required this.subName}) : super(key: key);

  @override
  State<DisplayMaterial> createState() => _DisplayMaterialState(subName);
}

class _DisplayMaterialState extends State<DisplayMaterial> {
  final String subName;

  _DisplayMaterialState(this.subName);

  @override
  void initState() {
    super.initState();
    listExample(subName);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: subList,
      builder: (context, List value, child) => Scaffold(
          appBar: AppBar(
            iconTheme: const IconThemeData(color: Colors.black),
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            title: Text(
              widget.subName,
              style: const TextStyle(color: Colors.black),
            ),
          ),
          body: subList.value.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                  itemBuilder: (context, index) => ListTile(
                      trailing: const Image(
                        image: AssetImage("assets/pdf.png"),
                      ),
                      leading: Text(
                        value[index],
                        style: const TextStyle(fontSize: 16),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<dynamic>(
                            builder: (_) => PDFViewerCachedFromUrl(
                              pdfName: value[index],
                              url: urls[index],
                            ),
                          ),
                        );
                      }),
                  separatorBuilder: (BuildContext context, int index) =>
                      Divider(
                        color: Colors.grey[350],
                      ),
                  itemCount: subList.value.length)),
    );
  }
}

class PDFViewerCachedFromUrl extends StatefulWidget {
  const PDFViewerCachedFromUrl(
      {Key? key, required this.url, required this.pdfName})
      : super(key: key);
  final String pdfName;
  final String url;

  @override
  State<PDFViewerCachedFromUrl> createState() =>
      _PDFViewerCachedFromUrlState(pdfName);
}

class _PDFViewerCachedFromUrlState extends State<PDFViewerCachedFromUrl> {
  final String pdfName;
  final Completer<PDFViewController> _pdfViewController =
      Completer<PDFViewController>();

  final StreamController<String> _pageCountController =
      StreamController<String>();

  _PDFViewerCachedFromUrlState(this.pdfName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          pdfName,
          style: const TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: <Widget>[
          StreamBuilder<String>(
              stream: _pageCountController.stream,
              builder: (_, AsyncSnapshot<String> snapshot) {
                if (snapshot.hasData) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      snapshot.data!,
                      style: const TextStyle(color: Colors.black),
                    ),
                  );
                }
                return const SizedBox();
              }),
        ],
      ),
      body: PDF(
        preventLinkNavigation: true,
        onPageChanged: (int? current, int? total) =>
            _pageCountController.add('${current! + 1} - $total'),
        onViewCreated: (PDFViewController pdfViewController) async {
          _pdfViewController.complete(pdfViewController);
          final int currentPage = await pdfViewController.getCurrentPage() ?? 0;
          final int? pageCount = await pdfViewController.getPageCount();
          _pageCountController.add('${currentPage + 1} - $pageCount');
        },
      ).cachedFromUrl(
        widget.url,
        placeholder: (double progress) => Center(child: Text('$progress %')),
           
        errorWidget: (dynamic error) => Center(child: Text(error.toString())),
      ),
    );
  }
}
