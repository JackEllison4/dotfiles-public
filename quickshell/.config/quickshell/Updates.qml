import QtQuick
import Quickshell
import Quickshell.Io

Rectangle {
    id: updatesArea
    
    property int updateCount: 0
    property var lastCheckTime: new Date()
    
    width: contentRect.width + 20
    height: 35
    
    color: "transparent"
    
    Component.onCompleted: {
        // Lazy loading: Delay first update check by 10 seconds
        initialDelayTimer.start()
    }
    
    // Startup delay timer - wait 10 seconds before first update check
    Timer {
        id: initialDelayTimer
        interval: 10000  // 10 seconds
        running: false
        repeat: false
        onTriggered: {
            updateCheckProcess.running = true
            lastCheckTime = new Date()
            // Start the regular update timer
            updateTimer.running = true
        }
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onClicked: {
            // Use direct script execution instead of shell concatenation
            // Script will handle package manager selection
            try {
                Quickshell.execDetached([
                    "kitty",
                    "-e",
                    Quickshell.env("HOME") + "/.config/quickshell/scripts/run-updates.sh"
                ])
            } catch (error) {
                console.error("Failed to launch updater:", error)
            }

            // Trigger a recheck after a short delay (user might close terminal)
            recheckTimer.start()
        }
        
        Rectangle {
            id: contentRect
            anchors.centerIn: parent
            width: 60  // Wider for icon + number
            height: 32
            
            color: mouseArea.containsMouse ? Qt.rgba(1, 1, 1, 0.10) : "transparent"
            radius: 6
            border.width: mouseArea.containsMouse ? 1 : 0
            border.color: Qt.rgba(1, 1, 1, 0.18)

        Behavior on color {
            ColorAnimation { duration: 200 }
        }
        Behavior on border.width {
            NumberAnimation { duration: 200 }
        }
        
        Row {
            id: updatesText
            anchors.centerIn: parent
            spacing: 6
            
            Text {
                text: "󰚰"
                font.family: "Symbols Nerd Font"
                font.pixelSize: 16
                color: updatesArea.updateCount > 0 ? ThemeManager.accentYellow : ThemeManager.accentBlue
                anchors.verticalCenter: parent.verticalCenter
                
                Behavior on color {
                    ColorAnimation { duration: 300 }
                }
            }
            
            Text {
                text: updatesArea.updateCount.toString()
                font.family: "Sen"
                font.pixelSize: 13
                color: updatesArea.updateCount > 0 ? ThemeManager.accentYellow : ThemeManager.accentBlue
                anchors.verticalCenter: parent.verticalCenter
                
                Behavior on color {
                    ColorAnimation { duration: 300 }
                }
            }
        }
        }
    }
    
    Process {
        id: updateCheckProcess
        // Use dedicated script that checks both official repos and AUR
        command: [Quickshell.env("HOME") + "/.config/quickshell/scripts/check-updates.sh"]
        running: false
        
        stdout: SplitParser {
            onRead: data => {
                let count = parseInt(data.trim()) || 0
                updatesArea.updateCount = count
            }
        }
        
        onStarted: {
        }

        onExited: (exitCode, exitStatus) => {
            // Restart the check if it failed (might be network issue)
            if (exitCode !== 0 && !updateTimer.running) {
                // Don't spam retries, just wait for next timer interval
            }
        }
    }
    
    Timer {
        id: updateTimer
        interval: 3600000  // 1 hour
        running: false  // Don't start until after initial delay
        repeat: true
        triggeredOnStart: false
        
        onTriggered: {
            lastCheckTime = new Date()
            updateCheckProcess.running = true
        }
    }
    
    // Signal based wake-from-sleep detection - much more efficient than a timer
    Process {
        id: wakeWatcher
        running: true
        command: ["gdbus", "monitor", "--system", "--dest", "org.freedesktop.login1", "--object-path", "/org/freedesktop/login1"]
        stdout: SplitParser {
            onRead: line => {
                if (line.includes("PrepareForSleep") && line.includes("false")) {
                    console.log("System resumed from sleep - triggering update check")
                    lastCheckTime = new Date()
                    updateCheckProcess.running = true
                }
            }
        }
    }

    
    // Recheck after manual update installation
    Timer {
        id: recheckTimer
        interval: 10000  // 10 seconds after launching updater (gives time to close)
        running: false
        repeat: true  // Keep checking periodically
        
        property int checkCount: 0
        property int maxChecks: 30  // Check for up to 5 minutes (30 * 10 seconds)
        
        onTriggered: {
            checkCount++
            lastCheckTime = new Date()
            updateCheckProcess.running = true

            // Stop checking after maxChecks attempts or if no updates remain
            if (checkCount >= maxChecks || updatesArea.updateCount === 0) {
                running = false
                checkCount = 0
            }
        }
        
        onRunningChanged: {
            if (running) {
                checkCount = 0
            }
        }
    }
}
