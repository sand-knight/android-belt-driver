import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

import '../../drivers/belt_driver/HappySleep.dart';



class GetData extends StatefulWidget {
  GetData({Key? key, required this.belt}) : super(key: key);

  final HappySleepDevice belt;

  @override
  _GetDataState createState() => _GetDataState(belt);
}

class _GetDataState extends State<GetData> {

  _GetDataState(this.belt);

  final HappySleepDevice belt;
  int status = 0;
  String message = "Press to start data gathering";
  ListQueue<int> data = ListQueue<int>(100);
  StreamSubscription<int> ? sub;
  RandomAccessFile ? file;
  
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void start() async {
    final directory = Directory((await getApplicationDocumentsDirectory()).path+"/csv");
    if (!await directory.exists()){
      directory.create();
    }
    file = await File("${directory.path}/${DateTime.now().millisecondsSinceEpoch.toString()}.csv").open(mode:FileMode.writeOnlyAppend);

    final asub = (await belt.setBcgOn()).listen(
      (bcgValue) async {
        print(bcgValue);
        file!.writeStringSync("$bcgValue\n");
            
        setState(
          () {
            data.add(bcgValue);
            print(data);
            if (data.length==101) data.removeFirst();
          }
        );

      }
    );

    //TODO USE THEN

    setState(() {
      sub=asub;
      data.clear();
      status = 1;
    });
  }

  Future<void> stop() async {
    await sub?.cancel();
    setState(
      () {
        status = 0;
      }
    );
    await file!.close();

  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // SfSparkLineChart.custom(
        //   dataCount: 100,
        //   yValueMapper: (index) => data.elementAt(index),
        // ),
        SfSparkLineChart(
          data: data.toList(),
        ),
        Row(
          children: [
            Text(message),
            IconButton(
              onPressed: status == 1 ? stop : start,
              icon: status == 1 ? Icon(Icons.downloading) : Icon(Icons.download)
              )
          ],
        )
      ]
    );
    
  }
}



class DemoPage extends StatelessWidget {
  const DemoPage({Key? key, this.drawer, required this.belt}) : super(key: key);

  final StatelessWidget ? drawer;
  final HappySleepDevice belt;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer:drawer,
      body: Center(
        child: GetData(
          belt: belt
        )
      ),
    );
  }
}