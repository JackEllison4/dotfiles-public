import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

RowLayout {
    id: workspaceBar

    property var workspaceData: []

    spacing: 6

    // Signal based workspace updates - much more efficient and instant
    Process {
        id: eventWatcher
        running: true
        command: ["sh", "-c", "socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | grep --line-buffered -E 'workspace|window'"]
        stdout: SplitParser {
            onRead: {
                hyprctlPoller.running = true;
            }
        }
    }

    Component.onCompleted: {
        hyprctlPoller.running = true;
    }

    Process {
        id: hyprctlPoller

        property string buffer: ""

        command: ["hyprctl", "workspaces", "-j"]
        running: false
        onRunningChanged: {
            if (!running && buffer !== "") {
                try {
                    const parsed = JSON.parse(buffer);
                    if (Array.isArray(parsed))
                        workspaceBar.workspaceData = parsed;

                } catch (e) {
                    console.log("🎨 Workspace Poll Error:", e);
                }
                buffer = "";
            }
        }

        stdout: SplitParser {
            onRead: (data) => {
                hyprctlPoller.buffer += data;
            }
        }

    }

    Repeater {
        model: 10

        MouseArea {
            id: staticWorkspaceButton

            property int workspaceId: index + 1
            property var hyprData: {
                for (let i = 0; i < workspaceBar.workspaceData.length; i++) {
                    if (workspaceBar.workspaceData[i].id == workspaceId)
                        return workspaceBar.workspaceData[i];

                }
                return null;
            }
            property bool hasWindows: hyprData ? (hyprData.windows > 0) : false
            property bool isCurrentWorkspace: {
                const monitor = Hyprland.focusedMonitor;
                return (monitor && monitor.activeWorkspace && monitor.activeWorkspace.id == workspaceId);
            }

            width: 36
            height: 32
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: Quickshell.execDetached(["hyprctl", "dispatch", "workspace", workspaceId.toString()])

            Rectangle {
                id: workspaceRect

                anchors.centerIn: parent
                width: 30
                height: 22
                radius: 4
                // Pure neutral white palette - no dark tints
                color: {
                    if (staticWorkspaceButton.isCurrentWorkspace)
                        return Qt.rgba(1, 1, 1, 0.45);

                    if (staticWorkspaceButton.containsMouse)
                        return Qt.rgba(1, 1, 1, 0.25);

                    if (staticWorkspaceButton.hasWindows)
                        return Qt.rgba(1, 1, 1, 0.15);

                    return "transparent";
                }
                border.width: staticWorkspaceButton.isCurrentWorkspace ? 1 : 0
                border.color: Qt.rgba(1, 1, 1, 0.5)
            }

            Text {
                anchors.centerIn: parent
                text: staticWorkspaceButton.workspaceId.toString()
                font.family: "Sen"
                font.pixelSize: 12
                font.bold: staticWorkspaceButton.isCurrentWorkspace
                color: {
                    if (staticWorkspaceButton.hyprData && staticWorkspaceButton.hyprData.urgent)
                        return "#ff5555";

                    if (staticWorkspaceButton.isCurrentWorkspace)
                        return "#ffffff";

                    return staticWorkspaceButton.hasWindows ? "#ffffff" : Qt.rgba(1, 1, 1, 0.35);
                }
            }

        }

    }

    // Dynamic Workspaces 11+
    Repeater {
        model: workspaceBar.workspaceData

        MouseArea {
            id: dynamicWorkspaceButton

            required property var modelData
            property bool isCurrentWorkspace: {
                const monitor = Hyprland.focusedMonitor;
                return (monitor && monitor.activeWorkspace && monitor.activeWorkspace.id == modelData.id);
            }

            visible: modelData.id >= 11
            width: visible ? 36 : 0
            height: 32
            opacity: visible ? 1 : 0
            onClicked: Quickshell.execDetached(["hyprctl", "dispatch", "workspace", modelData.id.toString()])

            Rectangle {
                anchors.centerIn: parent
                width: 30
                height: 22
                radius: 4
                color: dynamicWorkspaceButton.isCurrentWorkspace ? Qt.rgba(1, 1, 1, 0.45) : Qt.rgba(1, 1, 1, 0.15)
                border.width: dynamicWorkspaceButton.isCurrentWorkspace ? 1 : 0
                border.color: Qt.rgba(1, 1, 1, 0.5)
            }

            Text {
                anchors.centerIn: parent
                text: dynamicWorkspaceButton.modelData.id.toString()
                font.family: "Sen"
                font.pixelSize: 12
                font.bold: dynamicWorkspaceButton.isCurrentWorkspace
                color: "#ffffff"
            }

            Behavior on width {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }

            }

        }

    }

}
