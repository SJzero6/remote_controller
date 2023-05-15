import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:provider/provider.dart';
import 'package:remote_controller/home.dart';
import 'package:remote_controller/provider.dart';

class Stream extends StatefulWidget {
  const Stream({super.key});

  @override
  State<Stream> createState() => _StreamState();
}

class _StreamState extends State<Stream> {
  @override
  void initState() {
    Mqttprovider mqttprovider =
        Provider.of<Mqttprovider>(context, listen: false);

    mqttprovider.newAWSConnect();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Mqttprovider mqttprovider = Provider.of<Mqttprovider>(context);
    String ip = mqttprovider.ip;

    return Scaffold(
      body: Center(
        child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Mqttclient(
                            link: ip,
                          )));
            },
            child: Text("Stream")),
      ),
    );
  }
}
