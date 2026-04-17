import QtQuick
import QtQuick.Layouts

Item {
    id: drawer

    implicitWidth: buttonBubble.width
    implicitHeight: 35

    // Container for the drawer content
    Rectangle {
        anchors.fill: parent
        color: "transparent"

        // Bubble container for all quick access buttons
        Rectangle {
            id: buttonBubble
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: row.width + 12
            height: 35
            radius: 12
            color: Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.15)
            border.width: 1
            border.color: Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.35)

            RowLayout {
                id: row
                anchors.left: parent.left
                anchors.leftMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                DiscordButton {}
                NotionButton {}
            }
        }
    }
}
