import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Services
import qs.Widgets

// Utilities: record & wallpaper
NBox {
  Layout.fillWidth: true
  Layout.preferredWidth: 1
  implicitHeight: utilRow.implicitHeight + Style.marginMedium * 2 * scaling
  RowLayout {
    id: utilRow
    anchors.fill: parent
    anchors.margins: Style.marginSmall * scaling
    spacing: sidePanel.cardSpacing
    Item {
      Layout.fillWidth: true
    }
    // Screen Recorder
    NIconButton {
      icon: "videocam"
      showFilled: ScreenRecorder.isRecording
      onClicked: {
        ScreenRecorder.toggleRecording()
      }
    }

    // Wallpaper
    NIconButton {
      icon: "image"
      onClicked: {
        settingsPanel.requestedTab = settingsPanel.tabsIds.WALLPAPER_SELECTOR
        settingsPanel.isLoaded = true
      }
    }

    Item {
      Layout.fillWidth: true
    }
  }
}
