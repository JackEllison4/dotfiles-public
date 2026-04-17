import QtQuick
import Quickshell
import Quickshell.Io

Rectangle {
    id: ramIndicator

    width: ramText.width + 45
    height: parent.height - 10

    color: mouseArea.containsMouse ? Qt.rgba(1, 1, 1, 0.10) : "transparent"
    radius: 6
    border.width: mouseArea.containsMouse ? 1 : 0
    border.color: Qt.rgba(1, 1, 1, 0.18)

    property real ramUsagePercent: 0
    property string ramUsageText: "0%"

    Behavior on color {
        ColorAnimation { duration: 200 }
    }

    Row {
        anchors.centerIn: parent
        spacing: 8
        anchors.verticalCenterOffset: 2

        Text {
            text: ""
            font.family: "Iosevka Nerd Font"
            font.pixelSize: 14
            color: ThemeManager.fgPrimary
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            id: ramText
            text: ramIndicator.ramUsageText
            font.family: "JetBrains Mono"
            font.pixelSize: 13
            color: ThemeManager.fgPrimary
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
    }

    // Update RAM usage every second
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: updateRamUsage()
    }

    function updateRamUsage() {
        ramPoller.running = true
    }

    Process {
        id: ramPoller
        running: false
        command: [
            "bash",
            "-c",
            "cat /proc/meminfo | awk '/MemTotal:/ {total=$2} /MemAvailable:/ {avail=$2} END {used=total-avail; percent=int((used/total)*100); print sprintf(\"%.1f / %.1f GB (\" percent \"%%)\", used/1024/1024, total/1024/1024)}'"
        ]

        stdout: SplitParser {
            onRead: data => {
                ramIndicator.ramUsageText = data.trim()
            }
        }
    }
}
