import 'package:flutter/material.dart';

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
      theme: ThemeData.dark(), // اخترنا الثيم الداكن ليلائم أجواء الألعاب
      home: const ControllerHomeScreen(),
    );
  }
}

class ControllerHomeScreen extends StatefulWidget {
  const ControllerHomeScreen({super.key});

  @override
  State<ControllerHomeScreen> createState() => _ControllerHomeScreenState();
}

class _ControllerHomeScreenState extends State<ControllerHomeScreen> {
  // متحكم لحقل إدخال الـ IP الخاص بالـ PS4
  final TextEditingController _ipController = TextEditingController();

  // دالة لإرسال الأوامر للـ PS4 (سنقوم بتطويرها لاحقاً لترسل طلبات شبكية حقيقية)
  void _sendCommand(String commandName) {
    String ip = _ipController.text.trim();
    if (ip.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال عنوان IP الخاص بجهاز PS4 أولاً!')),
      );
      return;
    }
    
    // هنا سيتم إرسال الأمر لاحقاً عبر HTTP REST للـ GoldHEN
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم إرسال الأمر ($commandName) إلى الجهاز: $ip')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تحكم PS4 - GoldHEN'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // حقل إدخال الـ IP وزر الاتصال
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ipController,
                    decoration: const InputDecoration(
                      labelText: 'أدخل IP جهاز PS4 (مثال: 192.168.1.50)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    // اختبار الاتصال مبدئياً
                    _sendCommand("CONNECT");
                  },
                  child: const Text('ربط'),
                ),
              ],
            ),
            const Spacer(),
            
            // منطقة أزرار التحكم الافتراضية المبسطة
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text(
                    'أزرار التحكم',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  // أزرار الأشكال (مثلث، دائرة، مربع، إكس)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(onPressed: () => _sendCommand("SQUARE"), child: const Text('🟩 مربع')),
                      ElevatedButton(onPressed: () => _sendCommand("TRIANGLE"), child: const Text('🔺 مثلث')),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(onPressed: () => _sendCommand("CROSS"), child: const Text('❌ إكس')),
                      ElevatedButton(onPressed: () => _sendCommand("CIRCLE"), child: const Text('⭕ دائرة')),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
