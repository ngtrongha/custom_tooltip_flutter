import 'package:flutter/material.dart';
import 'package:custom_tooltip_flutter/custom_tooltip_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Tạo GlobalKey để truy cập state của CustomTooltip
    final tooltipKey = GlobalKey<CustomTooltipState>();
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('CustomTooltip Examples')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Default Tooltip:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              CustomTooltip(
                key: tooltipKey,
                tooltipContent: const Text('This is a default tooltip!'),
                child: const Icon(
                  Icons.info_outline,
                  size: 50,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  tooltipKey.currentState?.hideTooltip();
                },
                child: const Text('Hide Tooltip (Demo)'),
              ),
              const SizedBox(height: 40),
              const Text(
                'Customized Tooltip:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              CustomTooltip(
                tooltipContent: const Text(
                  'This is a customized tooltip with a larger arrow, different offset, fixed width, and custom decoration.',
                  textAlign: TextAlign.center,
                ),
                arrowSize: 12.0, // Larger arrow
                offset: 8.0, // Increased offset
                decoration: BoxDecoration(
                  color: Colors.deepPurpleAccent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.purple, width: 2),
                ),
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Hover Me!',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
