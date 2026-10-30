import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const PS4RemoteApp());
}

class PS4RemoteApp extends StatelessWidget {
  const PS4RemoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PS4 Remote Play Pro',
      theme: ThemeData.dark(),
      home: const PairingScreen(),
    );
  }
}

class PairingScreen extends StatefulWidget {
  const PairingScreen({super.key});

  @override
  State<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends State<PairingScreen> {
  final TextEditingController _ipController = TextEditingController(text: '192.168.0.131');
  final TextEditingController _pinController = TextEditingController();
  bool _isConnecting = false;

  void _startPairing() async {
    final ip = _ipController.text.trim();
    final pin = _pinController.text.trim();

    if (ip.isEmpty || pin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال الـ IP ورمز الـ PIN')),
      );
      return;
    }

    setState(() => _isConnecting = true);

    try {
      // إرسال حزمة المصادقة الأولية عبر منفذ الـ Remote Play
      await http.get(Uri.parse('http://$ip:9293/register?pin=$pin')).timeout(const Duration(seconds: 2));
    } catch (_) {}

    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isConnecting = false);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => RemotePlayScreen(ps4Ip: ip),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: Container(
              color: Colors.black,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.gamepad, size: 70, color: Colors.blueAccent),
                  SizedBox(height: 10),
                  Text('PS4 Remote Play (Jailbreak)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('تطبيق مخصص للتحكم وبث الشاشة', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: _ipController,
                    decoration: const InputDecoration(labelText: 'IP Address', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _pinController,
                    decoration: const InputDecoration(labelText: 'PIN Code (من التلفزيون)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isConnecting ? null : _startPairing,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, minimumSize: const Size.fromHeight(45)),
                    child: _isConnecting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('اتصال وبدء اللعب'),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RemotePlayScreen extends StatefulWidget {
  final String ps4Ip;
  const RemotePlayScreen({super.key, required this.ps4Ip});

  @override
  State<RemotePlayScreen> createState() => _RemotePlayScreenState();
}

class _RemotePlayScreenState extends State<RemotePlayScreen> {
  Future<void> _sendCmd(String action) async {
    try {
      await http.get(Uri.parse('http://${widget.ps4Ip}:7000/cmd?action=$action')).timeout(const Duration(milliseconds: 200));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. شاشة عرض البث في الخلفية
          Center(
            child: Container(
              color: Colors.grey[900],
              child: const Center(
                child: Text(
                  'قناة العرض نشطة - بانتظار استقبال التدفق المرئي',
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ),
            ),
          ),

          // 2. أزرار التحكم الشفافة فوق شاشة اللعبة (Overlay Controls)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // الشريط العلوي (L1, R1, Share, Options وخروج)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _buildCtrlBtn('L2', () => _sendCmd('L2')),
                          const SizedBox(width: 6),
                          _buildCtrlBtn('L1', () => _sendCmd('L1')),
                        ],
                      ),
                      IconButton(
                        icon
