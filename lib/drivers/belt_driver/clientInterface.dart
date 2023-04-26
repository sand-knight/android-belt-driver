import 'dart:async';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

abstract class HappySleepClient{
  abstract final String deviceID;
  abstract final Stream<DeviceConnectionState> connectionStateStream;
  abstract final Stream<List<int>> arrivingMessages;

  FutureOr<void> connect();
  FutureOr<void> disconnect();
  Future<void> sendMessage(List<int> message);
  
}