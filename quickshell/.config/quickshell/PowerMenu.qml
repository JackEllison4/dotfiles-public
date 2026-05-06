import QtQuick
import Quickshell
import Quickshell.Io

Rectangle {
    id: root

    property bool isVisible: false
    property int hoverIndex: -1
    property bool enableBlur: false

    signal requestClose()

    function executeAction(action) {
        console.log("Executing power action:", action);
        root.requestClose();
        executeTimer.pendingAction = action;
        executeTimer.start();
    }

    width: 586
    height: 120
    color: Qt.rgba(ThemeManager.bgBase.r, ThemeManager.bgBase.g, ThemeManager.bgBase.b, 0.92)
    radius: 16
    border.width: 1
    border.color: Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.35)
    antialiasing: true
    focus: true
    Keys.onEscapePressed: {
        root.requestClose();
    }
    onIsVisibleChanged: {
        if (isVisible) {
            hoverIndex = -1;
            root.forceActiveFocus();
            if (executeTimer.running) {
                executeTimer.stop();
                executeTimer.pendingAction = "";
            }
            blurSettingsLoader.running = true;
        }
    }

    // Load blur setting
    Process {
        id: blurSettingsLoader

        property string buffer: ""

        running: false
        command: ["cat", Quickshell.env("HOME") + "/.config/quickshell/settings.json"]
        onRunningChanged: {
            if (!running && buffer !== "") {
                try {
                    const settings = JSON.parse(buffer);
                    if (settings.general && settings.general.enableBlur !== undefined)
                        root.enableBlur = settings.general.enableBlur;

                } catch (e) {
                    console.error("Failed to parse power menu settings:", e);
                }
                buffer = "";
            } else if (running) {
                buffer = "";
            }
        }

        stdout: SplitParser {
            onRead: (data) => {
                blurSettingsLoader.buffer += data;
            }
        }

    }

    Row {
        anchors.centerIn: parent
        spacing: 16

        // Lock
        Rectangle {
            width: 70
            height: 70
            color: lockMouseArea.containsMouse ? Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.25) : "transparent"
            radius: 12
            border.width: lockMouseArea.containsMouse ? 1 : 0
            border.color: Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.5)

            Text {
                anchors.centerIn: parent
                text: "󰌾"
                font.family: "Symbols Nerd Font"
                font.pixelSize: 32
                color: ThemeManager.fgPrimary
            }

            MouseArea {
                id: lockMouseArea

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: executeAction("lock")
            }

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }

            }

            Behavior on border.width {
                NumberAnimation {
                    duration: 150
                }

            }

        }

        // Logout
        Rectangle {
            width: 70
            height: 70
            color: logoutMouseArea.containsMouse ? Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.25) : "transparent"
            radius: 12
            border.width: logoutMouseArea.containsMouse ? 1 : 0
            border.color: Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.5)

            Text {
                anchors.centerIn: parent
                text: "󰍃"
                font.family: "Symbols Nerd Font"
                font.pixelSize: 32
                color: ThemeManager.fgPrimary
            }

            MouseArea {
                id: logoutMouseArea

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: executeAction("logout")
            }

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }

            }

            Behavior on border.width {
                NumberAnimation {
                    duration: 150
                }

            }

        }

        // Suspend
        Rectangle {
            width: 70
            height: 70
            color: suspendMouseArea.containsMouse ? Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.25) : "transparent"
            radius: 12
            border.width: suspendMouseArea.containsMouse ? 1 : 0
            border.color: Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.5)

            Text {
                anchors.centerIn: parent
                text: "󰒲"
                font.family: "Symbols Nerd Font"
                font.pixelSize: 32
                color: ThemeManager.fgPrimary
            }

            MouseArea {
                id: suspendMouseArea

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: executeAction("suspend")
            }

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }

            }

            Behavior on border.width {
                NumberAnimation {
                    duration: 150
                }

            }

        }

        // Reboot
        Rectangle {
            width: 70
            height: 70
            color: rebootMouseArea.containsMouse ? Qt.rgba(ThemeManager.accentRed.r, ThemeManager.accentRed.g, ThemeManager.accentRed.b, 0.25) : "transparent"
            radius: 12
            border.width: rebootMouseArea.containsMouse ? 1 : 0
            border.color: Qt.rgba(ThemeManager.accentRed.r, ThemeManager.accentRed.g, ThemeManager.accentRed.b, 0.5)

            Text {
                anchors.centerIn: parent
                text: "󰜉"
                font.family: "Symbols Nerd Font"
                font.pixelSize: 32
                color: ThemeManager.fgPrimary
            }

            MouseArea {
                id: rebootMouseArea

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: executeAction("reboot")
            }

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }

            }

            Behavior on border.width {
                NumberAnimation {
                    duration: 150
                }

            }

        }

        // Shutdown
        Rectangle {
            width: 70
            height: 70
            color: shutdownMouseArea.containsMouse ? Qt.rgba(ThemeManager.accentRed.r, ThemeManager.accentRed.g, ThemeManager.accentRed.b, 0.25) : "transparent"
            radius: 12
            border.width: shutdownMouseArea.containsMouse ? 1 : 0
            border.color: Qt.rgba(ThemeManager.accentRed.r, ThemeManager.accentRed.g, ThemeManager.accentRed.b, 0.5)

            Text {
                anchors.centerIn: parent
                text: "󰐥"
                font.family: "Symbols Nerd Font"
                font.pixelSize: 32
                color: ThemeManager.fgPrimary
            }

            MouseArea {
                id: shutdownMouseArea

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: executeAction("shutdown")
            }

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }

            }

            Behavior on border.width {
                NumberAnimation {
                    duration: 150
                }

            }

        }

        // Cancel
        Rectangle {
            width: 70
            height: 70
            color: cancelMouseArea.containsMouse ? Qt.rgba(1, 1, 1, 0.1) : "transparent"
            radius: 12
            border.width: cancelMouseArea.containsMouse ? 1 : 0
            border.color: Qt.rgba(1, 1, 1, 0.18)

            Text {
                anchors.centerIn: parent
                text: "󰜺"
                font.family: "Symbols Nerd Font"
                font.pixelSize: 32
                color: ThemeManager.fgPrimary
            }

            MouseArea {
                id: cancelMouseArea

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.requestClose()
            }

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }

            }

            Behavior on border.width {
                NumberAnimation {
                    duration: 150
                }

            }

        }

    }

    Timer {
        id: executeTimer

        property string pendingAction: ""

        interval: 150
        onTriggered: {
            let command = [];
            if (pendingAction === "lock")
                command = ["hyprlock"];
            else if (pendingAction === "logout")
                command = ["hyprctl", "dispatch", "exit"];
            else if (pendingAction === "suspend")
                command = ["systemctl", "suspend"];
            else if (pendingAction === "reboot")
                command = ["systemctl", "reboot"];
            else if (pendingAction === "shutdown")
                command = ["systemctl", "poweroff"];
            if (command.length > 0) {
                console.log("Executing command:", command.join(" "));
                Quickshell.execDetached(command);
            }
            pendingAction = "";
        }
    }

    // Top specular highlight
    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 60
        radius: 16
        z: 10

        gradient: Gradient {
            GradientStop {
                position: 0
                color: Qt.rgba(1, 1, 1, 0.07)
            }

            GradientStop {
                position: 1
                color: Qt.rgba(1, 1, 1, 0)
            }

        }

    }

    // Bottom fade
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 40
        radius: 16
        z: 10

        gradient: Gradient {
            GradientStop {
                position: 0
                color: Qt.rgba(0, 0, 0, 0)
            }

            GradientStop {
                position: 1
                color: Qt.rgba(0, 0, 0, 0.12)
            }

        }

    }

}
