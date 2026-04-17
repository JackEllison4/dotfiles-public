import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: trayDrawer

    signal toggleClipboard()
    signal toggleControlCenter()

    height: 35
    width: trayItem.width + 12

    // System Tray bubble
    Rectangle {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: trayItem.width + 12
        height: 35
        radius: 12
        color: Qt.rgba(ThemeManager.accentPurple.r, ThemeManager.accentPurple.g, ThemeManager.accentPurple.b, 0.15)
        border.width: 1
        border.color: Qt.rgba(ThemeManager.accentPurple.r, ThemeManager.accentPurple.g, ThemeManager.accentPurple.b, 0.35)

        Item {
            id: trayItem
            anchors.centerIn: parent
            width: trayContent.width
            height: 35

            SystemTray {
                id: trayContent
                anchors.verticalCenter: parent.verticalCenter
                onToggleControlCenter: trayDrawer.toggleControlCenter()
            }
        }
    }
}

