import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: clockArea

    width: 85
    height: 35

    signal toggleCalendar()

    property bool use24Hour: true
    property bool showSeconds: false
    property bool dateFormatDMY: true

    // Clock content column
    Column {
        id: clockContent
        anchors.centerIn: parent
        width: parent.width
        spacing: 0

        Text {
            id: timeText
            width: parent.width
            font.family: "JetBrains Mono"
            font.pixelSize: 13
            font.bold: true
            color: ThemeManager.fgPrimary
            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            id: dateText
            width: parent.width
            font.family: "JetBrains Mono"
            font.pixelSize: 9
            color: ThemeManager.fgSecondary
            horizontalAlignment: Text.AlignHCenter
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            toggleCalendar()
            console.log("Calendar toggle signal emitted")
        }
    }

    Connections {
        target: shellRoot
        function onConfigVersionChanged() {
            settingsLoader.running = true;
        }
    }

    // Settings loader
    Process {
        id: settingsLoader
        running: false
        command: ["cat", Quickshell.env("HOME") + "/.config/quickshell/settings.json"]

        property string buffer: ""

        stdout: SplitParser {
            onRead: data => {
                settingsLoader.buffer += data
            }
        }

        onRunningChanged: {
            if (!running && buffer !== "") {
                try {
                    const settings = JSON.parse(buffer)
                    if (settings.general) {
                        // Force 24-hour and DMY format for this clock
                        clockArea.use24Hour = true
                        clockArea.dateFormatDMY = true
                        clockArea.showSeconds = false
                    }
                } catch (e) {
                    // Use defaults on error
                    clockArea.use24Hour = true
                    clockArea.dateFormatDMY = true
                }
                buffer = ""
            } else if (running) {
                buffer = ""
            }
        }
    }

    // Clock update timer - slowed down to 30s since seconds aren't shown
    Timer {
        interval: 30000
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            let now = new Date()
            let month = (now.getMonth() + 1).toString().padStart(2, '0')
            let day = now.getDate().toString().padStart(2, '0')
            let year = now.getFullYear()
            let hours = now.getHours()
            let minutes = now.getMinutes().toString().padStart(2, '0')

            // Format time (24-hour, no seconds)
            let timeStr = `${hours.toString().padStart(2, '0')}:${minutes}`

            // Format date (dd/mm/yyyy)
            let dateStr = `${day}/${month}/${year}`

            timeText.text = timeStr
            dateText.text = dateStr
        }
    }
}

