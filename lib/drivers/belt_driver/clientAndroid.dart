
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'Constants.dart';
import 'clientInterface.dart';

class HappySleepClientAndroid implements HappySleepClient{

  final FlutterReactiveBle _reactiveBle;
  final String deviceID;
  late final QualifiedCharacteristic writeCharacteristic, notificationCharacteristic;

  final StreamController<DeviceConnectionState> _connectionStateController = StreamController<DeviceConnectionState>(); //this controls the following broadcast
  late final Stream<DeviceConnectionState> _connectionStateStream; //here we expose a unique broadcast
  Stream<DeviceConnectionState> get connectionStateStream => _connectionStateStream;
  StreamSubscription<ConnectionStateUpdate> ? _connection;  //a subscription we must cancel() in order to disconnect (ask philips hue why the heck)
  StreamSubscription<DeviceConnectionState> ? _connection_watchdog ; //the thing which tries to reconnect every 10 seconds
    //https://github.com/PhilipsHue/flutter_reactive_ble/issues/27

  final StreamController<List<int>> _notificationStreamController = StreamController<List<int>>();
  late final Stream<List<int>> _encodedMeasurements;
  Stream<List<int>> get arrivingMessages => _encodedMeasurements;
  StreamSubscription<List<int>> ? _notificationSubscription;


  HappySleepClientAndroid(FlutterReactiveBle hostBleDevice, this.deviceID ) :
    _reactiveBle=hostBleDevice
  {
    _encodedMeasurements = _notificationStreamController.stream.asBroadcastStream();
    _connectionStateStream = _connectionStateController.stream.asBroadcastStream();
    writeCharacteristic = QualifiedCharacteristic(characteristicId: CHARACTERISTICS.WRITABLE, serviceId: SERVICES.MAIN, deviceId: deviceID);
    notificationCharacteristic = QualifiedCharacteristic(characteristicId: CHARACTERISTICS.NOTIFICATIONS, serviceId: SERVICES.MAIN, deviceId: deviceID);
  }



  FutureOr<void> _connect (){
    var connectionStateStream = _reactiveBle.connectToDevice(
      id: deviceID,
      connectionTimeout: const Duration(seconds: 10),

    );

    
    _connection = connectionStateStream.listen(
      (event) async {
        _connectionStateController.add(event.connectionState);
        if(event.connectionState == DeviceConnectionState.connected){
          print("Provo a connettermi");
          
          await _notificationSubscription?.cancel();
          _notificationSubscription = _reactiveBle.subscribeToCharacteristic(notificationCharacteristic)
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

    _connection_watchdog = _connectionStateStream.listen(
      (event) {
        print("Trying reconnection");
        if(event == DeviceConnectionState.disconnected){
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

    _encodedMeasurements.listen(
      (event) {
        print( "R ${DateTime.now().millisecondsSinceEpoch.toString()}: ${event.toString()}" );
      }
    );

    _connectionStateStream.listen(
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
  
  //======================== BASIC FUNCTIONS =============================================

  Future<void> sendMessage(List<int> message) async {
    print("S ${DateTime.now().millisecondsSinceEpoch}: ${message.toString()}");
    await _reactiveBle.writeCharacteristicWithResponse(writeCharacteristic, value: message);
  }

}