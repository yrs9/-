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
                  'قناة العرض نشطة - بانتظار استقبال التدفق المرئي',
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
                          _buildCtrlBtn('L2', () => _sendCmd('L2')),
                          const SizedBox(width: 6),
                          _buildCtrlBtn('L1', () => _sendCmd('L1')),
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
                          _buildCtrlBtn('R1', () => _sendCmd('R1')),
                          const SizedBox(width: 6),
                          _buildCtrlBtn('R2', () => _sendCmd('R2')),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          _buildCtrlBtn('▲', () => _sendCmd('up')),
                          Row(
                            children: [
                              _buildCtrlBtn('◄', () => _sendCmd('left')),
                              const SizedBox(width: 35),
                              _buildCtrlBtn('►', () => _sendCmd('right')),
                            ],
                          ),
                          _buildCtrlBtn('▼', () => _sendCmd('down')),
                        ],
                      ),
                      Column(
                        children: [
                          _buildCtrlBtn('△', () => _sendCmd('triangle'), color: Colors.green.withOpacity(0.7)),
                          Row(
                            children: [
                              _buildCtrlBtn('□', () => _sendCmd('square'), color: Colors.pink.withOpacity(0.7)),
                              const SizedBox(width: 35),
                              _buildCtrlBtn('◯', () => _sendCmd('circle'), color: Colors.red.withOpacity(0.7)),
                            ],
                          ),
                          _buildCtrlBtn('✕', () => _sendCmd('cross'), color: Colors.blue.withOpacity(0.7)),
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
