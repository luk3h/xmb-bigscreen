// The XMB "cross": a row of categories across the screen, with the selected category's
// items in a column below it. Items you've scrolled past move up above the row, like the PS3.
//
// categories: [ { name, icon, items: [ { label, sub, icon, ...anything else } ] } ]
// The cross only moves around and plays sounds; what an item *does* is up to XmbHome.
import QtQuick

FocusScope {
    id: cross
    property real s: 1
    property string fontName: "Noto Sans"
    property var categories: []
    property int catIdx: 0
    property var itemIdx: []            // selected item in each category, remembered per category

    readonly property real colX: width * 0.24      // the column, same line as the login screen's list
    readonly property real barY: height * 0.26     // centre of the category row
    readonly property real catGap: 200 * s
    readonly property real itemGap: 96 * s

    signal sound(string name)
    signal activated(var category, var item)

    function curItem(c) { var v = itemIdx[c]; return v === undefined ? 0 : v }
    function itemCount(c) { var cat = categories[c]; return (cat && cat.items) ? cat.items.length : 0 }
    function setItem(c, i) { var a = itemIdx.slice(); a[c] = i; itemIdx = a }
    function setCat(c) {
        c = Math.max(0, Math.min(categories.length - 1, c))
        if (c !== catIdx) { catIdx = c; sound("move") }
    }
    function moveItem(d) {
        var c = catIdx
        var n = Math.max(0, Math.min(itemCount(c) - 1, curItem(c) + d))
        if (n !== curItem(c)) { setItem(c, n); sound("move") }
    }
    function activate() {
        var cat = categories[catIdx]
        if (!cat || itemCount(catIdx) === 0) { sound("error"); return }
        activated(cat, cat.items[curItem(catIdx)])
    }
    // Back: jump to the top of the column
    function back() {
        if (curItem(catIdx) > 0) { setItem(catIdx, 0); sound("back") }
    }
    // centre line of item i when item cur is selected
    function itemY(i, cur) {
        if (i === cur) return barY + 150 * s
        if (i < cur) return barY - 120 * s - (cur - i - 1) * itemGap
        return barY + 150 * s + 30 * s + (i - cur) * itemGap
    }

    Keys.onPressed: (event) => {
        switch (event.key) {
        case Qt.Key_Left:      setCat(catIdx - 1); break
        case Qt.Key_Right:     setCat(catIdx + 1); break
        case Qt.Key_Up:        moveItem(-1); break
        case Qt.Key_Down:      moveItem(1); break
        case Qt.Key_PageUp:    moveItem(-5); break
        case Qt.Key_PageDown:  moveItem(5); break
        case Qt.Key_Return:
        case Qt.Key_Enter:
        case Qt.Key_Space:     activate(); break
        case Qt.Key_Escape:
        case Qt.Key_Backspace: back(); break
        default: return
        }
        event.accepted = true
    }

    // mouse wheel: up/down through the column
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        onWheel: (wheel) => cross.moveItem(wheel.angleDelta.y > 0 ? -1 : 1)
    }

    Repeater {
        model: cross.categories
        Item {
            id: catDel
            anchors.fill: parent
            readonly property bool sel: index === cross.catIdx
            readonly property int cur: cross.curItem(index)
            readonly property int catIndex: index
            readonly property var cat: modelData

            // ---- category icon in the row ----
            Item {
                id: catIcon
                width: 100 * cross.s
                height: width
                x: cross.colX + (catDel.catIndex - cross.catIdx) * cross.catGap - width / 2
                y: cross.barY - height / 2
                Behavior on x { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

                Image {
                    anchors.centerIn: parent
                    width: parent.width * 2.2; height: width
                    source: "assets/glow.png"
                    opacity: catDel.sel ? 0.45 : 0
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                }
                Image {
                    anchors.fill: parent
                    source: catDel.cat.icon
                    sourceSize: Qt.size(width * 2, height * 2)
                    smooth: true; mipmap: true
                    opacity: catDel.sel ? 1 : 0.5
                    scale: catDel.sel ? 1 : 0.8
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                    Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                }
                MouseArea { anchors.fill: parent; onClicked: cross.setCat(catDel.catIndex) }
            }
            Text {
                anchors.horizontalCenter: catIcon.horizontalCenter
                y: catIcon.y + catIcon.height + 6 * cross.s
                text: catDel.cat.name
                color: "white"
                font.family: cross.fontName
                font.pixelSize: 20 * cross.s
                opacity: catDel.sel ? 0.95 : 0
                Behavior on opacity { NumberAnimation { duration: 200 } }
            }

            // ---- this category's column (only the selected one shows) ----
            Item {
                anchors.fill: parent
                opacity: catDel.sel ? 1 : 0
                visible: opacity > 0
                Behavior on opacity { NumberAnimation { duration: 180 } }

                Repeater {
                    model: catDel.cat.items
                    XmbCrossItem {
                        s: cross.s
                        fontName: cross.fontName
                        selected: index === catDel.cur
                        iconSource: modelData.icon || ""
                        label: modelData.label || ""
                        sub: modelData.sub || ""
                        centerX: cross.colX
                        centerY: cross.itemY(index, catDel.cur)
                        onClicked: {
                            if (index === catDel.cur) cross.activate()
                            else { cross.setItem(catDel.catIndex, index); cross.sound("move") }
                        }
                    }
                }
                Text {
                    visible: catDel.cat.items.length === 0
                    x: cross.colX - 36 * cross.s
                    y: cross.itemY(0, 0) - height / 2
                    text: catDel.cat.empty || "There are no items."
                    color: "#c0ffffff"
                    font.family: cross.fontName
                    font.pixelSize: 22 * cross.s
                }
            }
        }
    }
}
