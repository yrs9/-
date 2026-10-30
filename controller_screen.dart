import 'package:flutter/material.dart';

class ControllerScreen extends StatelessWidget {
  const ControllerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // الجهة اليسرى: D-Pad وعصا التحكم اليسرى (Left Analog)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // مثال لعصا التحكم اليسرى
                  _buildAnalogStick("Left Analog"),
                  const SizedBox(height: 20),
                  // الـ D-Pad (الاتجاهات)
                  _buildDPad(),
                ],
              ),

              // المنتصف: أزرار النظام (Share, PS, Options)
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildSystemButton("SHARE", () {}),
                      const SizedBox(width: 10),
                      _buildSystemButton("PS", () {}),
                      const SizedBox(width: 10),
                      _buildSystemButton("OPTIONS", () {}),
                    ],
                  ),
                ],
              ),

              // الجهة اليمنى: أزرار الأكشن (Triangle, Circle, Cross, Square) وعصا التحكم اليمين
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildActionButtons(),
                  const SizedBox(height: 20),
                  _buildAnalogStick("Right Analog"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // تصميم الـ D-Pad
  Widget _buildDPad() {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        children: [
          Align(alignment: Alignment.topCenter, child: _buildButton("▲", () {})),
          Align(alignment: Alignment.bottomCenter, child: _buildButton("▼", () {})),
          Align(alignment: Alignment.centerLeft, child: _buildButton("◀", () {})),
          Align(alignment: Alignment.centerRight, child: _buildButton("▶", () {})),
        ],
      ),
    );
  }

  // تصميم أزرار الأكشن (المثلث، الدائرة، إلخ)
  Widget _buildActionButtons() {
    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        children: [
          Align(alignment: Alignment.topCenter, child: _buildButton("△", Colors.green, () {})),
          Align(alignment: Alignment.bottomCenter, child: _buildButton("✕", Colors.blue, () {})),
          Align(alignment: Alignment.centerLeft, child: _buildButton("▢", Colors.pink, () {})),
          Align(alignment: Alignment.centerRight, child: _buildButton("◯", Colors.red, () {})),
        ],
      ),
    );
  }

  Widget _buildButton(String label, [Color? color, VoidCallback? onPressed]) {
    return SizedBox(
      width: 40,
      height: 40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Colors.grey[800],
          padding: EdgeInsets.zero,
        ),
        onPressed: onPressed ?? () {},
        child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }

  Widget _buildSystemButton(String label, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _buildAnalogStick(String label) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[850],
        border: Border.all(color: Colors.grey[700]!, width: 2),
      ),
      child: Center(
        child: Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10), textAlign: TextAlign.center),
      ),
    );
  }
}
