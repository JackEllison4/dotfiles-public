import QtQuick
import QtQuick.Window

QtObject {
    property real currentWidth: Screen.width

    property real baseWidth: 1920
    property real scaleFactor: currentWidth / baseWidth

    function s(val) {
        return val * scaleFactor
    }
}
