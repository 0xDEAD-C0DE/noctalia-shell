import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pam
import Quickshell.Io
import Quickshell.Widgets
import qs.Services
import qs.Widgets

WlSessionLock {
  id: lock

  // Lockscreen is a different beast, needs a capital 'S' in 'Screen' to get the current screen
  readonly property real scaling: Scaling.scale(Screen)

  property string errorMessage: ""
  property bool authenticating: false
  property string password: ""
  property bool pamAvailable: typeof PamContext !== "undefined"
  locked: false

  function unlockAttempt() {
    console.log("Unlock attempt started")

    // Real PAM authentication
    if (!pamAvailable) {
      lock.errorMessage = "PAM authentication not available."
      console.log("PAM not available")
      return
    }
    if (!lock.password) {
      lock.errorMessage = "Password required."
      console.log("No password entered")
      return
    }
    console.log("Starting PAM authentication...")
    lock.authenticating = true
    lock.errorMessage = ""

    console.log("[LockScreen] About to create PAM context with userName:", Quickshell.env("USER"))
    var pam = Qt.createQmlObject(
          'import Quickshell.Services.Pam; PamContext { config: "login"; user: "' + Quickshell.env("USER") + '" }',
          lock)
    console.log("PamContext created", pam)

    pam.onCompleted.connect(function (result) {
      console.log("PAM completed with result:", result)
      lock.authenticating = false
      if (result === PamResult.Success) {
        console.log("Authentication successful, unlocking...")
        lock.locked = false
        lock.password = ""
        lock.errorMessage = ""
      } else {
        console.log("Authentication failed")
        lock.errorMessage = "Authentication failed."
        lock.password = ""
      }
      pam.destroy()
    })

    pam.onError.connect(function (error) {
      console.log("PAM error:", error)
      lock.authenticating = false
      lock.errorMessage = pam.message || "Authentication error."
      lock.password = ""
      pam.destroy()
    })

    pam.onPamMessage.connect(function () {
      console.log("PAM message:", pam.message, "isError:", pam.messageIsError)
      if (pam.messageIsError) {
        lock.errorMessage = pam.message
      }
    })

    pam.onResponseRequiredChanged.connect(function () {
      console.log("PAM response required:", pam.responseRequired)
      if (pam.responseRequired && lock.authenticating) {
        console.log("Responding to PAM with password")
        pam.respond(lock.password)
      }
    })

    var started = pam.start()
    console.log("PAM start result:", started)
  }

  WlSessionLockSurface {
    // Wallpaper image
    Image {
      id: lockBgImage
      anchors.fill: parent
      fillMode: Image.PreserveAspectCrop
      source: Wallpapers.currentWallpaper !== "" ? Wallpapers.currentWallpaper : ""
      cache: true
      smooth: true
      mipmap: false
    }

    // Blurred background
    Rectangle {
      anchors.fill: parent
      color: "transparent"

      // Simple blur effect
      layer.enabled: true
      layer.smooth: true
      layer.samples: 4
    }

    // Animated gradient overlay
    Rectangle {
      anchors.fill: parent
      gradient: Gradient {
        GradientStop {
          position: 0.0
          color: Qt.rgba(0, 0, 0, 0.6)
        }
        GradientStop {
          position: 0.3
          color: Qt.rgba(0, 0, 0, 0.3)
        }
        GradientStop {
          position: 0.7
          color: Qt.rgba(0, 0, 0, 0.4)
        }
        GradientStop {
          position: 1.0
          color: Qt.rgba(0, 0, 0, 0.7)
        }
      }

      // Subtle animated particles
      Repeater {
        model: 20
        Rectangle {
          width: Math.random() * 4 + 2
          height: width
          radius: width * 0.5
          color: Qt.rgba(Colors.mPrimary.r, Colors.mPrimary.g, Colors.mPrimary.b, 0.3)
          x: Math.random() * parent.width
          y: Math.random() * parent.height

          SequentialAnimation on opacity {
            loops: Animation.Infinite
            NumberAnimation {
              to: 0.8
              duration: 2000 + Math.random() * 3000
            }
            NumberAnimation {
              to: 0.1
              duration: 2000 + Math.random() * 3000
            }
          }
        }
      }
    }

    // Main content - Centered design
    Item {
      anchors.fill: parent

      // Top section - Time, date, and user info
      ColumnLayout {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 80 * scaling
        spacing: 40 * scaling

        // Time display - Large and prominent with pulse animation
        Column {
          spacing: 8 * scaling
          Layout.alignment: Qt.AlignHCenter

          Text {
            id: timeText
            text: Qt.formatDateTime(new Date(), "HH:mm")
            font.family: "Inter"
            font.pointSize: Style.fontSizeXXL * 6
            font.weight: Font.Bold
            font.letterSpacing: -2
            color: Colors.mOnSurface
            horizontalAlignment: Text.AlignHCenter

            SequentialAnimation on scale {
              loops: Animation.Infinite
              NumberAnimation {
                to: 1.02
                duration: 2000
                easing.type: Easing.InOutQuad
              }
              NumberAnimation {
                to: 1.0
                duration: 2000
                easing.type: Easing.InOutQuad
              }
            }
          }

          Text {
            id: dateText
            text: Qt.formatDateTime(new Date(), "dddd, MMMM d")
            font.family: "Inter"
            font.pointSize: Style.fontSizeXL
            font.weight: Font.Light
            color: Colors.mOnSurface
            horizontalAlignment: Text.AlignHCenter
            width: timeText.width
          }
        }

        // User section with animated avatar
        Column {
          spacing: 16 * scaling
          Layout.alignment: Qt.AlignHCenter

          // Animated avatar with glow effect
          Rectangle {
            width: 120 * scaling
            height: 120 * scaling
            radius: width * 0.5
            color: "transparent"
            border.color: Colors.mPrimary
            border.width: 3 * scaling
            anchors.horizontalCenter: parent.horizontalCenter

            // Glow effect
            Rectangle {
              anchors.centerIn: parent
              width: parent.width + 24 * scaling
              height: parent.height + 24 * scaling
              radius: width * 0.5
              color: "transparent"
              border.color: Qt.rgba(Colors.mPrimary.r, Colors.mPrimary.g, Colors.mPrimary.b, 0.3)
              border.width: 2 * scaling
              z: -1

              SequentialAnimation on scale {
                loops: Animation.Infinite
                NumberAnimation {
                  to: 1.1
                  duration: 1500
                  easing.type: Easing.InOutQuad
                }
                NumberAnimation {
                  to: 1.0
                  duration: 1500
                  easing.type: Easing.InOutQuad
                }
              }
            }

            NImageRounded {
              anchors.centerIn: parent
              width: 100 * scaling
              height: 100 * scaling
              imagePath: Quickshell.env("HOME") + "/.face"
              fallbackIcon: "person"
              imageRadius: width * 0.5
            }

            // Hover animation
            MouseArea {
              anchors.fill: parent
              hoverEnabled: true
              onEntered: parent.scale = 1.05
              onExited: parent.scale = 1.0
            }

            Behavior on scale {
              NumberAnimation {
                duration: 200
                easing.type: Easing.OutBack
              }
            }
          }
        }
      }

      // Centered terminal section
      Item {
        width: 720 * scaling
        height: 280 * scaling
        anchors.centerIn: parent

        ColumnLayout {
          anchors.centerIn: parent
          spacing: 20 * scaling
          width: parent.width

          // Futuristic Terminal-Style Input
          Item {
            width: parent.width
            height: 280 * scaling
            Layout.fillWidth: true

            // Terminal background with scanlines
            Rectangle {
              id: terminalBackground
              anchors.fill: parent
              radius: 16
              color: Colors.applyOpacity(Colors.mSurface, "E6")
              border.color: Colors.mPrimary
              border.width: 2 * scaling

              // Scanline effect
              Repeater {
                model: 20
                Rectangle {
                  width: parent.width
                  height: 1
                  color: Colors.applyOpacity(Colors.mPrimary, "1A")
                  y: index * 10
                  opacity: 0.3

                  SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    NumberAnimation {
                      to: 0.6
                      duration: 2000 + Math.random() * 1000
                    }
                    NumberAnimation {
                      to: 0.1
                      duration: 2000 + Math.random() * 1000
                    }
                  }
                }
              }

              // Terminal header
              Rectangle {
                width: parent.width
                height: 40 * scaling
                color: Colors.applyOpacity(Colors.mPrimary, "33")
                topLeftRadius: 14
                topRightRadius: 14

                RowLayout {
                  anchors.fill: parent
                  anchors.margins: 12 * scaling
                  spacing: 12 * scaling

                  Text {
                    text: "SECURE TERMINAL"
                    color: Colors.mOnSurface
                    font.family: "DejaVu Sans Mono"
                    font.pointSize: Style.fontSizeLarge
                    font.weight: Font.Bold
                    Layout.fillWidth: true
                  }
                }
              }

              // Terminal content area
              ColumnLayout {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.topMargin: 70 * scaling
                anchors.margins: 12 * scaling
                spacing: 12 * scaling

                // Welcome back typing effect
                RowLayout {
                  Layout.fillWidth: true
                  spacing: 12 * scaling

                  Text {
                    text: "root@noctalia:~$"
                    color: Colors.mPrimary
                    font.family: "DejaVu Sans Mono"
                    font.pointSize: Style.fontSizeLarge
                    font.weight: Font.Bold
                  }

                  Text {
                    id: welcomeText
                    text: ""
                    color: Colors.mOnSurface
                    font.family: "DejaVu Sans Mono"
                    font.pointSize: Style.fontSizeLarge
                    property int currentIndex: 0
                    property string fullText: "Welcome back, " + Quickshell.env("USER") + "!"

                    Timer {
                      interval: 100
                      running: true
                      repeat: true
                      onTriggered: {
                        if (parent.currentIndex < parent.fullText.length) {
                          parent.text = parent.fullText.substring(0, parent.currentIndex + 1)
                          parent.currentIndex++
                        } else {
                          running = false
                        }
                      }
                    }
                  }
                }

                // Command line with integrated password input
                RowLayout {
                  Layout.fillWidth: true
                  spacing: 12 * scaling

                  Text {
                    text: "root@noctalia:~$"
                    color: Colors.mPrimary
                    font.family: "DejaVu Sans Mono"
                    font.pointSize: Style.fontSizeLarge
                    font.weight: Font.Bold
                  }

                  Text {
                    text: "sudo unlock-session"
                    color: Colors.mOnSurface
                    font.family: "DejaVu Sans Mono"
                    font.pointSize: Style.fontSizeLarge
                  }

                  // Integrated password input (invisible, just for functionality)
                  TextInput {
                    id: passwordInput
                    width: 0
                    height: 0
                    visible: false
                    font.family: "DejaVu Sans Mono"
                    font.pointSize: Style.fontSizeLarge
                    color: Colors.mOnSurface
                    echoMode: TextInput.Password
                    passwordCharacter: "*"
                    passwordMaskDelay: 0

                    text: lock.password
                    onTextChanged: {
                      lock.password = text
                      // Terminal typing sound effect (visual)
                      typingEffect.start()
                    }

                    Keys.onPressed: function (event) {
                      if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        lock.unlockAttempt()
                      }
                    }

                    Component.onCompleted: {
                      forceActiveFocus()
                    }
                  }

                  // Visual password display with integrated cursor
                  Text {
                    id: asterisksText
                    text: "*".repeat(passwordInput.text.length)
                    color: Colors.mOnSurface
                    font.family: "DejaVu Sans Mono"
                    font.pointSize: Style.fontSizeLarge
                    visible: passwordInput.activeFocus

                    // Typing effect animation
                    SequentialAnimation {
                      id: typingEffect
                      NumberAnimation {
                        target: passwordInput
                        property: "scale"
                        to: 1.01
                        duration: 50
                      }
                      NumberAnimation {
                        target: passwordInput
                        property: "scale"
                        to: 1.0
                        duration: 50
                      }
                    }
                  }

                  // Blinking cursor positioned right after the asterisks
                  Rectangle {
                    width: 8 * scaling
                    height: 20 * scaling
                    color: Colors.mPrimary
                    visible: passwordInput.activeFocus
                    anchors.left: asterisksText.right
                    anchors.leftMargin: 2 * scaling
                    anchors.verticalCenter: asterisksText.verticalCenter

                    SequentialAnimation on opacity {
                      loops: Animation.Infinite
                      NumberAnimation {
                        to: 1.0
                        duration: 500
                      }
                      NumberAnimation {
                        to: 0.0
                        duration: 500
                      }
                    }
                  }
                }

                // Status messages
                Text {
                  text: lock.authenticating ? "Authenticating..." : (lock.errorMessage !== "" ? "Authentication failed." : "")
                  color: lock.authenticating ? Colors.mPrimary : (lock.errorMessage !== "" ? Colors.mError : "transparent")
                  font.family: "DejaVu Sans Mono"
                  font.pointSize: Style.fontSizeLarge
                  Layout.fillWidth: true

                  SequentialAnimation on opacity {
                    running: lock.authenticating
                    loops: Animation.Infinite
                    NumberAnimation {
                      to: 1.0
                      duration: 800
                    }
                    NumberAnimation {
                      to: 0.5
                      duration: 800
                    }
                  }
                }

                // Execute button
                Rectangle {
                  width: 120 * scaling
                  height: 40 * scaling
                  radius: 12
                  color: executeButtonArea.containsMouse ? Colors.mPrimary : Colors.applyOpacity(Colors.mPrimary, "33")
                  border.color: Colors.mPrimary
                  border.width: 1
                  enabled: !lock.authenticating
                  Layout.alignment: Qt.AlignRight
                  Layout.bottomMargin: -12 * scaling

                  Text {
                    anchors.centerIn: parent
                    text: lock.authenticating ? "EXECUTING" : "EXECUTE"
                    color: executeButtonArea.containsMouse ? Colors.onAccent : Colors.mPrimary
                    font.family: "DejaVu Sans Mono"
                    font.pointSize: Style.fontSizeMedium
                    font.weight: Font.Bold
                  }

                  MouseArea {
                    id: executeButtonArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: lock.unlockAttempt()

                    SequentialAnimation on scale {
                      running: containsMouse
                      NumberAnimation {
                        to: 1.05
                        duration: 150
                        easing.type: Easing.OutCubic
                      }
                    }

                    SequentialAnimation on scale {
                      running: !containsMouse
                      NumberAnimation {
                        to: 1.0
                        duration: 150
                        easing.type: Easing.OutCubic
                      }
                    }
                  }

                  // Processing animation
                  SequentialAnimation on scale {
                    loops: Animation.Infinite
                    running: lock.authenticating
                    NumberAnimation {
                      to: 1.02
                      duration: 600
                      easing.type: Easing.InOutQuad
                    }
                    NumberAnimation {
                      to: 1.0
                      duration: 600
                      easing.type: Easing.InOutQuad
                    }
                  }
                }
              }

              // Terminal glow effect
              Rectangle {
                anchors.fill: parent
                radius: parent.radius
                color: "transparent"
                border.color: Colors.applyOpacity(Colors.mPrimary, "4D")
                border.width: 1
                z: -1

                SequentialAnimation on opacity {
                  loops: Animation.Infinite
                  NumberAnimation {
                    to: 0.6
                    duration: 2000
                    easing.type: Easing.InOutQuad
                  }
                  NumberAnimation {
                    to: 0.2
                    duration: 2000
                    easing.type: Easing.InOutQuad
                  }
                }
              }
            }
          }
        }
      }
    }

    // Enhanced power buttons with hover effects
    Row {
      anchors.right: parent.right
      anchors.bottom: parent.bottom
      anchors.margins: 50 * scaling
      spacing: 20 * scaling

      // Shutdown with enhanced styling
      Rectangle {
        width: 64 * scaling
        height: 64 * scaling
        radius: 32
        color: Qt.rgba(Colors.mError.r, Colors.mError.g, Colors.mError.b, shutdownArea.containsMouse ? 0.9 : 0.2)
        border.color: Colors.mError
        border.width: 2 * scaling

        // Glow effect
        Rectangle {
          anchors.centerIn: parent
          width: parent.width + 10 * scaling
          height: parent.height + 10 * scaling
          radius: width * 0.5
          color: "transparent"
          border.color: Qt.rgba(Colors.mError.r, Colors.mError.g, Colors.mError.b, 0.3)
          border.width: 2 * scaling
          opacity: shutdownArea.containsMouse ? 1 : 0
          z: -1

          Behavior on opacity {
            NumberAnimation {
              duration: 200
              easing.type: Easing.OutCubic
            }
          }
        }

        MouseArea {
          id: shutdownArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            Qt.createQmlObject('import Quickshell.Io; Process { command: ["shutdown", "-h", "now"]; running: true }',
                               lock)
          }
        }

        Text {
          anchors.centerIn: parent
          text: "power_settings_new"
          font.family: "Material Symbols Outlined"
          font.pixelSize: 28 * scaling
          color: shutdownArea.containsMouse ? Colors.onAccent : Colors.mError
        }

        Behavior on color {
          ColorAnimation {
            duration: 200
            easing.type: Easing.OutCubic
          }
        }
        scale: shutdownArea.containsMouse ? 1.1 : 1.0
      }

      // Reboot with enhanced styling
      Rectangle {
        width: 64 * scaling
        height: 64 * scaling
        radius: 32
        color: Qt.rgba(Colors.mPrimary.r, Colors.mPrimary.g, Colors.mPrimary.b, rebootArea.containsMouse ? 0.9 : 0.2)
        border.color: Colors.mPrimary
        border.width: 2 * scaling

        // Glow effect
        Rectangle {
          anchors.centerIn: parent
          width: parent.width + 10 * scaling
          height: parent.height + 10 * scaling
          radius: width * 0.5
          color: "transparent"
          border.color: Qt.rgba(Colors.mPrimary.r, Colors.mPrimary.g, Colors.mPrimary.b, 0.3)
          border.width: 2 * scaling
          opacity: rebootArea.containsMouse ? 1 : 0
          z: -1

          Behavior on opacity {
            NumberAnimation {
              duration: 200
              easing.type: Easing.OutCubic
            }
          }
        }

        MouseArea {
          id: rebootArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            Qt.createQmlObject('import Quickshell.Io; Process { command: ["reboot"]; running: true }', lock)
          }
        }

        Text {
          anchors.centerIn: parent
          text: "refresh"
          font.family: "Material Symbols Outlined"
          font.pixelSize: 28 * scaling
          color: rebootArea.containsMouse ? Colors.onAccent : Colors.mPrimary
        }

        Behavior on color {
          ColorAnimation {
            duration: 200
            easing.type: Easing.OutCubic
          }
        }
        scale: rebootArea.containsMouse ? 1.1 : 1.0
      }

      // Logout with enhanced styling
      Rectangle {
        width: 64 * scaling
        height: 64 * scaling
        radius: 32
        color: Qt.rgba(Colors.mSecondary.r, Colors.mSecondary.g, Colors.mSecondary.b,
                       logoutArea.containsMouse ? 0.9 : 0.2)
        border.color: Colors.mSecondary
        border.width: 2 * scaling

        // Glow effect
        Rectangle {
          anchors.centerIn: parent
          width: parent.width + 10 * scaling
          height: parent.height + 10 * scaling
          radius: width * 0.5
          color: "transparent"
          border.color: Qt.rgba(Colors.mSecondary.r, Colors.mSecondary.g, Colors.mSecondary.b, 0.3)
          border.width: 2 * scaling
          opacity: logoutArea.containsMouse ? 1 : 0
          z: -1

          Behavior on opacity {
            NumberAnimation {
              duration: 200
              easing.type: Easing.OutCubic
            }
          }
        }

        MouseArea {
          id: logoutArea
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            Qt.createQmlObject(
                  'import Quickshell.Io; Process { command: ["loginctl", "terminate-user", "' + Quickshell.env(
                    "USER") + '"]; running: true }', lock)
          }
        }

        Text {
          anchors.centerIn: parent
          text: "exit_to_app"
          font.family: "Material Symbols Outlined"
          font.pixelSize: 28 * scaling
          color: logoutArea.containsMouse ? Colors.onAccent : Colors.mSecondary
        }

        Behavior on color {
          ColorAnimation {
            duration: 200
            easing.type: Easing.OutCubic
          }
        }
        scale: logoutArea.containsMouse ? 1.1 : 1.0
      }
    }

    // Timer for updating time
    Timer {
      interval: 1000
      running: true
      repeat: true
      onTriggered: {
        timeText.text = Qt.formatDateTime(new Date(), "HH:mm")
        dateText.text = Qt.formatDateTime(new Date(), "dddd, MMMM d")
      }
    }
  }
}
