// ignore_for_file: file_names, constant_identifier_names

import 'dart:typed_data';

class CHARACTERISTICS {

  CHARACTERISTICS._();

  static const String NOTIFICATIONS = "0000fff7-0000-1000-8000-00805f9b34fb";
  static const String WRITABLE = "0000fff6-0000-1000-8000-00805f9b34fb";
}


class RESPONSES {
  RESPONSES._();

  //3.1 set time
  static const List<int> SET_TIME_OK = [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1];
  static const List<int> SET_TIME_ERROR = [1+8*16,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1+8*16];
  
  //3.2 get time
  static const List<int> GET_TIME_HEADER = [1+4*16];
  static const List<int> GET_TIME_ERROR = [1+12*16,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1+12*16];

  //3.3 set user information
  static const List<int> SET_USERINFO_OK = [2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2];
  static const List<int> SET_USERINFO_ERROR = [8*16+2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8*16+2];

  //3.4 get user information
  static const List<int> GET_USERINFO_HEADER = [4*16+2];
  static const List<int> GET_USERINFO_ERROR = [2+12*16,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2+12*16];
  
  //3.5 get heart rate storage data
  static const List<int> GET_HEARTRATE_HEADER = [23,];
  static const List<int> GET_HEARTRATE_LAST = [23,0,0,0,0,0,0,0,0,0,0,0,0,0,0,23];

  //3.6 bed time
  static const List<int> GET_BEDTIME_HEADER = [20,];
  static const List<int> GET_BEDTIME_LAST = [20,255,0,0,0,0,0,0,0,0,0,0,0,0,0,19];

  //3.6.2 rollover
  static const List<int> GET_ROLLOVER_HEADER = [21,];
  static const List<int> GET_ROLLOVER_LAST = [21,255,0,0,0,0,0,0,0,0,0,0,0,0,0,20];

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