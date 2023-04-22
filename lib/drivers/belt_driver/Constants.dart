// ignore_for_file: file_names, constant_identifier_names

import 'dart:typed_data';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class SERVICES {
  SERVICES._();
  static late final Uuid MAIN = Uuid.parse("0000FFF0-0000-1000-8000-00805F9B34FB");
}

class CHARACTERISTICS {

  CHARACTERISTICS._();

  static late final Uuid NOTIFICATIONS = Uuid.parse("0000fff7-0000-1000-8000-00805f9b34fb");
  static late final Uuid WRITABLE = Uuid.parse("0000fff6-0000-1000-8000-00805f9b34fb");
}


class RESPONSES {
  RESPONSES._();

  //3.1 set time
  static const List<int> SET_TIME_OK = [0x01,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0x01];
  static const List<int> SET_TIME_ERROR = [0x81,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0x81];
  
  //3.2 get time
  static const List<int> GET_TIME_HEADER = [0x41];
  static const List<int> GET_TIME_ERROR = [0xc1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0xc1];

  //3.3 set user information
  static const List<int> SET_USERINFO_OK = [0x02,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0x02];
  static const List<int> SET_USERINFO_ERROR = [0X82,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0x82];

  //3.4 get user information
  static const List<int> GET_USERINFO_HEADER = [0x42];
  static const List<int> GET_USERINFO_ERROR = [0xc2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0xc2];
  
  //3.5 get heart rate storage data
  static const List<int> GET_HEARTRATE_HEADER = [0x17];
  static const List<int> GET_HEARTRATE_LAST = [0x17,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0X17];

  //3.6 bed time
  static const List<int> GET_BEDTIME_HEADER = [0x14];
  static const List<int> GET_BEDTIME_LAST = [0x14,255,0,0,0,0,0,0,0,0,0,0,0,0,0,0x13];

  //3.6.2 rollover
  static const List<int> GET_ROLLOVER_HEADER = [21];
  static const List<int> GET_ROLLOVER_LAST = [0x15,0xff,0,0,0,0,0,0,0,0,0,0,0,0,0,0x14];

}

class COMMANDS {

  COMMANDS._();

  //3.1 set time
  static const List<int> SET_TIME_HEADER = [0x01];

  //3.2 get time
  static const List<int> GET_TIME = [0x41, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0x41];

  //3.3 set userinfo
  static const List<int> SET_USERINFO_HEADER = [0X02];

  //3.4 get userinfo
  static const List<int> GET_USERINFO = [0X42, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0X42];


}

extension BLEMessage on List<int> {
  bool isMessage(List<int> other){
    if (other.length > this.length) return false;
    for (int i=0; i<other.length; i++){
      if (this[i]!=other[i]) return false;
    }
    return true;
  }
}