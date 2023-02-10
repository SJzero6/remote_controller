import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:image/image.dart' as imgs;

class Mqttclient extends StatefulWidget {
  const Mqttclient({Key? key}) : super(key: key);

  @override
  State<Mqttclient> createState() => _MqttclientState();
}

class _MqttclientState extends State<Mqttclient> {
  static const url = 'alq5vzvrt1h0b-ats.iot.ap-northeast-1.amazonaws.com';

  static const port = 8883;

  static const clientid = 'ESP_CAM';

  final client = MqttServerClient.withPort(url, clientid, port);

  @override
  void initState() {
    _connectMQTT();
    // TODO: implement initState
  }

  _connectMQTT() async {
    await newAWSConnect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(children: [
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: Colors.black,
            child: StreamBuilder(
                stream: client.updates,
                builder: ((context, snapshot) {
                  if (!snapshot.hasData) {
                    print("sooraj");
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                      ),
                    );
                  } else {
                    //print("iam here");
                    final mqttmss = snapshot.data
                        as List<MqttReceivedMessage<MqttMessage?>>?;
                    final recMess = mqttmss![0].payload as MqttPublishMessage;
                    imgs.Image jpgimage =
                        imgs.decodeJpg(recMess.payload.message)!;

                    print(
                        'img width = ${jpgimage.width}, height = ${jpgimage.height}');
                    return Image.memory(
                      imgs.encodeJpg(jpgimage) as Uint8List,
                      gaplessPlayback: true,
                    );
                  }
                })),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 400,
                width: 125,
                //color: Colors.amber,
                child: Stack(children: [
                  Positioned(
                    top: 210,
                    left: 13,
                    child: Container(
                      child: Column(
                        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          OutlinedButton(
                            onPressed: () => Forward(),
                            child: Icon(Icons.arrow_upward_rounded),
                            style: ElevatedButton.styleFrom(
                              shape: CircleBorder(),
                              padding: EdgeInsets.all(27),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          OutlinedButton(
                            onPressed: () => Backward(),
                            child: Icon(Icons.arrow_downward_rounded),
                            style: ElevatedButton.styleFrom(
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
              Container(
                height: 400,
                width: 210,
                //color: Colors.amber,
                child: Stack(children: [
                  Positioned(
                    top: 270,
                    left: 30,
                    child: Container(
                      child: Row(
                        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          OutlinedButton(
                            onPressed: () => Left(),
                            child: Icon(Icons.arrow_upward_rounded),
                            style: ElevatedButton.styleFrom(
                              shape: CircleBorder(),
                              padding: EdgeInsets.all(27),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          OutlinedButton(
                            onPressed: () => Right(),
                            child: Icon(Icons.arrow_downward_rounded),
                            style: ElevatedButton.styleFrom(
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
        ]),
      ),
    );
  }

  Future<int> newAWSConnect() async {
    client.secure = true;

    client.keepAlivePeriod = 20;

    client.setProtocolV311();

    client.logging(on: true);

    final context = SecurityContext.defaultContext;

    ByteData crctdata =
        await rootBundle.load('assets/certifcates/devicectft.crt');
    context.useCertificateChainBytes(crctdata.buffer.asUint8List());

    ByteData authorities =
        await rootBundle.load('assets/certifcates/AmazonRootCA1.pem');
    context.setClientAuthoritiesBytes(authorities.buffer.asUint8List());

    ByteData keybyte = await rootBundle.load('assets/certifcates/prvtkey.key');
    context.usePrivateKeyBytes(keybyte.buffer.asUint8List());
    client.securityContext = context;

    final mess =
        MqttConnectMessage().withClientIdentifier('ESP_CAM').startClean();
    client.connectionMessage = mess;

    try {
      print('MQTT client is connecting to AWS');
      await client.connect();
    } on Exception catch (e) {
      print('MQTT client exception - $e');
      client.disconnect();
    }
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('AWS iot connection succesfully done');

      const topic = 'esp32/cam_2';
      final maker = MqttClientPayloadBuilder();
      maker.addString('mommu');

      client.publishMessage(topic, MqttQos.atLeastOnce, maker.payload!);

      client.subscribe(topic, MqttQos.atLeastOnce);

      client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final rcvmsg = c[0].payload as MqttPublishMessage;
        final pt =
            MqttPublishPayload.bytesToStringAsString(rcvmsg.payload.message);
        print(
            'Example::Change notification:: topic is<${c[0].topic}>, payload is <--$pt-->');
      });
    } else {
      print(
          'ERROR MQTT client connection failed - disconnecting, state is ${client.connectionStatus!.state}');
      client.disconnect();
    }
    // print('died');
    // await MqttUtilities.asyncSleep(10);
    // print('Diconnectiong....');
    // client.disconnect();

    return 0;
  }

  void Forward() {
    const topic = 'motor';
    final make = MqttClientPayloadBuilder();
    make.addString('F');
    client.publishMessage(topic, MqttQos.atLeastOnce, make.payload!);
  }

  void Backward() {
    const topic = 'motor';
    final make = MqttClientPayloadBuilder();
    make.addString('B');
    client.publishMessage(topic, MqttQos.atLeastOnce, make.payload!);
  }

  void Left() {
    const topic = 'motor';
    final make = MqttClientPayloadBuilder();
    make.addString('L');
    client.publishMessage(topic, MqttQos.atLeastOnce, make.payload!);
  }

  void Right() {
    const topic = 'motor';
    final make = MqttClientPayloadBuilder();
    make.addString('R');
    client.publishMessage(topic, MqttQos.atLeastOnce, make.payload!);
  }
}
