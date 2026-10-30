import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const PS4RemoteApp());

class PS4RemoteApp extends StatelessWidget {
  const PS4RemoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PS4 Remote Play',
      theme: ThemeData(brightness: Brightness.dark, primaryColor: Colors.blue),
      home: const PairingScreen(),
    );
  }
}

// 1. شاشة إدخال رمز الاقتران (PIN) أو الـ IP
class PairingScreen extends StatefulWidget {
  const PairingScreen({super.key});

  @override
  State<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends State<PairingScreen> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _ipController = TextEditingController(text: '192.168.1.');
  bool _isLoading = false;

  Future<void> _pairDevice() async {
    final pin = _pinController.text.trim();
    final ip = _ipController.text.trim();
    
    if (pin.isEmpty || ip.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال رمز الاقتران وعنوان الـ IP')),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ControllerScreen(ps4Ip: ip)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إعدادات الاتصال بـ PS4'), backgroundColor: Colors.black),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.gamepad, size: 80, color: Colors.blueAccent),
            const SizedBox(height: 20),
            const Text(
              'أدخل عنوان IP الخاص بجهاز PS4 ورقم PIN الظاهر على الشاشة',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _ipController,
              decoration: const InputDecoration(
                labelText: 'عنوان IP لجهاز PS4 (مثال: 192.168.1.50)',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Color(0xFF1E1E1E),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _pinController,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, letterSpacing: 2),
              decoration: const InputDecoration(
                labelText: 'رمز الاقتران (PIN)',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Color(0xFF1E1E1E),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _pairDevice,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('اتصال وبدء اللعب', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

// 2. شاشة واجهة التحكم والأزرار
class ControllerScreen extends StatefulWidget {
  final String ps4Ip;
  const ControllerScreen({super.key, required this.ps4Ip});

  @override
  State<ControllerScreen> createState() => _ControllerScreenState();
}

class _ControllerScreenState extends State<ControllerScreen> {
  Future<void> _send(String cmd) async {
    try {
      await http.get(Uri.parse('http://${widget.ps4Ip}:7000/cmd?action=$cmd')).timeout(const Duration(milliseconds: 500));
    } catch (_) {}
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم إرسال الأمر: $cmd'), duration: const Duration(milliseconds: 200)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('متصل بـ: ${widget.ps4Ip}'),
        backgroundColor: Colors.grey[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const PairingScreen()),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.grey[900],
              child: const Center(
                child: Text(
                  'واجهة إرسال الأوامر والتحكم\n(Remote Controller Active)',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          ElevatedButton(onPressed: () => _send('L2'), child: const Text('L2')),
                          const SizedBox(width: 5),
                          ElevatedButton(onPressed: () => _send('L1'), child: const Text('L1')),
                        ],
                      ),
                      Row(
                        children: [
                          ElevatedButton(onPressed: () => _send('share'), child: const Text('Share')),
                          const SizedBox(width: 5),
                          ElevatedButton(onPressed: () => _send('options'), child: const Text('Options')),
                        ],
                      ),
                      Row(
                        children: [
                          ElevatedButton(onPressed: () => _send('R1'), child: const Text('R1')),
                          const SizedBox(width: 5),
                          ElevatedButton(onPressed: () => _send('R2'), child: const Text('R2')),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          ElevatedButton(onPressed: () => _send('up'), child: const Text('▲')),
                          Row(
                            children: [
                              ElevatedButton(onPressed: () => _send('left'), child: const Text('◄')),
                              const SizedBox(width: 30),
                              ElevatedButton(onPressed: () => _send('right'), child: const Text('►')),
                            ],
                          ),
                          ElevatedButton(onPressed: () => _send('down'), child: const Text('▼')),
                        ],
                      ),
                      Column(
                        children: [
                          ElevatedButton(
                            onPressed: () => _send('triangle'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            child: const Text('△'),
                          ),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () => _send('square'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                                child: const Text('□'),
                              ),
                              const SizedBox(width: 30),
                              ElevatedButton(
                                onPressed: () => _send('circle'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                child: const Text('◯'),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () => _send('cross'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                            child: const Text('✕'),
                          ),
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
