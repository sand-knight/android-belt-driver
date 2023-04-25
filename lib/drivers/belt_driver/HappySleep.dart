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
  StreamSubscription<ConnectionStateUpdate> ? _connection,  //a subscription we must cancel() in order to disconnect (ask philips hue why the heck)
                                              _connection_watchdog ; //the thing which tries to reconnect every 10 seconds
    //https://github.com/PhilipsHue/flutter_reactive_ble/issues/27

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
  
  //======================== BASIC FUNCTIONS =============================================

  Future<void> _sendMessage(List<int> message) async {
    print("Sending message: "+message.toString());
    await _reactiveBle.writeCharacteristicWithResponse(writeCharacteristic, value: message);
  }

  void _addPaddingTo(List<int> message){
    final int size = message.length;
    for( int i=0; i<(15-size); i++){
      message.add(0);
    }
  }

  int _calculateCRC(List<int> message){
    int sum = 0;
    for (int i in message){
      sum+=i;
    }
    return sum%255;
  }

  void _completeMessage(List<int> message){
    _addPaddingTo(message);
    message.add(_calculateCRC(message));
  }

  //======================= METHODS ======================================================

  /// Get Time
  /// 
  /// [return] is a DateTime object representing current time
  Future<DateTime> getTime() async {
    final fut = _sendMessage(COMMANDS.GET_TIME);
    final Completer<DateTime> value=Completer();

    final sub = encodedMeasurements
    .take(1).listen(
      (event) {
        if (event.isMessage(RESPONSES.GET_TIME_HEADER)){
          value.complete(_decode_BCD_time(event) );
        }else if (event.isMessage(RESPONSES.GET_TIME_ERROR)){
          value.completeError(Exception("Belt reported error"));
        }
      }
    );
    
    return value.future.timeout(
      const Duration(seconds: 1),
      onTimeout: () async {
        await sub.cancel();
        return Future<DateTime>.error(Exception("Communication timeout"));
      }
    );
  }

  Future<void> setTime({DateTime ? dt}) async {
    if (dt == null) dt = DateTime.now();

    final List<int> message = COMMANDS.SET_TIME_HEADER.sublist(0);
    message.addAll(_encode_BCD_time(dt));
    _completeMessage(message);

    final fut = _sendMessage(message);
    final Completer<void> value=Completer();

    final sub = encodedMeasurements
    .take(1).listen(
      (event) {
        if (event.isMessage(RESPONSES.SET_TIME_OK))
          value.complete();
        else if (event.isMessage(RESPONSES.SET_TIME_ERROR))
          value.completeError(Exception("Belt reported error"));
      }
    );
    
    return value.future.timeout(
      const Duration(seconds: 1),
      onTimeout: () async {
        await sub.cancel();
        return Future<void>.error(Exception("Communication timeout"));
      }
    );
  }
  

  //==================================== ENCODE/DECODE UTILITIES ===============
  /// Decode time for specifics 3.2
  /// 
  /// [message] is the whole message (i.e the first element will be ignored)
  DateTime _decode_BCD_time(List<int> message){
    
    int BCD_decode(int bcd){
      return (bcd~/16) *10+bcd%16; //tilde is integer division
    }
    return DateTime(
      2000+BCD_decode(message[1]),
      BCD_decode(message[2]),
      BCD_decode(message[3]),
      BCD_decode(message[4]),
      BCD_decode(message[5]),
      BCD_decode(message[6])

    );

  }

  List<int> _encode_BCD_time(DateTime dt){
    int BCD_encode(int data){
      return (data~/10)*16 + data%10;
    }

    List<int> returnval=[];
    returnval.add(BCD_encode(dt.year-2000));
    returnval.add(BCD_encode(dt.month));
    returnval.add(BCD_encode(dt.day));
    returnval.add(BCD_encode(dt.hour));
    returnval.add(BCD_encode(dt.minute));
    returnval.add(BCD_encode(dt.second));

    return returnval;
  }

}