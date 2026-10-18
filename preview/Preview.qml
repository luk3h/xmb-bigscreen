// Stage 2 preview: the XMB Bigscreen home screen with made-up items, full screen.
// Nothing launches and nothing is changed - choices just show a note at the bottom.
// Run it with: scripts/preview.sh
import QtQuick
import QtQuick.Window
import "../xmb"

Window {
    id: win
    width: 1920
    height: 1080
    visible: true
    visibility: Window.FullScreen
    color: "black"
    title: "XMB Bigscreen preview"

    function app(label, icon, sub) { return { kind: "app", label: label, icon: icon, sub: sub || "" } }
    function setting(label, icon, module) { return { kind: "settings", label: label, icon: icon, module: module } }
    function power(label, icon, act) { return { kind: "power", label: label, icon: home.asset(icon), act: act } }

    function note(t) { noteText.text = t; noteTimer.restart() }

    XmbHome {
        id: home
        anchors.fill: parent
        focus: true
        catIdx: 5   // start on Game, like the PS3 starts on your last category
        categories: [
            { name: "Users", icon: home.catIcon("users"), items: [
                { kind: "user", label: "luk3h", icon: home.asset("user") },
                win.power("Sleep", "suspend", "suspend"),
                win.power("Restart System", "restart", "reboot"),
                win.power("Turn Off System", "power", "off"),
                win.power("Log Out", "logout", "logout") ] },
            { name: "Settings", icon: home.catIcon("settings"), items: [
                win.setting("Audio", "audio-volume-high", "kcm_mediacenter_audiodevice"),
                win.setting("Bluetooth", "preferences-system-bluetooth", "kcm_mediacenter_bluetooth"),
                win.setting("Display", "video-display", "kcm_mediacenter_display"),
                win.setting("Input", "input-gamepad", "kcm_mediacenter_input"),
                win.setting("KDE Connect", "kdeconnect", "kcm_mediacenter_kdeconnect"),
                win.setting("System", "preferences-system", "kcm_mediacenter_bigscreen_settings"),
                win.setting("Wallpaper", "preferences-desktop-wallpaper", "kcm_mediacenter_wallpaper"),
                win.setting("Web Apps", "applications-internet", "kcm_mediacenter_webapps"),
                win.setting("Wi-Fi", "network-wireless", "kcm_mediacenter_wifi") ] },
            { name: "Photo", icon: home.catIcon("photo"), items: [
                win.app("Gwenview", "org.kde.gwenview", "Image viewer") ] },
            { name: "Music", icon: home.catIcon("music"), items: [
                win.app("Elisa", "org.kde.elisa", "Music player"),
                win.app("Spotify", "spotify-client") ] },
            { name: "Video", icon: home.catIcon("video"), items: [
                win.app("VLC", "vlc", "Media player"),
                win.app("Haruna", "org.kde.haruna", "Media player") ] },
            { name: "Game", icon: home.catIcon("game"), items: [
                win.app("Steam", "steam", "Game library"),
                win.app("Counter-Strike 2", "steam_icon_730"),
                win.app("DayZ", "steam_icon_221100"),
                win.app("Project Zomboid", "steam_icon_108600"),
                win.app("Minecraft", "minecraft-launcher"),
                win.app("Lutris", "lutris") ] },
            { name: "Network", icon: home.catIcon("network"), items: [
                win.app("Firefox", "firefox", "Web browser"),
                win.app("Discord", "discord") ] },
            { name: "Apps", icon: home.catIcon("apps"), items: [
                win.app("Dolphin", "org.kde.dolphin", "File manager"),
                win.app("Konsole", "utilities-terminal", "Terminal"),
                win.app("Kate", "kate", "Text editor"),
                win.app("Discover", "plasmadiscover", "Software"),
                win.app("System Monitor", "utilities-system-monitor"),
                win.app("Spectacle", "spectacle", "Screenshots"),
                win.app("KCalc", "accessories-calculator"),
                win.app("Okular", "okular", "Document viewer"),
                win.app("Ark", "ark", "Archives") ] }
        ]

        onLaunchRequested: (item) => win.note("Would open " + item.label + " (with the XMB launch screen in stage 5)")
        onSettingsRequested: (module) => win.note("Would run: plasma-bigscreen-settings -m " + module)
        onSearchRequested: win.note("Would open Search")
        onPowerRequested: (act) => {
            win.note("Would " + (act === "off" ? "turn off" : act === "reboot" ? "restart" : act === "logout" ? "log out" : "sleep") + " - nothing happens in the preview")
            backTimer.start()
        }
    }
    Timer { id: backTimer; interval: 1200; onTriggered: home.cancelBusy() }

    // P toggles the "app is open" pause, to check the wave stops (watch GPU power)
    Shortcut { sequence: "P"; onActivated: { home.paused = !home.paused; win.note(home.paused ? "Wave paused" : "Wave running") } }
    Shortcut { sequences: ["Ctrl+Q", "F10"]; onActivated: Qt.quit() }

    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 140 * home.s
        width: noteText.implicitWidth + 48 * home.s
        height: 52 * home.s
        radius: height / 2
        color: "#a0000000"
        border.color: "#50ffffff"
        opacity: noteTimer.running ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 250 } }
        Text {
            id: noteText
            anchors.centerIn: parent
            color: "white"
            font.family: home.fontName
            font.pixelSize: 20 * home.s
        }
        Timer { id: noteTimer; interval: 3000 }
    }
    Text {
        anchors.left: parent.left; anchors.bottom: parent.bottom
        anchors.leftMargin: 70 * home.s; anchors.bottomMargin: 72 * home.s
        text: "Preview - arrows move, Enter selects, Esc goes back, P pauses the wave, Ctrl+Q exits"
        color: "#90ffffff"
        // fades after 5 s, like the other previews, so screenshots come out clean
        opacity: helpTimer.running ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 600 } }
        Timer { id: helpTimer; interval: 5000; running: true }
        font.family: home.fontName
        font.pixelSize: 16 * home.s
    }
}
