#include "include/custom_tooltip_flutter/custom_tooltip_flutter_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "custom_tooltip_flutter_plugin.h"

void CustomTooltipFlutterPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  custom_tooltip_flutter::CustomTooltipFlutterPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
