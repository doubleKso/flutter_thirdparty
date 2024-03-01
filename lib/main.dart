import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thirdpartyflutter/const.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Third Party Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  SharedPreferences? _pref; //will create later before we used

  var runTime = 0;

  Map<String, dynamic> properties = {
    "runtime": 0,
    "level": 12,
    "actorblood": 50,
    "charname": "",
    "enemies": {"1": 10, "2": 100, "3": 70}
  };

  saveProperties() {
    properties["runtime"] = ++runTime;
    var propertyString =
        JsonEncoder().convert(properties); //flat ( obj -> string)
    _pref?.setString("property", propertyString);
    setState(() {});
  }

  readProperties() {
    var propertyString = _pref?.getString("property");
    if (propertyString != null) {
      properties = JsonDecoder().convert(propertyString)
          as Map<String, dynamic>; //embossed ( string-> obj)
      runTime = properties["runtime"] as int;
      setState(() {});
    }
  }

  save() {
    //here _pref must be instance
    _pref?.setInt(kRunTimeKey, ++runTime).then((value) => print(value));
    setState(() {});
  }

  read() {
    var runTimeNullable = _pref?.getInt(kRunTimeKey);
    if (runTimeNullable != null) {
      setState(() {
        runTime = runTimeNullable;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SharedPreferences.getInstance().then((pref) {
      _pref = pref; //now _pref is ready to be used ***
      readProperties();
    });
  }

  showToast() {
    Fluttertoast.showToast(
        msg: "Here I am toasting",
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_SHORT);
  }

  showSettingPage() {}

  getCameraPermission() async {
    //CHECK EXISTING PERMISSION
    var status = await Permission.camera.status;
    switch (status) {
      case PermissionStatus.denied:
      case PermissionStatus.limited:
        //request permission
        //following code not work in iOS , as of one time prompted
        var requestStatus = await Permission.camera.request();
        if (requestStatus.isGranted) {
          print("User granted");
        } else {
          print("User denied"); //** dont request again immediately */
          //but may inform that how it is important to the app
          //And next time request again when encounters
          showSettingPage();
        }
        break;
      case PermissionStatus.granted:
        print("Already granted");
      default: //already permission
        print("Denied");
        showSettingPage();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.title),
        actions: [
          IconButton(
              onPressed: readProperties,
              icon: Icon(
                Icons.book,
                color: Colors.blue,
              )),
          IconButton(
              onPressed: saveProperties,
              icon: Icon(
                Icons.save,
                color: Colors.white,
              )),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Runtime : $runTime"),
            ElevatedButton(onPressed: showToast, child: Text("Show Toast")),
            Text("Get Permissions"),
            Wrap(
              children: [
                ElevatedButton(
                    onPressed: () {
                      getCameraPermission();
                    },
                    child: Text("Camera Permission")),
                ElevatedButton(
                    onPressed: () {}, child: Text("Location Permission")),
                ElevatedButton(
                    onPressed: () {}, child: Text("Library Permission")),
              ],
            )
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
