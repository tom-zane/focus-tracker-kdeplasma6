import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

Item {
    id: page
    width: childrenRect.width
    height: childrenRect.height

    property alias cfg_ringColor: colorField.text
    property string cfg_clockFontFamily

    Kirigami.FormLayout {
        anchors.left: parent.left
        anchors.right: parent.right

        Item { Kirigami.FormData.isSection: true; Kirigami.FormData.label: "Typography" }
        PlasmaComponents.ComboBox {
            id: fontComboBox
            Kirigami.FormData.label: "Timer Font:"
            model: Qt.fontFamilies()
            currentIndex: fontComboBox.find(page.cfg_clockFontFamily)
            onActivated: page.cfg_clockFontFamily = currentText
        }

        Item { Kirigami.FormData.isSection: true; Kirigami.FormData.label: "Theme" }
        PlasmaComponents.TextField {
            id: colorField
            Kirigami.FormData.label: "Ring Color (Hex):"
            placeholderText: "#3daee9"
            Rectangle {
                anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter; anchors.margins: Kirigami.Units.smallSpacing
                width: height; height: parent.height - (Kirigami.Units.smallSpacing * 2)
                color: colorField.text; border.color: Kirigami.Theme.textColor; border.width: 1; radius: 3
            }
        }
        RowLayout {
            Kirigami.FormData.label: "Quick Presets:"
            spacing: Kirigami.Units.smallSpacing
            Repeater {
                model: ["#3daee9", "#2ecc71", "#f1c40f", "#e74c3c", "#9b59b6", "#e67e22", "#1abc9c"]
                delegate: Rectangle {
                    width: 24; height: 24; radius: 12; color: modelData
                    border.color: colorField.text === modelData ? Kirigami.Theme.textColor : "transparent"; border.width: 2
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: colorField.text = modelData }
                }
            }
        }
    }
}