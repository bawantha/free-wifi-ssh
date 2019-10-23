import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ssh/ssh.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _clientMAC = '';
  bool _isAuth=false;
  String ipAddress = '';

  

  Future<void> getMAC() async {
    var client = new SSHClient(
      host: "192.168.1.1",
      port: 22,
      username: "root",
      passwordOrKey: "mitra",
    );
    String isConnet;
    isConnet = await client.connect();
    if (isConnet == "session_connected") {
      _clientMAC = await client.execute(
          """ip neigh show "\${SSH_CONNECTION%% *}" | cut -d " " -f 5""");
      print(_clientMAC);
      client.disconnect();
    }
  }

  Future<void> authuser() async {
    var client = new SSHClient(
      host: "192.168.1.1",
      port: 22,
      username: "root",
      passwordOrKey: "mitra",
    );
    String result;
    String mac;
    try {
      result = await client.connect();
      if (result == "session_connected") {
        //  await client.execute("");

       await client.execute('ndsctl auth $_clientMAC');
      }
      client.disconnect();
    } on PlatformException catch (e) {
      print('Error: ${e.code}\nError Message: ${e.message}');
    }
  }

  Future<void> deauthUser() async {
    var client = new SSHClient(
      host: "192.168.1.1",
      port: 22,
      username: "root",
      passwordOrKey: "mitra",
    );
    String result;
    try {
      result = await client.connect();
      if (result == "session_connected") {
        await client.execute('ndsctl deauth $_clientMAC');
      }
      client.disconnect();
    } on PlatformException catch (e) {
      print('Error: ${e.code}\nError Message: ${e.message}');
    }
  }

  Future<void> getConnectionState(String mac) async {
    var client = new SSHClient(
      host: "192.168.1.1",
      port: 22,
      username: "root",
      passwordOrKey: "mitra",
    );
    String result;
    String reponse;
    try {
      result = await client.connect();
      if (result == "session_connected") {
        reponse = await client.execute("ndsctl json $_clientMAC");
        Map<String, dynamic> user = jsonDecode(reponse);
        //print(user['state']);
        if (user['state'] == "Authenticated") {
          //  print("yolla");
          _isAuth = true;
        } else {
          // print("wa;");
          _isAuth = false;
        }
      }
      client.disconnect();
    } on PlatformException catch (e) {
      print('Error: ${e.code}\nError Message: ${e.message}');
    }
  }

  @override
  void initState() {
    super.initState();
    getMAC();
    print("Called init State");
    setState(() {
     Future.delayed(const Duration(milliseconds: 500), () {
      getConnectionState(_clientMAC);
    }); 
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "FREE WIFI SSH",
      home: Scaffold(
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _isAuth
                ? RaisedButton(
                    child: Text("Connected"),
                    onPressed: null,
                  )
                : RaisedButton(
                    child: Text("Connect"),
                    onPressed: () {
                      setState(() {

                      //TODO add data to firebase  
                       authuser(); 
                      });
                      print(_isAuth.toString());
                    },
                  ),
            SizedBox(
              height: 20,
            ),
          ],
        )),
      ),
    );
  }
}
