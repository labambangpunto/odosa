import 'package:flutter/material.dart';

import 'tab_home.dart';
import 'tab_transaksi.dart';
import 'tab_utang.dart';
import 'tab_atur.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    TabHome(),
    TabTransaksi(),
    TabUtang(),
    TabAtur(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Transaksi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance),
            label: 'Utang',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Atur'),
        ],
      ),
    );
  }
}
