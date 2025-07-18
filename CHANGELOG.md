## 0.2.1

* Refactor: Tách các widget/phần logic lớn ra file riêng (`preferred_position.dart`, `custom_tooltip_shape_painter.dart`, `tooltip_positioner.dart`) giúp dễ bảo trì và mở rộng.
* Thêm hàm `hideTooltip` cho phép ẩn tooltip từ bên ngoài qua GlobalKey hoặc context.
* Cập nhật ví dụ sử dụng thực tế hàm `hideTooltip`.
* Cải thiện khả năng mở rộng và quản lý mã nguồn.

## 0.2.0

* Added `enableTapToOpen` property for tap-to-open functionality on all platforms
* When `enableTapToOpen` is enabled, mouse hover functionality is automatically disabled
* Improved mouse focus handling - tooltip now stays open when mouse moves from target to tooltip content
* Fixed tooltip positioning and mouse tracking logic
* Added comprehensive examples for all interaction modes
* Updated documentation with new features and examples

## 0.1.1

* Added WASM compatibility for web platform
* Improved shadow rendering for better cross-platform support 

## 0.1.0

* Added support for hold gesture on mobile devices
* Added `useHoldGesture` property to control tap/hold behavior
* Improved tooltip positioning logic
* Added smooth fade and scale animations
* Optimized performance and memory management
* Added comprehensive documentation
* Fixed potential memory leaks
* Improved code organization and readability

## 0.0.1

* Initial release of the custom_tooltip_flutter package.
