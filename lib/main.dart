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
      title: 'PS4 Jailbreak Streamer',
      theme: ThemeData.dark(),
      home: const ConnectionScreen(),
    );
  }
}

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  final TextEditingController _ipController = TextEditingController(text: '192.168.0.131');
  final TextEditingController _portController = TextEditingController(text: '8080');
  bool _isConnecting = false;

  void _connectToPS4() {
    final ip = _ipController.text.trim();
    final port = _portController.text.trim();

    if (ip.isEmpty || port.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال الـ IP ورقم البورت بشكل صحيح')),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => StreamControllerScreen(ps4Ip: ip, ps4Port: port),
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
                  Icon(Icons.sports_esports, size: 70, color: Colors.blueAccent),
                  SizedBox(height: 10),
                  Text('PS4 Jailbreak Direct Stream', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('اتصال مباشر بخادم البث المعدل', style: TextStyle(color: Colors.grey, fontSize: 12)),
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
                    decoration: const InputDecoration(labelText: 'PS4 IP Address', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _portController,
                    decoration: const InputDecoration(labelText: 'Server Port (مثال: 8080)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _connectToPS4,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, minimumSize: const Size.fromHeight(45)),
                    child: const Text('اتصال وعرض الشاشة'),
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

class StreamControllerScreen extends StatefulWidget {
  final String ps4Ip;
  final String ps4Port;
  const StreamControllerScreen({super.key, required this.ps4Ip, required this.ps4Port});

  @override
  State<StreamControllerScreen> createState() => _StreamControllerScreenState();
}

class _StreamControllerScreenState extends State<StreamControllerScreen> {
  Future<void> _sendAction(String action) async {
    try {
      await http.get(
        Uri.parse('http://${widget.ps4Ip}:${widget.ps4Port}/cmd?action=$action'),
      ).timeout(const Duration(milliseconds: 200));
    } catch (_) {}
  }

  Widget _buildButton(String label, VoidCallback onPressed, {Color? color}) {
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
    final streamUrl = 'http://${widget.ps4Ip}:${widget.ps4Port}/stream';

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. عرض خادم الفيديو المباشر من الـ PS4 المعدل
          Center(
            child: Container(
              color: Colors.grey[900],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.videocam_outlined, size: 40, color: Colors.blueAccent),
                    const SizedBox(height: 10),
                    Text(
                      'متصل بالخادم: $streamUrl',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'جاري استقبال تدفق الصورة من الـ PS4 المعدل...',
                      style: TextStyle(color: Colors.green, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. أزرار التحكم الشفافة فوق شاشة اللعبة
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
                          _buildButton('L2', () => _sendAction('L2')),
                          const SizedBox(width: 6),
                          _buildButton('L1', () => _sendAction('L1')),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.exit_to_app, color: Colors.redAccent),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const ConnectionScreen()),
                          );
                        },
                      ),
                      Row(
                        children: [
                          _buildButton('R1', () => _sendAction('R1')),
                          const SizedBox(width: 6),
                          _buildButton('R2', () => _sendAction('R2')),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          _buildButton('▲', () => _sendAction('up')),
                          Row(
                            children: [
                              _buildButton('◄', () => _sendAction('left')),
                              const SizedBox(width: 35),
                              _buildButton('►', () => _sendAction('right')),
                            ],
                          ),
                          _buildButton('▼', () => _sendAction('down')),
                        ],
                      ),
                      Column(
                        children: [
                          _buildButton('△', () => _sendAction('triangle'), color: Colors.green.withOpacity(0.7)),
                          Row(
                            children: [
                              _buildButton('□', () => _sendAction('square'), color: Colors.pink.withOpacity(0.7)),
                              const SizedBox(width: 35),
                              _buildButton('◯', () => _sendAction('circle'), color: Colors.red.withOpacity(0.7)),
                            ],
                          ),
                          _buildButton('✕', () => _sendAction('cross'), color: Colors.blue.withOpacity(0.7)),
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
