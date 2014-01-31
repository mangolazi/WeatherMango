import QtQuick 1.1
import com.nokia.symbian 1.1
import com.nokia.extras 1.1
import "dbcore.js" as DBcore
import "fx.js" as CommonFx

// SETTINGS - language, units
Page {
    id: settingsPage
    tools: mainToolbar

    property string p_lang_name : "" // language
    property string p_lang : "" // language
    property string p_units_name : "" // temperature units
    property string p_units : "" // temperature units
    property string p_windunits_name : "" // wind units
    property string p_windunits : "" // wind units


    // DEFAULT TOOLBAR
    // ================================================
    ToolBarLayout {
        id: mainToolbar

        ToolButton {
            id: toolbarbtnBack
            flat: true
            iconSource: "toolbar-back"
            onClicked: {
                saveSettings()
                CommonFx.settingsChanged = true;
                pageStack.pop()
            }
        }
    }

    // ================================================
    // language row - english, chinese, russian
    // for xml data only, not interface
    // ================================================
    Row {
        id: languageRow
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        Text {
            text: qsTr("Language")  + rootItem.emptyString
            width: parent.width / 2
            anchors.verticalCenter: languageList.verticalCenter
            horizontalAlignment: Text.AlignLeft
            color: "white"
            font.pixelSize: platformStyle.fontSizeLarge
            font.bold: true
            wrapMode: Text.Wrap
        }

        // Category chooser
        SelectionListItem {
            id: languageList
            width: parent.width / 2
            onClicked: languageDialog.open()

            SelectionDialog {
                id: languageDialog
                titleText: qsTr("Select a language") + rootItem.emptyString
                selectedIndex: -1
                model: ListModel {
                    ListElement { name: "English"; language: "en" }
                    ListElement { name: "Bulgarian"; language: "bg" }
                    ListElement { name: "German"; language: "de" }
                    ListElement { name: "French"; language: "fr"}
                    ListElement { name: "Spanish"; language: "es" }
                    ListElement { name: "Hungarian"; language: "hu" }
                    ListElement { name: "Italian"; language: "it" }
                    ListElement { name: "Macedonian"; language: "mk" }
                    ListElement { name: "Dutch"; language: "nl" }
                    ListElement { name: "Russian"; language: "ru" }
                    ListElement { name: "Turkish"; language: "tr" }
                }
                delegate: Component {
                    MenuItem {
                        text: name
                        onClicked: {
                            languageList.title = model.name
                            p_lang_name = model.name
                            p_lang = model.language
                            selectedIndex = index
                            root.accept()
                        }
                    }
                }
            }
        }

    } // end language row


    // units row - metric, imperial, us
    Row {
        id: unitsRow
        anchors.top: languageRow.bottom
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.right: parent.right

        Text {
            text: qsTr("Units")
            width: parent.width / 2
            anchors.verticalCenter: unitsList.verticalCenter
            horizontalAlignment: Text.AlignLeft
            color: "white"
            font.pixelSize: platformStyle.fontSizeLarge
            font.bold: true
            wrapMode: Text.Wrap
        }

        SelectionListItem {
            id: unitsList
            width: parent.width / 2
            onClicked: unitsDialog.open()

            SelectionDialog {
                id: unitsDialog
                titleText: qsTr("Select temperature units") + rootItem.emptyString
                selectedIndex: -1
                model: ListModel {
                    ListElement { name: "Celsius"; units: "celsius" }
                    ListElement { name: "Fahrenheit"; units: "fahrenheit"}
                    }
                delegate: Component {
                    MenuItem {
                        text: name
                        onClicked: {
                            unitsList.title = model.name
                            p_units_name = model.name
                            p_units = model.units
                            selectedIndex = index
                            root.accept()
                        }
                    }
                }
            }
        }
    }  // end units row

    // windspeed units row
    Row {
        id: windunitsRow
        anchors.top: unitsRow.bottom
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.right: parent.right

        Text {
            text: qsTr("Wind units") + rootItem.emptyString
            width: parent.width / 2
            anchors.verticalCenter: windunitsList.verticalCenter
            horizontalAlignment: Text.AlignLeft
            color: "white"
            font.pixelSize: platformStyle.fontSizeLarge
            font.bold: true
            wrapMode: Text.Wrap
        }

        // Category chooser
        SelectionListItem {
            id: windunitsList
            width: parent.width / 2
            onClicked: windunitsDialog.open()


            SelectionDialog {
                id: windunitsDialog
                titleText: qsTr("Select wind measurement") + rootItem.emptyString
                selectedIndex: -1
                model: ListModel {
                    ListElement { name: "meters / second"; windunits: "ms" }
                    ListElement { name: "km / hour"; windunits: "kph" }
                    ListElement { name: "feet / second"; windunits: "fs" }
                    ListElement { name: "miles / hour"; windunits: "mph" }
                    }
                delegate: Component {
                    MenuItem {
                        text: name
                        onClicked: {
                            windunitsList.title = model.name
                            p_windunits_name = model.name
                            p_windunits = model.windunits
                            selectedIndex = index
                            root.accept()
                        }
                    }
                }
            }
        }


    } // end windspeed units row


    // load current settings
    onStatusChanged: {
        if ( status == PageStatus.Activating  ) {
           var configitem;
            configitem = DBcore.readConfig("language_name")
            p_lang_name = configitem.configvalue
            languageList.title = p_lang_name
            configitem = DBcore.readConfig("language")
            p_lang = configitem.configvalue

            configitem = DBcore.readConfig("units_name")
            p_units_name = configitem.configvalue
            unitsList.title = p_units_name
            configitem = DBcore.readConfig("units")
            p_units = configitem.configvalue

            configitem = DBcore.readConfig("windunits_name")
            p_windunits_name = configitem.configvalue
            windunitsList.title = p_windunits_name
            configitem = DBcore.readConfig("windunits")
            p_windunits = configitem.configvalue

            console.log("LOAD DB " + p_lang + " " + p_units + " " + p_windunits)
            console.log("LOAD DB " + p_lang_name + " " + p_units_name + " " + p_windunits_name)
        }
    }

    // ================================================
    // SAVE SETTINGS TO DB, ASSIGN TO PUBLIC SETTINGS, RESET DYNAMIC TRANSLATION
    // ================================================
    function saveSettings() {
        var configitem = DBcore.defaultConfigItem()
        configitem.configkey = "language"
        configitem.configvalue = p_lang
        DBcore.deleteConfig(configitem.configkey)
        DBcore.createConfig(configitem);

        configitem.configkey = "language_name"
        configitem.configvalue = p_lang_name
        DBcore.deleteConfig(configitem.configkey)
        DBcore.createConfig(configitem);

        configitem.configkey = "units"
        configitem.configvalue = p_units
        DBcore.deleteConfig(configitem.configkey)
        DBcore.createConfig(configitem);

        configitem.configkey = "units_name"
        configitem.configvalue = p_units_name
        DBcore.deleteConfig(configitem.configkey)
        DBcore.createConfig(configitem);

        configitem.configkey = "windunits"
        configitem.configvalue = p_windunits
        DBcore.deleteConfig(configitem.configkey)
        DBcore.createConfig(configitem);

        configitem.configkey = "windunits_name"
        configitem.configvalue = p_windunits_name
        DBcore.deleteConfig(configitem.configkey)
        DBcore.createConfig(configitem);

        CommonFx.language = p_lang
        CommonFx.units = p_units
        CommonFx.windunits = p_windunits

        rootItem.selectLanguage(p_lang);

        console.log("SAVE DB " + p_lang + " " + p_units + " " + p_windunits)
        console.log("SAVE DB " + p_lang_name + " " + p_units_name + " " + p_windunits_name)
    }

}// end page
