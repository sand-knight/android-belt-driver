import 'dart:async';

import 'package:android_belt_driver/drivers/belt_driver/Constants.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class HappySleep_device{

  final FlutterReactiveBle _reactiveBle;
  final StreamController<ConnectionStateUpdate> _connectionStateController = StreamController<ConnectionStateUpdate>();
  final StreamController<List<int>> _notificationStreamController = StreamController<List<int>>();

  final String deviceID;
  late final QualifiedCharacteristic writeCharacteristic, notificationCharacteristic;
  late final Stream<ConnectionStateUpdate> connectionStateStream;
  late final Stream<List<int>> encodedMeasurements;

  HappySleep_device(FlutterReactiveBle hostBleDevice, this.deviceID ) :
    _reactiveBle=hostBleDevice
  {
    encodedMeasurements = _notificationStreamController.stream.asBroadcastStream();
    connectionStateStream = _connectionStateController.stream.asBroadcastStream();
    writeCharacteristic = QualifiedCharacteristic(characteristicId: CHARACTERISTICS.WRITABLE, serviceId: SERVICES.MAIN, deviceId: deviceID);
    notificationCharacteristic = QualifiedCharacteristic(characteristicId: CHARACTERISTICS.NOTIFICATIONS, serviceId: SERVICES.MAIN, deviceId: deviceID);
  }

  void connect(){
    print('provo');
    _connectionStateController.addStream(
      _reactiveBle.connectToAdvertisingDevice(
        id: deviceID,
        withServices: [SERVICES.MAIN],
        prescanDuration: const Duration(seconds: 7),
        connectionTimeout: const Duration(seconds: 10),

      )
    );

    // connectionStateStream.listen(
    //   (event) {
    //     if(event.connectionState == DeviceConnectionState.connected){
    //       print("Sono connesso");
    //       _notificationStreamController.addStream(
    //         _reactiveBle.subscribeToCharacteristic(notificationCharacteristic)
    //       );
    //     }
    //   }
    // );


    // connectionStateStream.where(
    //   (event) => event.connectionState == DeviceConnectionState.connected
    // ).take(1).listen(
    //   (event) {
    //     print("Sono connesso");
    //     _notificationStreamController.addStream(
    //       _reactiveBle.subscribeToCharacteristic(notificationCharacteristic)
    //     );
    //   }
    // );

    _notificationStreamController.addStream(
          _reactiveBle.subscribeToCharacteristic(notificationCharacteristic)
    );
    //https://github.com/PhilipsHue/flutter_reactive_ble/issues/27

    encodedMeasurements.listen(
      (event) {
        print(event.toString());
      }
    );
  }

  Future<void> _sendMessage(List<int> message) async {
    
    await _reactiveBle.writeCharacteristicWithResponse(writeCharacteristic, value: message);
  }

  Future<List<int>> get time async {
    final fut = _sendMessage(COMMANDS.GET_TIME);
    final Completer<List<int>> value=Completer();
    encodedMeasurements.where(
      (event) {
        return event.isMessage(RESPONSES.GET_TIME_HEADER);
      
      }
    ).take(1).listen(
      (event) {
        value.complete(event);
      }
    );
    
    return value.future;
  }
  

}