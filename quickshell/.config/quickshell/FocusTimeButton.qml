import QtQuick
import Quickshell

MouseArea {
    id: focusTimeButton

    width: 32
    height: 32

    signal toggleFocusTime()

    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    z: 10

    Rectangle {
        anchors.fill: parent
        radius: 6
        color: focusTimeButton.containsMouse
            ? Qt.rgba(ThemeManager.fgPrimary.r, ThemeManager.fgPrimary.g, ThemeManager.fgPrimary.b, 0.1)
            : "transparent"
        Behavior on color { ColorAnimation { duration: 200 } }

        Text {
            anchors.centerIn: parent
            text: "\uf2f2"
            font.family: "Symbols Nerd Font"
            font.pixelSize: ThemeManager.fontSizeIcon
            color: ThemeManager.fgPrimary
        }
    }

    onClicked: {
        focusTimeButton.toggleFocusTime()
    }
}
