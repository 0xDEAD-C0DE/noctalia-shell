import QtQuick
import Quickshell.Io

Item {
  id: root

  // Reference to the lockscreen component
  property var lockscreen: null

  IpcHandler {
    target: "settings"

    function toggle() {
      settingsPanel.isLoaded = !settingsPanel.isLoaded
    }
  }

  IpcHandler {
    target: "notifications"

    function toggleHistory() {
      notificationHistoryPanel.isLoaded = !notificationHistoryPanel.isLoaded
    }

    function toggleDoNotDisturb() {// TODO
    }
  }

  IpcHandler {
    target: "idleInhibitor"

    function toggle() {// TODO
    }
  }

  IpcHandler {
    target: "appLauncher"

    function toggle() {
      appLauncherPanel.isLoaded = !appLauncherPanel.isLoaded
    }
  }

  IpcHandler {
    target: "lockScreen"

    function toggle() {
      lockScreen.locked = !lockScreen.locked
    }
  }

  IpcHandler {
    target: "brightness"

    function increase() {
      BrightnessService.increaseBrightness()
    }

    function decrease() {
      BrightnessService.decreaseBrightness()
    }
  }
}
