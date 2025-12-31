import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick

PanelWindow {
    color: "#FF7777"
    WlrLayershell.namespace: `raiden`
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Background
    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true

    Image {
        id: wallpaper

        anchors.fill: parent
        source: "file:///home/yangsiyu/Pictures/Wallpapers/random_wallpaper.jpg"
    }  // Image($wallpaper)

    PanelWindow {
        id: bar

        anchors.left: true
        anchors.right: true
        anchors.top: true
        implicitHeight: 30
        color: "white"

        Text {
            id: clock
            anchors.centerIn: parent

            Process {
                // give the process object an id so we can talk
                // about it from the timer
                id: dateProc

                command: ["date"]
                running: true

                stdout: StdioCollector {
                    onStreamFinished: clock.text = this.text
                }
            }  // Process($dateProc)

            // use a timer to rerun the process at an interval
            Timer {
                // 1000 milliseconds is 1 second
                interval: 1000

                // start the timer immediately
                running: true

                // run the timer again when it ends
                repeat: true

                // when the timer is triggered, set the running property of the
                // process to true, which reruns it if stopped.
                onTriggered: dateProc.running = true
            }  // Timer
        }  // Text($clock)
    }  // PanelWindow($bar)
}  // PanelWindow
