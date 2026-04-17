import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

Rectangle {
    id: notificationPanel
    
    color: Qt.rgba(ThemeManager.bgBase.r, ThemeManager.bgBase.g, ThemeManager.bgBase.b, 0.92)
    radius: 16
    border.width: 1
    border.color: Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.35)
    clip: true

    width: 500
    height: 400

    signal requestClose()

    property bool dndEnabled: false

    // Sync DND state with swaync
    Process {
        id: swayncDndQuery
        command: ["swaync-client", "-D"]
        running: false
        
        property string buffer: ""
        
        stdout: SplitParser {
            onRead: data => {
                swayncDndQuery.buffer += data
            }
        }
        
        onRunningChanged: {
            if (!running && buffer !== "") {
                notificationPanel.dndEnabled = (buffer.trim() === "true")
                buffer = ""
            } else if (running) {
                buffer = ""
            }
        }
    }
    
    // Periodically poll DND state to stay in sync
    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: swayncDndQuery.running = true
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        // Header
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            
            Text {
                text: "Notifications"
                font.family: "Sen"
                font.pixelSize: 20
                font.weight: Font.Bold
                color: ThemeManager.fgPrimary
                Layout.alignment: Qt.AlignVCenter
            }

            Item { Layout.fillWidth: true } // Spacer

            Row {
                Layout.alignment: Qt.AlignVCenter
                spacing: 12

                // DND Toggle
                Row {
                    spacing: 8
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        text: "󰂛"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 18
                        color: notificationPanel.dndEnabled ? ThemeManager.fgTertiary : ThemeManager.accentBlue
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Rectangle {
                        width: 44
                        height: 24
                        radius: 12
                        color: notificationPanel.dndEnabled ? ThemeManager.accentBlue : Qt.rgba(1, 1, 1, 0.07)
                        anchors.verticalCenter: parent.verticalCenter
                        
                        Rectangle {
                            width: 18
                            height: 18
                            radius: 9
                            color: ThemeManager.fgPrimary
                            x: notificationPanel.dndEnabled ? parent.width - width - 3 : 3
                            anchors.verticalCenter: parent.verticalCenter
                            Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                Quickshell.execDetached(["swaync-client", "-d"])
                                notificationPanel.dndEnabled = !notificationPanel.dndEnabled
                            }
                        }
                    }
                }

                // Clear All Button
                Rectangle {
                    width: 85
                    height: 32
                    radius: 8
                    color: clearMouseArea.containsMouse ? Qt.rgba(1, 1, 1, 0.16) : Qt.rgba(1, 1, 1, 0.07)
                    anchors.verticalCenter: parent.verticalCenter
                    
                    Text {
                        anchors.centerIn: parent
                        text: "Clear All"
                        font.family: "Sen"
                        font.pixelSize: 13
                        color: ThemeManager.fgSecondary
                    }
                    
                    MouseArea {
                        id: clearMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Quickshell.execDetached(["swaync-client", "-C"]) // Tells Swaync to clear notifications
                        }
                    }
                }
            }
        }

        // --- MEDIA PLAYER ---
        MediaPlayerPopupWidget {
            id: mediaPopup
            Layout.fillWidth: true
            Layout.preferredHeight: height
            visible: mediaPopup.hasMedia
        }

        // --- NOTIFICATIONS LIST ---
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Qt.rgba(1, 1, 1, 0.03)
            radius: 12
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.05)

            Column {
                anchors.centerIn: parent
                spacing: 12

                Text {
                    text: notificationPanel.dndEnabled ? "󰂛" : "󰂚"
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 48
                    color: notificationPanel.dndEnabled ? ThemeManager.accentBlue : Qt.rgba(ThemeManager.fgTertiary.r, ThemeManager.fgTertiary.g, ThemeManager.fgTertiary.b, 0.5)
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: notificationPanel.dndEnabled ? "Do Not Disturb is On" : "You're all caught up!"
                    font.family: "Sen"
                    font.pixelSize: 16
                    font.weight: Font.Bold
                    color: notificationPanel.dndEnabled ? ThemeManager.fgPrimary : ThemeManager.fgSecondary
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: notificationPanel.dndEnabled ? "Notifications are silenced." : "No new notifications right now."
                    font.family: "Sen"
                    font.pixelSize: 13
                    color: ThemeManager.fgTertiary
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }

        // Close button
        Rectangle {
            Layout.fillWidth: true
            height: 36
            radius: 8
            color: closeButtonMa.containsMouse ? ThemeManager.accent : Qt.rgba(1, 1, 1, 0.05)

            Text {
                anchors.centerIn: parent
                text: "Close"
                font.family: "JetBrains Mono"
                font.weight: Font.Bold
                font.pixelSize: 14
                color: closeButtonMa.containsMouse ? ThemeManager.bgPrimary : ThemeManager.fgPrimary
            }

            MouseArea {
                id: closeButtonMa
                anchors.fill: parent
                hoverEnabled: true
                onClicked: notificationPanel.requestClose()
            }
        }
    }
}
