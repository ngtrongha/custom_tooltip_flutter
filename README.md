# Custom Tooltip Flutter

[![Pub Version](https://img.shields.io/pub/v/custom_tooltip_flutter.svg)](https://pub.dev/packages/custom_tooltip_flutter)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A highly customizable tooltip widget for your Flutter applications. Display informative messages when a user hovers over a widget.

<!-- Optional: Add a GIF or a couple of screenshots here to showcase your tooltip in action! -->
<!-- <img src="link_to_your_gif_or_screenshot.png" width="300"> -->

## Features

*   **Fully Customizable Content**: Use any widget as the content of your tooltip.
*   **Customizable Appearance**: Control the arrow size, offset from the target, tooltip width, and apply custom `BoxDecoration` for colors, borders, shadows, and border radius.
*   **Easy to Use**: Simple API for quick integration.
*   **Pure Dart**: Works on all platforms supported by Flutter.

## Getting Started

Add `custom_tooltip_flutter` to your `pubspec.yaml` file:

```yaml
dependencies:
  custom_tooltip_flutter: ^latest_version # Replace with the latest version from pub.dev
```

Then, run `flutter pub get` in your terminal.

## Usage

Import the package in your Dart file:

```dart
import 'package:custom_tooltip_flutter/custom_tooltip_flutter.dart';
```

Here's a basic example of how to use `CustomTooltip`:

```dart
CustomTooltip(
  tooltipContent: const Text('This is a simple tooltip!'),
  child: const Icon(Icons.info),
)
```

And here's an example with more customizations:

```dart
CustomTooltip(
  tooltipContent: Container(
    padding: const EdgeInsets.all(8.0),
    child: const Text(
      'This is a customized tooltip with a larger arrow, different offset, fixed width, and custom decoration.',
      textAlign: TextAlign.center,
    ),
  ),
  arrowSize: 12.0,
  offset: 8.0,
  contentWidth: 200.0,
  decoration: BoxDecoration(
    color: Colors.deepPurpleAccent,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.3),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
    border: Border.all(
      color: Colors.purple,
      width: 2,
    ),
  ),
  child: Container(
    padding: const EdgeInsets.all(12.0),
    decoration: BoxDecoration(
      color: Colors.orangeAccent,
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Text(
      'Hover Me!',
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
  ),
)
```

## Properties

The `CustomTooltip` widget accepts the following properties for customization:

*   `child`: (Required) The widget that will trigger the tooltip when hovered.
*   `tooltipContent`: (Required) The widget to display as the content of the tooltip.
*   `arrowSize`: `double` (default: `8.0`) - The size of the arrow pointing to the child widget.
*   `offset`: `double` (default: `4.0`) - The vertical distance between the child widget and the tooltip.
*   `contentWidth`: `double?` (optional) - A fixed width for the tooltip content. If null, it sizes to its content.
*   `decoration`: `BoxDecoration?` (optional) - Custom decoration for the tooltip container. Allows you to control background color, border, border radius, shadow, etc.

## Contributing

Contributions are welcome! If you find any issues or have suggestions for improvements, please open an issue or submit a pull request on the repository.

## License

This package is licensed under the MIT License - see the [LICENSE](LICENSE) file for details (assuming you have a LICENSE file, if not, you can remove this link or create one).

