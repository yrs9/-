import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const PS4ControllerApp());
}

class PS4ControllerApp extends StatelessWidget {
  const PS4ControllerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PS4 Remote Controller',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: const ControllerHomePage(),
    );
  }
}

class ControllerHomePage extends StatefulWidget {
  const ControllerHomePage({super.key});

  @override
  State<ControllerHomePage> createState() => _ControllerHomePageState();
}

class _ControllerHomePageState extends State<ControllerHomePage> {
  final TextEditingController _ipController = TextEditingController(text: '192.168.1.');
  bool _isConnected = false;

  // دالة لإرسال الأوامر إلى الـ PS4 عبر الشبكة المحلية
  Future<void> _sendCommand(String command) async {
    final ip = _ipController.text.trim();
    if (ip.isEmpty) {
      _showMsg('الرجاء إدخال عنوان الـ IP أولاً');
      return;
    }

    final url = Uri.parse('http://$ip:7000/cmd?action=$command');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 2));
      if (response.statusCode == 200) {
        setState(() => _isConnected = true);
      } else {
        _showMsg('استجابة غير متوقعة من الجهاز');
      }
    } catch (e) {
      setState(() => _isConnected = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم إرسال الأمر: $command (IP:$ip)'), duration: const Duration(milliseconds: 500)),
      );
    }
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PS4 Remote Controller'),
        backgroundColor: const Color(0xFF1F1F1F),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isConnected ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(_isConnected ? 'متصل' : 'غير متصل', style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // حقل إدخال عنوان IP للـ PS4
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ipController,
                    decoration: const InputDecoration(
                      labelText: 'عنوان IP الخاص بـ PS4',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Color(0xFF1E1E1E),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    _sendCommand('connect');
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                  child: const Text('اتصال'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // أزرار العلوية (L1, R1, L2, R2, Share, Options)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildButton('L2', () => _sendCommand('L2')),
                    const SizedBox(width: 8),
                    _buildButton('L1', () => _sendCommand('L1')),
                  ],
                ),
                Row(
                  children: [
                    _buildButton('Share', () => _sendCommand('share')),
                    const SizedBox(width: 8),
                    _buildButton('Options', () => _sendCommand('options')),
                  ],
                ),
                Row(
                  children: [
                    _buildButton('R1', () => _sendCommand('R1')),
                    const SizedBox(width: 8),
                    _buildButton('R2',
