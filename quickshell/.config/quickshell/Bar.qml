import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

Item {
    id: bar

    property string backgroundStyle: "transparent" // "opaque", "translucent", or "transparent"
    property bool enableBlur: false
    property string position: "top" // "top" or "bottom"
    property real barOpacity: 0.7 // Dynamic opacity value from settings
    property bool showBorder: false
    property bool floating: true
    property alias clockComponent: clockComponent
    property alias archComponent: archComponent
    property alias powerComponent: powerComponent
    property alias focusTimeButtonComponent: quickAccessDrawer.focusTimeButtonComponent

    signal toggleClipboard()
    signal toggleControlCenter()

    // Delayed initial settings load
    Component.onCompleted: {
        // Wait 500ms before starting settings polling
        Qt.callLater(() => {
            barSettingsLoader.running = true;
        });
    }

    // Load bar settings
    Process {
        id: barSettingsLoader

        property string buffer: ""

        running: false
        command: ["cat", Quickshell.env("HOME") + "/.config/quickshell/settings.json"]
        onRunningChanged: {
            if (!running && buffer !== "") {
                try {
                    const settings = JSON.parse(buffer);
                    if (settings.bar) {
                        if (settings.bar.backgroundStyle !== undefined)
                            bar.backgroundStyle = settings.bar.backgroundStyle;

                        if (settings.bar.position !== undefined)
                            bar.position = settings.bar.position;

                        if (settings.bar.barOpacity !== undefined)
                            bar.barOpacity = settings.bar.barOpacity;

                        if (settings.bar.showBorder !== undefined)
                            bar.showBorder = settings.bar.showBorder;

                        if (settings.bar.floating !== undefined)
                            bar.floating = settings.bar.floating;

                    }
                    if (settings.general && settings.general.enableBlur !== undefined)
                        bar.enableBlur = settings.general.enableBlur;

                } catch (e) {
                    console.log("🎨 Error parsing bar settings:", e);
                }
                buffer = "";
            } else if (running) {
                buffer = "";
            }
        }

        stdout: SplitParser {
            onRead: (data) => {
                barSettingsLoader.buffer += data;
            }
        }

    }

    Connections {
        target: shellRoot
        function onConfigVersionChanged() {
            barSettingsLoader.running = true;
        }
    }


    // Background shape – flat top, rounded bottom corners
    Shape {
        id: background

        readonly property real cornerRadius: 10
        readonly property color bgColor: {
            if (bar.backgroundStyle === "transparent")
                return "transparent";

            if (bar.backgroundStyle === "opaque")
                return ThemeManager.bgBase;

            return Qt.rgba(ThemeManager.bgBase.r, ThemeManager.bgBase.g, ThemeManager.bgBase.b, bar.barOpacity);
        }

        anchors.fill: parent
        z: -1

        ShapePath {
            fillColor: background.bgColor
            strokeColor: bar.showBorder ? Qt.rgba(ThemeManager.accentBlue.r, ThemeManager.accentBlue.g, ThemeManager.accentBlue.b, 0.35) : "transparent"
            strokeWidth: bar.showBorder ? 1 : 0
            // Top-left (sharp)
            startX: 0
            startY: 0

            // Top edge → top-right (sharp)
            PathLine {
                x: background.width
                y: 0
            }

            // Right edge down to bottom-right curve start
            PathLine {
                x: background.width
                y: background.height - background.cornerRadius
            }

            // Bottom-right rounded corner
            PathArc {
                x: background.width - background.cornerRadius
                y: background.height
                radiusX: background.cornerRadius
                radiusY: background.cornerRadius
                direction: PathArc.Clockwise
            }

            // Bottom edge
            PathLine {
                x: background.cornerRadius
                y: background.height
            }

            // Bottom-left rounded corner
            PathArc {
                x: 0
                y: background.height - background.cornerRadius
                radiusX: background.cornerRadius
                radiusY: background.cornerRadius
                direction: PathArc.Clockwise
            }

            // Left edge back to top-left
            PathLine {
                x: 0
                y: 0
            }

        }

    }

    // LEFT SECTION
    RowLayout {
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8

        ArchButton {
            id: archComponent
        }

        WorkspaceBar {
        }

        Separator {
        }

        QuickAccessDrawer {
            id: quickAccessDrawer
        }

    }

    // CENTER SECTION - Absolutely centered
    Clock {
        id: clockComponent

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
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

            RamIndicator {
                id: ramIndicator

                anchors.verticalCenter: parent.verticalCenter
            }

            TrayDrawer {
                id: trayDrawerComponent

                onToggleClipboard: bar.toggleClipboard()
                onToggleControlCenter: bar.toggleControlCenter()
            }

            PowerButton {
                id: powerComponent

                anchors.verticalCenter: parent.verticalCenter
            }

        }

    }

}
