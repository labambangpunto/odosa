import 'package:flutter/material.dart';

import 'features/transactions/presentation/forms/expense_form.dart';
import 'features/transactions/presentation/forms/income_form.dart';
import 'features/transactions/presentation/forms/transfer_form.dart';

import 'features/debts/presentation/forms/payable_form.dart';
import 'features/debts/presentation/forms/receivable_form.dart';

import 'features/settings/presentation/pages/settings_page.dart'; // Import halaman settings
import 'features/transactions/presentation/pages/transaction_log_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Floating Dock App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Google Sans Flex',
      ),
      debugShowCheckedModeBanner: false,
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    Center(child: Text('Halaman Home', style: TextStyle(fontSize: 24))),
    TransactionLogPage(), // Diganti menggunakan TransactionLogPage
    Center(child: Text('Halaman Utang', style: TextStyle(fontSize: 24))),
    SettingsPage(),
  ];

  void _navigateToForm(BuildContext context, String title, Widget formWidget) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(title),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 1,
          ),
          body: formWidget,
        ),
      ),
    );
  }

  void _showTransactionOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Tambah Transaksi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.arrow_upward, color: Colors.red),
              title: const Text('Pengeluaran'),
              onTap: () {
                Navigator.pop(context);
                _navigateToForm(
                  context,
                  'Tambah Pengeluaran',
                  const ExpenseForm(),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.arrow_downward, color: Colors.green),
              title: const Text('Pemasukan'),
              onTap: () {
                Navigator.pop(context);
                _navigateToForm(
                  context,
                  'Tambah Pemasukan',
                  const IncomeForm(),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz, color: Colors.blue),
              title: const Text('Transfer Antarakun'),
              onTap: () {
                Navigator.pop(context);
                _navigateToForm(
                  context,
                  'Transfer Antarakun',
                  const TransferForm(),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showDebtOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Tambah Catatan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.arrow_circle_right_outlined,
                color: Colors.green,
              ),
              title: const Text('Orang Berutang (Piutang)'),
              subtitle: const Text('Anda menalangi atau meminjamkan dana'),
              onTap: () {
                Navigator.pop(context);
                _navigateToForm(
                  context,
                  'Tambah Piutang',
                  const ReceivableForm(),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.arrow_circle_left_outlined,
                color: Colors.red,
              ),
              title: const Text('Saya Berutang (Utang)'),
              subtitle: const Text('Anda menerima pinjaman dana'),
              onTap: () {
                Navigator.pop(context);
                _navigateToForm(context, 'Tambah Utang', const PayableForm());
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget? _buildFab() {
    if (_currentIndex == 1) {
      return FloatingActionButton(
        onPressed: () => _showTransactionOptions(context),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      );
    } else if (_currentIndex == 2) {
      return FloatingActionButton(
        onPressed: () => _showDebtOptions(context),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      extendBody: true,
      body: _pages[_currentIndex],
      floatingActionButton: _buildFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: SafeArea(
          child: Container(
            margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavItem(Icons.home_rounded, 'Home', 0),
                _buildNavItem(Icons.receipt_long_rounded, 'Transaksi', 1),
                _buildNavItem(Icons.account_balance_wallet_rounded, 'Utang', 2),
                _buildNavItem(Icons.settings_rounded, 'Atur', 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blue.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.blue : Colors.grey[600]),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.blue,
                  fontVariations: [FontVariation('wght', 700)],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
