import QtQuick
import QtQuick.Controls
import qs.Services

Item {
  id: root

  readonly property real scaling: Scaling.scale(screen)

  property string icon: ""
  property string text: ""
  property string tooltipText: ""
  property color pillColor: Colors.colorSurfaceVariant
  property color textColor: Colors.colorOnSurface
  property color iconCircleColor: Colors.colorPrimary
  property color iconTextColor: Colors.colorSurface
  property color collapsedIconColor: Colors.colorOnSurface
  property real sizeMultiplier: 0.8
  property bool autoHide: false

  signal shown
  signal hidden
  signal entered
  signal exited
  signal clicked
  signal wheel(int delta)

  // Internal state
  property bool showPill: false
  property bool shouldAnimateHide: false

  // Exposed width logic
  readonly property int pillHeight: Style.baseWidgetSize * sizeMultiplier * scaling
  readonly property int iconSize: Style.baseWidgetSize * sizeMultiplier * scaling
  readonly property int pillPaddingHorizontal: Style.marginMedium * scaling
  readonly property int pillOverlap: iconSize * 0.5
  readonly property int maxPillWidth: Math.max(1, textItem.implicitWidth + pillPaddingHorizontal * 2 + pillOverlap)

  width: iconSize + (showPill ? maxPillWidth - pillOverlap : 0)
  height: pillHeight

  Rectangle {
    id: pill
    width: showPill ? maxPillWidth : 1
    height: pillHeight
    x: (iconCircle.x + iconCircle.width / 2) - width
    opacity: showPill ? Style.opacityFull : Style.opacityNone
    color: pillColor
    topLeftRadius: pillHeight * 0.5
    bottomLeftRadius: pillHeight * 0.5
    anchors.verticalCenter: parent.verticalCenter

    NText {
      id: textItem
      anchors.centerIn: parent
      text: root.text
      font.pointSize: Style.fontSizeSmall * scaling
      font.weight: Style.fontWeightBold
      color: textColor
      visible: showPill
    }

    Behavior on width {
      enabled: showAnim.running || hideAnim.running
      NumberAnimation {
        duration: Style.animationNormal
        easing.type: Easing.OutCubic
      }
    }
    Behavior on opacity {
      enabled: showAnim.running || hideAnim.running
      NumberAnimation {
        duration: Style.animationNormal
        easing.type: Easing.OutCubic
      }
    }
  }

  Rectangle {
    id: iconCircle
    width: iconSize
    height: iconSize
    radius: width * 0.5
    color: showPill ? iconCircleColor : "transparent"
    anchors.verticalCenter: parent.verticalCenter
    anchors.right: parent.right

    Behavior on color {
      ColorAnimation {
        duration: Style.animationNormal
        easing.type: Easing.InOutQuad
      }
    }

    Text {
      anchors.centerIn: parent
      font.family: showPill ? "Material Symbols Rounded" : "Material Symbols Outlined"
      font.pointSize: Style.fontSizeMedium * scaling
      text: root.icon
      color: showPill ? iconTextColor : collapsedIconColor
    }
  }

  ParallelAnimation {
    id: showAnim
    running: false
    NumberAnimation {
      target: pill
      property: "width"
      from: 1
      to: maxPillWidth
      duration: Style.animationNormal
      easing.type: Easing.OutCubic
    }
    NumberAnimation {
      target: pill
      property: "opacity"
      from: 0
      to: 1
      duration: Style.animationNormal
      easing.type: Easing.OutCubic
    }
    onStarted: {
      showPill = true
    }
    onStopped: {
      delayedHideAnim.start()
      root.shown()
    }
  }

  SequentialAnimation {
    id: delayedHideAnim
    running: false
    PauseAnimation {
      duration: 2500
    }
    ScriptAction {
      script: if (shouldAnimateHide) {
                hideAnim.start()
              }
    }
  }

  ParallelAnimation {
    id: hideAnim
    running: false
    NumberAnimation {
      target: pill
      property: "width"
      from: maxPillWidth
      to: 1
      duration: Style.animationNormal
      easing.type: Easing.InCubic
    }
    NumberAnimation {
      target: pill
      property: "opacity"
      from: 1
      to: 0
      duration: Style.animationNormal
      easing.type: Easing.InCubic
    }
    onStopped: {
      showPill = false
      shouldAnimateHide = false
      root.hidden()
    }
  }

  NTooltip {
    id: tooltip
    positionAbove: false
    target: pill
    delay: Style.tooltipDelayLong
    text: root.tooltipText
  }

  Timer {
    id: showTimer
    interval: Style.pillDelay
    onTriggered: {
      if (!showPill) {
        showAnim.start()
      }
    }
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    onEntered: {
      showDelayed()
      tooltip.show()
      root.entered()
    }
    onExited: {
      hide()
      tooltip.hide()
      root.exited()
    }
    onClicked: {
      root.clicked()
    }
    onWheel: wheel => {
               root.wheel(wheel.angleDelta.y)
             }
  }

  function show() {
    if (!showPill) {
      shouldAnimateHide = autoHide
      showAnim.start()
    } else {
      hideAnim.stop()
      delayedHideAnim.restart()
    }
  }

  function hide() {
    if (showPill) {
      hideAnim.start()
    }
    showTimer.stop()
  }

  function showDelayed() {
    if (!showPill) {
      shouldAnimateHide = autoHide
      showTimer.start()
    } else {
      hideAnim.stop()
      delayedHideAnim.restart()
    }
  }
}
