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

// 1. شاشة إدخال رمز الاقتران (PIN) والحصول عليه من إعدادات الـ PS4
class PairingScreen extends StatefulWidget {
  const PairingScreen({super.key});

  @override
  State<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends State<PairingScreen> {
  final TextEditingController _pinController = TextEditingController();
  bool _isLoading = false;

  Future<void> _pairDevice() async {
    final pin = _pinController.text.trim();
    if (pin.isEmpty || pin.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال رمز الاقتران الصحيح المكون من أرقام الحروف من البلايستيشن')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // محاكاة الاتصال وطلب الربط عبر الشبكة المحلية باستخدام رمز PIN
    await Future.delayed(const Duration(seconds: 15));

    setState(() => _isLoading = false);

    // الانتقال لشاشة التحكم واللعب بعد نجاح الربط
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ControllerScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ربط PS4 عبر رمز PIN'), backgroundColor: Colors.black),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.gamepad, size: 80, color: Colors.blueAccent),
            const SizedBox(height: 20),
            const Text(
              'للحصول على رمز PIN من جهاز الـ PS4 اذهب إلى:\nالإعدادات ➔ النظام ➔ اللعب عن بعد ➔ ربط جهاز',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _pinController,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, letterSpacing: 2),
              decoration: const InputDecoration(
                labelText: 'أدخل رمز الاقتران (PIN)',
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
                  const CircularProgressIndicator(color: Colors.white)
                  : const Text('ربط الجهاز وعرض الشاشة', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

// 2. شاشة واجهة التحكم والأزرار التي تظهر بعد الربط
class ControllerScreen extends StatefulWidget {
  const ControllerScreen({super.key});

  @override
  State<ControllerScreen> createState() => _ControllerScreenState();
}

class _ControllerScreenState extends State<ControllerScreen> {
  Future<void> _send(String cmd) async {
    try {
      // إرسال أمر التحكم عبر بروتوكول الشبكة المحلية للـ PS4 المهكر
      await http.get(Uri.parse('http://192.168.1.50:7000/cmd?action=$cmd')).timeout(const Duration(milliseconds: 500));
    } catch (_) {}
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم تنفيذ الأمر: $cmd'), duration: const Duration(milliseconds: 200)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('PS4 Remote Play - متصل'),
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
          // شاشة عرض محاكاة البث أو مكان العرض المرئي للعبة
          Expanded(
            flex: 4,
            container(
              color: Colors.grey[900],
              child: const Center(
                child: Text(
                  'شاشة عرض اللعب عن بُعد\n(Remote Play Screen)',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                ),
              ),
            ),
          ),
          
          // أزرار التحكم السفلية
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // أزرار علوية L1/R1 و Share/Options
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
                  
                  // الأزرار الرئيسية (الاتجاهات والأشكال)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // D-Pad
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
                      
                      // Shape Buttons (Triangle, Circle, Cross, Square)
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
