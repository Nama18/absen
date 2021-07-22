import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import 'package:latihan_crud/database.dart';
import 'package:latihan_crud/item_card.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.cyan,
        accentColor: Colors.indigoAccent),
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Database db;
  List docs = [];
  initialise() {
    db = Database();
    db.initialiase();
    db.read().then((value) => {
          setState(() {
            docs = value;
          })
        });
  }

  @override
  void initState() {
    super.initState();
    initialise();
  }

  String workerName, workerID;
  DateTime tanggal;

  getWorkerID(id) {
    this.workerID = id;
  }

  getWorkerName(name) {
    this.workerName = name;
  }

  absenMasuk() {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection("Pekerja").doc(workerName);
    DocumentReference masuk =
        FirebaseFirestore.instance.collection("absen").doc(workerName);
    Map<String, dynamic> worker = {
      "workerID": workerID,
      "absen_masuk": DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now()),
      "jamPulang": null,
    };

    masuk.set(worker).whenComplete(() {
      print("$workerName created");
    });
  }

  absenPulang() {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection("Pekerja").doc(workerName);

    Map<String, dynamic> worker = {
      "workerID": workerID,
      "jamPulang": DateFormat('kk:mm').format(DateTime.now()),
    };

    DocumentReference pulang =
        FirebaseFirestore.instance.collection("absen").doc(workerName);

    pulang.update(worker).whenComplete(() {
      print("$workerName updated");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Absensi"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(bottom: 10.0),
                child: TextFormField(
                  decoration: InputDecoration(
                      labelText: "ID",
                      fillColor: Colors.white,
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.blue, width: 2.0))),
                  onChanged: (String id) {
                    getWorkerID(id);
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 10.0),
                child: TextFormField(
                  decoration: InputDecoration(
                      labelText: "Name",
                      fillColor: Colors.white,
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.blue, width: 2.0))),
                  onChanged: (String name) {
                    getWorkerName(name);
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  RaisedButton(
                    color: Colors.red,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: Text("Absen Masuk"),
                    textColor: Colors.white,
                    onPressed: () {
                      absenMasuk();
                    },
                  ),
                  RaisedButton(
                    color: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: Text("Absen Pulang"),
                    textColor: Colors.white,
                    onPressed: () {
                      absenPulang();
                    },
                  ),
                ],
              ),
              StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('pekerja')
                      .snapshots(),
                  builder: (_, snapshot) {
                    if (snapshot.hasData) {
                      return Column(
                        children: snapshot.data.docs
                            .map((e) => ItemCard(
                                e.data()[getWorkerID('workerID')],
                                e.data()[getWorkerName('workerName')]))
                            .toList(),
                      );
                    } else {
                      return CircularProgressIndicator();
                    }
                  })
            ],
          ),
        ));
  }
}
