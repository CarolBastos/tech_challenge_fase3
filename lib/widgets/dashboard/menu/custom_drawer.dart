import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          ListTile(
            title: Text('Início'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('Transferência'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('Investimentos'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('Outros Serviços'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
