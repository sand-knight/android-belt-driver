import 'dart:async';

import 'package:android_belt_driver/drivers/belt_driver/Constants.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class HappySleep_device{

  final FlutterReactiveBle _reactiveBle;
  final String deviceID;
  late final QualifiedCharacteristic writeCharacteristic, notificationCharacteristic;

  final StreamController<ConnectionStateUpdate> _connectionStateController = StreamController<ConnectionStateUpdate>(); //this controls the following broadcast
  late final Stream<ConnectionStateUpdate> connectionStateStream; //here we expose a unique broadcast
  StreamSubscription<ConnectionStateUpdate> ? _connection, _connection_watchdog ;

  final StreamController<List<int>> _notificationStreamController = StreamController<List<int>>();
  late final Stream<List<int>> encodedMeasurements;
  StreamSubscription<List<int>> ? _encodedMeasurements;


  HappySleep_device(FlutterReactiveBle hostBleDevice, this.deviceID ) :
    _reactiveBle=hostBleDevice
  {
    encodedMeasurements = _notificationStreamController.stream.asBroadcastStream();
    connectionStateStream = _connectionStateController.stream.asBroadcastStream();
    writeCharacteristic = QualifiedCharacteristic(characteristicId: CHARACTERISTICS.WRITABLE, serviceId: SERVICES.MAIN, deviceId: deviceID);
    notificationCharacteristic = QualifiedCharacteristic(characteristicId: CHARACTERISTICS.NOTIFICATIONS, serviceId: SERVICES.MAIN, deviceId: deviceID);
  }

  void _connect (){
    var connectionStateStream = _reactiveBle.connectToDevice(
      id: deviceID,
      connectionTimeout: const Duration(seconds: 10),

    );

    
    _connection = connectionStateStream.listen(
      (event) async {
        _connectionStateController.add(event);
        if(event.connectionState == DeviceConnectionState.connected){
          print("Provo a connettermi");
          
          await _encodedMeasurements?.cancel();
          _encodedMeasurements = _reactiveBle.subscribeToCharacteristic(notificationCharacteristic)
          .listen(
            (event) {

              _notificationStreamController.add(event);
            }
          );
          
        }
      }
    );

  }

  void connect(){
    
    _connection?.cancel();
    _connect();

    _connection_watchdog = connectionStateStream.listen(
      (event) {
        print("Trying reconnection");
        if(event.connectionState == DeviceConnectionState.disconnected){
          Future.delayed(const Duration(seconds: 10)).then(
            (value) async {
              await _connection!.cancel();
              _connect();
            }
          );
        }
      }
      
    );
  
  
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

    // _notificationStreamController.addStream(
    //       _reactiveBle.subscribeToCharacteristic(notificationCharacteristic)
    // );
    //https://github.com/PhilipsHue/flutter_reactive_ble/issues/27

    encodedMeasurements.listen(
      (event) {
        print(event.toString());
      }
    );

    connectionStateStream.listen(
      (event){
        print(event.toString());
      }
    );
  }

  FutureOr<void> disconnect() async{

    return _connection_watchdog?.cancel()
    .then(
      (e) async {
        _connection?.cancel();
      }
    );
  }
  

  Future<void> _sendMessage(List<int> message) async {
    
    await _reactiveBle.writeCharacteristicWithResponse(writeCharacteristic, value: message);
  }

  Future<List<int>> get time async {
    final fut = _sendMessage(COMMANDS.GET_TIME);
    final Completer<List<int>> value=Completer();

    final sub = encodedMeasurements.where(
      (event) {
        return event.isMessage(RESPONSES.GET_TIME_HEADER);
      
      }
    ).take(1).listen(
      (event) {
        value.complete(event);
      }
    );
    
    return value.future.timeout(
      const Duration(seconds: 1),
      onTimeout: () async {
        await sub.cancel();
        return Future<List<int>>.error(Exception("Communication timeout"));
      }
    );
  }
  

}