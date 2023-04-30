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

  //3.7 set device ID code
  static const List<int> SET_DEVICEID_OK = [0x05, 0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0, 0x05];
  static const List<int> SET_DEVICEID_ERROR = [0x85,0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x85];

  //3.8 real time heart rate
  static const List<int> GET_REALTIME_HEARTBREATH_HEADER = [0X11];
  static const List<int> GET_REALTIME_HEARTBREATH_OK = [0x11, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x11];
  static const List<int> GET_REALTIME_HEARTBREAT_ERROR = [0xc1, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0xc1];

  //3.9 restore factory settings
  static const List<int> RESTORE_FACTORY_OK = [0x12, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x12];
  static const List<int> RESTORE_FACTORY_ERROR = [0x92, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x92];

  //3.10 read device power
  static const List<int> GET_POWER_HEADER = [0x13];
  static const List<int> GET_POWER_ERROR = [0x93, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x93];

  //3.11 get device MAC address
  static const List<int> GET_MACADDR_HEADER = [0x22];
  static const List<int> GET_MACADDR_ERROR = [0xa2, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0xa2];

  //3.12 read the firmware version number
  static const List<int> GET_FIRMVER_HEADER = [0x27];
  static const List<int> GET_FIRMVER_ERROR = [0xA7, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0xA7];

  //3.13 soft reset
  static const List<int> SOFTRESET_OK = [0x2E, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x2E];
  static const List<int> SOFTRESET_ERROR = [0xAE, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0xAE];

  //3.14 NOT DOCUMENTED SO NOT IMPLEMENTED

  //3.15 SET DEVICE NAME
  static const List<int> SET_DEVICENAME_OK = [0x3D, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x3D];
  static const List<int> SET_DEVICENAME_ERROR = [0xBD, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0xBD];

  //3.16 GET DEVICE NAME
  static const List<int> GET_DEVICENAME_HEADER = [0x3E, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x3E];
  static const List<int> GET_DEVICENAME_ERROR = [0xBE, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0xBE];

  //3.17 GET DEBUG DATA
  static const List<int> GET_DEBUGDATA_HEARTRATE_HEADER = [0x03, 0x0];
  static const List<int> GET_DEBUGDATA_TURNOVER_HEADER = [0x03, 0x01];
  static const List<int> GET_DEBUGDATA_BEDTIME_HEADER = [0x03, 0x02];

  //3.18 GET RAW DATA
  static const List<int> GET_RAWDATA_OK = [0x16, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x16];
  static const List<int> GET_RAWDATA_HEADER = [0x16];
  static const List<int> GET_RAWDATA_ERROR = [0xC6, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0xC6];

  //3.19 DELETE HISTORICAL DATA
  static const List<int> DELETE_HISTORICALDATA_OK = [0x28, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x28];
  static const List<int> DELETE_HISTORICALDATA_ERROR = [0xB8, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0xB8];

  //3.20 TEMPERATURE
  static const List<int> GET_TEMPERATURE_OK = [0x0D, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0D];
  static const List<int> GET_TEMPERATURE_HEADER = [0x0D];
  static const List<int> GET_TEMPERATURE_ERROR = [0x0D, 0xFF, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0C];

  //3.21 DELETE ALL DATA
  static const List<int> DELETE_ALL_DATA_OK = [0x04, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x04];
  static const List<int> DELETE_ALL_DATA_ERROR = [0x04, 0xFF, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x03];
  

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

  //3.5 GET HEARTRATE STORAGE DATA
  static const List<int> GET_STORAGE_HEARTRATE_HEADER = [0x17];

  //3.6 GET BED TIME DATA
  static const List<int> GET_BEDTIME_HEADER = [0x14];

  //3.6.1 GET ROLLOVER
  static const List<int> GET_ROLLOVER_HEADER = [0x15];

  //3.7 SET DEVICE ID
  static const List<int> SET_DEVICEID_HEADER = [0x05];

  //3.8 REALTIME HEARTRATE
  static const List<int> GET_REALTIME_HEARTBREATH_ON = [0x11, 0x01, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x12];
  static const List<int> GET_REALTIME_HEARTBREATH_OFF = [0x11, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x11];

  //3.9 RESTORE FACTORY
  static const List<int> RESTORE_FACTORY = [0x12, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x12];

  //3.10 READ DEVICE POWER
  static const List<int> GET_POWER = [0x13, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x13];

  //3.11 READ MAC ADDRESS
  static const List<int> GET_MACADDR = [0x22, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x22];

  //3.12 READ FIRMVER
  static const List<int> GET_FIRVER = [0x27, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x27];

  //3.13 MCU SOFT RESET
  static const List<int> SOFT_RESET = [0x2E, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x2E];

  //3.14 FIRMWARE UPGRADE NOT DOCUMENTED SO NOT IMPLEMENTED

  //3.15 SET BLE DEVICE NAME
  static const List<int> SET_DEVICENAME_HEADER = [0x3D];

  //3.16 GET BLE DEVICE NAME
  static const List<int> GET_DEVICENAME = [0x3E, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x3E];

  //3.17 DEBUG DATA
  static const List<int> GET_DEBUGDATA_ON = [0x03, 0x05, 0x01, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x09];
  static const List<int> GET_DEBUGDATA_OFF = [0x03, 0x05, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x08];

  //3.18 GET RAW DATA
  static const List<int> GET_RAWDATA_ON = [0x16, 0x01, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x17];
  static const List<int> GET_RAWDATA_OFF = [0x16, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x16];

  //3.19 DELETE HISTORICAL DATA
  static const List<int> DELETE_HISTORICAL_DATA = [0x28, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x28];

  //3.20 TEMPERATURE AND HUMIDITY
  static const List<int> GET_TEMPERATURE_ON = [0x0D, 0x01, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0E];
  static const List<int> GET_TEMPERATURE_OFF = [0x0D, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0D];

  //3.21 DELETE ALL DATA
  static const List<int> DELETE_ALL_DATA = [0x04, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x04];

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