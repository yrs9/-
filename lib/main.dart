import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // سنستخدمها لإرسال الطلبات للـ PS4

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
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: Colors.blueAccent,
      ),
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
  final TextEditingController _ipController = TextEditingController(text: '192.168.1.');
  bool _isConnected = false;

  // دالة لإرسال الأوامر عبر الشبكة المحلية إلى الـ PS4 (GoldHEN REST API / Payloads)
  Future<void> _sendCommand(String command) async {
    String ip = _ipController.text.trim();
    if (ip.isEmpty) {
      _showSnackBar('الرجاء إدخال عنوان IP الخاص بجهاز PS4 أولاً!');
      return;
    }

    // مثال على عنوان الاتصال (غالباً ما تستخدم بايولوجات الـ GoldHEN منفذ معين مثل 9090 أو حسب السكريبت)
    // يمكنك تعديل المنفذ (Port) ليطابق البايولود الذي تستخدمه على جهازك
    final url = Uri.parse('http://$ip:9090/cmd?action=$command');

    try {
      // إرسال طلب HTTP GET أو POST حسب الحاجة
      final response = await http.get(url).timeout(const Duration(seconds: 2));
      if (response.statusCode == 200) {
        _showSnackBar('تم إرسال: $command بنجاح ✅');
      } else {
        _showSnackBar('استابج الجهاز ولكن بخطأ: ${response.statusCode}');
      }
    } catch (e) {
      // للتجربة والتعلم، سنعرض رسالة نجاح وهمية حتى لو لم يكن الجهاز متصلاً الآن
      _showSnackBar('تم الضغط على: $command (محاكاة أو خطأ اتصال بالـ IP)');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(milliseconds: 800)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PS4 GoldHEN Remote Play'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isConnected ? Icons.link : Icons.link_off, 
                color: _isConnected ? Colors.green : Colors.red),
            onPressed: () {
              setState(() {
                _isConnected = !_isConnected;
              });
              _showSnackBar(_isConnected ? 'تم الاتصال بالوضع التجريبي' : 'تم قطع الاتصال');
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // حقل إدخال الـ IP
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ipController,
                    decoration: InputDecoration(
                      labelText: 'PS4 IP Address',
                      filled: true,
                      fillColor: Colors.grey[850],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _sendCommand("CONNECT"),
                  icon: const Icon(Icons.wifi),
                  label: const Text('ربط'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // أزرار L1 / L2 / R1 / R2 العلوية
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildTopButton('L2', () => _sendCommand('L2')),
                    const SizedBox(width: 8),
                    _buildTopButton('L1', () => _sendCommand('L1')),
                  ],
                ),
                Row(
                  children: [
                    _buildTopButton('R1', () => _sendCommand('R1')),
                    const SizedBox(width: 8),
                    _buildTopButton('R2', () => _sendCommand('R2')),
                  ],
                ),
              ],
            ),
            const Spacer(),

            // منطقة الأزرار الوسطى (D-Pad على اليسار والأشكال على اليمين)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // أزرار الاتجاهات (D-Pad)
                SizedBox(
                  width: 140,
                  height: 140,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(top: 0, child: _buildCircularButton(Icons.arrow_drop_up, () => _sendCommand('UP'))),
                      Positioned(bottom: 0, child: _buildCircularButton(Icons.arrow_drop_down, () => _sendCommand('DOWN'))),
                      Positioned(left: 0, child: _buildCircularButton(Icons.arrow_left, () => _sendCommand('LEFT'))),
                      Positioned(right: 0, child: _buildCircularButton(Icons.arrow_right, () => _sendCommand('RIGHT'))),
                    ],
                  ),
                ),

                // أزرار Share و Options في المنتصف
                Column(
                  children: [
                    Row(
                      children: [
                        _buildSmallButton('SHARE', () => _sendCommand('SHARE')),
                        const SizedBox(width: 10),
                        _buildSmallButton('OPTIONS', () => _sendCommand('OPTIONS')),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildSmallButton('PS', () => _sendCommand('PS_BUTTON')),
                  ],
                ),

                // أزرار الأشكال (مربع، مثلث، دائرة، إكس)
                SizedBox(
                  width: 140,
                  height: 140,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(top: 0, child: _buildShapeButton('🔺', Colors.green, () => _sendCommand('TRIANGLE'))),
                      Positioned(bottom: 0, child: _buildShapeButton('❌', Colors.blue, () => _sendCommand('CROSS'))),
                      Positioned(left: 0, child: _buildShapeButton('🟩', Colors.pink, () => _sendCommand('SQUARE'))),
                      Positioned(right: 0, child: _buildShapeButton('⭕', Colors.red, () => _sendCommand('CIRCLE'))),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  // دوال مساعدة لتصميم الأزرار بشكل أنيق
  Widget _buildTopButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[800],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildCircularButton(IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: 45,
      height: 45,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[850],
          foregroundColor: Colors.white,
          padding: EdgeInsets.zero,
          shape: const CircleBorder(),
        ),
        child: Icon(icon, size: 30),
      ),
    );
  }

  Widget _buildShapeButton(String text, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: 42,
      height: 42,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[850],
          foregroundColor: Colors.white,
          padding: EdgeInsets.zero,
          shape: const CircleBorder(),
        ),
        child: Text(text, style: const TextStyle(fontSize: 18)),
      ),
    );
  }

  Widget _buildSmallButton(String label, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.grey[300],
        side: BorderSide(color: Colors.grey[700]!),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      ),
      child: Text(label, style: const TextStyle(fontSize: 10)),
    );
  }
}
