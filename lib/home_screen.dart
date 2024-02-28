import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PlatformChannel extends StatefulWidget {
  const PlatformChannel({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PlatformChannelState createState() => _PlatformChannelState();
}

class _PlatformChannelState extends State<PlatformChannel> {
  static const MethodChannel methodChannel =
      MethodChannel('samples.flutter.io/battery');
  static const EventChannel eventChannel =
      EventChannel('samples.flutter.io/charging');

  String _batteryLevel = 'Battery level: unknown';
  String _chargingStatus = 'Battery status: unknown';

  Future getBatteryLevel() async {
    String batteryLevel;
    try {
      final int result = await methodChannel.invokeMethod('getBatteryLevel');
      batteryLevel = 'Battery level: $result%';
    } on PlatformException catch (e) {
      log("error is $e");
      batteryLevel = 'Failed to get battery level';
    }
    setState(() {
      _batteryLevel = batteryLevel;
    });
  }

  @override
  void initState() {
    super.initState();
    getStatus();
  }

  getStatus() {
    eventChannel.receiveBroadcastStream().listen((charginStatus) {
      setState(() {
        _chargingStatus = charginStatus;
      });
    }, onError: _onError);
  }

  void _onError(Object error) {
    setState(() {
      _chargingStatus = 'Error';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          title: const Text(
            'Platform Channel',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 30, bottom: 10),
                child: batteryBuild(_chargingStatus),
              ),
              Text(
                _batteryLevel,
                style:
                    const TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  height: 60,
                  width: 120,
                  child: ElevatedButton(
                    style: const ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(Colors.blue)),
                    onPressed: () {
                      getBatteryLevel();
                    },
                    child: const Text(
                      'Refresh',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
              ),
              Text(
                'Battery status: $_chargingStatus',
                style:
                    const TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ));
  }

  Widget batteryBuild(String chargingStatus) {
    switch (chargingStatus) {
      case 'Charging':
        return const SizedBox(
          height: 200,
          width: 200,
          child: Icon(
            Icons.battery_charging_full,
            size: 200,
            color: Colors.blue,
          ),
        );
      case 'Discharging':
        return const SizedBox(
          height: 200,
          width: 200,
          child: Icon(
            Icons.battery_alert,
            size: 200,
            color: Colors.orange,
          ),
        );
      default:
        return const SizedBox(
            height: 200,
            width: 200,
            child: Icon(
              Icons.battery_unknown,
              color: Colors.red,
              size: 200,
            ));
    }
  }
}
