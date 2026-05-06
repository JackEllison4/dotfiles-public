import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: nordvpnButton

    implicitWidth: row.width
    implicitHeight: 32

    property bool isConnected: false

    // Check VPN status
    Process {
        id: statusCheck
        command: ["nordvpn", "status"]
        running: false

        property string buffer: ""

        stdout: SplitParser {
            onRead: data => {
                statusCheck.buffer += data
            }
        }

        onRunningChanged: {
            if (!running && statusCheck.buffer !== "") {
                const output = statusCheck.buffer.toLowerCase()
                // "disconnected" contains "connected" as a substring — check specifically
                nordvpnButton.isConnected = output.includes("status: connected") && !output.includes("status: disconnected")
                statusCheck.buffer = ""
            } else if (running) {
                statusCheck.buffer = ""
            }
        }
    }

    // Signal based status updates - more efficient than polling
    Process {
        id: signalWatcher
        running: true
        command: ["gdbus", "monitor", "--system", "--dest", "org.freedesktop.NetworkManager", "--object-path", "/org/freedesktop/NetworkManager"]
        stdout: SplitParser {
            onRead: {
                statusCheck.running = true;
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            Quickshell.execDetached(["kitty", "--title", "NordVPN", "-e", "nordvpn-tui"])
        }

        Rectangle {
            anchors.fill: parent
            radius: 6
            color: parent.containsMouse
                ? Qt.rgba(ThemeManager.fgPrimary.r, ThemeManager.fgPrimary.g, ThemeManager.fgPrimary.b, 0.1)
                : "transparent"
            Behavior on color { ColorAnimation { duration: 150 } }
        }

        RowLayout {
            id: row
            anchors.centerIn: parent
            spacing: 5

            Text {
                text: "\ued25"
                font.family: "Symbols Nerd Font"
                font.pixelSize: 16
                color: nordvpnButton.isConnected ? ThemeManager.accentGreen : ThemeManager.fgTertiary
                Behavior on color { ColorAnimation { duration: 200 } }
            }

            Text {
                text: nordvpnButton.isConnected ? "Connected" : "Disconnected"
                font.family: "Sen"
                font.pixelSize: 11
                font.weight: Font.Medium
                color: nordvpnButton.isConnected ? ThemeManager.accentGreen : ThemeManager.fgTertiary
                Behavior on color { ColorAnimation { duration: 200 } }
            }
        }
    }
}
