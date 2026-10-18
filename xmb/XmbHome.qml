// XMB PS3 home screen for Plasma Bigscreen: wave, clock, the cross, hints, Yes/No dialog, sounds.
// It doesn't know about Plasma at all: whoever uses it passes in the categories and
// reacts to the signals (launch an app, open a settings page, power actions).
//
// Item fields it understands (anything else is passed straight back in the signals):
//   kind: "app"      -> launchRequested(item)
//         "settings" -> settingsRequested(item.module)   (empty module = Settings home)
//         "power"    -> Yes/No, then powerRequested(item.act)   act: suspend | reboot | off | logout
//         "user"     -> nothing yet
//         "search"   -> searchRequested()
import QtQuick

FocusScope {
    id: home
    readonly property real s: height / 1080
    property string fontName: "Noto Sans"
    property alias categories: cross.categories
    property alias catIdx: cross.catIdx
    property bool paused: false          // true while an app is in front: stops the wave
    readonly property bool dialogUp: confirm.open || confirm.busy

    signal launchRequested(var item)
    signal settingsRequested(string module)
    signal powerRequested(string act)
    signal searchRequested()

    // URL of one of the built-in category icons, e.g. catIcon("game")
    function catIcon(name) { return Qt.resolvedUrl("assets/categories/" + name + ".svg") }
    function asset(name) { return Qt.resolvedUrl("assets/" + name + ".png") }

    // after a power action that didn't happen (preview, or it failed): back to the menu
    function cancelBusy() {
        confirm.unfade()
        cross.forceActiveFocus()
    }
    function focusMenu() { if (!dialogUp) cross.forceActiveFocus() }

    property string pendingAct: ""
    function busyTextFor(act) {
        if (act === "reboot") return "Restarting..."
        if (act === "off") return "Turning off..."
        if (act === "logout") return "Logging out..."
        return "Going to sleep..."
    }
    function askPower(item) {
        pendingAct = item.act
        if (item.act === "reboot") confirm.ask("Restart System", "Restart the system?", "restart", busyTextFor("reboot"))
        else if (item.act === "off") confirm.ask("Turn Off System", "Turn off the system?", "power", busyTextFor("off"))
        else if (item.act === "logout") confirm.ask("Log Out", "Log out now?", "logout", busyTextFor("logout"))
        else confirm.ask("Sleep", "Put the system to sleep?", "suspend", busyTextFor("suspend"))
        sfxPlay("open")
    }
    function handle(cat, item) {
        switch (item.kind) {
        case "app":      sfxPlay("select"); launchRequested(item); break
        case "settings": sfxPlay("select"); settingsRequested(item.module || ""); break
        case "search":   sfxPlay("select"); searchRequested(); break
        case "power":    askPower(item); break
        default:         sfxPlay("error")
        }
    }

    XmbBackground {
        anchors.fill: parent
        paused: home.paused
    }

    Item {
        id: ui
        anchors.fill: parent
        opacity: 0
        Component.onCompleted: { fadeIn.start(); openSound.start() }
        // the "open" sound as the screen appears (after the sound player has loaded)
        Timer { id: openSound; interval: 300; onTriggered: home.sfxPlay("open") }
        NumberAnimation { id: fadeIn; target: ui; property: "opacity"; to: 1; duration: 900; easing.type: Easing.OutCubic }

        Clock {
            s: home.s; fontName: home.fontName
            anchors.right: parent.right; anchors.top: parent.top
            anchors.rightMargin: 70 * home.s; anchors.topMargin: 60 * home.s
        }

        XmbCross {
            id: cross
            anchors.fill: parent
            s: home.s
            fontName: home.fontName
            focus: true
            opacity: home.dialogUp ? 0 : 1
            Behavior on opacity { NumberAnimation { duration: 200 } }
            onSound: (name) => home.sfxPlay(name)
            onActivated: (cat, item) => home.handle(cat, item)
        }

        Row {
            anchors.right: parent.right; anchors.bottom: parent.bottom
            anchors.rightMargin: 70 * home.s; anchors.bottomMargin: 60 * home.s
            spacing: 14 * home.s
            opacity: home.dialogUp ? 0 : 1
            Behavior on opacity { NumberAnimation { duration: 200 } }
            HintButton {
                s: home.s; fontName: home.fontName
                keyText: "Esc"; label: "Back"
                onClicked: cross.back()
            }
            HintButton {
                s: home.s; fontName: home.fontName
                keyText: "Enter"; label: "Select"
                onClicked: cross.activate()
            }
        }
    }

    ConfirmDialog {
        id: confirm
        s: home.s; fontName: home.fontName
        onAccepted: {
            home.sfxPlay("select")
            var act = home.pendingAct
            confirm.busyThenFade(home.busyTextFor(act), function() { home.powerRequested(act) })
        }
        onRejected: {
            home.sfxPlay("back")
            confirm.close()
            cross.forceActiveFocus()
        }
        onChoiceChanged: if (confirm.open) home.sfxPlay("move")
    }

    // assets/sounds-off.png for --no-sounds; a missing Qt Multimedia just means no sound.
    Image { id: soundsOff; visible: false; asynchronous: false; source: "assets/sounds-off.png" }
    Loader { id: sfx; active: soundsOff.status !== Image.Ready; source: "XmbSounds.qml" }
    function sfxPlay(name) { if (sfx.item) sfx.item.play(name) }
}
