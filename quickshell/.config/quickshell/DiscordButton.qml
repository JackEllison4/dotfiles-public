import QtQuick
import Quickshell

IconButton {
    icon: "\uf392"
    tooltip: "Discord"
    onClicked: Quickshell.execDetached(["discord"])
}
