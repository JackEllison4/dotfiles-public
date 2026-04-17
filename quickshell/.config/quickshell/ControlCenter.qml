import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Rectangle {
    id: root
    
    width: 420
    height: 940
    color: Qt.rgba(ThemeManager.bgBase.r, ThemeManager.bgBase.g, ThemeManager.bgBase.b, 0.92)
    radius: 16
    border.width: 1
    border.color: Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.35)
    clip: true
    
    property bool isVisible: false
    signal requestClose()
    
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
    property bool muted: false
    property int batteryLevel: 100
    property bool charging: false
    property bool acOnline: false
    property string batteryTimeRemaining: ""
    property bool bluetoothEnabled: false
    property var bluetoothDevices: []
    property int brightness: 50
    property bool nightlightEnabled: false
    property int colorTemperature: 4500
    property string powerProfile: "balanced"
    
    focus: true
    
    Keys.onEscapePressed: {
        root.requestClose()
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
                color: closeMouseArea.containsMouse ? Qt.rgba(ThemeManager.accentRed.r, ThemeManager.accentRed.g, ThemeManager.accentRed.b, 0.30) : "transparent"
                border.width: closeMouseArea.containsMouse ? 1 : 0
                border.color: Qt.rgba(ThemeManager.accentRed.r, ThemeManager.accentRed.g, ThemeManager.accentRed.b, 0.5)
                z: 1000

                Behavior on color { ColorAnimation { duration: 150 } }

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
                        console.log("Close button clicked")
                        root.requestClose()
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
            border.color: Qt.rgba(1, 1, 1, 0.10)
            
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
                                    if (root.signalStrength >= 80) return "󰤨"
                                    else if (root.signalStrength >= 60) return "󰤥"
                                    else if (root.signalStrength >= 40) return "󰤢"
                                    else if (root.signalStrength >= 20) return "󰤟"
                                    else return "󰤯"
                                } else if (root.networkType === "ethernet") {
                                    return "󰈀"
                                } else {
                                    return "󰌙"
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
                            
                            Behavior on x { NumberAnimation { duration: 200 } }
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (root.networkType === "wifi") {
                                    wifiDisableProcess.running = true
                                } else {
                                    wifiEnableProcess.running = true
                                }
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
                            console.log("Opening WiFi settings")
                            Quickshell.execDetached(["wlctl"])
                            root.requestClose()
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
        
        // Audio Section
        Rectangle {
            width: parent.width
            height: 136
            color: Qt.rgba(1, 1, 1, 0.07)
            radius: 12
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.10)
            
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
                                volumeDownProcess.running = true
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
                                volumeMuteProcess.running = true
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
                                volumeUpProcess.running = true
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
        
        // Bluetooth Section
        Rectangle {
            width: parent.width
            height: Math.max(116, 80 + (bluetoothDevicesColumn.children.length * 28))
            color: Qt.rgba(1, 1, 1, 0.07)
            radius: 12
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.10)
            
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
                            
                            Behavior on x { NumberAnimation { duration: 200 } }
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (root.bluetoothEnabled) {
                                    bluetoothDisableProcess.running = true
                                } else {
                                    bluetoothEnableProcess.running = true
                                }
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
                            console.log("Opening Bluetooth settings")
                            Quickshell.execDetached(["bluetui"])
                            root.requestClose()
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
        
        // Brightness Section
        Rectangle {
            width: parent.width
            height: 136
            color: Qt.rgba(1, 1, 1, 0.07)
            radius: 12
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.10)
            
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
                }
                
                // Brightness controls
                Row {
                    width: parent.width
                    spacing: 8
                    
                    Rectangle {
                        width: (parent.width - 8) / 2
                        height: 32
                        color: brightDownMouseArea.containsMouse ? Qt.rgba(1, 1, 1, 0.16) : Qt.rgba(1, 1, 1, 0.07)
                        radius: 8
                        
                        MouseArea {
                            id: brightDownMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                brightnessDownProcess.running = true
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
                        width: (parent.width - 8) / 2
                        height: 32
                        color: brightUpMouseArea.containsMouse ? Qt.rgba(1, 1, 1, 0.16) : Qt.rgba(1, 1, 1, 0.07)
                        radius: 8
                        
                        MouseArea {
                            id: brightUpMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                brightnessUpProcess.running = true
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

        // Nightlight Section
        Rectangle {
            width: parent.width
            height: 140
            color: Qt.rgba(1, 1, 1, 0.07)
            radius: 12
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.10)

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
                                text: root.nightlightEnabled ? root.colorTemperature + "K" : "Off"
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

                            Behavior on x { NumberAnimation { duration: 200 } }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                console.log("Nightlight toggle clicked, current state:", root.nightlightEnabled)
                                if (root.nightlightEnabled) {
                                    console.log("Disabling nightlight")
                                    nightlightDisableProcess.running = true
                                } else {
                                    console.log("Enabling nightlight with temp:", root.colorTemperature)
                                    nightlightEnableProcess.running = true
                                }
                            }
                        }
                    }
                }

                // Temperature slider
                Rectangle {
                    width: parent.width
                    height: 8
                    color: Qt.rgba(1, 1, 1, 0.07)
                    radius: 4
                    visible: root.nightlightEnabled

                    Rectangle {
                        width: parent.width * ((root.colorTemperature - 3000) / (6000 - 3000))
                        height: parent.height
                        color: ThemeManager.accentRed
                        radius: 4
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            var percentage = Math.max(0, Math.min(1, (mouse.x - x) / width))
                            root.colorTemperature = Math.round(3000 + (percentage * 3000))
                            nightlightSetTemperatureProcess.running = true
                        }
                    }
                }

                // Temperature display and controls
                Row {
                    width: parent.width
                    spacing: 8
                    visible: root.nightlightEnabled

                    Rectangle {
                        width: (parent.width - 16) / 3
                        height: 32
                        color: tempDownMouseArea.containsMouse ? Qt.rgba(1, 1, 1, 0.16) : Qt.rgba(1, 1, 1, 0.07)
                        radius: 8

                        MouseArea {
                            id: tempDownMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.colorTemperature = Math.max(3000, root.colorTemperature - 300)
                                nightlightSetTemperatureProcess.running = true
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
                        color: Qt.rgba(1, 1, 1, 0.07)
                        radius: 8

                        Text {
                            anchors.centerIn: parent
                            text: root.colorTemperature + "K"
                            font.family: "Sen"
                            font.pixelSize: 12
                            color: ThemeManager.accentRed
                        }
                    }

                    Rectangle {
                        width: (parent.width - 16) / 3
                        height: 32
                        color: tempUpMouseArea.containsMouse ? Qt.rgba(1, 1, 1, 0.16) : Qt.rgba(1, 1, 1, 0.07)
                        radius: 8

                        MouseArea {
                            id: tempUpMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.colorTemperature = Math.min(6000, root.colorTemperature + 300)
                                nightlightSetTemperatureProcess.running = true
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

        
        // Power Profiles Section
        Rectangle {
            width: parent.width
            height: 86
            color: Qt.rgba(1, 1, 1, 0.07)
            radius: 12
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.10)
            
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
                                root.powerProfile = "power-saver"
                                powerProfileSetProcess.command = ["sh", "-c", "dbus-send --system --print-reply --dest=net.hadess.PowerProfiles /net/hadess/PowerProfiles org.freedesktop.DBus.Properties.Set string:'net.hadess.PowerProfiles' string:'ActiveProfile' variant:string:power-saver"]
                                powerProfileSetProcess.running = true
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
                                root.powerProfile = "balanced"
                                powerProfileSetProcess.command = ["sh", "-c", "dbus-send --system --print-reply --dest=net.hadess.PowerProfiles /net/hadess/PowerProfiles org.freedesktop.DBus.Properties.Set string:'net.hadess.PowerProfiles' string:'ActiveProfile' variant:string:balanced"]
                                powerProfileSetProcess.running = true
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
                                root.powerProfile = "performance"
                                powerProfileSetProcess.command = ["sh", "-c", "dbus-send --system --print-reply --dest=net.hadess.PowerProfiles /net/hadess/PowerProfiles org.freedesktop.DBus.Properties.Set string:'net.hadess.PowerProfiles' string:'ActiveProfile' variant:string:performance"]
                                powerProfileSetProcess.running = true
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
                root.volume = Math.min(100, root.volume + 5)
                volumeUpdateTimer.restart()
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
                root.volume = Math.max(0, root.volume - 5)
                volumeUpdateTimer.restart()
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
                root.muted = !root.muted
                volumeUpdateTimer.restart()
            }
        }
    }

    // Delay timer for volume updates after button clicks
    Timer {
        id: volumeUpdateTimer
        interval: 50
        repeat: false
        onTriggered: updateVolume()
    }
    
    // Update functions
    Timer {
        interval: 1000
        running: root.isVisible
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            console.log("ControlCenter Timer triggered - isVisible:", root.isVisible)
            updateVolume()
            updateBattery()
            updateNetwork()
            updateBluetooth()
            updateBrightness()
            updatePowerProfile()
        }
    }
    
    function updateVolume() {
        volumeLevelProcess.running = true
    }
    
    Process {
        id: volumeLevelProcess
        command: ["sh", "-c", "pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\\d+%' | head -1 | tr -d '%'"]
        running: false
        
        stdout: SplitParser {
            onRead: data => {
                root.volume = parseInt(data.trim()) || 0
            }
        }
        
        onExited: {
            // After getting volume, check mute status
            volumeMuteStatusProcess.running = true
        }
    }
    
    Process {
        id: volumeMuteStatusProcess
        command: ["sh", "-c", "pactl get-sink-mute @DEFAULT_SINK@ | grep -q yes && echo 1 || echo 0"]
        running: false
        
        stdout: SplitParser {
            onRead: data => {
                root.muted = (data.trim() === "1")
            }
        }
    }
    
    function updateBattery() {
        console.log("ControlCenter updateBattery called")
        batteryCheckProcess.running = true
    }
    
    Process {
        id: batteryCheckProcess
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
        
        property string buffer: ""
        
        stdout: SplitParser {
            onRead: data => { batteryCheckProcess.buffer += data }
        }
        
        onRunningChanged: {
            if (!running && buffer !== "") {
                let parts = buffer.trim().split('|')
                console.log("ControlCenter battery check:", parts.length, "parts:", JSON.stringify(parts))
                if (parts.length >= 3) {
                    root.batteryLevel = parseInt(parts[0]) || 100
                    root.charging = parts[1].includes("Charging")
                    root.acOnline = parts[2] === "1"
                    console.log("ControlCenter battery - Level:", root.batteryLevel, "Charging:", root.charging, "AC:", root.acOnline)
                    
                    // Calculate time remaining/until full
                    if (root.charging || !root.acOnline) {
                        batteryTimeProcess.running = true
                    } else if (root.acOnline && root.batteryLevel >= 99) {
                        root.batteryTimeRemaining = "Fully charged"
                    } else {
                        root.batteryTimeRemaining = ""
                    }
                }
                buffer = ""
            } else if (running) {
                buffer = ""
            }
        }
    }
    
    Process {
        id: batteryTimeProcess
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
                            echo "${TIME_H}h ${TIME_M}m until fully charged"
                        elif echo "$STATUS" | grep -q "Discharging"; then
                            TIME_H=$(( $CHARGE / $CURRENT ))
                            TIME_M=$(( ($CHARGE * 60 / $CURRENT) % 60 ))
                            echo "${TIME_H}h ${TIME_M}m remaining"
                        fi
                    fi
                fi
            fi
        `]
        running: false
        
        property string buffer: ""
        
        stdout: SplitParser {
            onRead: data => { batteryTimeProcess.buffer += data }
        }
        
        onRunningChanged: {
            if (!running && buffer !== "") {
                root.batteryTimeRemaining = buffer.trim()
                console.log("ControlCenter battery time:", root.batteryTimeRemaining)
                buffer = ""
            } else if (running) {
                buffer = ""
            }
        }
    }
    
    function updateNetwork() {
        networkCheckProcess.running = true
    }
    
    Process {
        id: networkCheckProcess
        running: false
        command: ["sh", "-c", "nmcli -t -f TYPE,STATE,DEVICE,NAME connection show --active | head -1"]
        
        property string buffer: ""
        
        stdout: SplitParser {
            onRead: data => { networkCheckProcess.buffer += data }
        }
        
        onRunningChanged: {
            if (!running && buffer !== "") {
                let line = buffer.trim()
                if (line) {
                    let parts = line.split(':')
                    if (parts.length >= 4) {
                        root.networkType = parts[0].includes("wireless") || parts[0].includes("wifi") ? "wifi" : "ethernet"
                        root.networkName = parts[3] || "Connected"
                        
                        if (root.networkType === "wifi") {
                            signalCheckProcess.running = true
                        }
                    }
                }
                buffer = ""
            } else if (running) {
                buffer = ""
            }
        }
    }
    
    Process {
        id: signalCheckProcess
        running: false
        command: ["sh", "-c", "nmcli -t -f IN-USE,SIGNAL dev wifi | grep '^\\*' | cut -d':' -f2"]
        
        property string buffer: ""
        
        stdout: SplitParser {
            onRead: data => { signalCheckProcess.buffer += data }
        }
        
        onRunningChanged: {
            if (!running && buffer !== "") {
                root.signalStrength = parseInt(buffer.trim()) || 100
                buffer = ""
            } else if (running) {
                buffer = ""
            }
        }
    }
    
    Process {
        id: trafficProcess
        command: ["sh", "-c", `
            interface=$(ip route | grep default | awk '{print $5}' | head -1)
            if [ -n "$interface" ]; then
                rx=$(cat /sys/class/net/$interface/statistics/rx_bytes 2>/dev/null || echo 0)
                tx=$(cat /sys/class/net/$interface/statistics/tx_bytes 2>/dev/null || echo 0)
                echo "$rx $tx"
            else
                echo "0 0"
            fi
        `]
        running: false
        
        stdout: SplitParser {
            onRead: data => {
                var parts = data.trim().split(" ")
                if (parts.length >= 2) {
                    var rxBytes = parseFloat(parts[0])
                    var txBytes = parseFloat(parts[1])
                    var currentTime = Date.now()
                    
                    if (root.lastTrafficCheck > 0) {
                        var timeDiff = (currentTime - root.lastTrafficCheck) / 1000.0  // seconds
                        if (timeDiff > 0) {
                            // Calculate speeds in KB/s
                            var rxDiff = (rxBytes - root.lastRxBytes) / 1024.0
                            var txDiff = (txBytes - root.lastTxBytes) / 1024.0
                            
                            root.downloadSpeed = rxDiff / timeDiff
                            root.uploadSpeed = txDiff / timeDiff
                            
                            // Format as KB/s or MB/s
                            if (root.downloadSpeed >= 1024) {
                                root.downloadRate = (root.downloadSpeed / 1024).toFixed(1) + " MB/s"
                            } else {
                                root.downloadRate = Math.round(root.downloadSpeed) + " KB/s"
                            }
                            
                            if (root.uploadSpeed >= 1024) {
                                root.uploadRate = (root.uploadSpeed / 1024).toFixed(1) + " MB/s"
                            } else {
                                root.uploadRate = Math.round(root.uploadSpeed) + " KB/s"
                            }
                        }
                    }
                    
                    root.lastRxBytes = rxBytes
                    root.lastTxBytes = txBytes
                    root.lastTrafficCheck = currentTime
                }
            }
        }
    }
    
    Timer {
        id: trafficTimer
        interval: 2000  // Update traffic every 2 seconds
        running: root.isVisible
        repeat: true
        triggeredOnStart: true
        
        onTriggered: {
            trafficProcess.running = true
        }
    }
    
    // Wi-Fi toggle processes
    Process {
        id: wifiEnableProcess
        running: false
        command: ["sh", "-c", "wlctl wifi on"]
        onRunningChanged: if (!running) Qt.callLater(updateNetwork)
    }

    Process {
        id: wifiDisableProcess
        running: false
        command: ["sh", "-c", "wlctl wifi off"]
        onRunningChanged: if (!running) Qt.callLater(updateNetwork)
    }
    
    // Bluetooth functions
    function updateBluetooth() {
        bluetoothStatusProcess.running = true
    }
    
    Process {
        id: bluetoothStatusProcess
        running: false
        command: ["sh", "-c", "rfkill list bluetooth | grep 'Soft blocked:' | head -n1 | awk '{print $3}'"]
        
        property string buffer: ""
        
        stdout: SplitParser {
            onRead: data => { bluetoothStatusProcess.buffer += data }
        }
        
        onRunningChanged: {
            if (!running && buffer !== "") {
                // rfkill returns "no" when NOT blocked (i.e., when enabled)
                root.bluetoothEnabled = buffer.trim() === "no"
                buffer = ""
                
                // If bluetooth is on, get connected devices
                if (root.bluetoothEnabled) {
                    bluetoothDevicesProcess.running = true
                } else {
                    root.bluetoothDevices = []
                }
            } else if (running) {
                buffer = ""
            }
        }
    }
    
    Process {
        id: bluetoothDevicesProcess
        running: false
        command: ["sh", "-c", "bluetoothctl devices Connected | awk '{$1=$2=\"\"; print substr($0,3)}'"]
        
        property string buffer: ""
        
        stdout: SplitParser {
            onRead: data => { bluetoothDevicesProcess.buffer += data }
        }
        
        onRunningChanged: {
            if (!running && buffer !== "") {
                let lines = buffer.trim().split('\n').filter(line => line.length > 0)
                root.bluetoothDevices = lines
                buffer = ""
            } else if (running) {
                buffer = ""
            }
        }
    }
    
    Process {
        id: bluetoothEnableProcess
        running: false
        command: ["sh", "-c", "bluetui power on"]
        onRunningChanged: if (!running) Qt.callLater(updateBluetooth)
    }

    Process {
        id: bluetoothDisableProcess
        running: false
        command: ["sh", "-c", "bluetui power off"]
        onRunningChanged: if (!running) Qt.callLater(updateBluetooth)
    }
    
    // Brightness functions
    function updateBrightness() {
        brightnessLevelProcess.running = true
    }
    
    Process {
        id: brightnessLevelProcess
        running: false
        command: ["sh", "-c", "brightnessctl -m | cut -d',' -f4 | tr -d '%'"]
        
        stdout: SplitParser {
            onRead: data => {
                root.brightness = parseInt(data.trim()) || 50
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
                root.brightness = Math.min(100, root.brightness + 5)
                brightnessUpdateTimer.restart()
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
                root.brightness = Math.max(0, root.brightness - 5)
                brightnessUpdateTimer.restart()
            }
        }
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
        command: ["sh", "-c", `wlsunset -t ${root.colorTemperature} -T ${root.colorTemperature} &`]
        onRunningChanged: {
            if (!running) {
                root.nightlightEnabled = true
            }
        }
    }

    Process {
        id: nightlightDisableProcess
        running: false
        command: ["sh", "-c", "killall wlsunset 2>/dev/null || true"]
        onRunningChanged: {
            if (!running) {
                root.nightlightEnabled = false
            }
        }
    }

    Process {
        id: nightlightSetTemperatureProcess
        running: false
        command: ["sh", "-c", `killall wlsunset 2>/dev/null; sleep 0.1; wlsunset -t ${root.colorTemperature} -T ${root.colorTemperature} &`]
        onRunningChanged: {
            console.log("nightlightSetTemperatureProcess running:", running, "temp:", root.colorTemperature)
        }
    }

    // Power Profile functions
    function updatePowerProfile() {
        powerProfileCheckProcess.running = true
    }

    Process {
        id: powerProfileCheckProcess
        running: false
        command: ["sh", "-c", "dbus-send --system --print-reply --dest=net.hadess.PowerProfiles /net/hadess/PowerProfiles org.freedesktop.DBus.Properties.Get string:'net.hadess.PowerProfiles' string:'ActiveProfile' 2>/dev/null | grep variant | awk '{print $3}' | tr -d '\"'"]
        
        stdout: SplitParser {
            onRead: data => {
                let p = data.trim();
                if (p === "power-saver" || p === "balanced" || p === "performance") {
                    root.powerProfile = p;
                }
            }
        }
    }

    Process {
        id: powerProfileSetProcess
        running: false
        command: [] // Set dynamically
    }

    // Top specular highlight
    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 120
        radius: 16
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.07) }
            GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.0) }
        }
        z: 10
    }

    // Bottom fade
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 80
        radius: 16
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.0) }
            GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.12) }
        }
        z: 10
    }
}
