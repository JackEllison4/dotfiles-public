import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root
    
    property bool active: false
    
    Grid {
        anchors.fill: parent
        columns: 2
        columnSpacing: 16
        rowSpacing: 16
        
        // CPU Monitor
        Rectangle {
            width: (parent.width - 16) / 2
            height: (parent.height - 16) / 2
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
                    spacing: 8
                    
                    Text {
                        text: "🖥️"
                        font.pixelSize: 20
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    
                    Text {
                        text: "CPU Usage"
                        font.family: "Sen"
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: ThemeManager.fgPrimary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    
                    Item { width: parent.width - 200; height: 1 }
                    
                    Text {
                        id: cpuPercentText
                        text: "0%"
                        font.family: "Sen"
                        font.pixelSize: 24
                        font.weight: Font.Bold
                        color: cpuMonitor.currentValue > 80 ? ThemeManager.accentRed : ThemeManager.accentBlue
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                
                // Sparkline
                SparklineChart {
                    id: cpuSparkline
                    width: parent.width
                    height: parent.height - 80
                    values: cpuMonitor.history
                    maxValue: 100
                    color: cpuMonitor.currentValue > 80 ? ThemeManager.accentRed : ThemeManager.accentBlue
                    fillColor: Qt.rgba(
                        parseInt(ThemeManager.accentBlue.toString().substr(1,2), 16) / 255,
                        parseInt(ThemeManager.accentBlue.toString().substr(3,2), 16) / 255,
                        parseInt(ThemeManager.accentBlue.toString().substr(5,2), 16) / 255,
                        0.2
                    )
                }
                
                Row {
                    width: parent.width
                    spacing: 16
                    
                    Text {
                        text: "Cores: " + cpuMonitor.coreCount
                        font.family: "Sen"
                        font.pixelSize: 12
                        color: ThemeManager.fgSecondary
                    }
                    
                    Text {
                        text: "Avg: " + cpuMonitor.avgValue + "%"
                        font.family: "Sen"
                        font.pixelSize: 12
                        color: ThemeManager.fgSecondary
                    }
                }
            }
        }
        
        // Memory Monitor
        Rectangle {
            width: (parent.width - 16) / 2
            height: (parent.height - 16) / 2
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
                    spacing: 8
                    
                    Text {
                        text: "💾"
                        font.pixelSize: 20
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    
                    Text {
                        text: "Memory Usage"
                        font.family: "Sen"
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: ThemeManager.fgPrimary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    
                    Item { width: parent.width - 200; height: 1 }
                    
                    Text {
                        id: memPercentText
                        text: "0%"
                        font.family: "Sen"
                        font.pixelSize: 24
                        font.weight: Font.Bold
                        color: memMonitor.currentValue > 80 ? ThemeManager.accentRed : ThemeManager.accentCyan
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                
                // Sparkline
                SparklineChart {
                    id: memSparkline
                    width: parent.width
                    height: parent.height - 80
                    values: memMonitor.history
                    maxValue: 100
                    color: memMonitor.currentValue > 80 ? ThemeManager.accentRed : ThemeManager.accentCyan
                    fillColor: Qt.rgba(
                        parseInt(ThemeManager.accentCyan.toString().substr(1,2), 16) / 255,
                        parseInt(ThemeManager.accentCyan.toString().substr(3,2), 16) / 255,
                        parseInt(ThemeManager.accentCyan.toString().substr(5,2), 16) / 255,
                        0.2
                    )
                }
                
                Row {
                    width: parent.width
                    spacing: 16
                    
                    Text {
                        text: "Used: " + memMonitor.usedGB + " GB"
                        font.family: "Sen"
                        font.pixelSize: 12
                        color: ThemeManager.fgSecondary
                    }
                    
                    Text {
                        text: "Total: " + memMonitor.totalGB + " GB"
                        font.family: "Sen"
                        font.pixelSize: 12
                        color: ThemeManager.fgSecondary
                    }
                }
            }
        }
        
        // Storage Monitor
        Rectangle {
            width: (parent.width - 16) / 2
            height: (parent.height - 16) / 2
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
                    spacing: 8
                    
                    Text {
                        text: "💿"
                        font.pixelSize: 20
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    
                    Text {
                        text: "Disk Usage"
                        font.family: "Sen"
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: ThemeManager.fgPrimary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    
                    Item { width: parent.width - 200; height: 1 }
                    
                    Text {
                        id: diskPercentText
                        text: "0%"
                        font.family: "Sen"
                        font.pixelSize: 24
                        font.weight: Font.Bold
                        color: diskMonitor.currentValue > 80 ? ThemeManager.accentRed : ThemeManager.accentPurple
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                
                // Dark container for disk info
                Rectangle {
                    width: parent.width
                    height: parent.height - 80
                    color: Qt.rgba(1, 1, 1, 0.07)
                    radius: 8
                    
                    Column {
                        anchors.centerIn: parent
                        spacing: 16
                        width: parent.width - 32
                        
                        // Disk info rows
                        Column {
                            width: parent.width
                            spacing: 10
                            
                            Row {
                                width: parent.width
                                spacing: 8
                                
                                Text {
                                    width: 60
                                    text: "Used:"
                                    font.family: "Sen"
                                    font.pixelSize: 13
                                    color: ThemeManager.fgTertiary
                                }
                                Text {
                                    text: diskMonitor.usedGB + " GB"
                                    font.family: "Sen"
                                    font.pixelSize: 14
                                    font.weight: Font.Bold
                                    color: ThemeManager.fgPrimary
                                }
                            }
                            
                            Row {
                                width: parent.width
                                spacing: 8
                                
                                Text {
                                    width: 60
                                    text: "Free:"
                                    font.family: "Sen"
                                    font.pixelSize: 13
                                    color: ThemeManager.fgTertiary
                                }
                                Text {
                                    text: diskMonitor.freeGB + " GB"
                                    font.family: "Sen"
                                    font.pixelSize: 14
                                    font.weight: Font.Bold
                                    color: ThemeManager.accentGreen
                                }
                            }
                            
                            Row {
                                width: parent.width
                                spacing: 8
                                
                                Text {
                                    width: 60
                                    text: "Total:"
                                    font.family: "Sen"
                                    font.pixelSize: 13
                                    color: ThemeManager.fgTertiary
                                }
                                Text {
                                    text: diskMonitor.totalGB + " GB"
                                    font.family: "Sen"
                                    font.pixelSize: 14
                                    font.weight: Font.Bold
                                    color: ThemeManager.fgPrimary
                                }
                            }
                        }
                        
                        // Disk usage bar
                        Rectangle {
                            width: parent.width
                            height: 6
                            color: Qt.rgba(1, 1, 1, 0.10)
                            radius: 3
                            
                            Rectangle {
                                width: parent.width * (diskMonitor.currentValue / 100)
                                height: parent.height
                                color: diskMonitor.currentValue > 80 ? ThemeManager.accentRed : ThemeManager.accentPurple
                                radius: 3
                                
                                Behavior on width {
                                    NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // Temperature Monitor
        Rectangle {
            width: (parent.width - 16) / 2
            height: (parent.height - 16) / 2
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
                    spacing: 8
                    
                    Text {
                        text: "🌡️"
                        font.pixelSize: 20
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    
                    Text {
                        text: "Temperature"
                        font.family: "Sen"
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: ThemeManager.fgPrimary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    
                    Item { 
                        width: Math.max(0, parent.width - 250)
                        height: 1 
                    }
                    
                    Text {
                        id: tempText
                        text: "0°C"
                        font.family: "Sen"
                        font.pixelSize: 24
                        font.weight: Font.Bold
                        color: tempMonitor.currentValue > 70 ? ThemeManager.accentRed : ThemeManager.accentGreen
                        anchors.verticalCenter: parent.verticalCenter
                        horizontalAlignment: Text.AlignRight
                        elide: Text.ElideRight
                        width: Math.min(implicitWidth, 120)
                    }
                }
                
                // Sparkline
                SparklineChart {
                    id: tempSparkline
                    width: parent.width
                    height: parent.height - 80
                    values: tempMonitor.history
                    maxValue: 100
                    color: tempMonitor.currentValue > 70 ? ThemeManager.accentRed : ThemeManager.accentGreen
                    fillColor: Qt.rgba(
                        parseInt(ThemeManager.accentGreen.toString().substr(1,2), 16) / 255,
                        parseInt(ThemeManager.accentGreen.toString().substr(3,2), 16) / 255,
                        parseInt(ThemeManager.accentGreen.toString().substr(5,2), 16) / 255,
                        0.2
                    )
                }
                
                Row {
                    width: parent.width
                    spacing: 16
                    
                    Text {
                        text: "Min: " + tempMonitor.minValue + "°C"
                        font.family: "Sen"
                        font.pixelSize: 12
                        color: ThemeManager.fgSecondary
                    }
                    
                    Text {
                        text: "Max: " + tempMonitor.maxValue + "°C"
                        font.family: "Sen"
                        font.pixelSize: 12
                        color: ThemeManager.fgSecondary
                    }
                }
            }
        }
    }
    
    // Monitor data objects
    QtObject {
        id: cpuMonitor
        property real currentValue: 0
        property var history: []
        property int coreCount: 0
        property real avgValue: 0
        
        function update(value) {
            currentValue = value
            history.push(value)
            if (history.length > 60) history.shift()
            
            let sum = history.reduce((a, b) => a + b, 0)
            avgValue = Math.round(sum / history.length)
            
            cpuPercentText.text = Math.round(value) + "%"
            cpuSparkline.requestPaint()
        }
    }
    
    QtObject {
        id: memMonitor
        property real currentValue: 0
        property var history: []
        property string usedGB: "0"
        property string totalGB: "0"
        
        function update(value, used, total) {
            currentValue = value
            usedGB = used
            totalGB = total
            history.push(value)
            if (history.length > 60) history.shift()
            
            memPercentText.text = Math.round(value) + "%"
            memSparkline.requestPaint()
        }
    }
    
    QtObject {
        id: diskMonitor
        property real currentValue: 0
        property string usedGB: "0"
        property string freeGB: "0"
        property string totalGB: "0"
        property string filesystem: ""
        
        function update(value, used, free, total, fs) {
            currentValue = value
            usedGB = used
            freeGB = free
            totalGB = total
            filesystem = fs
            
            diskPercentText.text = Math.round(value) + "%"
        }
    }
    
    QtObject {
        id: tempMonitor
        property real currentValue: 0
        property var history: []
        property real minValue: 999
        property real maxValue: 0
        
        function update(value) {
            currentValue = value
            history.push(value)
            if (history.length > 60) history.shift()
            
            if (history.length > 0) {
                minValue = Math.min(...history)
                maxValue = Math.max(...history)
            }
            
            tempText.text = Math.round(value) + "°C"
            tempSparkline.requestPaint()
        }
    }
    
    // Consolidated System Monitor - Single persistent process for all stats
    Process {
        id: consolidatedMonitor
        running: root.active
        command: ["sh", "-c", `
            while true; do
                # CPU
                cpu=$(top -bn2 -d 0.5 | grep '^%Cpu' | tail -1 | awk '{print 100-$8}')
                # Mem
                mem=$(free -g | awk 'NR==2 {printf "%.1f|%.1f|%.1f", ($3/$2)*100, $3, $2}')
                # Disk
                disk=$(df -h / | awk 'NR==2 {gsub("G","",$3); gsub("G","",$4); gsub("G","",$2); gsub("%","",$5); printf "%s|%s|%s|%s|%s", $5, $3, $4, $2, $1}')
                # Temp
                temp=$(sensors 2>/dev/null | grep -E 'Package id 0|Tctl|Core 0' | head -1 | awk '{print $4}' | sed 's/[+°C]//g' || echo 0)
                
                echo "$cpu|$mem|$disk|$temp"
                sleep 5
            done
        `]
        
        stdout: SplitParser {
            onRead: data => {
                const parts = data.trim().split('|')
                if (parts.length >= 10) {
                    // CPU (0)
                    cpuMonitor.update(parseFloat(parts[0]) || 0)
                    
                    // Mem (1, 2, 3)
                    memMonitor.update(
                        parseFloat(parts[1]) || 0,
                        parts[2] || "0",
                        parts[3] || "0"
                    )
                    
                    // Disk (4, 5, 6, 7, 8)
                    diskMonitor.update(
                        parseFloat(parts[4]) || 0,
                        parts[5] || "0",
                        parts[6] || "0",
                        parts[7] || "0",
                        parts[8] || ""
                    )
                    
                    // Temp (9)
                    tempMonitor.update(parseFloat(parts[9]) || 0)
                }
            }
        }
    }

}
