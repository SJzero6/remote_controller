import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import "package:mqtt_client/mqtt_client.dart";
import 'package:mqtt_client/mqtt_server_client.dart';

class Mqttprovider with ChangeNotifier {
  static const url = 'alq5vzvrt1h0b-ats.iot.ap-northeast-1.amazonaws.com';

  static const port = 8883;

  static const clientid = 'espcam';

  final client = MqttServerClient.withPort(url, clientid, port);

  Map<String, dynamic> _map = {};

  set urldata(data) {
    urldata = data;
    notifyListeners();
  }

  Map<String, dynamic> get urldata => _map;

  String _ipdata = "{}";
  var _ip = '';
  set ipdata(data) {
    _ipdata = data;
    Map<String, dynamic> ipdata = json.decode(_ipdata);
    _ip = ipdata['ip'];

    notifyListeners();
  }

  String get ipdata => _ipdata;
  String get ip => _ip;

  newAWSConnect() async {
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
        MqttConnectMessage().withClientIdentifier('espcam').startClean();
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
      // final maker = MqttClientPayloadBuilder();
      // maker.addString('mommu');

      // client.publishMessage(topic, MqttQos.atLeastOnce, maker.payload!);

      client.subscribe(topic, MqttQos.atLeastOnce);
      client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final rcvmsg = c[0].payload as MqttPublishMessage;
        final pt =
            MqttPublishPayload.bytesToStringAsString(rcvmsg.payload.message);
        print(
            'Example::Change notification:: topic is<${c[0].topic}>, payload is <--$pt-->');
        ipdata = pt;
        print('helloworld$pt');
      });
    } else {
      print(
          'ERROR MQTT client connection failed - disconnecting, state is ${client.connectionStatus!.state}');
      client.disconnect();
    }

    return 0;
  }

  publish(msg) {
    const topic = "motor";
    final builder = MqttClientPayloadBuilder();
    builder.addString(msg);
    client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }
}
