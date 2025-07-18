import 'package:flutter/material.dart';
import 'package:custom_tooltip_flutter/custom_tooltip_flutter.dart';

void main() {
  runApp(const MyApp());
}

/// Main application widget demonstrating various CustomTooltip configurations.
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
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                // Example 1: Basic tooltip with default settings
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

                // Example 2: Customized tooltip with advanced styling
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
                  arrowSize: 12.0, // Larger arrow for better visibility
                  offset: 8.0, // Increased distance from target
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
                const SizedBox(height: 40),

                // Example 3: Mouse focus test - demonstrates improved mouse tracking
                const Text(
                  'Mouse Focus Test Tooltip:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                CustomTooltip(
                  tooltipContent: Container(
                    padding: const EdgeInsets.all(8.0),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Hover over this tooltip content!',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'The tooltip should stay open when you move your mouse from the target to this content.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green, width: 2),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Test Mouse Focus',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Example 4: Tap to open mode - demonstrates the new tap functionality
                const Text(
                  'Tap to Open Tooltip:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                CustomTooltip(
                  // Enable tap to open mode - disables mouse hover
                  enableTapToOpen: true,
                  tooltipContent: Container(
                    padding: const EdgeInsets.all(8.0),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Tap to Open Mode!',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'This tooltip opens on tap and closes on tap again.\nMouse hover is disabled in this mode.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red, width: 2),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Tap Me!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Example 5: Test hideTooltip with show/hide buttons
                const Text(
                  'Test hideTooltip:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _HideTooltipDemo(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Thêm widget demo test hideTooltip
class _HideTooltipDemo extends StatefulWidget {
  @override
  State<_HideTooltipDemo> createState() => _HideTooltipDemoState();
}

class _HideTooltipDemoState extends State<_HideTooltipDemo> {
  final GlobalKey<CustomTooltipState> _tooltipKey =
      GlobalKey<CustomTooltipState>();

  void _showTooltip() {
    _tooltipKey.currentState?.showTooltip();
  }

  void _hideTooltip() {
    _tooltipKey.currentState?.hideTooltip();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomTooltip(
          key: _tooltipKey,
          tooltipContent: const Text('Tooltip for test!'),
          child: const Icon(Icons.lightbulb, size: 40, color: Colors.amber),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: _showTooltip,
          child: const Text('Show Tooltip'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _hideTooltip,
          child: const Text('Hide Tooltip'),
        ),
      ],
    );
  }
}
