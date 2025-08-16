import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Services
import qs.Widgets

NIconButton {
  id: root

  readonly property bool wifiEnabled: Settings.data.network.wifiEnabled
  sizeMultiplier: 0.8
  showBorder: false
  icon: {
    let connected = false
    let signalStrength = 0
    for (const net in NetworkService.networks) {
      if (NetworkService.networks[net].connected) {
        connected = true
        signalStrength = network.networks[net].signal
        break
      }
    }
    return connected ? NetworkService.signalIcon(signalStrength) : "wifi_off"
  }
  tooltipText: "WiFi Networks"
  onClicked: {
    if (!wifiMenuLoader.active) {
      wifiMenuLoader.isLoaded = true
    }
    if (wifiMenuLoader.item) {
      if (wifiMenuLoader.item.visible) {
        // Panel is visible, hide it with animation
        if (wifiMenuLoader.item.hide) {
          wifiMenuLoader.item.hide()
        } else {
          wifiMenuLoader.item.visible = false
          NetworkService.onMenuClosed()
        }
      } else {
        // Panel is hidden, show it
        wifiMenuLoader.item.visible = true
        NetworkService.onMenuOpened()
      }
    }
  }

  WiFiMenu {
    id: wifiMenuLoader
  }
}
