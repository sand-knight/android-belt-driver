import 'package:android_belt_driver/drivers/belt_driver/HappySleep.dart';
import 'package:flutter/material.dart';

import 'Demo/DemoPage.dart';


class MainDrawer extends StatelessWidget {
  const MainDrawer({Key? key, required this.belt}) : super(key: key);
  final HappySleepDevice belt;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Text("Android HappySleep Driver")
          ),
          ListTile(
            title: Text("Demo"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DemoPage(belt: belt)
                ) 
              );
            }
            
          )
        ],
      ),
    );
  }
}