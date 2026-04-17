import QtQuick
import Quickshell

IconButton {
    icon: "\uf0ae"
    tooltip: "Notion"
    onClicked: Quickshell.execDetached(["notion-app"])
}
