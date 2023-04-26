import 'dart:io';

import 'package:android_belt_driver/drivers/belt_driver/HappySleep.dart';
import 'package:android_belt_driver/drivers/belt_driver/clientAndroid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

void main() {

  WidgetsFlutterBinding.ensureInitialized();
  final blePlatform;
  if( Platform.isAndroid ){
    blePlatform = FlutterReactiveBle();
  }else{
    blePlatform = FlutterReactiveBle();
  }
  runApp(MyApp(blePlatform));
}

class MyApp extends StatelessWidget {
  MyApp(this.blePlatform, {super.key});
  final blePlatform;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(blePlatform, title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage(this.blePlatform, {super.key, required this.title});
  final blePlatform;
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState(blePlatform);
}

class _MyHomePageState extends State<MyHomePage> {
  String _counter = "Get time?";
  _MyHomePageState(this.blePlatform);
  final blePlatform;

  late final HappySleepDevice belt;

  late final Stream<DeviceConnectionState> _connectionstate;
  int _state = 0;
  bool buttonaval=true;
  Future<String> ? message;

  @override
  void initState() { 
    super.initState();
    belt = HappySleepDevice(
        Platform.isAndroid ? HappySleepClientAndroid(blePlatform, "ED:D0:65:DB:42:42") : throw Exception()
      );

    Stream<DeviceConnectionState> _connectionstate = belt.connectionStateStream;

    blePlatform.statusStream.listen(
      (status) {
        print("Status:\n"+ status.toString());
        if(status == BleStatus.ready){
          setState(
            () {
              _state = 1;
            
            }
          );
        }else{
          setState(
            (){
              _state = 0;
            }
          );
        }
      }
    );

    _connectionstate.listen(
      (event) {
        if(event == DeviceConnectionState.connected){
          setState(
            () {
              _state = 2;
            
            }
          );
        }else{
          if (_state == 2){
            _state = 1;
          }
        }
      }
    );
  }


  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      //_counter++;
      buttonaval=false;

      message = belt.setTime().then(
        (value) {
          return belt.getTime().then(
            (beltTime) {
              setState(() {
                buttonaval=true;
              });
              return beltTime.toString();
            }
          );
        }
      );

      // message=belt.getTime().then(
      //   (value) {
      //     setState(() {
      //       buttonaval=true;
      //     });
      //     return value.toString();
      //   }
      // );
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Row(
            //   children: [
            //     const Text("State "),
            //     Icon(
            //       Icons.access_alarm,
            //       color: _state==0 ? Color.fromRGBO(255, 0, 0, 1) : ( _state==1 ? Color.fromRGBO(0, 0, 255, 1) :Color.fromRGBO(0, 255, 0, 1) )
            //     )
                  
                
            //   ],
            // ),
            FutureBuilder(
              future: message,
              builder: (BuildContext, m) {
                if(m.hasData) return Text(m.data!);
                else if (m.hasError) return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error),
                    Text(m.error.toString())
                  ],
                );
                return const CircularProgressIndicator();
              },
              initialData: "get time?",
            ),
            IconButton(
              onPressed: () => belt.connect(),
              icon: const Icon(Icons.bluetooth),
              color: _state==0 ? Color.fromRGBO(255, 0, 0, 1) : ( _state==1 ? Color.fromRGBO(0, 0, 255, 1) :Color.fromRGBO(0, 255, 0, 1) ),
            )
            
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
       // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
