import QtQuick
import QtQuick.Layouts

Item {
    id: drawer

    implicitWidth: row.width
    implicitHeight: 35

    // Expose FocusTimeButton so Bar.qml can alias it to shell.qml
    property alias focusTimeButtonComponent: focusTimeButtonComponent

    RowLayout {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4

        DiscordButton {}
        FocusTimeButton { id: focusTimeButtonComponent }
        NotionButton {}
        NordVPNButton {}
    }
}
