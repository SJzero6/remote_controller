import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:image/image.dart' as imgs;
import 'package:provider/provider.dart';
import 'package:remote_controller/provider.dart';

class Mqttclient extends StatefulWidget {
  Mqttclient({Key? key, required this.link}) : super(key: key);

  String link;

  @override
  State<Mqttclient> createState() => _MqttclientState();
}

class _MqttclientState extends State<Mqttclient>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  bool isconnected = false;

  @override
  void initState() {
    Mqttprovider mqttprovider =
        Provider.of<Mqttprovider>(context, listen: false);

    mqttprovider.newAWSConnect();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);

    // TODO: implement initState
  }

  var link;
  InAppWebViewController? webViewController;
  PullToRefreshController? refreshController;

  var sensor = 1;

  @override
  Widget build(BuildContext context) {
    Mqttprovider mqttprovider = Provider.of<Mqttprovider>(context);
    Map<String, dynamic> ipdata = json.decode(mqttprovider.ipdata);
    sensor = ipdata["sensor"] ?? 0;

    return Scaffold(
        body: Stack(children: [
      Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: link == null
            ? InAppWebView(
                initialUrlRequest:
                    URLRequest(url: Uri.parse("http://${widget.link}")),
              )
            : Center(
                child: Text('No stream available'),
              ),
      ),

      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
              //color: Colors.white,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: sensor == 1
                  ? Text(
                      "GAS DETECTED",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    )
                  : Text("NO GAS",
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold))),
          Container(
              child: sensor == 1
                  ? containered(animation: _animation)
                  : containerani(animation: _animation)),
        ],
      ),

      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            height: 400,
            width: 125,
            //color: Colors.amber,
            child: Stack(children: [
              Positioned(
                top: 130,
                left: 20,
                child: Container(
                  child: Column(
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          mqttprovider.publish("F");
                        },
                        child: Image.asset(
                          'assets/images/up (2).png',
                          height: 40,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          elevation: 10,
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(27),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          mqttprovider.publish("B");
                        },
                        child: Image.asset(
                          "assets/images/down (2).png",
                          height: 40,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          elevation: 10,
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(27),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]),
          ),
          SizedBox(
            height: 400,
            width: 250,
            // color: Colors.amber,
            child: Stack(children: [
              Positioned(
                top: 240,
                left: 10,
                child: Container(
                  child: Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          mqttprovider.publish("L");
                        },
                        child: Image.asset(
                          'assets/images/left (2).png',
                          height: 40,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          elevation: 10,
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(27),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          mqttprovider.publish('R');
                        },
                        child: Image.asset(
                          'assets/images/right (6).png',
                          height: 40,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          elevation: 10,
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(27),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ],
      )
      // ]),
      // ),
    ]));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class containerani extends StatelessWidget {
  const containerani({
    super.key,
    required Animation<double> animation,
  }) : _animation = animation;

  final Animation<double> _animation;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 50, vertical: 50),
      child: FadeTransition(
        opacity: _animation,
        child: Container(
          decoration: BoxDecoration(
              shape: BoxShape.circle, color: Color.fromARGB(255, 238, 19, 4)),
          width: 30,
          height: 30,
        ),
      ),
    );
  }
}

class containered extends StatelessWidget {
  const containered({
    super.key,
    required Animation<double> animation,
  }) : _animation = animation;

  final Animation<double> _animation;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 50, vertical: 50),
      child: FadeTransition(
        opacity: _animation,
        child: Container(
          decoration: BoxDecoration(
              shape: BoxShape.circle, color: Color.fromARGB(255, 0, 248, 79)),
          width: 30,
          height: 30,
        ),
      ),
    );
  }
}
