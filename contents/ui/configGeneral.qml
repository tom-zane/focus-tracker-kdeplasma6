import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

Item {
    id: page
    width: childrenRect.width
    height: childrenRect.height

    property alias cfg_focusTimeMinutes: focusTimeSpin.value
    property alias cfg_breakTimeMinutes: breakTimeSpin.value
    property alias cfg_dailyGoalHours: goalSpin.value
    property alias cfg_notifyOnEnd: notifyCheck.checked 


    Kirigami.FormLayout {
        anchors.left: parent.left
        anchors.right: parent.right

        Item { Kirigami.FormData.isSection: true; Kirigami.FormData.label: "Timer Durations" }
        PlasmaComponents.SpinBox { id: focusTimeSpin; Kirigami.FormData.label: "Focus Time (minutes):"; from: 1; to: 120 }
        PlasmaComponents.SpinBox { id: breakTimeSpin; Kirigami.FormData.label: "Break Time (minutes):"; from: 1; to: 60 }

        RowLayout {
            Kirigami.FormData.label: "Quick Presets:"
            spacing: Kirigami.Units.largeSpacing 
            Layout.rightMargin: Kirigami.Units.largeSpacing

            Repeater {
                model: [
                    {f: 25, b: 5, c: "#81d4fa"}, 
                    {f: 45, b: 6, c: "#a5d6a7"}, 
                    {f: 50, b: 7, c: "#fff59d"}, 
                    {f: 60, b: 10, c: "#ffcc80"}
                ]
              delegate: PlasmaComponents.Button {
                    Layout.preferredWidth: 60
                    Layout.preferredHeight: 32
                    text: modelData.f + "|" + modelData.b
                    
                    // Force the button to be "flat" so it doesn't use the OS theme background
                    flat: true 
                    
                    // We define the background explicitly, and nothing else
                    background: Rectangle {
                        id: bgRect
                        radius: 6
                        border.color: modelData.c
                        border.width: 1
                        
                        // Use the same State/Transition logic as before
                        color: Qt.rgba(
                            parseInt(modelData.c.substr(1, 2), 16) / 255,
                            parseInt(modelData.c.substr(3, 2), 16) / 255,
                            parseInt(modelData.c.substr(5, 2), 16) / 255,
                            0.2
                        )
                    }

                    states: [
                        State {
                            name: "hovered"
                            when: hoverHandler.hovered
                            PropertyChanges { 
                                target: bgRect
                                // Set color to a high-opacity tint instead of white
                                color: Qt.rgba(
                                    parseInt(modelData.c.substr(1, 2), 16) / 255,
                                    parseInt(modelData.c.substr(3, 2), 16) / 255,
                                    parseInt(modelData.c.substr(5, 2), 16) / 255,
                                    0.6) 
                            }
                        }
                    ]

                    transitions: Transition {
                        ColorAnimation { duration: 150 }
                    }

                    HoverHandler { id: hoverHandler }

                    onClicked: {
                        focusTimeSpin.value = modelData.f
                        breakTimeSpin.value = modelData.b
                    }
                }
            }
        }
        Item { Kirigami.FormData.isSection: true; Kirigami.FormData.label: "Goals" }
        PlasmaComponents.SpinBox { id: goalSpin; Kirigami.FormData.label: "Daily Focus Goal (Hours):"; from: 1; to: 24 }
    
        Item { Kirigami.FormData.isSection: true; Kirigami.FormData.label: "Alerts" }
        
        PlasmaComponents.CheckBox {
            id: notifyCheck
            Kirigami.FormData.label: "System Notifications:"
            text: "Show popup when a session ends"
        }
    }

}