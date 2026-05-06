import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: trayDrawer

    signal toggleClipboard()
    signal toggleControlCenter()

    height: 35
    width: trayContent.width

    SystemTray {
        id: trayContent
        anchors.verticalCenter: parent.verticalCenter
        onToggleControlCenter: trayDrawer.toggleControlCenter()
    }
}
