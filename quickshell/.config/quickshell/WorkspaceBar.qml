import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

RowLayout {
    id: workspaceBar
    spacing: 4

    property var workspaceData: []

    // Polling timer for hyprctl
    Timer {
        interval: 500
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: hyprctlPoller.running = true
    }

    // Robust hyprctl process with buffering
    Process {
        id: hyprctlPoller
        command: ["hyprctl", "workspaces", "-j"]
        running: false
        
        property string buffer: ""
        
        stdout: SplitParser {
            onRead: data => {
                hyprctlPoller.buffer += data
            }
        }
        
        onRunningChanged: {
            if (!running && buffer !== "") {
                try {
                    const parsed = JSON.parse(buffer)
                    if (Array.isArray(parsed)) {
                        workspaceBar.workspaceData = parsed
                    }
                } catch (e) {
                    console.log("🎨 Workspace Poll Error:", e)
                }
                buffer = ""
            }
        }
    }

    // Always show workspaces 1-10
    Repeater {
        model: 10

        MouseArea {
            id: staticWorkspaceButton

            property int workspaceId: index + 1
            
            // Search in polled data
            property var hyprData: {
                for (let i = 0; i < workspaceBar.workspaceData.length; i++) {
                    if (workspaceBar.workspaceData[i].id == workspaceId) {
                        return workspaceBar.workspaceData[i]
                    }
                }
                return null
            }

            property bool hasWindows: hyprData ? (hyprData.windows > 0) : false

            property bool isCurrentWorkspace: {
                // Keep Hyprland service for active workspace if it works
                const monitor = Hyprland.focusedMonitor
                if (monitor && monitor.activeWorkspace && monitor.activeWorkspace.id == workspaceId) return true
                return false
            }

            width: 40
            height: 32

            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            enabled: true
            z: 10

            Rectangle {
                id: workspaceRect
                anchors.centerIn: parent
                width: 35
                height: parent.height - 10
                radius: 6

                color: {
                    if (staticWorkspaceButton.isCurrentWorkspace) return Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.30)
                    if (staticWorkspaceButton.hasWindows) return Qt.rgba(ThemeManager.accentTeal.r, ThemeManager.accentTeal.g, ThemeManager.accentTeal.b, 0.20)
                    if (staticWorkspaceButton.containsMouse) return Qt.rgba(1, 1, 1, 0.10)
                    return "transparent"
                }
                border.width: {
                    if (staticWorkspaceButton.isCurrentWorkspace || staticWorkspaceButton.containsMouse) return 1
                    if (staticWorkspaceButton.hasWindows) return 1
                    return 0
                }
                border.color: {
                    if (staticWorkspaceButton.isCurrentWorkspace) return Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.55)
                    if (staticWorkspaceButton.hasWindows) return Qt.rgba(ThemeManager.accentTeal.r, ThemeManager.accentTeal.g, ThemeManager.accentTeal.b, 0.55)
                    return Qt.rgba(1, 1, 1, 0.18)
                }

                Behavior on color {
                    ColorAnimation { duration: 150 }
                }
                Behavior on border.width {
                    NumberAnimation { duration: 150 }
                }
            }

            Text {
                id: workspaceText
                anchors.centerIn: workspaceRect
                text: staticWorkspaceButton.workspaceId.toString()
                font.family: "Sen"
                font.pixelSize: 13
                font.bold: staticWorkspaceButton.isCurrentWorkspace
                textFormat: Text.PlainText

                color: {
                    if (staticWorkspaceButton.hyprData && staticWorkspaceButton.hyprData.urgent) return ThemeManager.accentRed
                    if (staticWorkspaceButton.isCurrentWorkspace) return ThemeManager.fgPrimary
                    if (staticWorkspaceButton.hasWindows) return ThemeManager.fgPrimary
                    return ThemeManager.fgTertiary
                }

                Behavior on color {
                    ColorAnimation { duration: 200 }
                }
            }

            onClicked: {
                console.log("Workspace", staticWorkspaceButton.workspaceId, "clicked")
                Quickshell.execDetached(["hyprctl", "dispatch", "workspace", staticWorkspaceButton.workspaceId.toString()])
            }
        }
    }

    // Show workspaces 11+ only when in use
    Repeater {
        model: workspaceBar.workspaceData

        MouseArea {
            id: dynamicWorkspaceButton

            required property var modelData

            property bool isCurrentWorkspace: {
                const monitor = Hyprland.focusedMonitor
                if (monitor && monitor.activeWorkspace && monitor.activeWorkspace.id == modelData.id) return true
                return false
            }

            // Only show for ID >= 11 (static ones handled above)
            visible: modelData.id >= 11

            width: visible ? 40 : 0
            height: 32
            opacity: visible ? 1.0 : 0.0

            Behavior on width {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }
            Behavior on opacity {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }

            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            enabled: true
            z: 10

            Rectangle {
                id: dynamicWorkspaceRect
                anchors.centerIn: parent
                width: 35
                height: parent.height - 10
                radius: 6

                color: {
                    if (dynamicWorkspaceButton.isCurrentWorkspace) return Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.30)
                    if (dynamicWorkspaceButton.modelData.windows > 0) return Qt.rgba(ThemeManager.accentTeal.r, ThemeManager.accentTeal.g, ThemeManager.accentTeal.b, 0.20)
                    if (dynamicWorkspaceButton.containsMouse) return Qt.rgba(1, 1, 1, 0.10)
                    return "transparent"
                }
                border.width: {
                    if (dynamicWorkspaceButton.isCurrentWorkspace || dynamicWorkspaceButton.containsMouse) return 1
                    if (dynamicWorkspaceButton.modelData.windows > 0) return 1
                    return 0
                }
                border.color: {
                    if (dynamicWorkspaceButton.isCurrentWorkspace) return Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.55)
                    if (dynamicWorkspaceButton.modelData.windows > 0) return Qt.rgba(ThemeManager.accentTeal.r, ThemeManager.accentTeal.g, ThemeManager.accentTeal.b, 0.55)
                    return Qt.rgba(1, 1, 1, 0.18)
                }

                Behavior on color {
                    ColorAnimation { duration: 150 }
                }
                Behavior on border.width {
                    NumberAnimation { duration: 150 }
                }
            }

            Text {
                id: dynamicWorkspaceText
                anchors.centerIn: dynamicWorkspaceRect
                text: dynamicWorkspaceButton.modelData.id.toString()
                font.family: "Sen"
                font.pixelSize: 13
                font.bold: dynamicWorkspaceButton.isCurrentWorkspace
                textFormat: Text.PlainText

                color: {
                    if (dynamicWorkspaceButton.modelData.urgent) return ThemeManager.accentRed
                    if (dynamicWorkspaceButton.isCurrentWorkspace) return ThemeManager.fgPrimary
                    if (dynamicWorkspaceButton.modelData.windows > 0) return ThemeManager.fgPrimary
                    return ThemeManager.fgTertiary
                }

                Behavior on color {
                    ColorAnimation { duration: 200 }
                }
            }

            onClicked: {
                console.log("Workspace", dynamicWorkspaceButton.modelData.id, "clicked")
                Quickshell.execDetached(["hyprctl", "dispatch", "workspace", dynamicWorkspaceButton.modelData.id.toString()])
            }
        }
    }
}
