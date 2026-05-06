import QtQuick
import Quickshell
import Quickshell.Io

ShellWindow {
    width: 200
    height: 200
    color: "red"
    
    Process {
        id: testProcess
        command: ["curl", "-s", "wttr.in/?format=j1"]
        running: true
        property string buffer: ""
        stdout: SplitParser {
            onRead: data => { testProcess.buffer += data }
        }
        onRunningChanged: {
            if (!running) {
                console.log("BUFFER LENGTH:", buffer.length)
                try {
                    let d = JSON.parse(buffer)
                    console.log("PARSE SUCCESS:", d.weather[0].maxtempC)
                } catch(e) {
                    console.log("PARSE FAIL:", e)
                }
                Qt.callLater(() => Qt.quit())
            }
        }
    }
}
