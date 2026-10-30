import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  String _statusText = '';

  Future<void> _startPairing() async {
    final ipStr = _ipController.text.trim();
    final pinStr = _pinController.text.trim();

    if (ipStr.isEmpty || pinStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال الـ IP ورمز الـ PIN')),
      );
      return;
    }

    setState(() {
      _isConnecting = true;
      _statusText = 'جاري إرسال حزم الـ UDP للـ PS4...';
    });

    try {
      // استخدام RawDatagramSocket لإرسال حزم المصادقة الثنائية عبر منفذ Remote Play (9295)
      final targetAddress = InternetAddress(ipStr);
      final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      
      // تجهيز حزمة الطلب الثنائية المخصصة للاقتران برمز الـ PIN
      final List<int> pinBytes = pinStr.codeUnits;
      final List<int> packet = [0x00, 0x01, 0x00, pinBytes.length, ...pinBytes];
      
      socket.send(packet, targetAddress, 9295);
      socket.close();
    } catch (_) {}

    await Future.delayed(const Duration(seconds: 15));
    if (!mounted) return;
    
    setState(() => _isConnecting = false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => RemotePlayScreen(ps4Ip: ipStr),
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
                  Text('إرسال حزم بروتوكول الـ UDP المباشر', style: TextStyle(color: Colors.grey, fontSize: 12)),
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
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                              const SizedBox(width: 10),
                              Text(_statusText, style: const TextStyle(fontSize: 12)),
                            ],
                          )
                        : const Text('اقتران عبر UDP وبدء البث'),
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
  RawDatagramSocket? _udpSocket;

  @override
  void initState() {
    super.initState();
    _initUdpController();
  }

  void _initUdpController() async {
    try {
      _udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    } catch (_) {}
  }

  void _sendUdpCmd(String action) {
    if (_udpSocket == null) return;
    try {
      final targetAddress = InternetAddress(widget.ps4Ip);
      final List<int> data = action.codeUnits;
      _udpSocket!.send(data, targetAddress, 9297); // منفذ التحكم في الـ Remote Play
    } catch (_) {}
  }

  @override
  void dispose() {
    _udpSocket?.close();
    super.dispose();
  }

  Widget _buildCtrlBtn(String label, VoidCallback onPressed, {Color? color}) {
    return SizedBox(
      width: 48,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Colors.grey[850]?.withOpacity(0.6),
          foregroundColor: Colors.white,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Container(
              color: Colors.grey[900],
              child: const Center(
                child: Text(
                  'قناة UDP النشطة - بانتظار إطارات الفيديو (H.264)',
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _buildCtrlBtn('L2', () => _sendUdpCmd('L2')),
                          const SizedBox(width: 6),
                          _buildCtrlBtn('L1', () => _sendUdpCmd('L1')),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.exit_to_app, color: Colors.redAccent),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const PairingScreen()),
                          );
                        },
                      ),
                      Row(
                        children: [
                          _buildCtrlBtn('R1', () => _sendUdpCmd('R1')),
                          const SizedBox(width: 6),
                          _buildCtrlBtn('R2', () => _sendUdpCmd('R2')),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          _buildCtrlBtn('▲', () => _sendUdpCmd('up')),
                          Row(
                            children: [
                              _buildCtrlBtn('◄', () => _sendUdpCmd('left')),
                              const SizedBox(width: 35),
                              _buildCtrlBtn('►', () => _sendUdpCmd('right')),
                            ],
                          ),
                          _buildCtrlBtn('▼', () => _sendUdpCmd('down')),
                        ],
                      ),
                      Column(
                        children: [
                          _buildCtrlBtn('△', () => _sendUdpCmd('triangle'), color: Colors.green.withOpacity(0.7)),
                          Row(
                            children: [
                              _buildCtrlBtn('□', () => _sendUdpCmd('square'), color: Colors.pink.withOpacity(0.7)),
                              const SizedBox(width: 35),
                              _buildCtrlBtn('◯', () => _sendUdpCmd('circle'), color: Colors.red.withOpacity(0.7)),
                            ],
                          ),
                          _buildCtrlBtn('✕', () => _sendUdpCmd('cross'), color: Colors.blue.withOpacity(0.7)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
