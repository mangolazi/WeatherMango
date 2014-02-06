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
    property string p_firstpage : "" // daily or hourly view as first page
    property string p_hourunits : "" // am/pm or 24 hour time


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
        ToolButton {
            id: toolbarbtnAbout
            flat: false
            text: "About"
            onClicked: {
                pageStack.push(Qt.resolvedUrl("About.qml"))
            }
        }
    }

    // ================================================
    // language row - english, chinese, russian
    // for xml data only, not interface
    // ================================================
    Flickable {
         width: parent.width
         height: parent.height
         contentWidth: parent.width
         contentHeight: languageRow.height + unitsRow.height + windunitsRow.height + firstpageRow.height + hourunitsRow.height + hourunitsRow.height


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

    // hour units row
    Row {
        id: hourunitsRow
        anchors.top: firstpageRow.bottom
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.right: parent.right

        Text {
            text: qsTr("Hour units") + rootItem.emptyString
            width: parent.width / 2
            anchors.verticalCenter: hourunitsList.verticalCenter
            horizontalAlignment: Text.AlignLeft
            color: "white"
            font.pixelSize: platformStyle.fontSizeLarge
            font.bold: true
            wrapMode: Text.Wrap
        }

        // Category chooser
        SelectionListItem {
            id: hourunitsList
            width: parent.width / 2
            onClicked: hourunitsDialog.open()

            SelectionDialog {
                id: hourunitsDialog
                titleText: qsTr("Hour units") + rootItem.emptyString
                selectedIndex: -1
                model: ListModel {
                    ListElement { name: "am pm"; hourunits: "am pm" }
                    ListElement { name: "24"; hourunits: "24" }
                    }
                delegate: Component {
                    MenuItem {
                        text: name
                        onClicked: {
                            hourunitsList.title = model.name
                            p_hourunits = model.hourunits
                            selectedIndex = index
                            root.accept()
                        }
                    }
                }
            }
        }
    } // end firstpage row

    // firstpage row
    Row {
        id: firstpageRow
        anchors.top: windunitsRow.bottom
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.right: parent.right

        Text {
            text: qsTr("First page") + rootItem.emptyString
            width: parent.width / 2
            anchors.verticalCenter: firstpageList.verticalCenter
            horizontalAlignment: Text.AlignLeft
            color: "white"
            font.pixelSize: platformStyle.fontSizeLarge
            font.bold: true
            wrapMode: Text.Wrap
        }

        // Category chooser
        SelectionListItem {
            id: firstpageList
            width: parent.width / 2
            onClicked: firstpageDialog.open()

            SelectionDialog {
                id: firstpageDialog
                titleText: qsTr("Forecast to view on loading") + rootItem.emptyString
                selectedIndex: -1
                model: ListModel {
                    ListElement { name: "daily"; firstpage: "daily" }
                    ListElement { name: "hourly"; firstpage: "hourly" }
                    }
                delegate: Component {
                    MenuItem {
                        text: name
                        onClicked: {
                            firstpageList.title = model.name
                            p_firstpage = model.firstpage
                            selectedIndex = index
                            root.accept()
                        }
                    }
                }
            }
        }
    } // end firstpage row

    } // end flickable

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

            configitem = DBcore.readConfig("firstpage")
            p_firstpage = configitem.configvalue
            firstpageList.title = p_firstpage

            configitem = DBcore.readConfig("hourunits")
            p_hourunits = configitem.configvalue
            hourunitsList.title = p_hourunits

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

        configitem.configkey = "firstpage"
        configitem.configvalue = p_firstpage
        DBcore.deleteConfig(configitem.configkey)
        DBcore.createConfig(configitem);

        configitem.configkey = "hourunits"
        configitem.configvalue = p_hourunits
        DBcore.deleteConfig(configitem.configkey)
        DBcore.createConfig(configitem);

        CommonFx.language = p_lang
        CommonFx.units = p_units
        CommonFx.windunits = p_windunits
        CommonFx.hourunits = p_hourunits

        rootItem.selectLanguage(p_lang);

        console.log("SAVE DB " + p_lang + " " + p_units + " " + p_windunits)
        console.log("SAVE DB " + p_lang_name + " " + p_units_name + " " + p_windunits_name + " " + p_firstpage + p_hourunits)
    }

}// end page
