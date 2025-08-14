import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.Services
import qs.Widgets
import qs.Modules.LockScreen

NPanel {
  id: powerMenu
  visible: false

  // Anchors will be set by the parent component
  function show() {
    visible = true
  }

  function hide() {
    visible = false
  }

  Rectangle {
    width: 160 * scaling
    height: 220 * scaling
    radius: Style.radiusMedium * scaling
    border.color: Colors.outline
    border.width: Math.max(1, Style.borderThin * scaling)
    gradient: Gradient {
      GradientStop {
        position: 0.0
        color: Colors.backgroundSecondary
      }
      GradientStop {
        position: 1.0
        color: Colors.backgroundTertiary
      }
    }

    visible: true
    z: 9999

    anchors.top: parent.top
    anchors.right: parent.right
    anchors.rightMargin: Style.marginLarge * scaling
    anchors.topMargin: 86 * scaling

    // Prevent closing when clicking in the panel bg
    MouseArea {
      anchors.fill: parent
      onClicked: {

      }
    }

    ColumnLayout {
      anchors.fill: parent
      anchors.margins: Style.marginSmall * scaling
      spacing: Style.marginTiny * scaling

      // --------------
      // Lock
      Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 36 * scaling
        radius: Style.radiusSmall * scaling
        color: lockButtonArea.containsMouse ? Colors.hover : "transparent"

        Item {
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          anchors.leftMargin: Style.marginMedium * scaling
          anchors.rightMargin: Style.marginMedium * scaling

          Row {
            id: lockRow
            spacing: Style.marginSmall * scaling
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

            Text {
              text: "lock_outline"
              font.family: "Material Symbols Outlined"
              font.pointSize: Style.fontSizeLarge * scaling
              font.variableAxes: {
                "wght": (Font.Normal + Font.Bold) / 2.0
              }
              color: lockButtonArea.containsMouse ? Colors.textPrimary : Colors.textPrimary
              verticalAlignment: Text.AlignVCenter
              anchors.verticalCenter: parent.verticalCenter
              anchors.verticalCenterOffset: 1 * scaling
            }

            Text {
              text: "Lock Screen"
              color: lockButtonArea.containsMouse ? Colors.textPrimary : Colors.textPrimary
              verticalAlignment: Text.AlignVCenter
              anchors.verticalCenter: parent.verticalCenter
              anchors.verticalCenterOffset: 1 * scaling
            }
          }
        }

        MouseArea {
          id: lockButtonArea

          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            console.log("Lock screen requested")
            // Lock the screen
            lockScreen.locked = true
            powerMenu.visible = false
          }
        }
      }

      // --------------
      // Suspend
      Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 36 * scaling
        radius: Style.radiusSmall * scaling
        color: suspendButtonArea.containsMouse ? Colors.hover : "transparent"

        Item {
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          anchors.leftMargin: Style.marginMedium * scaling
          anchors.rightMargin: Style.marginMedium * scaling

          Row {
            id: suspendRow
            spacing: Style.marginSmall * scaling
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

            Text {
              text: "bedtime"
              font.family: "Material Symbols Outlined"
              font.pointSize: Style.fontSizeLarge * scaling
              font.variableAxes: {
                "wght": (Font.Normal + Font.Bold) / 2.0
              }
              color: suspendButtonArea.containsMouse ? Colors.textPrimary : Colors.textPrimary
              verticalAlignment: Text.AlignVCenter
              anchors.verticalCenter: parent.verticalCenter
              anchors.verticalCenterOffset: 1 * scaling
            }

            Text {
              text: "Suspend"
              color: suspendButtonArea.containsMouse ? Colors.textPrimary : Colors.textPrimary
              verticalAlignment: Text.AlignVCenter
              anchors.verticalCenter: parent.verticalCenter
              anchors.verticalCenterOffset: 1 * scaling
            }
          }
        }

        MouseArea {
          id: suspendButtonArea

          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            suspend()
            powerMenu.visible = false
          }
        }
      }

      // --------------
      // Reboot
      Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 36 * scaling
        radius: Style.radiusSmall * scaling
        color: rebootButtonArea.containsMouse ? Colors.hover : "transparent"

        Item {
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          anchors.leftMargin: Style.marginMedium * scaling
          anchors.rightMargin: Style.marginMedium * scaling

          Row {
            id: rebootRow
            spacing: Style.marginSmall * scaling
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

            Text {
              text: "refresh"
              font.family: "Material Symbols Outlined"
              font.pointSize: Style.fontSizeLarge * scaling
              font.variableAxes: {
                "wght": (Font.Normal + Font.Bold) / 2.0
              }
              color: rebootButtonArea.containsMouse ? Colors.textPrimary : Colors.textPrimary
              verticalAlignment: Text.AlignVCenter
              anchors.verticalCenter: parent.verticalCenter
              anchors.verticalCenterOffset: 1 * scaling
            }

            Text {
              text: "Reboot"
              color: rebootButtonArea.containsMouse ? Colors.textPrimary : Colors.textPrimary
              verticalAlignment: Text.AlignVCenter
              anchors.verticalCenter: parent.verticalCenter
              anchors.verticalCenterOffset: 1 * scaling
            }
          }
        }

        MouseArea {
          id: rebootButtonArea

          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            reboot()
            powerMenu.visible = false
          }
        }
      }

      // --------------
      // Logout
      Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 36 * scaling
        radius: Style.radiusSmall * scaling
        color: logoutButtonArea.containsMouse ? Colors.hover : "transparent"

        Item {
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          anchors.leftMargin: Style.marginMedium * scaling
          anchors.rightMargin: Style.marginMedium * scaling

          Row {
            id: logoutRow
            spacing: Style.marginSmall * scaling
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

            Text {
              text: "exit_to_app"
              font.family: "Material Symbols Outlined"
              font.pointSize: Style.fontSizeLarge * scaling
              font.variableAxes: {
                "wght": (Font.Normal + Font.Bold) / 2.0
              }
              color: logoutButtonArea.containsMouse ? Colors.textPrimary : Colors.textPrimary
              verticalAlignment: Text.AlignVCenter
              anchors.verticalCenter: parent.verticalCenter
              anchors.verticalCenterOffset: 1 * scaling
            }

            Text {
              text: "Logout"
              color: logoutButtonArea.containsMouse ? Colors.textPrimary : Colors.textPrimary
              verticalAlignment: Text.AlignVCenter
              anchors.verticalCenter: parent.verticalCenter
              anchors.verticalCenterOffset: 1 * scaling
            }
          }
        }

        MouseArea {
          id: logoutButtonArea

          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            logout()
            powerMenu.visible = false
          }
        }
      }

      // --------------
      // Shutdown
      Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 36 * scaling
        radius: Style.radiusSmall * scaling
        color: shutdownButtonArea.containsMouse ? Colors.hover : "transparent"

        Item {
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          anchors.leftMargin: Style.marginMedium * scaling
          anchors.rightMargin: Style.marginMedium * scaling

          Row {
            id: shutdownRow
            spacing: Style.marginSmall * scaling
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

            Text {
              text: "power_settings_new"
              font.family: "Material Symbols Outlined"
              font.pointSize: Style.fontSizeLarge * scaling
              font.variableAxes: {
                "wght": (Font.Normal + Font.Bold) / 2.0
              }
              color: shutdownButtonArea.containsMouse ? Colors.textPrimary : Colors.textPrimary
              verticalAlignment: Text.AlignVCenter
              anchors.verticalCenter: parent.verticalCenter
              anchors.verticalCenterOffset: 1 * scaling
            }

            Text {
              text: "Shutdown"
              color: shutdownButtonArea.containsMouse ? Colors.textPrimary : Colors.textPrimary
              verticalAlignment: Text.AlignVCenter
              anchors.verticalCenter: parent.verticalCenter
              anchors.verticalCenterOffset: 1 * scaling
            }
          }
        }

        MouseArea {
          id: shutdownButtonArea

          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            shutdown()
            powerMenu.visible = false
          }
        }
      }
    }
  }

  // ----------------------------------
  // System functions
  function logout() {
    if (Workspaces.isNiri) {
      logoutProcessNiri.running = true
    } else if (Workspaces.isHyprland) {
      logoutProcessHyprland.running = true
    } else {
      console.warn("No supported compositor detected for logout")
    }
  }

  function suspend() {
    suspendProcess.running = true
  }

  function shutdown() {
    shutdownProcess.running = true
  }

  function reboot() {
    rebootProcess.running = true
  }

  Process {
    id: shutdownProcess

    command: ["shutdown", "-h", "now"]
    running: false
  }

  Process {
    id: rebootProcess

    command: ["reboot"]
    running: false
  }

  Process {
    id: suspendProcess

    command: ["systemctl", "suspend"]
    running: false
  }

  Process {
    id: logoutProcessNiri

    command: ["niri", "msg", "action", "quit", "--skip-confirmation"]
    running: false
  }

  Process {
    id: logoutProcessHyprland

    command: ["hyprctl", "dispatch", "exit"]
    running: false
  }

  Process {
    id: logoutProcess

    command: ["loginctl", "terminate-user", Quickshell.env("USER")]
    running: false
  }

  // LockScreen instance
  LockScreen {
    id: lockScreen
  }
}
