import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:flutter_easy_nfc/flutter_easy_nfc.dart';
import 'package:flutter_nfc_app/utils/nfc_utils.dart';
//import 'package:nfc_manager/nfc_manager.dart';
//import 'package:nfc_manager/platform_tags.dart';
import 'package:openapi/api.dart';

import '../widgets/reserve_machine_widget.dart';

class ListPage extends StatefulWidget {
  static const routeName = "/list";

  ListPage({Key key, this.title}) : super(key: key) {}

  final String title;

  @override
  _ListPageState createState() => new _ListPageState();
}

class _ListPageState extends State<ListPage> {
  var platform = const MethodChannel('de.htw.nfc.flutter_nfc_app.readCard');

  List<Machine> items;

  Future _handleMethod(MethodCall call) {
    switch (call.method) {
      case "message":
        setState(() {
          items = [];
        });
    }
  }

  @override
  void initState() {
    super.initState();
    log('data:asda');
    platform.setMethodCallHandler(_handleMethod);

    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(widget.title),
        ),
        body: getBody());
  }

  getBody() {
    if (showLoadingDialog()) {
      return getProgressDialog();
    } else if (showEmptyPlaceholder()) {
      return getEmptyPlaceholder();
    } else {
      return getListView();
    }
  }

  showEmptyPlaceholder() => items?.length == 0;

  showLoadingDialog() => items == null;

  getProgressDialog() => new Center(child: new CircularProgressIndicator());

  getEmptyPlaceholder() =>
      Center(child: Text("No available machines at this time."));

  Widget getListView() => RefreshIndicator(
        child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (BuildContext context, int position) {
              return getRow(position);
            }),
        onRefresh: loadData,
      );

  Widget getRow(int i) {
    final currentItem = items[i];

    return new ListTile(
        title: Text(
            "House ${currentItem.houseNumber}, Machine ${currentItem.name}"),
        leading: Icon(Icons.local_laundry_service, size: 32),
        trailing: ReserveMachineWidget(machine: currentItem));
  }

  void onReserve(Machine machine) {}
/*
  void _onTagDiscovered(NfcTag tag) {
    var a = tag.data;
    var miFareTag = MiFare.fromTag(tag);
    //miFareTag
    if (miFareTag != null) {
      setState(() {
        items = [];
      });
    }
  }

  void f(NfcEvent<BasicTagTechnology> event) {
    setState(() {});
  }
*/
  Future<void> loadData() async {
    try {
//      var a = await NFCUtils.readCardId();

      //var start = await FlutterEasyNfc.startup();
      //F//lutterEasyNfc.onNfcEvent(f); //;(event) {

    } catch (err) {
      print(err);
    }
    try {
      var a = await NFCUtils.readCardId();
      var apiClient = MachineApi();
      var machines = await apiClient.listAvailableMachines();
      machines.sort((a, b) =>
          a.houseNumber * 100 + b.name > b.houseNumber * 100 + b.name ? 1 : -1);
      setState(() {
        items = machines.where((x) => x.type != "Dryer").toList();
      });
    } catch (e) {
      //Scaffold.of(context).showSnackBar(new SnackBar(content: Text(e)));
      setState(() {
        items = [];
      });
    }
  }
}
