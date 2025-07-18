## 0.2.3

* Fixed: In `enableTapToOpen` mode, tapping again now properly closes the tooltip. Previously, the tooltip could not be closed by tapping a second time due to a state synchronization issue.

## 0.2.2

* Fixed: `hideTooltip` did not work when showing/hiding the tooltip from outside or via hover/tap. Now the tooltip visibility state (`_isTooltipVisible`) is always synchronized, ensuring `hideTooltip` works correctly on all platforms and trigger methods.

## 0.2.1

* Refactor: Split major widgets and logic into separate files (`preferred_position.dart`, `custom_tooltip_shape_painter.dart`, `tooltip_positioner.dart`) for better maintainability and extensibility.
* Added `hideTooltip` method to allow hiding the tooltip from outside via GlobalKey or context.
* Updated example to demonstrate real usage of `hideTooltip`.
* Improved codebase structure for easier management and extension.

## 0.2.0

* Added `enableTapToOpen` property for tap-to-open functionality on all platforms.
* When `enableTapToOpen` is enabled, mouse hover functionality is automatically disabled.
* Improved mouse focus handling - tooltip now stays open when mouse moves from target to tooltip content.
* Fixed tooltip positioning and mouse tracking logic.
* Added comprehensive examples for all interaction modes.
* Updated documentation with new features and examples.

## 0.1.1

* Added WASM compatibility for web platform.
* Improved shadow rendering for better cross-platform support.

## 0.1.0

* Added support for hold gesture on mobile devices.
* Added `useHoldGesture` property to control tap/hold behavior.
* Improved tooltip positioning logic.
* Added smooth fade and scale animations.
* Optimized performance and memory management.
* Added comprehensive documentation.
* Fixed potential memory leaks.
* Improved code organization and readability.

## 0.0.1

* Initial release of the custom_tooltip_flutter package.
