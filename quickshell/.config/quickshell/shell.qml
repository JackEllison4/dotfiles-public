import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "focustime"

ShellRoot {
    id: shellRoot
    
    property bool calendarVisible: false
    property bool appLauncherVisible: false
    property bool notificationsVisible: false
    property bool powerMenuVisible: false
    property bool themeSwitcherVisible: false
    property bool screenshotVisible: false
    property bool clipboardVisible: false
    property bool controlCenterVisible: false
    property bool focustimeVisible: false
    property bool isAnyFullscreen: false
    property var wallpaperPicker: wallpaperPickerWindow
    
    // Make shellRoot globally accessible via objectName
    objectName: "shellRoot"
    
    // Public toggle functions for IPC
    function toggleAppLauncher() {
        console.log("IPC: Toggling app launcher")
        shellRoot.appLauncherVisible = !shellRoot.appLauncherVisible
    }
    
    function toggleCalendar() {
        console.log("IPC: Toggling calendar")
        shellRoot.calendarVisible = !shellRoot.calendarVisible
    }
    
    function togglePowerMenu() {
        console.log("IPC: Toggling power menu")
        shellRoot.powerMenuVisible = !shellRoot.powerMenuVisible
    }
    
    function toggleThemeSwitcher() {
        console.log("IPC: Toggling theme switcher")
        shellRoot.themeSwitcherVisible = !shellRoot.themeSwitcherVisible
    }
    
    function toggleScreenshot() {
        console.log("IPC: Toggling screenshot widget")
        shellRoot.screenshotVisible = !shellRoot.screenshotVisible
    }

    function toggleClipboard() {
        console.log("IPC: Toggling clipboard")
        shellRoot.clipboardVisible = !shellRoot.clipboardVisible
    }
    
    function toggleControlCenter() {
        console.log("IPC: Toggling control center")
        shellRoot.controlCenterVisible = !shellRoot.controlCenterVisible
    }

    function toggleFocusTime() {
        console.log("IPC: Toggling focus time")
        shellRoot.focustimeVisible = !shellRoot.focustimeVisible
    }

    function takeScreenshot() {
        console.log("Taking screenshot via Print Screen")
        const scriptPath = Quickshell.env("HOME") + "/.config/quickshell/take-screenshot.sh"
        // Default: output mode, no delay, save to disk, copy to clipboard
        Quickshell.execDetached([scriptPath, "output", "0", "true", "true"])
    }

    // App launcher, wallpaper picker, etc. removed
    Connections {
        target: Quickshell
        function onReload() {
            console.log("Quickshell reloaded")
        }
    }

    // Consolidated IPC watcher - single process for all keybinds (efficient!)
    Process {
        id: consolidatedIpcWatcher
        running: true
        command: [Quickshell.env("HOME") + "/.config/quickshell/consolidated-ipc-watcher.sh"]
        
        stdout: SplitParser {
            onRead: line => {
                const parts = line.split(":")
                if (parts.length !== 2) return
                
                const component = parts[0]
                const action = parts[1]
                
                if (action === "toggle") {
                    switch (component) {
                        case "themeswitcher":
                            shellRoot.themeSwitcherVisible = !shellRoot.themeSwitcherVisible
                            console.log("Theme switcher toggled via keybind:", shellRoot.themeSwitcherVisible)
                            break
                        case "applauncher":
                            shellRoot.appLauncherVisible = !shellRoot.appLauncherVisible
                            console.log("App launcher toggled via keybind:", shellRoot.appLauncherVisible)
                            break
                        case "calendar":
                            shellRoot.calendarVisible = !shellRoot.calendarVisible
                            console.log("Calendar toggled via keybind:", shellRoot.calendarVisible)
                            break
                        case "powermenu":
                            shellRoot.powerMenuVisible = !shellRoot.powerMenuVisible
                            console.log("Power menu toggled via keybind:", shellRoot.powerMenuVisible)
                            break
                        case "screenshot":
                            shellRoot.screenshotVisible = !shellRoot.screenshotVisible
                            console.log("Screenshot widget toggled via keybind:", shellRoot.screenshotVisible)
                            break
                        case "clipboard":
                            shellRoot.clipboardVisible = !shellRoot.clipboardVisible
                            console.log("Clipboard toggled via keybind:", shellRoot.clipboardVisible)
                            break
                        case "focustime":
                            shellRoot.focustimeVisible = !shellRoot.focustimeVisible
                            console.log("Focus time toggled via keybind:", shellRoot.focustimeVisible)
                            break
                    }
                }
            }
        }
    }

    Process {
        id: focusDaemon
        running: true
        command: ["python3", Quickshell.env("HOME") + "/.config/quickshell/focustime/focus_daemon.py"]
    }

    // Fullscreen Watcher - hides bar when a window is fullscreen
    Process {
        id: fullscreenWatcher
        running: true
        command: [Quickshell.env("HOME") + "/.config/quickshell/fullscreen-watcher.sh"]
        stdout: SplitParser {
            onRead: data => {
                shellRoot.isAnyFullscreen = (data.trim() === "1")
                console.log("Fullscreen state changed:", shellRoot.isAnyFullscreen)
            }
        }
    }

    // Calendar popup - anchored below clock (center)
    Variants {
        model: Quickshell.screens
        
        PanelWindow {
            property var modelData
            screen: modelData
            
            visible: shellRoot.calendarVisible

            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }

            margins {
                top: 0
                left: 0
                right: 0
                bottom: 0
            }

            color: "transparent"
            exclusiveZone: 0

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

            // Escape key handler
            Shortcut {
                sequence: "Escape"
                onActivated: {
                    shellRoot.calendarVisible = false
                }
            }

            // Background overlay - click to close
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    console.log("Clicked outside calendar panel")
                    shellRoot.calendarVisible = false
                }
                propagateComposedEvents: false
            }
            
            // Panel positioned at top-center, slides down
            Item {
                anchors.fill: parent
                anchors.topMargin: shellRoot.calendarVisible ? 20 : -700

                Behavior on anchors.topMargin {
                    NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                }

                CalendarPopupWidget {
                    width: 1400
                    height: 800
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 20
                    opacity: shellRoot.calendarVisible ? 1 : 0

                    Behavior on opacity {
                        NumberAnimation { duration: 250 }
                    }
                }
            }
        }
    }
    
    // App Launcher popup - anchored below Arch button
    Variants {
        model: Quickshell.screens
        
        PanelWindow {
            property var modelData
            screen: modelData
            
            visible: shellRoot.appLauncherVisible

            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }

            margins {
                top: 0
                left: 0
                right: 0
                bottom: 0
            }

            color: "transparent"
            exclusiveZone: 0

            WlrLayershell.namespace: "quickshell-launcher"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

            // Background overlay - click to close
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    console.log("Clicked outside app launcher")
                    shellRoot.appLauncherVisible = false
                }
                propagateComposedEvents: false
            }
            
            // Panel positioned at center, slides down from top
            Item {
                width: 1000
                height: 600
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: shellRoot.appLauncherVisible ? 0 : -800

                Behavior on anchors.verticalCenterOffset {
                    NumberAnimation { duration: 350; easing.type: Easing.OutCubic }
                }
                
                    // AppLauncher removed
                    Item { anchors.fill: parent }
            }
        }
    }
    
    // Power Menu popup - anchored below power button (top right)
    Variants {
        model: Quickshell.screens
        
        PanelWindow {
            property var modelData
            screen: modelData
            
            visible: shellRoot.powerMenuVisible
            
            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }
            
            margins {
                top: 0
                left: 0
                right: 0
                bottom: 0
            }
            
            color: "transparent"
            exclusiveZone: 0
            
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
            
            // Background overlay - click to close
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    console.log("Clicked outside power menu")
                    shellRoot.powerMenuVisible = false
                }
                propagateComposedEvents: true
            }
            
            // Panel positioned at center, slides down from top
            Item {
                width: 586
                height: 120
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: shellRoot.powerMenuVisible ? 0 : -400
                z: 1  // Ensure menu is above background
                
                Behavior on anchors.verticalCenterOffset {
                    NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                }
                
                // Stop background clicks from closing menu
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        // Absorb clicks on the menu panel itself
                    }
                    propagateComposedEvents: true
                }
                
                PowerMenu {
                    id: powerMenu
                    anchors.fill: parent
                    isVisible: shellRoot.powerMenuVisible
                    opacity: shellRoot.powerMenuVisible ? 1 : 0
                    z: 2  // Ensure PowerMenu is above the absorbing MouseArea
                    
                    Behavior on opacity {
                        NumberAnimation { duration: 250 }
                    }
                    
                    onRequestClose: {
                        console.log("PowerMenu requested close")
                        shellRoot.powerMenuVisible = false
                    }
                }
            }
        }
    }

    // Notifications Panel - top left
    Variants {
        model: Quickshell.screens

        PanelWindow {
            property var modelData
            screen: modelData

            visible: shellRoot.notificationsVisible

            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }

            margins {
                top: 0
                left: 0
                right: 0
                bottom: 0
            }

            color: "transparent"
            exclusiveZone: 0

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

            // Escape key handler
            Shortcut {
                sequence: "Escape"
                onActivated: {
                    shellRoot.notificationsVisible = false
                }
            }

            // Background overlay - click to close
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    shellRoot.notificationsVisible = false
                }
                propagateComposedEvents: true
            }

            // Panel positioned at top-left
            Item {
                width: 550
                height: 500
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.margins: 20
                anchors.leftMargin: shellRoot.notificationsVisible ? 20 : -600
                z: 1

                Behavior on anchors.leftMargin {
                    NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                }

                NotificationsWidget {
                    anchors.fill: parent
                    opacity: shellRoot.notificationsVisible ? 1 : 0

                    Behavior on opacity {
                        NumberAnimation { duration: 250 }
                    }

                    onRequestClose: {
                        shellRoot.notificationsVisible = false
                    }
                }
            }
        }
    }

    // Clipboard Manager Panel
    Variants {
        model: Quickshell.screens
        
        PanelWindow {
            property var modelData
            screen: modelData
            
            visible: shellRoot.clipboardVisible
            
            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }
            
            margins {
                top: 0
                left: 0
                right: 0
                bottom: 0
            }
            
            color: "transparent"
            exclusiveZone: 0
            
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
            
            // Background overlay - click to close
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    console.log("Clicked outside clipboard panel")
                    shellRoot.clipboardVisible = false
                }
                propagateComposedEvents: true
            }
            
            // Panel positioned at center, slides down from top
            Item {
                width: 500
                height: 600
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: shellRoot.clipboardVisible ? 0 : -800
                z: 1  // Ensure panel is above background
                
                Behavior on anchors.verticalCenterOffset {
                    NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                }
                
                // Stop background clicks from closing panel
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        // Absorb clicks on the panel itself
                    }
                    propagateComposedEvents: true
                }
                
                // ClipboardPanel removed
                Item { anchors.fill: parent }
            }
        }
    }
    
    // Control Center Panel
    Variants {
        model: Quickshell.screens
        
        PanelWindow {
            property var modelData
            screen: modelData
            visible: shellRoot.controlCenterVisible
            
            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }
            
            margins {
                top: 0
                left: 0
                right: 0
                bottom: 0
            }
            
            color: "transparent"
            exclusiveZone: 0
            
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

            // Escape key handler
            Shortcut {
                sequence: "Escape"
                onActivated: {
                    shellRoot.controlCenterVisible = false
                }
            }

            // Background overlay - click to close
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    console.log("Clicked outside control center panel")
                    shellRoot.controlCenterVisible = false
                }

                // Prevent clicks from reaching the background
                propagateComposedEvents: false
            }
            
            // Panel positioned at top-right, slides down from top
            Item {
                width: 420
                height: 940
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.topMargin: shellRoot.controlCenterVisible ? 6 : -960
                anchors.rightMargin: 6
                
                Behavior on anchors.topMargin {
                    NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                }
                
                ControlCenter {
                    id: controlCenterPanel
                    anchors.fill: parent
                    isVisible: shellRoot.controlCenterVisible
                    opacity: shellRoot.controlCenterVisible ? 1 : 0
                    
                    Behavior on opacity {
                        NumberAnimation { duration: 250 }
                    }
                    
                    onRequestClose: {
                        console.log("ControlCenter requested close")
                        shellRoot.controlCenterVisible = false
                    }
                }
            }
        }
    }
    
    // Theme Switcher widget removed
    // Screenshot widget
    Variants {
        model: Quickshell.screens
        
        ScreenshotWidget {
            property var modelData
            screen_: modelData
            visible: shellRoot.screenshotVisible
            
            onCloseRequested: {
                shellRoot.screenshotVisible = false
            }
        }
    }

    // FocusTime widget - full screen overlay
    Variants {
        model: Quickshell.screens

        PanelWindow {
            property var modelData
            screen: modelData

            visible: shellRoot.focustimeVisible

            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }

            margins {
                top: 0
                left: 0
                right: 0
                bottom: 0
            }

            color: "transparent"
            exclusiveZone: 0

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

            // Escape key handler
            Shortcut {
                sequence: "Escape"
                onActivated: {
                    shellRoot.focustimeVisible = false
                }
            }

            // Background overlay - click to close
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    console.log("Clicked outside focus time panel")
                    shellRoot.focustimeVisible = false
                }
                propagateComposedEvents: false
            }

            // Panel centered
            Item {
                anchors.fill: parent
                anchors.topMargin: shellRoot.focustimeVisible ? 0 : -1200

                Behavior on anchors.topMargin {
                    NumberAnimation { duration: 350; easing.type: Easing.OutCubic }
                }

                FocusTimePopup {
                    width: 1200
                    height: 800
                    anchors.centerIn: parent
                    opacity: shellRoot.focustimeVisible ? 1 : 0

                    Behavior on opacity {
                        NumberAnimation { duration: 250 }
                    }
                }
            }
        }
    }



    Variants {
        model: Quickshell.screens

        PanelWindow {
            property var modelData
            screen: modelData
            
            property bool barAtBottom: false
            property bool barAutoHide: false
            property bool barHovered: false
            property bool barFloating: false
            
            // Load bar position and auto-hide settings
            Process {
                id: barPositionLoader
                running: true
                command: ["sh", "-c", "cat ~/.config/quickshell/settings.json 2>/dev/null || echo '{}'"]
                
                property string buffer: ""
                
                stdout: SplitParser {
                    onRead: data => {
                        barPositionLoader.buffer += data
                    }
                }
                
                onRunningChanged: {
                    if (!running && buffer !== "") {
                        try {
                            const settings = JSON.parse(buffer)
                            if (settings.bar) {
                                if (settings.bar.position) {
                                    barAtBottom = settings.bar.position === "bottom"
                                }
                                if (settings.bar.autoHide !== undefined) {
                                    barAutoHide = settings.bar.autoHide
                                }
                                if (settings.bar.floating !== undefined) {
                                    barFloating = settings.bar.floating
                                }
                            }
                        } catch (e) {}
                        buffer = ""
                    } else if (running) {
                        buffer = ""
                    }
                }
            }
            
            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: barPositionLoader.running = true
            }
            
            anchors {
                top: !barAtBottom
                bottom: barAtBottom
                left: true
                right: true
            }
            
            implicitHeight: 42
            color: "transparent"
            
            margins {
                top: (barAutoHide && !barHovered) || shellRoot.isAnyFullscreen ? (barAtBottom ? 0 : -implicitHeight) : (barFloating && !barAtBottom ? 8 : 0)
                bottom: (barAutoHide && !barHovered) || shellRoot.isAnyFullscreen ? (barAtBottom ? -implicitHeight : 0) : (barFloating && barAtBottom ? 8 : 0)
                left: barFloating ? 8 : 0
                right: barFloating ? 8 : 0
            }

            Behavior on margins.top {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }

            Behavior on margins.bottom {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }

            Behavior on margins.left {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }

            Behavior on margins.right {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }
            
            // Explicitly enable interaction
            visible: true
            exclusiveZone: barAutoHide ? 0 : height
            
            // Mouse detection area for auto-hide
            MouseArea {
                anchors.fill: parent
                anchors.topMargin: barAtBottom ? 0 : -10
                anchors.bottomMargin: barAtBottom ? -10 : 0
                hoverEnabled: true
                propagateComposedEvents: true
                enabled: barAutoHide
                z: 100
                
                onEntered: barHovered = true
                onExited: barHovered = false
                onClicked: function(mouse) { mouse.accepted = false }
            }
            
            Bar {
                id: bar
                anchors.fill: parent
                
                // Connect clock toggle signal to shellRoot
                Connections {
                    target: bar.clockComponent
                    function onToggleCalendar() {
                        shellRoot.calendarVisible = !shellRoot.calendarVisible
                        console.log("Calendar toggled via Connections:", shellRoot.calendarVisible)
                    }
                }
                
                // Connect launcher toggle signal (Arch button) - now for notifications
                Connections {
                    target: bar.archComponent
                    function onToggleLauncher() {
                        shellRoot.notificationsVisible = !shellRoot.notificationsVisible
                        console.log("Notifications toggled:", shellRoot.notificationsVisible)
                    }
                }
                
                // Connect power menu toggle signal
                Connections {
                    target: bar.powerComponent
                    function onTogglePowerMenu() {
                        shellRoot.powerMenuVisible = !shellRoot.powerMenuVisible
                        console.log("PowerMenu toggled:", shellRoot.powerMenuVisible)
                    }
                }

                
                // Connect clipboard toggle signal
                Connections {
                    target: bar
                    function onToggleClipboard() {
                        shellRoot.clipboardVisible = !shellRoot.clipboardVisible
                        console.log("Clipboard toggled:", shellRoot.clipboardVisible)
                    }
                }
                
                // Connect control center toggle signal
                Connections {
                    target: bar
                    function onToggleControlCenter() {
                        shellRoot.controlCenterVisible = !shellRoot.controlCenterVisible
                        console.log("ControlCenter toggled:", shellRoot.controlCenterVisible)
                    }
                }

                // Connect focus time toggle signal
                Connections {
                    target: bar.focusTimeButtonComponent
                    function onToggleFocusTime() {
                        shellRoot.focustimeVisible = !shellRoot.focustimeVisible
                        console.log("FocusTime toggled:", shellRoot.focustimeVisible)
                    }
                }
            }
        }
    }
}
