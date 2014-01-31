import QtQuick 1.1
import com.nokia.symbian 1.1
import com.nokia.extras 1.1
import "dbcore.js" as DBcore
import "fx.js" as CommonFx

// MANAGE FAVORITE CITIES - delete
Page {
    id: manageCities
    tools: mainToolbar

    // DEFAULT TOOLBAR
    // ================================================
    ToolBarLayout {
        id: mainToolbar

        ToolButton {
            id: toolbarbtnBack
            flat: true
            iconSource: "toolbar-back"
            onClicked: pageStack.pop()
            }
    }

    // ================================================
    // MAIN LISTVIEW
    // ================================================
    ListView {
        id: savedCitiesView
        anchors.fill: parent
        clip: true
        delegate: savedCitiesDelegate
    }

    Component {
        id: savedCitiesDelegate
            ListItem {
                property variant myData: model
                height:  cityTxt.height + cityidTxt.height + positionTxt.height + platformStyle.paddingMedium
                Text {
                    id: cityTxt
                    anchors.top: parent.top
                    anchors.topMargin: 5
                    anchors.left: parent.left
                    text: city + ", " + country
                    verticalAlignment: Text.AlignVCenter
                    color: "white"
                    font.pixelSize: platformStyle.fontSizeLarge
                    font.bold: true
                }
                Text {
                    id: cityidTxt
                    anchors.top: cityTxt.bottom
                    anchors.left: parent.left
                    text: "City ID " + model.cityid
                    verticalAlignment: Text.AlignVCenter
                    color: "lightgray"
                    font.pixelSize: platformStyle.fontSizeMedium
                }
                Text {
                    id: positionTxt
                    anchors.top: cityidTxt.bottom
                    anchors.left: parent.left
                    text: "Lat: " + model.lats.substring(0, model.lats.lastIndexOf('.') + 4) + " Long: " + model.longs.substring(0, model.longs.lastIndexOf('.') + 4)
                    verticalAlignment: Text.AlignVCenter
                    color: "lightgray"
                    font.pixelSize: platformStyle.fontSizeMedium
                }
                ToolButton {
                    id: deleteButton
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    iconSource: "toolbar-delete"
                    onClicked: {
                        savedCitiesView.currentIndex = index
                        delDialog.open()
                    }
                }

            }
    }

    ListModel {
        id: modelSavedCities
    }

    // ================================================
    // DELETE DIALOG
    // ================================================
    QueryDialog {
        id: delDialog
        titleText: "Remove city from favorites list?"
        message: savedCitiesView.currentItem.myData.city + ", " + savedCitiesView.currentItem.myData.country + " will be deleted.\n"
        acceptButtonText: "OK"
        rejectButtonText: "Cancel"
        onAccepted: {
            console.log("Removing favorite " + savedCitiesView.currentItem.myData.cityid + " " + savedCitiesView.currentItem.myData.city)
            DBcore.setFavorite(savedCitiesView.currentItem.myData.cityid, 0)
            delDialog.close()
            loadCityList()
        }
        onRejected: {
            delDialog.close()
        }
    }

    // LOAD LIST OF FAVORITE CITIES ON STARTUP AND AFTER UPDATES
    Component.onCompleted: {
        loadCityList()
    }

    function loadCityList() {
        console.log("Load favorite city list")
        savedCitiesView.model = 0
        DBcore.readCityList(modelSavedCities)
        savedCitiesView.model = modelSavedCities
    }

} // end page
