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

    property var notifications: []
    property bool dndEnabled: false

    // Read notifications from file
    Process {
        id: notificationsReader
        command: ["cat", Quickshell.env("HOME") + "/.cache/notifications.json"]
        running: false

        property string buffer: ""

        stdout: SplitParser {
            onRead: data => {
                notificationsReader.buffer += data
            }
        }

        onRunningChanged: {
            if (!running && notificationsReader.buffer !== "") {
                try {
                    let parsed = JSON.parse(notificationsReader.buffer)
                    if (Array.isArray(parsed)) {
                        notificationPanel.notifications = parsed.reverse()
                    }
                } catch (e) {
                    notificationPanel.notifications = []
                }
                notificationsReader.buffer = ""
            }
        }
    }

    // Signal based updates - instant and efficient
    Process {
        id: notificationSignalWatcher
        running: true
        command: ["gdbus", "monitor", "--session", "--dest", "org.freedesktop.Notifications", "--object-path", "/org/freedesktop/Notifications"]
        stdout: SplitParser {
            onRead: {
                // Delay slightly to allow the notification daemon to write to the cache file
                Qt.callLater(() => {
                    notificationsReader.running = true;
                });
            }
        }
    }

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
            }
        }
    }

    // DND Signal watcher - efficient and instant
    Process {
        id: dndSignalWatcher
        running: true
        // swaync uses this object path for DND state
        command: ["gdbus", "monitor", "--session", "--dest", "org.ericson.SwayNotificationCenter", "--object-path", "/org/ericson/SwayNotificationCenter"]
        stdout: SplitParser {
            onRead: {
                swayncDndQuery.running = true;
            }
        }
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

            Item { Layout.fillWidth: true }

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
                            // Clear notifications file
                            Quickshell.execDetached(["sh", "-c", "echo '[]' > ~/.cache/notifications.json"])
                            notificationPanel.notifications = []
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

            Flickable {
                anchors.fill: parent
                anchors.margins: 12
                contentWidth: width
                contentHeight: notificationsColumn.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                Column {
                    id: notificationsColumn
                    width: parent.width
                    spacing: 8

                    Repeater {
                        model: notificationPanel.notifications.length

                        delegate: Rectangle {
                            width: parent.width
                            height: contentCol.implicitHeight + 16
                            radius: 8
                            color: Qt.rgba(1, 1, 1, 0.1)
                            border.width: 1
                            border.color: Qt.rgba(1, 1, 1, 0.15)

                            property var notification: notificationPanel.notifications[index]

                            ColumnLayout {
                                id: contentCol
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 6

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 8

                                    Text {
                                        text: notification.app_name || "Notification"
                                        font.family: "Sen"
                                        font.pixelSize: 13
                                        font.weight: Font.Bold
                                        color: ThemeManager.fgPrimary
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        text: {
                                            const time = new Date(notification.time * 1000)
                                            const now = new Date()
                                            const diff = Math.floor((now - time) / 1000)
                                            if (diff < 60) return "now"
                                            if (diff < 3600) return Math.floor(diff / 60) + "m"
                                            if (diff < 86400) return Math.floor(diff / 3600) + "h"
                                            return time.toLocaleDateString()
                                        }
                                        font.family: "Sen"
                                        font.pixelSize: 11
                                        color: ThemeManager.fgTertiary
                                    }
                                }

                                Text {
                                    text: notification.summary || ""
                                    font.family: "Sen"
                                    font.pixelSize: 12
                                    color: ThemeManager.fgPrimary
                                    Layout.fillWidth: true
                                    wrapMode: Text.Wrap
                                    visible: notification.summary
                                    font.weight: Font.Bold
                                }

                                Text {
                                    text: notification.body || ""
                                    font.family: "Sen"
                                    font.pixelSize: 11
                                    color: ThemeManager.fgTertiary
                                    Layout.fillWidth: true
                                    wrapMode: Text.Wrap
                                    visible: notification.body
                                }
                            }
                        }
                    }
                }
            }

            Column {
                anchors.centerIn: parent
                spacing: 12
                visible: notificationPanel.notifications.length === 0

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
