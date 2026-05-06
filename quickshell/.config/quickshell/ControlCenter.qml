import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Rectangle {
    id: root
    width: 420
    height: Math.max(contentColumn.childrenRect.height + 100, 920)
    color: Qt.rgba(ThemeManager.bgBase.r, ThemeManager.bgBase.g, ThemeManager.bgBase.b, 0.92)
    radius: 16
    border.width: 1
    border.color: Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.35)
    clip: true
    
    property bool isVisible: false
    // Properties from system
    property string networkType: "wifi"
    property int signalStrength: 100
    property string networkName: "Unknown"
    property string downloadRate: "0 KB/s"
    property string uploadRate: "0 KB/s"
    property real downloadSpeed: 0
    property real uploadSpeed: 0
    property real lastRxBytes: 0
    property real lastTxBytes: 0
    property real lastTrafficCheck: 0
    property int volume: 50
    property bool muted: true
    property int batteryLevel: 100
    property bool charging: false
    property bool acOnline: false
    property string batteryTimeRemaining: ""
    property bool bluetoothEnabled: false
    property var bluetoothDevices: []
    property int brightness: 50
    property bool nightlightEnabled: false
    property string powerProfile: "balanced"

    signal requestClose()

    function updateVolume() {
        volumeLevelProcess.running = true;
    }

    function updateBattery() {
        batteryCheckProcess.running = true;
    }

    function updateNetwork() {
        networkCheckProcess.running = true;
    }

    // Bluetooth functions
    function updateBluetooth() {
        bluetoothStatusProcess.running = true;
    }

    // Brightness functions
    function updateBrightness() {
        brightnessLevelProcess.running = true;
    }

    // Power Profile functions
    function updatePowerProfile() {
        powerProfileCheckProcess.running = true;
    }

    focus: true
    Keys.onEscapePressed: {
        root.requestClose();
    }

    Flickable {
        anchors.fill: parent
        anchors.margins: 14
        anchors.bottomMargin: 26
        contentWidth: width
        contentHeight: contentColumn.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: contentColumn

            width: parent.width
            spacing: 16

            // Header
            Item {
                width: parent.width
                height: 44

                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Control Center"
                    font.family: "Sen"
                    font.pixelSize: 20
                    font.weight: Font.Bold
                    color: ThemeManager.fgPrimary
                }

                // Close button
                Rectangle {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    width: 32
                    height: 32
                    radius: 6
                    color: closeMouseArea.containsMouse ? Qt.rgba(ThemeManager.accentRed.r, ThemeManager.accentRed.g, ThemeManager.accentRed.b, 0.3) : "transparent"
                    border.width: closeMouseArea.containsMouse ? 1 : 0
                    border.color: Qt.rgba(ThemeManager.accentRed.r, ThemeManager.accentRed.g, ThemeManager.accentRed.b, 0.5)
                    z: 1000

                    Text {
                        anchors.centerIn: parent
                        text: "✕"
                        font.family: "Sen"
                        font.pixelSize: 18
                        font.weight: Font.Bold
                        color: ThemeManager.fgSecondary
                    }

                    MouseArea {
                        id: closeMouseArea

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        propagateComposedEvents: false
                        onClicked: {
                            root.requestClose();
                        }
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }

                    }

                }

            }

            // WiFi Section
            Rectangle {
                width: parent.width
                height: 140
                color: Qt.rgba(1, 1, 1, 0.07)
                radius: 12
                border.width: 1
                border.color: Qt.rgba(1, 1, 1, 0.1)

                Column {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    Item {
                        width: parent.width
                        height: 44

                        Row {
                            width: parent.width - 60
                            spacing: 12

                            Text {
                                text: {
                                    if (root.networkType === "wifi") {
                                        if (root.signalStrength >= 80)
                                            return "󰤨";
                                        else if (root.signalStrength >= 60)
                                            return "󰤥";
                                        else if (root.signalStrength >= 40)
                                            return "󰤢";
                                        else if (root.signalStrength >= 20)
                                            return "󰤟";
                                        else
                                            return "󰤯";
                                    } else if (root.networkType === "ethernet") {
                                        return "󰈀";
                                    } else {
                                        return "󰌙";
                                    }
                                }
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 28
                                color: ThemeManager.accentGreen
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Column {
                                spacing: 4
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    text: root.networkType === "wifi" ? "Wi-Fi" : root.networkType === "ethernet" ? "Ethernet" : "Disconnected"
                                    font.family: "Sen"
                                    font.pixelSize: 16
                                    font.weight: Font.Bold
                                    color: ThemeManager.fgPrimary
                                }

                                Text {
                                    text: root.networkName
                                    font.family: "Sen"
                                    font.pixelSize: 13
                                    color: ThemeManager.fgSecondary
                                }

                            }

                        }

                        // Wi-Fi toggle - positioned absolutely in top right
                        Rectangle {
                            width: 48
                            height: 24
                            radius: 12
                            color: root.networkType === "wifi" ? ThemeManager.accentGreen : Qt.rgba(1, 1, 1, 0.07)
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter

                            Rectangle {
                                width: 18
                                height: 18
                                radius: 9
                                color: ThemeManager.fgPrimary
                                x: root.networkType === "wifi" ? parent.width - width - 3 : 3
                                anchors.verticalCenter: parent.verticalCenter

                                Behavior on x {
                                    NumberAnimation {
                                        duration: 200
                                    }

                                }

                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (root.networkType === "wifi")
                                        wifiDisableProcess.running = true;
                                    else
                                        wifiEnableProcess.running = true;
                                }
                            }

                        }

                    }

                    // Network stats row
                    Row {
                        width: parent.width
                        spacing: 16

                        Text {
                            text: root.networkType === "wifi" ? root.signalStrength + "%" : ""
                            font.family: "Sen"
                            font.pixelSize: 14
                            font.weight: Font.Bold
                            color: ThemeManager.accentBlue
                            visible: root.networkType === "wifi"
                        }

                        Text {
                            text: "↓ " + root.downloadRate
                            font.family: "Sen"
                            font.pixelSize: 11
                            color: ThemeManager.fgSecondary
                        }

                        Text {
                            text: "↑ " + root.uploadRate
                            font.family: "Sen"
                            font.pixelSize: 11
                            color: ThemeManager.fgSecondary
                        }

                    }

                    // Network settings button
                    Rectangle {
                        width: parent.width
                        height: 32
                        color: netSettingsMouseArea.containsMouse ? Qt.rgba(1, 1, 1, 0.16) : Qt.rgba(1, 1, 1, 0.07)
                        radius: 8

                        MouseArea {
                            id: netSettingsMouseArea

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                Quickshell.execDetached(["kitty", "-e", "wlctl"]);
                                root.requestClose();
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "Network Settings"
                            font.family: "Sen"
                            font.pixelSize: 13
                            color: ThemeManager.fgPrimary
                        }

                    }

                }

            }

            // Bluetooth Section
            Rectangle {
                width: parent.width
                height: Math.max(116, 80 + (bluetoothDevicesColumn.children.length * 28))
                color: Qt.rgba(1, 1, 1, 0.07)
                radius: 12
                border.width: 1
                border.color: Qt.rgba(1, 1, 1, 0.1)

                Column {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    Item {
                        width: parent.width
                        height: 44

                        Row {
                            width: parent.width - 60
                            spacing: 12

                            Text {
                                text: "󰂯"
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 28
                                color: root.bluetoothEnabled ? ThemeManager.accentBlue : ThemeManager.fgTertiary
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Column {
                                spacing: 4
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    text: "Bluetooth"
                                    font.family: "Sen"
                                    font.pixelSize: 16
                                    font.weight: Font.Bold
                                    color: ThemeManager.fgPrimary
                                }

                                Text {
                                    text: root.bluetoothEnabled ? (root.bluetoothDevices.length > 0 ? root.bluetoothDevices.length + " device(s) connected" : "No devices connected") : "Off"
                                    font.family: "Sen"
                                    font.pixelSize: 13
                                    color: ThemeManager.fgSecondary
                                }

                            }

                        }

                        // Bluetooth toggle - positioned absolutely in top right
                        Rectangle {
                            width: 48
                            height: 24
                            radius: 12
                            color: root.bluetoothEnabled ? ThemeManager.accentBlue : Qt.rgba(1, 1, 1, 0.07)
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter

                            Rectangle {
                                width: 18
                                height: 18
                                radius: 9
                                color: ThemeManager.fgPrimary
                                x: root.bluetoothEnabled ? parent.width - width - 3 : 3
                                anchors.verticalCenter: parent.verticalCenter

                                Behavior on x {
                                    NumberAnimation {
                                        duration: 200
                                    }

                                }

                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (root.bluetoothEnabled)
                                        bluetoothDisableProcess.running = true;
                                    else
                                        bluetoothEnableProcess.running = true;
                                }
                            }

                        }

                    }

                    // Connected devices list
                    Column {
                        id: bluetoothDevicesColumn

                        width: parent.width
                        spacing: 4
                        visible: root.bluetoothDevices.length > 0

                        Repeater {
                            model: root.bluetoothDevices

                            delegate: Text {
                                text: "  • " + modelData
                                font.family: "Sen"
                                font.pixelSize: 12
                                color: ThemeManager.fgSecondary
                            }

                        }

                    }

                    // Bluetooth manager button
                    Rectangle {
                        width: parent.width
                        height: 32
                        color: btSettingsMouseArea.containsMouse ? Qt.rgba(1, 1, 1, 0.16) : Qt.rgba(1, 1, 1, 0.07)
                        radius: 8

                        MouseArea {
                            id: btSettingsMouseArea

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                Quickshell.execDetached(["kitty", "-e", "bluetui"]);
                                root.requestClose();
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "Bluetooth Settings"
                            font.family: "Sen"
                            font.pixelSize: 13
                            color: ThemeManager.fgPrimary
                        }

                    }

                }

            }

            // Audio Section
            Rectangle {
                width: parent.width
                height: 136
                color: Qt.rgba(1, 1, 1, 0.07)
                radius: 12
                border.width: 1
                border.color: Qt.rgba(1, 1, 1, 0.1)

                Column {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    Row {
                        width: parent.width
                        spacing: 12

                        Text {
                            text: root.muted ? "󰝟" : root.volume >= 70 ? "󰕾" : root.volume >= 30 ? "󰖀" : "󰕿"
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 28
                            color: root.muted ? ThemeManager.fgTertiary : ThemeManager.accentBlue
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            spacing: 4
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                text: "Volume"
                                font.family: "Sen"
                                font.pixelSize: 16
                                font.weight: Font.Bold
                                color: ThemeManager.fgPrimary
                            }

                            Text {
                                text: root.muted ? "Muted" : root.volume + "%"
                                font.family: "Sen"
                                font.pixelSize: 13
                                color: ThemeManager.fgSecondary
                            }

                        }

                    }

                    // Volume slider
                    Rectangle {
                        width: parent.width
                        height: 8
                        color: Qt.rgba(1, 1, 1, 0.07)
                        radius: 4

                        Rectangle {
                            width: parent.width * (root.volume / 100)
                            height: parent.height
                            color: root.muted ? ThemeManager.fgTertiary : ThemeManager.accentBlue
                            radius: 4
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            
                            function updateFromMouse(mouse) {
                                let percent = Math.max(0, Math.min(100, Math.round((mouse.x / width) * 100)));
                                root.volume = percent;
                                
                                // Automatically unmute if user slides volume up
                                if (root.muted && percent > 0) {
                                    root.muted = false;
                                    Quickshell.execDetached(["pactl", "set-sink-mute", "@DEFAULT_SINK@", "0"]);
                                }
                                
                                volumeSetProcess.command = ["sh", "-c", "pactl set-sink-volume @DEFAULT_SINK@ " + percent + "%"];
                                volumeSetProcess.running = true;
                            }
                            
                            onPressed: (mouse) => updateFromMouse(mouse)
                            onPositionChanged: (mouse) => {
                                if (pressed) updateFromMouse(mouse)
                            }
                        }
                    }

                    // Volume controls
                    Row {
                        width: parent.width
                        spacing: 8

                        Rectangle {
                            width: (parent.width - 16) / 3
                            height: 32
                            color: volDownMouseArea.containsMouse ? Qt.rgba(1, 1, 1, 0.16) : Qt.rgba(1, 1, 1, 0.07)
                            radius: 8

                            MouseArea {
                                id: volDownMouseArea

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    volumeDownProcess.running = true;
                                }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "−"
                                font.pixelSize: 20
                                color: ThemeManager.fgPrimary
                            }

                        }

                        Rectangle {
                            width: (parent.width - 16) / 3
                            height: 32
                            color: volMuteMouseArea.containsMouse ? Qt.rgba(1, 1, 1, 0.16) : Qt.rgba(1, 1, 1, 0.07)
                            radius: 8

                            MouseArea {
                                id: volMuteMouseArea

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    volumeMuteProcess.running = true;
                                }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: root.muted ? "󰝟" : "󰖁"
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 16
                                color: ThemeManager.fgPrimary
                            }

                        }

                        Rectangle {
                            width: (parent.width - 16) / 3
                            height: 32
                            color: volUpMouseArea.containsMouse ? Qt.rgba(1, 1, 1, 0.16) : Qt.rgba(1, 1, 1, 0.07)
                            radius: 8

                            MouseArea {
                                id: volUpMouseArea

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    volumeUpProcess.running = true;
                                }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "+"
                                font.pixelSize: 20
                                color: ThemeManager.fgPrimary
                            }

                        }

                    }

                }

            }

            // Brightness Section
            Rectangle {
                width: parent.width
                height: 96
                color: Qt.rgba(1, 1, 1, 0.07)
                radius: 12
                border.width: 1
                border.color: Qt.rgba(1, 1, 1, 0.1)

                Column {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    Row {
                        width: parent.width
                        spacing: 12

                        Text {
                            text: root.brightness >= 70 ? "󰃠" : root.brightness >= 40 ? "󰃟" : "󰃞"
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 28
                            color: ThemeManager.accentYellow
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            spacing: 4
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                text: "Brightness"
                                font.family: "Sen"
                                font.pixelSize: 16
                                font.weight: Font.Bold
                                color: ThemeManager.fgPrimary
                            }

                            Text {
                                text: root.brightness + "%"
                                font.family: "Sen"
                                font.pixelSize: 13
                                color: ThemeManager.fgSecondary
                            }

                        }

                    }

                    // Brightness slider
                    Rectangle {
                        width: parent.width
                        height: 8
                        color: Qt.rgba(1, 1, 1, 0.07)
                        radius: 4

                        Rectangle {
                            width: parent.width * (root.brightness / 100)
                            height: parent.height
                            color: ThemeManager.accentYellow
                            radius: 4
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            
                            function updateFromMouse(mouse) {
                                let percent = Math.max(0, Math.min(100, Math.round((mouse.x / width) * 100)));
                                root.brightness = percent;
                                brightnessSetProcess.command = ["brightnessctl", "set", percent + "%"];
                                brightnessSetProcess.running = true;
                            }
                            
                            onPressed: (mouse) => updateFromMouse(mouse)
                            onPositionChanged: (mouse) => {
                                if (pressed) updateFromMouse(mouse)
                            }
                        }
                    }



                }

            }

            // Nightlight Section
            Rectangle {
                width: parent.width
                height: 76
                color: Qt.rgba(1, 1, 1, 0.07)
                radius: 12
                border.width: 1
                border.color: Qt.rgba(1, 1, 1, 0.1)

                Column {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    Item {
                        width: parent.width
                        height: 44

                        Row {
                            width: parent.width - 60
                            spacing: 12

                            Text {
                                text: "󰅪"
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 28
                                color: root.nightlightEnabled ? ThemeManager.accentRed : ThemeManager.fgTertiary
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Column {
                                spacing: 4
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    text: "Nightlight"
                                    font.family: "Sen"
                                    font.pixelSize: 16
                                    font.weight: Font.Bold
                                    color: ThemeManager.fgPrimary
                                }

                                Text {
                                    text: root.nightlightEnabled ? "On" : "Off"
                                    font.family: "Sen"
                                    font.pixelSize: 13
                                    color: ThemeManager.fgSecondary
                                }

                            }

                        }

                        // Nightlight toggle - positioned absolutely in top right
                        Rectangle {
                            width: 48
                            height: 24
                            radius: 12
                            color: root.nightlightEnabled ? ThemeManager.accentRed : Qt.rgba(1, 1, 1, 0.07)
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter

                            Rectangle {
                                width: 18
                                height: 18
                                radius: 9
                                color: ThemeManager.fgPrimary
                                x: root.nightlightEnabled ? parent.width - width - 3 : 3
                                anchors.verticalCenter: parent.verticalCenter

                                Behavior on x {
                                    NumberAnimation {
                                        duration: 200
                                    }

                                }

                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (root.nightlightEnabled)
                                        nightlightDisableProcess.running = true;
                                    else
                                        nightlightEnableProcess.running = true;
                                }
                            }

                        }

                    }

                }

            }

            // Power Profiles Section
            Rectangle {
                width: parent.width
                height: 86
                color: Qt.rgba(1, 1, 1, 0.07)
                radius: 12
                border.width: 1
                border.color: Qt.rgba(1, 1, 1, 0.1)

                Column {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 12

                    Text {
                        text: "Power Profile"
                        font.family: "Sen"
                        font.pixelSize: 15
                        font.weight: Font.Bold
                        color: ThemeManager.fgPrimary
                    }

                    Row {
                        width: parent.width
                        spacing: 8

                        Rectangle {
                            width: (parent.width - 16) / 3
                            height: 32
                            radius: 8
                            color: root.powerProfile === "power-saver" ? Qt.rgba(ThemeManager.accentGreen.r, ThemeManager.accentGreen.g, ThemeManager.accentGreen.b, 0.3) : (psMouseArea.containsMouse ? Qt.rgba(1, 1, 1, 0.16) : Qt.rgba(1, 1, 1, 0.07))
                            border.width: root.powerProfile === "power-saver" ? 1 : 0
                            border.color: ThemeManager.accentGreen

                            MouseArea {
                                id: psMouseArea

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.powerProfile = "power-saver";
                                    // Use whitelisted profile directly without concatenation
                                    powerProfileSetProcess.command = ["dbus-send", "--system", "--print-reply", "--dest=net.hadess.PowerProfiles", "/net/hadess/PowerProfiles", "org.freedesktop.DBus.Properties.Set", "string:net.hadess.PowerProfiles", "string:ActiveProfile", "variant:string:power-saver"];
                                    powerProfileSetProcess.running = true;
                                }
                            }

                            Row {
                                anchors.centerIn: parent
                                spacing: 6

                                Text {
                                    text: "󰾆"
                                    font.family: "Symbols Nerd Font"
                                    font.pixelSize: 14
                                    color: root.powerProfile === "power-saver" ? ThemeManager.accentGreen : ThemeManager.fgSecondary
                                }

                                Text {
                                    text: "Saver"
                                    font.family: "Sen"
                                    font.pixelSize: 12
                                    font.weight: root.powerProfile === "power-saver" ? Font.Bold : Font.Normal
                                    color: root.powerProfile === "power-saver" ? ThemeManager.fgPrimary : ThemeManager.fgSecondary
                                }

                            }

                        }

                        Rectangle {
                            width: (parent.width - 16) / 3
                            height: 32
                            radius: 8
                            color: root.powerProfile === "balanced" ? Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.3) : (balMouseArea.containsMouse ? Qt.rgba(1, 1, 1, 0.16) : Qt.rgba(1, 1, 1, 0.07))
                            border.width: root.powerProfile === "balanced" ? 1 : 0
                            border.color: ThemeManager.accentBlue

                            MouseArea {
                                id: balMouseArea

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.powerProfile = "balanced";
                                    // Use whitelisted profile directly without concatenation
                                    powerProfileSetProcess.command = ["dbus-send", "--system", "--print-reply", "--dest=net.hadess.PowerProfiles", "/net/hadess/PowerProfiles", "org.freedesktop.DBus.Properties.Set", "string:net.hadess.PowerProfiles", "string:ActiveProfile", "variant:string:balanced"];
                                    powerProfileSetProcess.running = true;
                                }
                            }

                            Row {
                                anchors.centerIn: parent
                                spacing: 6

                                Text {
                                    text: "󰗑"
                                    font.family: "Symbols Nerd Font"
                                    font.pixelSize: 14
                                    color: root.powerProfile === "balanced" ? ThemeManager.accentBlue : ThemeManager.fgSecondary
                                }

                                Text {
                                    text: "Balanced"
                                    font.family: "Sen"
                                    font.pixelSize: 12
                                    font.weight: root.powerProfile === "balanced" ? Font.Bold : Font.Normal
                                    color: root.powerProfile === "balanced" ? ThemeManager.fgPrimary : ThemeManager.fgSecondary
                                }

                            }

                        }

                        Rectangle {
                            width: (parent.width - 16) / 3
                            height: 32
                            radius: 8
                            color: root.powerProfile === "performance" ? Qt.rgba(ThemeManager.accentRed.r, ThemeManager.accentRed.g, ThemeManager.accentRed.b, 0.3) : (perfMouseArea.containsMouse ? Qt.rgba(1, 1, 1, 0.16) : Qt.rgba(1, 1, 1, 0.07))
                            border.width: root.powerProfile === "performance" ? 1 : 0
                            border.color: ThemeManager.accentRed

                            MouseArea {
                                id: perfMouseArea

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.powerProfile = "performance";
                                    // Use whitelisted profile directly without concatenation
                                    powerProfileSetProcess.command = ["dbus-send", "--system", "--print-reply", "--dest=net.hadess.PowerProfiles", "/net/hadess/PowerProfiles", "org.freedesktop.DBus.Properties.Set", "string:net.hadess.PowerProfiles", "string:ActiveProfile", "variant:string:performance"];
                                    powerProfileSetProcess.running = true;
                                }
                            }

                            Row {
                                anchors.centerIn: parent
                                spacing: 6

                                Text {
                                    text: "󰓅"
                                    font.family: "Symbols Nerd Font"
                                    font.pixelSize: 14
                                    color: root.powerProfile === "performance" ? ThemeManager.accentRed : ThemeManager.fgSecondary
                                }

                                Text {
                                    text: "Perform"
                                    font.family: "Sen"
                                    font.pixelSize: 12
                                    font.weight: root.powerProfile === "performance" ? Font.Bold : Font.Normal
                                    color: root.powerProfile === "performance" ? ThemeManager.fgPrimary : ThemeManager.fgSecondary
                                }

                            }

                        }

                    }

                }

            }

            // Screen Settings (hyprmon)
            Rectangle {
                width: parent.width
                height: 60
                color: Qt.rgba(1, 1, 1, 0.07)
                radius: 12
                border.width: 1
                border.color: Qt.rgba(1, 1, 1, 0.1)

                Item {
                    anchors.fill: parent
                    anchors.margins: 16

                    Row {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 12

                        Text {
                            text: "󰍹"
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 24
                            color: ThemeManager.accentTeal
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            spacing: 2
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                text: "Screen Settings"
                                font.family: "Sen"
                                font.pixelSize: 15
                                font.weight: Font.Bold
                                color: ThemeManager.fgPrimary
                            }

                            Text {
                                text: "Open hyprmon"
                                font.family: "Sen"
                                font.pixelSize: 12
                                color: ThemeManager.fgTertiary
                            }
                        }
                    }

                    // Launch button
                    Rectangle {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        width: 72
                        height: 32
                        radius: 8
                        color: hyprmonMouseArea.containsMouse ? Qt.rgba(ThemeManager.accentTeal.r, ThemeManager.accentTeal.g, ThemeManager.accentTeal.b, 0.25) : Qt.rgba(1, 1, 1, 0.07)
                        border.width: 1
                        border.color: hyprmonMouseArea.containsMouse ? Qt.rgba(ThemeManager.accentTeal.r, ThemeManager.accentTeal.g, ThemeManager.accentTeal.b, 0.5) : Qt.rgba(1, 1, 1, 0.1)

                        Text {
                            anchors.centerIn: parent
                            text: "Launch"
                            font.family: "Sen"
                            font.pixelSize: 13
                            color: hyprmonMouseArea.containsMouse ? ThemeManager.accentTeal : ThemeManager.fgPrimary
                        }

                        MouseArea {
                            id: hyprmonMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                Quickshell.execDetached(["kitty", "-e", "hyprmon"]);
                                root.requestClose();
                            }
                        }

                        Behavior on color { ColorAnimation { duration: 150 } }
                        Behavior on border.color { ColorAnimation { duration: 150 } }
                    }
                }
            }

            // Bottom spacer to prevent compression
            Item {
                width: parent.width
                height: 40
            }

        }

    }

    // Volume control processes
    Process {
        id: volumeUpProcess

        running: false
        command: ["sh", "-c", "pactl set-sink-volume @DEFAULT_SINK@ +5%"]
        onRunningChanged: {
            if (!running) {
                // Optimistic update - increase volume immediately
                root.volume = Math.min(100, root.volume + 5);
                volumeUpdateTimer.restart();
            }
        }
    }

    Process {
        id: volumeDownProcess

        running: false
        command: ["sh", "-c", "pactl set-sink-volume @DEFAULT_SINK@ -5%"]
        onRunningChanged: {
            if (!running) {
                // Optimistic update - decrease volume immediately
                root.volume = Math.max(0, root.volume - 5);
                volumeUpdateTimer.restart();
            }
        }
    }

    Process {
        id: volumeMuteProcess

        running: false
        command: ["sh", "-c", "pactl set-sink-mute @DEFAULT_SINK@ toggle"]
        onRunningChanged: {
            if (!running) {
                // Optimistic update - toggle mute immediately
                root.muted = !root.muted;
                volumeUpdateTimer.restart();
            }
        }
    }

    Process {
        id: volumeSetProcess
        running: false
        command: []
    }

    // Delay timer for volume updates after button clicks
    Timer {
        id: volumeUpdateTimer

        interval: 50
        repeat: false
        onTriggered: updateVolume()
    }

    // Update functions
    // Signal based watchers for instant updates
    Process {
        id: volumeSignalWatcher
        running: root.isVisible
        command: ["sh", "-c", "pactl subscribe | grep --line-buffered \"sink\""]
        stdout: SplitParser { onRead: updateVolume() }
    }

    Process {
        id: batterySignalWatcher
        running: root.isVisible
        command: ["sh", "-c", "BAT_PATH=$(upower -e | grep battery | head -n 1); [ -n \"$BAT_PATH\" ] && gdbus monitor --system --dest org.freedesktop.UPower --object-path \"$BAT_PATH\""]
        stdout: SplitParser { onRead: updateBattery() }
    }

    Process {
        id: networkSignalWatcher
        running: root.isVisible
        command: ["gdbus", "monitor", "--system", "--dest", "org.freedesktop.NetworkManager", "--object-path", "/org/freedesktop/NetworkManager"]
        stdout: SplitParser { onRead: updateNetwork() }
    }

    // Slower timer for less critical updates (bluetooth, brightness, power profile)
    Timer {
        interval: 5000
        running: root.isVisible
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            updateBluetooth();
            updateBrightness();
            updatePowerProfile();
        }
    }


    Process {
        id: volumeLevelProcess

        command: ["sh", "-c", "pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\\d+%' | head -1 | tr -d '%'"]
        running: false
        onExited: {
            // After getting volume, check mute status
            volumeMuteStatusProcess.running = true;
        }

        stdout: SplitParser {
            onRead: (data) => {
                root.volume = parseInt(data.trim()) || 0;
            }
        }

    }

    Process {
        id: volumeMuteStatusProcess

        command: ["sh", "-c", "pactl get-sink-mute @DEFAULT_SINK@ | grep -q yes && echo 1 || echo 0"]
        running: false

        stdout: SplitParser {
            onRead: (data) => {
                root.muted = (data.trim() === "1");
            }
        }

    }

    Process {
        id: batteryCheckProcess

        property string buffer: ""

        command: ["sh", "-c", `
            BAT_PATH=$(echo /sys/class/power_supply/BAT* 2>/dev/null | awk '{print $1}')
            if [ -n "$BAT_PATH" ] && [ -d "$BAT_PATH" ]; then
                LEVEL=$(cat "$BAT_PATH/capacity" 2>/dev/null || echo 100)
                STATUS=$(cat "$BAT_PATH/status" 2>/dev/null || echo "Unknown")

                AC_ONLINE=0
                for ac_path in /sys/class/power_supply/AC* /sys/class/power_supply/ACAD /sys/class/power_supply/ADP*; do
                    if [ -f "$ac_path/online" ]; then
                        AC_ONLINE=$(cat "$ac_path/online" 2>/dev/null || echo 0)
                        break
                    fi
                done

                echo "$LEVEL|$STATUS|$AC_ONLINE"
            else
                echo "100|Unknown|0"
            fi
        `]
        running: false
        onRunningChanged: {
            if (!running && buffer !== "") {
                let parts = buffer.trim().split('|');
                if (parts.length >= 3) {
                    root.batteryLevel = parseInt(parts[0]) || 100;
                    root.charging = parts[1].includes("Charging");
                    root.acOnline = parts[2] === "1";
                    // Calculate time remaining/until full
                    if (root.charging || !root.acOnline)
                        batteryTimeProcess.running = true;
                    else if (root.acOnline && root.batteryLevel >= 99)
                        root.batteryTimeRemaining = "Fully charged";
                    else
                        root.batteryTimeRemaining = "";
                }
                buffer = "";
            } else if (running) {
                buffer = "";
            }
        }

        stdout: SplitParser {
            onRead: (data) => {
                batteryCheckProcess.buffer += data;
            }
        }

    }

    Process {
        id: batteryTimeProcess

        property string buffer: ""

        command: ["sh", "-c", `
            BAT_PATH=$(echo /sys/class/power_supply/BAT* 2>/dev/null | awk '{print $1}')
            if [ -n "$BAT_PATH" ] && [ -d "$BAT_PATH" ]; then
                STATUS=$(cat "$BAT_PATH/status" 2>/dev/null || echo "Unknown")

                if [ -f "$BAT_PATH/current_now" ] && [ -f "$BAT_PATH/charge_now" ]; then
                    CURRENT=$(cat "$BAT_PATH/current_now" 2>/dev/null || echo 0)
                    CHARGE=$(cat "$BAT_PATH/charge_now" 2>/dev/null || echo 0)
                    FULL=$(cat "$BAT_PATH/charge_full" 2>/dev/null || echo $CHARGE)

                    if [ "$CURRENT" -gt 0 ] 2>/dev/null; then
                        if echo "$STATUS" | grep -q "Charging"; then
                            TIME_H=$(( ($FULL - $CHARGE) / $CURRENT ))
                            TIME_M=$(( (($FULL - $CHARGE) * 60 / $CURRENT) % 60 ))
                            echo "\${TIME_H}h \${TIME_M}m until fully charged"
                        elif echo "$STATUS" | grep -q "Discharging"; then
                            TIME_H=$(( $CHARGE / $CURRENT ))
                            TIME_M=$(( ($CHARGE * 60 / $CURRENT) % 60 ))
                            echo "\${TIME_H}h \${TIME_M}m remaining"
                        fi
                    fi
                fi
            fi
        `]
        running: false
        onRunningChanged: {
            if (!running && buffer !== "") {
                root.batteryTimeRemaining = buffer.trim();
                buffer = "";
            } else if (running) {
                buffer = "";
            }
        }

        stdout: SplitParser {
            onRead: (data) => {
                batteryTimeProcess.buffer += data;
            }
        }

    }

    Process {
        id: networkCheckProcess

        property string buffer: ""

        running: false
        command: ["sh", "-c", "nmcli -t -f TYPE,STATE,DEVICE,NAME connection show --active | head -1"]
        onRunningChanged: {
            if (!running && buffer !== "") {
                let line = buffer.trim();
                if (line) {
                    let parts = line.split(':');
                    if (parts.length >= 4) {
                        root.networkType = parts[0].includes("wireless") || parts[0].includes("wifi") ? "wifi" : "ethernet";
                        root.networkName = parts[3] || "Connected";
                        if (root.networkType === "wifi")
                            signalCheckProcess.running = true;

                    }
                }
                buffer = "";
            } else if (running) {
                buffer = "";
            }
        }

        stdout: SplitParser {
            onRead: (data) => {
                networkCheckProcess.buffer += data;
            }
        }

    }

    Process {
        id: signalCheckProcess

        property string buffer: ""

        running: false
        command: ["sh", "-c", "nmcli -t -f IN-USE,SIGNAL dev wifi | grep '^\\*' | cut -d':' -f2"]
        onRunningChanged: {
            if (!running && buffer !== "") {
                root.signalStrength = parseInt(buffer.trim()) || 100;
                buffer = "";
            } else if (running) {
                buffer = "";
            }
        }

        stdout: SplitParser {
            onRead: (data) => {
                signalCheckProcess.buffer += data;
            }
        }

    }

    Process {
        id: trafficProcess

        command: ["sh", "-c", `
            while true; do
                interface=$(ip route | grep default | awk '{print $5}' | head -1)
                if [ -n "$interface" ]; then
                    rx=$(cat /sys/class/net/$interface/statistics/rx_bytes 2>/dev/null || echo 0)
                    tx=$(cat /sys/class/net/$interface/statistics/tx_bytes 2>/dev/null || echo 0)
                    echo "$rx $tx"
                else
                    echo "0 0"
                fi
                sleep 5
            done
        `]
        running: root.isVisible

        stdout: SplitParser {
            onRead: (data) => {
                var parts = data.trim().split(" ");
                if (parts.length >= 2) {
                    var rxBytes = parseFloat(parts[0]);
                    var txBytes = parseFloat(parts[1]);
                    var currentTime = Date.now();
                    if (root.lastTrafficCheck > 0) {
                        var timeDiff = (currentTime - root.lastTrafficCheck) / 1000; // seconds
                        if (timeDiff > 0) {
                            // Calculate speeds in KB/s
                            var rxDiff = (rxBytes - root.lastRxBytes) / 1024;
                            var txDiff = (txBytes - root.lastTxBytes) / 1024;
                            root.downloadSpeed = rxDiff / timeDiff;
                            root.uploadSpeed = txDiff / timeDiff;
                            // Format as KB/s or MB/s
                            if (root.downloadSpeed >= 1024)
                                root.downloadRate = (root.downloadSpeed / 1024).toFixed(1) + " MB/s";
                            else
                                root.downloadRate = Math.round(root.downloadSpeed) + " KB/s";
                            if (root.uploadSpeed >= 1024)
                                root.uploadRate = (root.uploadSpeed / 1024).toFixed(1) + " MB/s";
                            else
                                root.uploadRate = Math.round(root.uploadSpeed) + " KB/s";
                        }
                    }
                    root.lastRxBytes = rxBytes;
                    root.lastTxBytes = txBytes;
                    root.lastTrafficCheck = currentTime;
                }
            }
        }

    }

    // trafficTimer removed - trafficProcess is now persistent and starts/stops based on root.isVisible

    // Wi-Fi toggle processes
    Process {
        id: wifiEnableProcess

        running: false
        command: ["sh", "-c", "nmcli radio wifi on"]
        onRunningChanged: {
            if (!running)
                Qt.callLater(updateNetwork);

        }
    }

    Process {
        id: wifiDisableProcess

        running: false
        command: ["sh", "-c", "nmcli radio wifi off"]
        onRunningChanged: {
            if (!running)
                Qt.callLater(updateNetwork);

        }
    }

    Process {
        id: bluetoothStatusProcess

        property string buffer: ""

        running: false
        command: ["sh", "-c", "rfkill list bluetooth | grep 'Soft blocked:' | head -n1 | awk '{print $3}'"]
        onRunningChanged: {
            if (!running && buffer !== "") {
                // rfkill returns "no" when NOT blocked (i.e., when enabled)
                root.bluetoothEnabled = buffer.trim() === "no";
                buffer = "";
                // If bluetooth is on, get connected devices
                if (root.bluetoothEnabled)
                    bluetoothDevicesProcess.running = true;
                else
                    root.bluetoothDevices = [];
            } else if (running) {
                buffer = "";
            }
        }

        stdout: SplitParser {
            onRead: (data) => {
                bluetoothStatusProcess.buffer += data;
            }
        }

    }

    Process {
        id: bluetoothDevicesProcess

        property string buffer: ""

        running: false
        command: ["sh", "-c", "bluetoothctl devices Connected | awk '{$1=$2=\"\"; print substr($0,3)}'"]
        onRunningChanged: {
            if (!running && buffer !== "") {
                let lines = buffer.trim().split('\n').filter((line) => {
                    return line.length > 0;
                });
                root.bluetoothDevices = lines;
                buffer = "";
            } else if (running) {
                buffer = "";
            }
        }

        stdout: SplitParser {
            onRead: (data) => {
                bluetoothDevicesProcess.buffer += data;
            }
        }

    }

    Process {
        id: bluetoothEnableProcess

        running: false
        command: ["rfkill", "unblock", "bluetooth"]
        onRunningChanged: {
            if (!running)
                Qt.callLater(updateBluetooth);

        }
    }

    Process {
        id: bluetoothDisableProcess

        running: false
        command: ["rfkill", "block", "bluetooth"]
        onRunningChanged: {
            if (!running)
                Qt.callLater(updateBluetooth);

        }
    }

    Process {
        id: brightnessLevelProcess

        running: false
        command: ["sh", "-c", "brightnessctl -m -c backlight | head -n1 | cut -d',' -f4 | tr -d '%'"]

        stdout: SplitParser {
            onRead: (data) => {
                let val = parseInt(data.trim());
                if (!isNaN(val)) {
                    root.brightness = val;
                }
            }
        }

    }

    Process {
        id: brightnessUpProcess

        running: false
        command: ["sh", "-c", "brightnessctl set +5%"]
        onRunningChanged: {
            if (!running) {
                // Optimistic update - increase brightness immediately
                root.brightness = Math.min(100, root.brightness + 5);
                brightnessUpdateTimer.restart();
            }
        }
    }

    Process {
        id: brightnessDownProcess

        running: false
        command: ["sh", "-c", "brightnessctl set 5%-"]
        onRunningChanged: {
            if (!running) {
                // Optimistic update - decrease brightness immediately
                root.brightness = Math.max(0, root.brightness - 5);
                brightnessUpdateTimer.restart();
            }
        }
    }

    Process {
        id: brightnessSetProcess
        running: false
        command: []
    }

    // Delay timer for brightness updates after button clicks
    Timer {
        id: brightnessUpdateTimer

        interval: 50
        repeat: false
        onTriggered: updateBrightness()
    }

    // Nightlight enable/disable processes
    Process {
        id: nightlightEnableProcess

        running: false
        command: ["sh", "-c", "killall -q wlsunset; exec wlsunset -t 4500 -T 4501"]
        onRunningChanged: {
            root.nightlightEnabled = running;
        }
    }

    Process {
        id: nightlightDisableProcess

        running: false
        command: ["killall", "wlsunset"]
    }

    Process {
        id: powerProfileCheckProcess

        running: false
        command: ["sh", "-c", "dbus-send --system --print-reply --dest=net.hadess.PowerProfiles /net/hadess/PowerProfiles org.freedesktop.DBus.Properties.Get string:'net.hadess.PowerProfiles' string:'ActiveProfile' 2>/dev/null | grep variant | awk '{print $3}' | tr -d '\"'"]

        stdout: SplitParser {
            onRead: (data) => {
                let p = data.trim();
                if (p === "power-saver" || p === "balanced" || p === "performance")
                    root.powerProfile = p;

            }
        }

    }

    Process {
        id: powerProfileSetProcess

        running: false
        command: [] // Set dynamically
        onExited: {
            // Verify the change after a short delay
            powerProfileUpdateTimer.restart();
        }
    }

    Timer {
        id: powerProfileUpdateTimer
        interval: 200
        repeat: false
        onTriggered: updatePowerProfile()
    }

    // Top specular highlight
    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 120
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
        height: 80
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
