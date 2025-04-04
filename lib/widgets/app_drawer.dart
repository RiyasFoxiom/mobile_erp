import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../view/items_adding_view.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.store, size: 48, color: Colors.white),
                  SizedBox(height: 8),
                  Text(
                    'Mobile ERP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.add_shopping_cart),
            title: Text('Item'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Get.to(() => ItemsAddingView());
            },
          ),
          // ListTile(
          //   leading: Icon(Icons.bar_chart),
          //   title: Text('Reports'),
          //   onTap: () {
          //     Navigator.pop(context); // Close drawer
          //     Get.to(() => ReportView());
          //   },
          // ),
          // Spacer(),
          // Divider(),
          // ListTile(
          //   leading: Icon(Icons.settings),
          //   title: Text('Settings'),
          //   onTap: () {
          //     Navigator.pop(context); // Close drawer
          //
          //   },
          // ),
          // ListTile(
          //   leading: Icon(Icons.info),
          //   title: Text('About'),
          //   onTap: () {
          //     Navigator.pop(context); // Close drawer
          //
          //   },
          // ),
          // SizedBox(height: 16),
        ],
      ),
    );
  }
}
