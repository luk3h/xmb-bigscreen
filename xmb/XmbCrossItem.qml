// One entry in a category's column: icon + name (+ a smaller second line when selected).
// Bigger and brighter when selected, like the PS3.
import QtQuick
import org.kde.kirigami as Kirigami

Item {
    id: item
    property real s: 1
    property string fontName: "Noto Sans"
    property bool selected: false
    property string iconSource: ""      // an icon name ("firefox") or a file URL
    property string label: ""
    property string sub: ""             // second line, only shown when selected
    property real centerX: 0            // where the icon's centre sits (the column)
    property real centerY: 0
    signal clicked()

    readonly property real iconSize: (selected ? 104 : 72) * s
    x: centerX - iconSize / 2
    y: centerY - iconSize / 2
    width: 900 * s
    height: iconSize
    Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
    Behavior on y { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

    Image {
        anchors.centerIn: icon
        width: icon.width * 2.2; height: width
        source: "assets/glow.png"
        opacity: item.selected ? 0.5 : 0
        Behavior on opacity { NumberAnimation { duration: 200 } }
    }

    Kirigami.Icon {
        id: icon
        width: item.iconSize
        height: width
        source: item.iconSource
        fallback: "application-x-executable"
        opacity: item.selected ? 1 : 0.65
        Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        Behavior on opacity { NumberAnimation { duration: 200 } }
    }

    Column {
        anchors.left: icon.right
        anchors.leftMargin: 26 * item.s
        anchors.verticalCenter: icon.verticalCenter
        spacing: 4 * item.s
        Text {
            text: item.label
            color: "white"
            font.family: item.fontName
            font.pixelSize: (item.selected ? 28 : 22) * item.s
            opacity: item.selected ? 1 : 0.7
            style: Text.Raised
            styleColor: "#40002040"
        }
        Text {
            text: item.sub
            visible: item.selected && text !== ""
            color: "#c8ffffff"
            font.family: item.fontName
            font.pixelSize: 18 * item.s
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: item.clicked()
    }
}
