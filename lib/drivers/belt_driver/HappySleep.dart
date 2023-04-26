// ignore_for_file: prefer_conditional_assignment, curly_braces_in_flow_control_structures

import 'dart:async';

import 'package:android_belt_driver/drivers/belt_driver/Constants.dart';
import 'package:android_belt_driver/drivers/belt_driver/clientInterface.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class HappySleepDevice{

  HappySleepDevice(HappySleepClient client)
  : _client = client {
    connect = client.connect;
    disconnect = client.disconnect;
  }

  late final HappySleepClient _client;
  late final FutureOr<void> Function () connect;
  late final FutureOr<void> Function () disconnect;
  Stream<DeviceConnectionState>  get connectionStateStream => _client.connectionStateStream;

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
    final fut = _client.sendMessage(COMMANDS.GET_TIME);
    final Completer<DateTime> value=Completer();

    final sub = _client.arrivingMessages
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

    final fut = _client.sendMessage(message);
    final Completer<void> value=Completer();

    final sub = _client.arrivingMessages
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