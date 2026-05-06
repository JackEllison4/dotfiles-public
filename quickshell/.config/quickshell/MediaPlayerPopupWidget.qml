import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Io

Item {
    id: root
    
    signal requestClose()
    
    implicitWidth: 480
    implicitHeight: backgroundRect.height
    width: parent ? parent.width : implicitWidth
    height: implicitHeight

    property string mStatus: ""
    property string mTitle: ""
    property string mArtist: ""
    property real mLength: 0
    property string mArtUrl: ""
    property real mPosition: 0
    property bool isActive: mTitle !== ""
    property bool hasMedia: isActive

    // Format microseconds or seconds to m:ss
    function formatTime(val) {
        if (!val || isNaN(val)) return "0:00";
        var seconds = 0;
        if (val > 1000000) {
            seconds = Math.floor(val / 1000000); 
        } else {
            seconds = Math.floor(val);
        }
        var m = Math.floor(seconds / 60);
        var s = Math.floor(seconds % 60);
        return m + ":" + (s < 10 ? "0" : "") + s;
    }

    // --- Event-driven metadata updates ---
    Process {
        id: metaFollowProcess
        running: true
        // This command waits for changes and outputs them immediately
        command: ["playerctl", "metadata", "--follow", "-f", "{{status}}||{{title}}||{{artist}}||{{mpris:length}}||{{mpris:artUrl}}||{{position}}"]
        
        stdout: SplitParser {
            onRead: line => {
                var parts = line.trim().split("||");
                if (parts.length >= 6) {
                    // Update all metadata instantly
                    root.mStatus = parts[0];
                    root.mTitle = parts[1];
                    root.mArtist = parts[2] || "Unknown Artist";
                    root.mLength = Number(parts[3]) || 0;
                    root.mArtUrl = parts[4] || "";
                    
                    // Sync position from player
                    var playerPos = Number(parts[5]) * 1000000;
                    // Only update if drift is significant (> 2s) to avoid jumping
                    if (Math.abs(root.mPosition - playerPos) > 2000000 || root.mStatus !== "Playing") {
                        root.mPosition = playerPos;
                    }
                } else {
                    root.mStatus = "";
                    root.mTitle = "";
                }
            }
        }
    }

    // Local position timer - only runs when music is playing
    // This provides a smooth slider without constant process spawning
    Timer {
        id: positionTimer
        interval: 1000
        running: root.mStatus === "Playing"
        repeat: true
        onTriggered: {
            if (root.mPosition < root.mLength) {
                root.mPosition += 1000000;
            }
        }
    }

    // Main Container
    Rectangle {
        id: backgroundRect
        width: parent.width
        height: root.isActive ? playersColumn.implicitHeight + 32 : 0 
        visible: root.isActive
        
        color: Qt.rgba(0.18, 0.18, 0.19, 0.98) 
        radius: 20
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.08)

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowOpacity: 0.15
            shadowBlur: 16
            shadowColor: "#000000"
            shadowVerticalOffset: 6
        }

        ColumnLayout {
            id: playersColumn
            anchors.centerIn: parent
            width: parent.width - 32
            spacing: 0
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 16
                
                // Art Container
                Item {
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 100
                    Layout.alignment: Qt.AlignVCenter
                    
                    Rectangle {
                        anchors.fill: parent
                        radius: 12
                        color: Qt.rgba(1, 1, 1, 0.05)
                        border.width: 1
                        border.color: Qt.rgba(1, 1, 1, 0.1)
                        
                        Text {
                            anchors.centerIn: parent
                            text: "󰎆" 
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 40
                            color: Qt.rgba(1, 1, 1, 0.3)
                        }
                    }
                    
                    Image {
                        id: artImage
                        anchors.fill: parent
                        // Only allow safe URL schemes
                        source: {
                            if (!root.mArtUrl) return ""
                            const url = String(root.mArtUrl)
                            // Only allow http, https, or file schemes
                            if (url.startsWith("http://") || url.startsWith("https://") || url.startsWith("file://")) {
                                return url
                            }
                            return ""  // Reject any other scheme or path
                        }
                        fillMode: Image.PreserveAspectCrop
                        visible: root.mArtUrl !== ""
                        
                        layer.enabled: true
                        layer.effect: MultiEffect {
                            maskEnabled: true
                            maskSource: ShaderEffectSource {
                                sourceItem: Rectangle {
                                    width: artImage.width
                                    height: artImage.height
                                    radius: 12
                                }
                            }
                        }
                    }
                }
                
                // Controls and Info
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 0
                    
                    Item { Layout.fillHeight: true } 
                    
                    // App Name / Source
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        
                        Text {
                            text: "󰎆"
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 12
                            color: ThemeManager.accentPurple
                        }
                        
                        Text {
                            text: "Media Player"
                            font.family: "Sen"
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            color: ThemeManager.accentPurple
                        }
                    }
                    
                    Item { Layout.preferredHeight: 8 }
                    
                    // Title & Artist
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        
                        Text {
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                            text: root.mTitle || "No Media Playing"
                            font.family: "Sen"
                            font.weight: Font.Bold
                            font.pixelSize: 18
                            color: "#FFFFFF"
                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }
                        
                        Text {
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                            text: root.mArtist || "Unknown Artist"
                            font.family: "Sen"
                            font.pixelSize: 14
                            color: Qt.rgba(1, 1, 1, 0.7)
                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }
                        
                        Item { Layout.preferredHeight: 12 }
                        
                        // Scrubber
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 6
                            
                            property real progressAmt: root.mLength > 0 ? (root.mPosition / root.mLength) : 0
                            
                            Rectangle {
                                Layout.fillWidth: true
                                height: 4
                                radius: 2
                                color: Qt.rgba(1, 1, 1, 0.2)
                                
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: function(mouse) {
                                        if (root.mLength > 0) {
                                            var targetPos = (mouse.x / width) * root.mLength;
                                            Quickshell.execDetached(["playerctl", "position", String(targetPos / 1000000)]);
                                        }
                                    }
                                }
                                
                                Rectangle {
                                    width: parent.width * Math.max(0, Math.min(1, parent.parent.progressAmt))
                                    height: parent.height
                                    radius: 2
                                    color: "#FFFFFF"
                                    
                                    Rectangle {
                                        width: 10
                                        height: 10
                                        radius: 5
                                        color: "white"
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }
                        }
                        
                        Item { Layout.preferredHeight: 10 }
                            
                        // Hardware Controls
                        RowLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 8
                            
                            Item { Layout.fillWidth: true }
                            
                            Text {
                                text: root.formatTime(root.mPosition)
                                font.family: "JetBrains Mono"
                                font.pixelSize: 11
                                color: Qt.rgba(1, 1, 1, 0.5)
                                Layout.alignment: Qt.AlignVCenter
                            }
                            
                            Rectangle {
                                Layout.preferredWidth: 36
                                Layout.preferredHeight: 36
                                radius: 18
                                color: prevMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.1) : "transparent"
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: "󰒮" 
                                    font.family: "Symbols Nerd Font"
                                    font.pixelSize: 18
                                    color: "#FFFFFF"
                                }
                                
                                MouseArea {
                                    id: prevMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: Quickshell.execDetached(["playerctl", "previous"])
                                }
                            }
                            
                            Rectangle {
                                Layout.preferredWidth: 46
                                Layout.preferredHeight: 46
                                radius: 23
                                color: playMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.2) : Qt.rgba(1, 1, 1, 0.1)
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: root.mStatus === "Playing" ? "󰏤" : "󰐊" 
                                    font.family: "Symbols Nerd Font"
                                    font.pixelSize: 22
                                    color: "#FFFFFF"
                                    anchors.horizontalCenterOffset: text === "󰐊" ? 2 : 0
                                }
                                
                                MouseArea {
                                    id: playMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: Quickshell.execDetached(["playerctl", "play-pause"])
                                }
                            }
                            
                            Rectangle {
                                Layout.preferredWidth: 36
                                Layout.preferredHeight: 36
                                radius: 18
                                color: nextMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.1) : "transparent"
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: "󰒭"
                                    font.family: "Symbols Nerd Font"
                                    font.pixelSize: 18
                                    color: "#FFFFFF"
                                }
                                
                                MouseArea {
                                    id: nextMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: Quickshell.execDetached(["playerctl", "next"])
                                }
                            }
                            
                            Text {
                                text: root.formatTime(root.mLength)
                                font.family: "JetBrains Mono"
                                font.pixelSize: 11
                                color: Qt.rgba(1, 1, 1, 0.5)
                                Layout.alignment: Qt.AlignVCenter
                            }
                            
                            Item { Layout.fillWidth: true } 
                        }
                    }
                    
                    Item { Layout.fillHeight: true }
                }
            }
        }
    }
}
