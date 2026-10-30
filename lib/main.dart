import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ControllerScreen(),
    );
  }
}

class ControllerScreen extends StatefulWidget {
  const ControllerScreen({super.key});

  @override
  State<ControllerScreen> createState() => _ControllerScreenState();
}

class _ControllerScreenState extends State<ControllerScreen> {
  final TextEditingController _ipCtrl = TextEditingController(text: '192.168.1.');

  Future<void> _send(String cmd) async {
    final ip = _ipCtrl.text.trim();
    try {
      await http.get(Uri.parse('http://$ip:7000/cmd?action=$cmd')).timeout(const Duration(seconds: 1));
    } catch (_) {}
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم إرسال: $cmd'), duration: const Duration(milliseconds: 300)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(title: const Text('PS4 Remote Controller'), backgroundColor: Colors.black),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ipCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'PS4 IP', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(onPressed: () => _send('connect'), child: const Text('اتصال')),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(onPressed: () => _send('L1'), child: const Text('L1')),
                ElevatedButton(onPressed: () => _send('share'), child: const Text('Share')),
                ElevatedButton(onPressed: () => _send('options'), child: const Text('Options')),
                ElevatedButton(onPressed: () => _send('R1'), child: const Text('R1')),
              ],
            ),
            const Spacer(),
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
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
