import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.LocalStorage
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

Item {
    id: page
    width: childrenRect.width
    height: childrenRect.height

    function getDb() {
        return LocalStorage.openDatabaseSync("FocusTrackerDB", "1.0", "Storage for Focus Sessions", 100000);
    }

    function showMessage(msg, isError = false) {
        statusBanner.text = msg;
        statusBanner.type = isError ? Kirigami.MessageType.Error : Kirigami.MessageType.Positive;
        statusBanner.visible = true;
    }

    Kirigami.FormLayout {
        anchors.left: parent.left
        anchors.right: parent.right

        // Status Banner
        Kirigami.InlineMessage {
            id: statusBanner
            Layout.fillWidth: true
            showCloseButton: true
            visible: false
        }

        Item { Kirigami.FormData.isSection: true; Kirigami.FormData.label: "Log Data" }
        
        // 1. Manual Entry
        RowLayout {
            Kirigami.FormData.label: "Manual Entry:"
            PlasmaComponents.Button {
                text: manualForm.visible ? "Close" : "Add Past Session"
                icon.name: "list-add"
                onClicked: { manualForm.visible = !manualForm.visible; allDbFormsOff(manualForm); }
            }
        }
        ColumnLayout {
            id: manualForm
            visible: false
            Kirigami.FormData.label: "" 
            RowLayout {
                PlasmaComponents.TextField { id: manualDate; placeholderText: "YYYY-MM-DD" }
                PlasmaComponents.TextField { id: manualStart; placeholderText: "09:00" }
                PlasmaComponents.TextField { id: manualEnd; placeholderText: "11:30" }
                PlasmaComponents.Button {
                    text: "Save"
                    onClicked: {
                        try {
                            let startParts = manualStart.text.split(":");
                            let endParts = manualEnd.text.split(":");
                            let startMins = parseInt(startParts[0])*60 + parseInt(startParts[1]);
                            let endMins = parseInt(endParts[0])*60 + parseInt(endParts[1]);
                            if (endMins <= startMins) throw "End time must be after start time.";
                            
                            let elapsedSeconds = (endMins - startMins) * 60;
                            let timestamp = manualDate.text + " " + manualEnd.text + ":00";
                            
                            let db = getDb();
                            db.transaction(function(tx) {
                                tx.executeSql("INSERT INTO sessions (type, duration_seconds, elapsed_seconds, status, timestamp) VALUES ('Focus', ?, ?, 'Completed', ?)", 
                                    [elapsedSeconds, elapsedSeconds, timestamp]);
                            });
                            showMessage("Manual session logged: " + (elapsedSeconds/60) + " minutes.");
                            manualDate.text = ""; manualStart.text = ""; manualEnd.text = "";
                            manualForm.visible = false;
                        } catch (err) { showMessage("Error: " + err, true); }
                    }
                }
            }
        }

        Item { Kirigami.FormData.isSection: true; Kirigami.FormData.label: "Data Management" }

        // 2. Danger Zone
        RowLayout {
            spacing: Kirigami.Units.smallSpacing
            Kirigami.FormData.label: "Danger Zone:"
            PlasmaComponents.Button {
                text: fakeDataForm.visible ? "Cancel" : "Load Fake Data"
                icon.name: "tools-wizard"
                onClicked: { fakeDataForm.visible = !fakeDataForm.visible; allDbFormsOff(fakeDataForm); }
            }
            PlasmaComponents.Button {
                text: clearDbForm.visible ? "Cancel" : "Clear Database"
                icon.name: "edit-delete"
                Kirigami.Theme.colorSet: Kirigami.Theme.Negative 
                onClicked: { clearDbForm.visible = !clearDbForm.visible; allDbFormsOff(clearDbForm); }
            }
        }

        // Fake Data Form
        RowLayout {
            id: fakeDataForm
            visible: false
            Kirigami.FormData.label: ""
            PlasmaComponents.TextField { id: debugPasscode; placeholderText: "Passcode (6969)"; echoMode: TextInput.Password }
            PlasmaComponents.Button {
                text: "Inject"
                onClicked: {
                    if (debugPasscode.text === "6969") {
                        let db = getDb();
                        db.transaction(function(tx) {
                            let now = new Date();
                            for(let i = 0; i < 30; i++) {
                                let d = new Date(now);
                                d.setDate(d.getDate() - i);
                                let seconds = Math.floor(Math.random() * 14400) + 1800;
                                let dateStr = d.toISOString().replace('T', ' ').substring(0, 19);
                                tx.executeSql("INSERT INTO sessions (type, duration_seconds, elapsed_seconds, status, timestamp) VALUES ('Focus', ?, ?, 'Completed', ?)", 
                                    [seconds, seconds, dateStr]);
                            }
                        });
                        showMessage("Fake data injected!");
                        fakeDataForm.visible = false;
                    } else { showMessage("Incorrect passcode.", true); }
                    debugPasscode.text = "";
                }
            }
        }

        // Clear DB Form
        RowLayout {
            id: clearDbForm
            visible: false
            Kirigami.FormData.label: ""
            PlasmaComponents.TextField { 
                id: clearConfirmText
                placeholderText: "Type 'yes, clear db'" 
                font.pixelSize: 16
                Layout.preferredHeight: 40
                Layout.preferredWidth: 250
                horizontalAlignment: TextInput.AlignHCenter 
            }
            PlasmaComponents.Button {
                text: "Wipe Data"
                // error theme
                Kirigami.Theme.colorSet: Kirigami.Theme.Negative
                onClicked: {
                    if (clearConfirmText.text === "yes, clear db") {
                        let db = getDb();
                        db.transaction(function(tx) { tx.executeSql("DELETE FROM sessions"); });
                        showMessage("Database wiped cleanly.");
                        clearDbForm.visible = false;
                    } else { showMessage("Clear aborted. Text did not match.", true); }
                    clearConfirmText.text = "";
                }
            }
        }
    }

    function allDbFormsOff(except) {
        if (except !== manualForm) manualForm.visible = false;
        if (except !== fakeDataForm) fakeDataForm.visible = false;
        if (except !== clearDbForm) clearDbForm.visible = false;
        statusBanner.visible = false;
    }
}