// Disable reload popup add this as a new row:  //pragma Env QS_NO_RELOAD_POPUP=1
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Services.Pipewire
import qs.Modules.Bar
import qs.Modules.Dock
import qs.Modules.Calendar
import qs.Modules.Demo
import qs.Modules.Background
import qs.Modules.SidePanel
import qs.Modules.AppLauncher
import qs.Modules.Notification
import qs.Modules.Settings
import qs.Services
import qs.Widgets

ShellRoot {
  id: shellRoot

  Background {}
  Overview {}
  ScreenCorners {}
  Bar {}
  Dock {}

  AppLauncher {
    id: appLauncherPanel
  }



  DemoPanel {
    id: demoPanel
  }

  SidePanel {
    id: sidePanel
  }

  Calendar {
    id: calendarPanel
  }

  SettingsPanel {
    id: settingsPanel
  }

  Notification {
    id: notification
  }

  NotificationHistoryPanel {
    id: notificationHistoryPanel
  }

  IPCManager {}

  Component.onCompleted: {
    // Ensure our singleton is created as soon as possible so we start fetching weather asap
    Location.init()
  }
}
