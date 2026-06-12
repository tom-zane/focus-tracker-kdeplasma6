import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: "General"
        icon: "settings-configure"
        source: "configGeneral.qml"
    }
    ConfigCategory {
        name: "Appearance"
        icon: "preferences-desktop-color" 
        source: "configAppearance.qml"
    }
    ConfigCategory {
        name: "Database"
        icon: "server-database"
        source: "configDatabase.qml"
    }
}