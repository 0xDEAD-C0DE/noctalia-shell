import QtQuick
import QtQuick.Controls
import qs.Commons
import qs.Services
import qs.Widgets

RadioButton {
  id: root

  indicator: Rectangle {
    id: outerCircle

    implicitWidth: Style.baseWidgetSize * 0.625 * scaling
    implicitHeight: Style.baseWidgetSize * 0.625 * scaling
    radius: width * 0.5
    color: "transparent"
    border.color: root.checked ? Colors.mPrimary : Colors.mOnSurface
    border.width: Math.max(1, Style.borderMedium * scaling)
    anchors.verticalCenter: parent.verticalCenter

    Rectangle {
      anchors.centerIn: parent
      implicitWidth: Style.marginSmall * scaling
      implicitHeight: Style.marginSmall * scaling

      radius: width * 0.5
      color: Qt.alpha(Colors.mPrimary, root.checked ? 1 : 0)
    }

    Behavior on border.color {
      ColorAnimation {
        duration: Style.animationNormal
        easing.type: Easing.InQuad
      }
    }
  }

  contentItem: NText {
    text: root.text
    font.pointSize: Style.fontSizeMedium * scaling
    anchors.verticalCenter: parent.verticalCenter
    anchors.left: outerCircle.right
    anchors.leftMargin: Style.marginSmall * scaling
  }
}
