import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // تثبيت الاتجاه الأفقي مثل تطبيق PS Remote Play الأصلي
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
      title: 'PS4 Jailbreak Remote Play',
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

  void _startRemotePlay() async {
    if (_ipController.text.isEmpty || _pinController.text.isEmpty) return;

    setState(() => _isConnecting = true);

    // محاكاة إرسال حزمة المصادقة الأولية لبروتوكول Remote Play
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => RemoteStreamScreen(
          ps4Ip: _ipController.text.trim(),
          pinCode: _pinController.text.trim(),
        ),
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
              color: Colors.black87,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.tv, size: 70, color: Colors.blueAccent),
                  SizedBox(height: 10),
                  Text('PS4 Remote Play Engine', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('مخصص لأجهزة PS4 المعدلة (GoldHEN)', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: _ipController,
                    decoration: const InputDecoration(labelText: 'IP Address', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _pinController,
                    decoration: const InputDecoration(labelText: 'PIN Code (من شاشة PS4)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: _isConnecting ? null : _startRemotePlay,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, minimumSize: const Size.fromHeight(45)),
                    child: _isConnecting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('اقتران وبدء البث المباشر'),
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

class RemoteStreamScreen extends StatelessWidget {
  final String ps4Ip;
  final String pinCode;

  const RemoteStreamScreen({super.key, required this.ps4Ip, required this.pinCode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // شاشة عرض البث المباشر الممتدة (Video Stream View)
          Center(
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: Colors.grey[900],
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(color: Colors.blueAccent),
                      const SizedBox(height: 15),
                      Text('جاري فتح قناة البث المباشر بدقة 720p عبر $ps4Ip...'),
                      const Text('Remote Play Socket Active', style: TextStyle(color: Colors.green, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // أزرار التحكّم الشفافة المباشرة فوق شاشة اللعبة (Overlay Controls)
          Positioned(
            bottom: 20,
            left: 20,
            child: Row(
              children: [
                IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white54), onPressed: () {}),
                IconButton(icon: const Icon(Icons.arrow_forward, color: Colors.white54), onPressed: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
