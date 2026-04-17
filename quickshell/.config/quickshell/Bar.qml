import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import QtQuick.Effects

Item {
    id: bar

    property string backgroundStyle: "translucent"  // "opaque", "translucent", or "transparent"
    property bool enableBlur: false
    property string position: "top"  // "top" or "bottom"
    property real barOpacity: 0.70  // Dynamic opacity value from settings
    property bool showBorder: false
    property bool floating: true

    signal toggleClipboard()
    signal toggleControlCenter()

    // Load bar settings
    Process {
        id: barSettingsLoader
        running: false
        command: ["cat", Quickshell.env("HOME") + "/.config/quickshell/settings.json"]

        property string buffer: ""

        stdout: SplitParser {
            onRead: data => {
                barSettingsLoader.buffer += data
            }
        }

        onRunningChanged: {
            if (!running && buffer !== "") {
                try {
                    const settings = JSON.parse(buffer)
                    if (settings.bar) {
                        if (settings.bar.backgroundStyle !== undefined) {
                            bar.backgroundStyle = settings.bar.backgroundStyle
                        }
                        if (settings.bar.position !== undefined) {
                            bar.position = settings.bar.position
                        }
                        if (settings.bar.barOpacity !== undefined) {
                            bar.barOpacity = settings.bar.barOpacity
                        }
                        if (settings.bar.showBorder !== undefined) {
                            bar.showBorder = settings.bar.showBorder
                        }
                        if (settings.bar.floating !== undefined) {
                            bar.floating = settings.bar.floating
                        }
                    }
                    if (settings.general && settings.general.enableBlur !== undefined) {
                        bar.enableBlur = settings.general.enableBlur
                    }
                } catch (e) {
                    console.log("🎨 Error parsing bar settings:", e)
                }
                buffer = ""
            } else if (running) {
                buffer = ""
            }
        }
    }

    // Auto-reload settings every second - delayed start for performance
    Timer {
        id: barSettingsTimer
        interval: 1000
        running: false  // Don't start immediately
        repeat: true
        onTriggered: {
            barSettingsLoader.running = true
        }
    }

    // Delayed initial settings load
    Component.onCompleted: {
        // Wait 500ms before starting settings polling
        Qt.callLater(() => {
            barSettingsLoader.running = true
            barSettingsTimer.running = true
        })
    }

    // Background rectangle – glass style with floating appearance
    Rectangle {
        id: background
        anchors.fill: parent
        color: {
            if (bar.backgroundStyle === "transparent") return "transparent"
            if (bar.backgroundStyle === "opaque") return ThemeManager.bgBase
            return Qt.rgba(ThemeManager.bgBase.r, ThemeManager.bgBase.g, ThemeManager.bgBase.b, bar.barOpacity)
        }
        radius: 16
        border.width: bar.showBorder ? 1 : 0
        border.color: Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.35)
        z: -1

        Behavior on radius { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        Behavior on border.width { NumberAnimation { duration: 150 } }

        // Top specular highlight
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 1
            height: 1
            color: Qt.rgba(1, 1, 1, 0.10)
            visible: !bar.showBorder
            radius: 16
        }
    }

    property alias clockComponent: clockComponent
    property alias archComponent: archComponent
    property alias powerComponent: powerComponent
    property alias focusTimeButtonComponent: focusTimeButtonComponent

    // LEFT SECTION
    RowLayout {
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8

        ArchButton {
            id: archComponent
        }
        WorkspaceBar {}
        Separator {}
        QuickAccessDrawer {
            id: quickAccessDrawer
        }
    }

    // CENTER SECTION - Absolutely centered
    Rectangle {
        id: clockContainer
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        width: 85
        height: 35
        radius: 12
        color: Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.15)
        border.width: 1
        border.color: Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.35)

        Clock {
            id: clockComponent
            anchors.centerIn: parent
        }
    }



    // RIGHT SECTION
    Item {
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height
        width: rightRow.width

        Row {
            id: rightRow
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8

            // FocusTimeButton bubble
            Rectangle {
                width: focusTimeContent.width + 12
                height: 35
                radius: 12
                color: Qt.rgba(ThemeManager.accentPurple.r, ThemeManager.accentPurple.g, ThemeManager.accentPurple.b, 0.15)
                border.width: 1
                border.color: Qt.rgba(ThemeManager.accentPurple.r, ThemeManager.accentPurple.g, ThemeManager.accentPurple.b, 0.35)
                anchors.verticalCenter: parent.verticalCenter

                Item {
                    id: focusTimeContent
                    anchors.centerIn: parent
                    width: focusTimeButtonComponent.width
                    height: 35

                    FocusTimeButton {
                        id: focusTimeButtonComponent
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            // RamIndicator bubble
            Rectangle {
                width: ramContent.width + 12
                height: 35
                radius: 12
                color: Qt.rgba(ThemeManager.accentTeal.r, ThemeManager.accentTeal.g, ThemeManager.accentTeal.b, 0.15)
                border.width: 1
                border.color: Qt.rgba(ThemeManager.accentTeal.r, ThemeManager.accentTeal.g, ThemeManager.accentTeal.b, 0.35)
                anchors.verticalCenter: parent.verticalCenter

                Item {
                    id: ramContent
                    anchors.centerIn: parent
                    width: ramIndicator.width
                    height: 35

                    RamIndicator {
                        id: ramIndicator
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            TrayDrawer {
                id: trayDrawerComponent
                onToggleClipboard: bar.toggleClipboard()
                onToggleControlCenter: bar.toggleControlCenter()
            }

            // PowerButton bubble
            Rectangle {
                width: powerContent.width + 12
                height: 35
                radius: 12
                color: Qt.rgba(ThemeManager.accentRed.r, ThemeManager.accentRed.g, ThemeManager.accentRed.b, 0.15)
                border.width: 1
                border.color: Qt.rgba(ThemeManager.accentRed.r, ThemeManager.accentRed.g, ThemeManager.accentRed.b, 0.35)
                anchors.verticalCenter: parent.verticalCenter

                Item {
                    id: powerContent
                    anchors.centerIn: parent
                    width: powerComponent.width
                    height: 35

                    PowerButton {
                        id: powerComponent
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
    }
}
