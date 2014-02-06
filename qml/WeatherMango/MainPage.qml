/* Copyright © mangolazi 2013.
This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 1.1
import com.nokia.symbian 1.1
import com.nokia.extras 1.1
import QtMobility.location 1.1
import "dbcore.js" as DBcore
import "fx.js" as Commonfx

Page {
    id: mainPage
    tools: mainToolbar
    property string cityParam: "" // city name to search for
    property string cityActive: "" // currently active city ID
    property bool useGPSPosition: false // use gps position or search by city name
    property string homeCity: "" // home city??
    property int favoriteCity: 0 // favorite city, 0=no, 1=yes
    property int favoriteCityIndex: 0 // index in favorite city model
    property int timezone: 0 // user's time zone

    // DEFAULT TOOLBAR
    // ================================================
    ToolBarLayout {
        id: mainToolbar

        ToolButton {
            id: toolbarbtnBack
            flat: true
            iconSource: (flipable.flipped == true) ? "toolbar-back" : "qrc:/icons/close_stop"
            onClicked: (flipable.flipped == true) ? (flipable.flipped = false) : Qt.quit()
            }

        ToolButton {
            id: toolbarbtnHome
            flat: true
            iconSource: "toolbar-home"
            property bool longPress : false
            onPlatformReleased: {
                // refresh last city data first, then load gps position
                if (longPress == false) {
                    if (homeCity != "") {
                        cityActive = homeCity
                        favoriteCityIndex = -1
                        loadLocalDB()
                        // set favorite city status from database, if set
                        favoriteCity = modelCity.get(0).favoritecity
                        // load online data if more than an hour has passed since last update
                        if (Commonfx.getNewUpdate(modelCity.get(0).lastupdate, timezone) == true) {
                            xmlCity.query = "/current"
                            xmlCity.source = "http://api.openweathermap.org/data/2.5/weather?id=" + cityActive + "&units=metric&lang=en&mode=xml"
                            xmlCity.reload()
                        }
                    }
                }
                longPress = false
            }
            onPlatformPressAndHold: {
                //favoriteCity = 1
                gpsSource.active = true
                gpsSource.update()
                longPress = true
            }
        }

        ToolButton {
            id: toolbarbtnFavorites
            flat: true
            iconSource: "toolbar-list"
            onClicked: savedCitiesDialog.open()
        }

        ToolButton {
            id: toolbarbtnSearch
            flat: true
            iconSource: "toolbar-search"
            onClicked: searchDialog.open()
        }

        ToolButton {
            id: toolbarbtnMenu
            flat: true
            iconSource: "toolbar-menu"
            onClicked: mainMenu.open()
        }
    } // end toolbar

    // ================================================
    // MAIN MENU
    // ================================================
    Menu {
         id: mainMenu
         content: MenuLayout {
             MenuItem {
                 text: qsTr("Set as favorite city") + rootItem.emptyString
                 onClicked: {
                     console.log("Setting as favorite " + cityActive)
                     DBcore.setFavorite(cityActive, 1)
                 }
             }
             MenuItem {
                 text: qsTr("Manage favorite cities") + rootItem.emptyString
                 onClicked: pageStack.push(Qt.resolvedUrl("ManageCities.qml"))
             }
             MenuItem {
                 text: qsTr("Refresh") + rootItem.emptyString
                 onClicked: {
                     if (cityActive != "") {
                         favoriteCity = modelCity.get(0).favoritecity
                         xmlCity.query = "/current"
                         xmlCity.source = "http://api.openweathermap.org/data/2.5/weather?id=" + cityActive + "&units=metric&lang=en&mode=xml"
                         xmlCity.reload()
                         infoBanner.showText("Refreshing weather data...")
                     }
                 }
             }
             MenuItem {
                 text: qsTr("View on OpenWeatherMap.org") + rootItem.emptyString
                 onClicked: Qt.openUrlExternally("http://m.openweathermap.org/city/" + cityActive)
             }
             MenuItem {
                 text: qsTr("Settings") + rootItem.emptyString
                 onClicked: pageStack.push(Qt.resolvedUrl("Settings.qml"))
             }
             /*MenuItem {
                 text: qsTr("About")  + rootItem.emptyString
                 onClicked: pageStack.push(Qt.resolvedUrl("About.qml"))
             }*/
         }
     }

    // ================================================
    // SEARCH DIALOG
    // ================================================
    CommonDialog {
        id: searchDialog
        titleText: qsTr("Search for city")  + rootItem.emptyString
        buttonTexts: ["OK", "Cancel"]
        content:
            TextField {
                 id: searchBox
                 anchors.top: parent.top
                 anchors.topMargin: 10
                 anchors.left: parent.left
                 anchors.leftMargin: 10
                 anchors.right: parent.right
                 anchors.rightMargin: 10
                 placeholderText: qsTr("Enter city name...")  + rootItem.emptyString
                 Keys.onReturnPressed : { searchCity() }
                 Keys.onEnterPressed : { searchCity() }
             }

        onButtonClicked: {
            if (!index) { // OK button pressed
                searchCity()
            }
            else { // cancel button pressed
                close()
            }
            searchBox.text = ""
        }

        function searchCity() {
            console.log("Searching for city")
            if (searchBox.text != "") {
                useGPSPosition = false
                cityParam = searchBox.text
                forecastViewDaily.model  = 0
                forecastViewHourly.model = 0
                favoriteCity = 0
                xmlCity.query = "/cities/list/item"
                xmlCity.source = "http://api.openweathermap.org/data/2.5/find?q=" + cityParam + "&units=metric&lang=en&mode=xml"
                xmlCity.reload()
                close()
            }
        }
    }

    // ================================================
    // MULTIPLE CITIES DIALOG, CHOOSE ONE
    // ================================================
    SelectionDialog {
        id: selectionDialog
        titleText: qsTr("Select a city to view")  + rootItem.emptyString
        selectedIndex: -1
        model: xmlCity
        delegate: selectionDialogDelegate
    }
    Component {
            id: selectionDialogDelegate
            MenuItem {
                text: city + ", " + country + " (" + lats.substring(0, lats.lastIndexOf('.') + 4) + ", " + longs.substring(0, longs.lastIndexOf('.') + 4)  + ")"
                onClicked: {
                    selectedIndex = index
                    xmlCity.xmlCityLoaded()
                    close()
                }
            }
    }

    // ================================================
    // SAVED CITIES DIALOG
    // ================================================
    SelectionDialog {
        id: savedCitiesDialog
        titleText: qsTr("Select favorite city to view")  + rootItem.emptyString
        selectedIndex: -1
        delegate: savedCitiesDelegate
        onStatusChanged: {
            if (status == Component.Ready) {
                useGPSPosition = false // don't save as home city again
                console.log("Loading list of favorite cities")
                savedCitiesDialog.model = 0
                DBcore.readCityList(modelSavedCities)
                savedCitiesDialog.model = modelSavedCities
            }
        }
    }
    Component {
            id: savedCitiesDelegate
            MenuItem {
                text: city + ", " + country + " (" + lats.substring(0, lats.lastIndexOf('.') + 4) + ", " + longs.substring(0, longs.lastIndexOf('.') + 4)  + ")"
                onClicked: {
                    cityActive = model.cityid
                    favoriteCityIndex = index
                    console.log("Fav city is " + cityActive + " " + model.city + ", " + model.country)
                    loadLocalDB()

                    // set favorite city status from database, if set
                    favoriteCity = modelCity.get(0).favoritecity
                    console.log("Setting favorite city status to " + favoriteCity)

                    // load online data if more than an hour has passed since last update
                    if (Commonfx.getNewUpdate(modelCity.get(0).lastupdate, timezone) == true) {
                        xmlCity.query = "/current"
                        xmlCity.source = "http://api.openweathermap.org/data/2.5/weather?id=" + cityActive + "&units=metric&lang=en&mode=xml"
                        xmlCity.reload()
                    }
                    close()
                }
            }
    }
    ListModel {
        id: modelSavedCities
    }

    // ================================================
    // PROGRESS BAR, to show XML loading progress
    // ================================================
    Rectangle {
        id: loadingBar
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        height: 40
        width: progressbar.width + 10
        z: 1
        color: "#202020"
        state: "hidden"
        radius: 20
        property alias value: progressbar.value

        ProgressBar {
            id: progressbar
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            width: 160
            minimumValue: 0
            maximumValue: 3
            value: 0
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                loadingBar.state = "hidden"
            }
        }

        states: [
            State { name: "hidden"; PropertyChanges { target: loadingBar; visible: false; opacity: 0.2 } },
            State { name: "loading"; PropertyChanges { target: loadingBar; visible: true; opacity: 1.0 } }
        ]
        transitions: [
            Transition {
                from: "loading"
                to: "hidden"
                PropertyAnimation { target: loadingBar; property: "opacity"; duration: 600 }
                PropertyAnimation { target: loadingBar; property: "visible"; duration: 600 }
            },
            Transition {
                from: "hidden"
                to: "loading"
                PropertyAnimation { target: loadingBar; property: "opacity"; duration: 600 }
                PropertyAnimation { target: loadingBar; property: "visible"; duration: 100 }
            }
        ]

    }

    // ================================================
    // CITY VIEW
    // ================================================
    Flickable {
        id: cityFlick
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: parent.height / 3 + 20
        flickableDirection: Flickable.HorizontalFlick

        Loader {
            id: cityView
            anchors.fill: parent

            // properties to map to DB or XML values
            property string p_city : ""
            property string p_country : ""
            property string p_lastupdate : ""
            property string p_icon : ""
            property real p_currenttemp : 0
            property string p_tempunit : ""
            property string p_sunrise : ""
            property string p_sunset : ""
            property real p_winddirection : 0
            property real p_windspeed : 0
            property string p_humidity : ""
            property string p_humidityunit : ""
        } // end city loader

    states: [
        State {
            name: "PORTRAIT";
            PropertyChanges { target: cityFlick; height: parent.height / 3 + 20}
            PropertyChanges { target: cityView; source: "" }
            PropertyChanges { target: cityView; source: "CityDelePortrait.qml" }
        },
        State {
            name: "LANDSCAPE";
            PropertyChanges { target: cityFlick; height: parent.height / 3 + 35}
            PropertyChanges { target: cityView; source: "" }
            PropertyChanges { target: cityView; source: "CityDeleLandscape.qml" }
        },
        State {
            name: "E6";
            PropertyChanges { target: cityFlick; height: parent.height / 2 - 10 }
            PropertyChanges { target: cityView; source: "" }
            PropertyChanges { target: cityView; source: "CityDeleE6.qml" }
        }
    ]

    // FLICKABLE FUNCTIONS
    onFlickStarted: {
        // Left flick, advance forward through favorite cities list
        if (horizontalVelocity > 0) {
            favoriteCityIndex += 1
            if (favoriteCityIndex < modelSavedCities.count) {
                // if next city is not home city, load, otherwise skip
                if (homeCity != modelSavedCities.get(favoriteCityIndex).cityid) {
                    console.log("Not home city, loading data + " + favoriteCityIndex)
                    cityActive = modelSavedCities.get(favoriteCityIndex).cityid
                }
                else {
                    favoriteCityIndex += 1
                    cityActive = modelSavedCities.get(favoriteCityIndex).cityid
                    console.log("Home city found, skipping to + " + favoriteCityIndex)
                }
            }
            else { // at end, loop back to home city
                console.log("End, loop back to start, home")
                favoriteCityIndex = -1
                cityActive = homeCity
            }
        }
        // Right flick, reverse through favorite cities list
        else {            
            favoriteCityIndex -= 1
            if (favoriteCityIndex > 0) {
                if (homeCity != modelSavedCities.get(favoriteCityIndex).cityid) {
                    console.log("Not home city, loading data - " + favoriteCityIndex)
                    cityActive = modelSavedCities.get(favoriteCityIndex).cityid
                }
                else {
                    favoriteCityIndex -= 1
                    cityActive = modelSavedCities.get(favoriteCityIndex).cityid
                    console.log("Home city found, skipping to - " + favoriteCityIndex)
                }
            }
            else { // at end, loop back to home
                console.log("End, loop back to start, home")
                favoriteCityIndex = -1
                cityActive = homeCity
            }
        }

        // load online data if more than an hour has passed since last update
        loadLocalDB()

        if (Commonfx.getNewUpdate(modelCity.get(0).lastupdate, timezone) == true) {
            console.log("Supposed to reload data")
            xmlCity.query = "/current"
            xmlCity.source = "http://api.openweathermap.org/data/2.5/weather?id=" + cityActive + "&units=metric&lang=en&mode=xml"
            xmlCity.reload()
        }
    }

    } // end city flick


    // ================================================
    // FLIPABLE FOR DAILY/HOURLY FORECAST VIEWS
    // ================================================
    Rectangle {
        anchors.top: cityFlick.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        gradient: Gradient {
                GradientStop { position: 0.0; color: "#000000" }
                GradientStop { position: 1.0; color: "#303030" }
            }

    Flipable {
         id: flipable
         anchors.fill: parent
         property bool flipped: false

         // ================================================
         // DAILY FORECAST VIEW
         // ================================================
         front:
             ListView {
             id: forecastViewDaily
             anchors.fill: parent
             clip: true
             orientation: ListView.Vertical
             enabled: true

             states: [
                 State {
                     name: "PORTRAIT";
                     PropertyChanges { target: forecastViewDaily; orientation: ListView.Vertical }
                     PropertyChanges { target: forecastViewDaily; delegate: forecastDelePortrait }
                 },
                 State {
                     name: "LANDSCAPE";
                     PropertyChanges { target: forecastViewDaily; orientation: ListView.Horizontal }
                     PropertyChanges { target: forecastViewDaily; delegate: forecastDeleLandscape }
                 },
                 State {
                     name: "E6";
                     PropertyChanges { target: forecastViewDaily; orientation: ListView.Horizontal }
                     PropertyChanges { target: forecastViewDaily; delegate: forecastDeleE6 }
                 }
             ]
         }

         // ================================================
         // HOURLY FORECAST VIEW
         // ================================================
         back:
             ListView {
             id: forecastViewHourly
             anchors.fill: parent
             clip: true
             orientation: ListView.Vertical
             enabled: true
                 /*Loader {
                     source: getHourlyDele()
                     function getHourlyDele() {
                         if (forecastViewHourly.state == "PORTRAIT") return "HourlyDelePortrait.qml"
                         if (forecastViewHourly.state == "LANDSCAPE") return "HourlyDeleLandscape.qml"
                         if (forecastViewHourly.state == "E6") return "HourlyDeleE6.qml"
                     }
                 }*/


             states: [
                 State {
                     name: "PORTRAIT";
                     PropertyChanges { target: forecastViewHourly; orientation: ListView.Vertical }
                     PropertyChanges { target: forecastViewHourly; delegate: hourlyDelePortrait }
                 },
                 State {
                     name: "LANDSCAPE";
                     PropertyChanges { target: forecastViewHourly; orientation: ListView.Horizontal }
                     PropertyChanges { target: forecastViewHourly; delegate: hourlyDeleLandscape }
                 },
                 State {
                     name: "E6";
                     PropertyChanges { target: forecastViewHourly; orientation: ListView.Horizontal }
                     PropertyChanges { target: forecastViewHourly; delegate: hourlyDeleE6 }
                 }
             ]
         }

         transform: Rotation {
             id: rotation
             origin.x: flipable.width/2
             origin.y: flipable.height/2
             axis.x: 1; axis.y: 0; axis.z: 0     // set axis.y to 1 to rotate around y-axis
             angle: 0    // the default angle
         }

         states: State {
             name: "back"
             PropertyChanges { target: rotation; angle: 180 }
             when: flipable.flipped
         }

         transitions: Transition {
             NumberAnimation { target: rotation; property: "angle"; duration: 300 }
         }
     } // end flipable

    } // end rectangle

    // ================================================
    // MISC FORECAST MODELS FOR DATABASE ACCESS AND DELEGATES
    // ================================================
    ListModel { id: modelCity }
    ListModel { id: modelForecastDaily }
    ListModel { id: modelForecastHourly }

    ForecastDeleE6 { id: forecastDeleE6 }
    ForecastDeleLandscape { id: forecastDeleLandscape }
    ForecastDelePortrait { id: forecastDelePortrait }
    HourlyDeleE6 { id: hourlyDeleE6 }
    HourlyDeleLandscape { id: hourlyDeleLandscape }
    HourlyDelePortrait { id: hourlyDelePortrait }

    // ================================================
    // CITY XML MODEL
    // ================================================
    XmlListModel {
        id: xmlCity
        query: "/current"

        property int cityIndex : 0 // city index if multiple

        XmlRole { name: "cityid"; query: "city/@id/string()" }
        XmlRole { name: "city"; query: "city/@name/string()" }
        XmlRole { name: "country"; query: "city/country/string()" }
        XmlRole { name: "lats"; query: "city/coord/@lat/string()" }
        XmlRole { name: "longs"; query: "city/coord/@lon/string()" }
        XmlRole { name: "sunrise"; query: "city/sun/@rise/string()" }
        XmlRole { name: "sunset"; query: "city/sun/@set/string()" }
        XmlRole { name: "currenttemp"; query: "temperature/@value/number()" }
        XmlRole { name: "tempunit"; query: "temperature/@unit/string()" }
        XmlRole { name: "icon"; query: "weather/@icon/string()" }
        XmlRole { name: "weathernumber"; query: "weather/@number/string()" }
        XmlRole { name: "humidity"; query: "humidity/@value/string()" }
        XmlRole { name: "humidityunit"; query: "humidity/@unit/string()" }
        XmlRole { name: "windspeed"; query: "wind/speed/@value/number()" }
        XmlRole { name: "winddirection"; query: "wind/direction/@value/number()" }
        XmlRole { name: "lastupdate"; query: "lastupdate/@value/string()" }

        onStatusChanged: {
            if ((status == XmlListModel.Error) && (source != "")) {
                loadingBar.state = "hidden"
                loadingBar.value = 0
            }
            if ((status == XmlListModel.Loading) && (source != "")) {
                loadingBar.value = 0
                loadingBar.state = "loading"
            }
            if ((status == XmlListModel.Ready) && (source != "")) {
                loadingBar.value = progress
                xmlCityChoose()
            }
        }

        function xmlCityChoose() {
            //cityView.model = 0
            forecastViewDaily.model = 0
            forecastViewHourly.model = 0
            if (xmlCity.count == 0) {
                // no city found
                infoBanner.showText("No city found, please search for another city")
                loadingBar.state = "hidden"
            }
            else {
                // one city found
                if (xmlCity.count == 1) {
                    console.log("One city found")
                    cityIndex = 0
                    xmlCityLoaded()
                }
                else {
                    // choose city between multiple results
                    console.log("multiple cities")
                    selectionDialog.open()
                    loadingBar.state = "hidden"
                }
            }
        }

        function xmlCityLoaded() {
            if (xmlCity.count > 1) {
                if (selectionDialog.selectedIndex> -1 )  {
                    cityIndex = selectionDialog.selectedIndex
                } else {
                    // if cancelled, no gps save setting and home city setting
                    useGPSPosition = false
                }
            }
            loadingBar.state = "loading"
            console.log("Cityindex is " + cityIndex)
            modelCity.clear()

            // load XML data into city view
            cityView.p_city = xmlCity.get(cityIndex).city
            cityView.p_country = xmlCity.get(cityIndex).country
            cityView.p_lastupdate = xmlCity.get(cityIndex).lastupdate
            cityView.p_currenttemp = xmlCity.get(cityIndex).currenttemp
            cityView.p_tempunit = xmlCity.get(cityIndex).tempunit
            cityView.p_icon = xmlCity.get(cityIndex).icon
            cityView.p_sunrise = xmlCity.get(cityIndex).sunrise
            cityView.p_sunset = xmlCity.get(cityIndex).sunset
            cityView.p_winddirection = xmlCity.get(cityIndex).winddirection
            cityView.p_windspeed = xmlCity.get(cityIndex).windspeed
            cityView.p_humidity = xmlCity.get(cityIndex).humidity
            cityView.p_humidityunit = xmlCity.get(cityIndex).humidityunit

            // save current weather to db
            var cityItem = DBcore.defaultCityItem()
            cityActive = xmlCity.get(cityIndex).cityid
            cityItem.cityid = cityActive
            DBcore.deleteCity(cityItem.cityid) // important! otherwise data keeps ballooning
            cityItem.city = xmlCity.get(cityIndex).city
            cityItem.country = xmlCity.get(cityIndex).country
            cityItem.lat = xmlCity.get(cityIndex).lats
            cityItem.long = xmlCity.get(cityIndex).longs
            cityItem.sunrise = xmlCity.get(cityIndex).sunrise
            cityItem.sunset = xmlCity.get(cityIndex).sunset
            cityItem.currenttemp = xmlCity.get(cityIndex).currenttemp
            cityItem.tempunit = xmlCity.get(cityIndex).tempunit
            Commonfx.currentUnits = xmlCity.get(cityIndex).tempunit
            cityItem.humidity = xmlCity.get(cityIndex).humidity
            cityItem.humidityunit = xmlCity.get(cityIndex).humidityunit
            cityItem.icon = xmlCity.get(cityIndex).icon
            cityItem.weathernumber = xmlCity.get(cityIndex).weathernumber
            cityItem.windspeed = xmlCity.get(cityIndex).windspeed
            cityItem.winddirection = xmlCity.get(cityIndex).winddirection
            cityItem.lastupdate = xmlCity.get(cityIndex).lastupdate
            cityItem.favoritecity = favoriteCity
            console.log("Copying CITY XML to db " + cityItem.cityid + " " + cityItem.city + " " + cityItem.country)
            console.log("Lastupdate " + cityItem.lastupdate)
            console.log("Favcity " + cityItem.favoritecity)
            DBcore.createCity(cityItem)

            // get forecast data
            xmlForecastDaily.source = "http://api.openweathermap.org/data/2.5/forecast/daily?id=" + cityItem.cityid + "&units=metric&lang=en&mode=xml&cnt=5"
            xmlForecastDaily.reload()
            xmlForecastHourly.source = "http://api.openweathermap.org/data/2.5/forecast?id=" + cityActive + "&units=metric&lang=en&mode=xml"
            xmlForecastHourly.reload()

            if (useGPSPosition == true) {
                // save home city from GPS fix
                homeCity = cityItem.cityid
                var configitem = DBcore.defaultConfigItem()
                configitem.configkey = "cityhome"
                configitem.configvalue = cityItem.cityid
                DBcore.deleteConfig(configitem.configkey)
                DBcore.createConfig(configitem);
            }

        }
    }

    // ================================================
    // DAILY FORECAST XML MODEL
    // ================================================
    XmlListModel {
        id: xmlForecastDaily
        query: "/weatherdata/forecast/time"
        signal xmlForecastDailyLoaded // forecast loaded, cache data

        XmlRole { name: "day"; query: "@day/string()" }
        XmlRole { name: "icon"; query: "symbol/@var/string()" }
        XmlRole { name: "weathernumber"; query: "symbol/@number/string()" }
        XmlRole { name: "mintemp"; query: "temperature/@min/number()" }
        XmlRole { name: "maxtemp"; query: "temperature/@max/number()" }
        XmlRole { name: "windspeed"; query: "windSpeed/@mps/number()" }
        XmlRole { name: "winddirection"; query: "windDirection/@deg/number()" }

        onStatusChanged: {
            // copy forecast XML data to database for caching
            // city XML data must be properly loaded first!
            if ((status == XmlListModel.Loading) && (source != "")) {
                loadingBar.value = 1 + progress
            }
            if ((status == XmlListModel.Ready)  && (xmlCity.status == XmlListModel.Ready)) {
                forecastViewDaily.model = xmlForecastDaily
                xmlForecastDailyLoaded()
            }
        }

        onXmlForecastDailyLoaded: {
            console.log("Copying DAILY FORECAST XML to database..." + cityActive)
            var i = 0;
            for (i =0; i < xmlForecastDaily.count; i++) {
                var forecastItem = DBcore.defaultDailyForecastItem
                forecastItem.cityid = cityActive
                forecastItem.day = xmlForecastDaily.get(i).day
                forecastItem.icon = xmlForecastDaily.get(i).icon
                forecastItem.weathernumber = xmlForecastDaily.get(i).weathernumber
                forecastItem.mintemp = xmlForecastDaily.get(i).mintemp
                forecastItem.maxtemp = xmlForecastDaily.get(i).maxtemp
                forecastItem.tempunit = Commonfx.currentUnits
                forecastItem.windspeed = xmlForecastDaily.get(i).windspeed
                forecastItem.winddirection = xmlForecastDaily.get(i).winddirection
                console.log("Daily " + forecastItem.cityid + " " + forecastItem.day)
                DBcore.createDailyForecast(forecastItem)
            }
        }
    }

    // ================================================
    // HOURLY FORECAST XML MODEL
    // ================================================
    XmlListModel {
        id: xmlForecastHourly
        query: "/weatherdata/forecast/time"
        signal xmlForecastHourlyLoaded // forecast loaded, cache data

        //XmlRole { name: "datefromday"; query: "adjust-dateTime-to-timezone(xs:dateTime(@from))" }
        XmlRole { name: "datefrom"; query: "@from/string()" }
        XmlRole { name: "dateto"; query: "@to/string()" }
        XmlRole { name: "icon"; query: "symbol/@var/string()" }
        XmlRole { name: "weathernumber"; query: "symbol/@number/string()" }
        XmlRole { name: "mintemp"; query: "temperature/@min/number()" }
        XmlRole { name: "maxtemp"; query: "temperature/@max/number()" }
        XmlRole { name: "windspeed"; query: "windSpeed/@mps/number()" }
        XmlRole { name: "winddirection"; query: "windDirection/@deg/number()" }

        onStatusChanged: {
            // copy forecast XML data to database for caching
            // city XML data must be properly loaded first!
            if ((status == XmlListModel.Loading) && (source != "")) {
                loadingBar.value = 2 + progress
            }
            if ((status == XmlListModel.Ready)  && (xmlCity.status == XmlListModel.Ready)) {
                loadingBar.value = 2 + progress
                forecastViewHourly.model = xmlForecastHourly
                xmlForecastHourlyLoaded()
            }
        }

        onXmlForecastHourlyLoaded: {
            loadingBar.state = "hidden"
            console.log("Copying HOURLY FORECAST XML to database..." + cityActive)
            var i = 0;
            for (i =0; i < xmlForecastHourly.count; i++) {
                var forecastItem = DBcore.defaultHourlyForecastItem()
                forecastItem.cityid = cityActive
                forecastItem.datefrom = xmlForecastHourly.get(i).datefrom
                forecastItem.dateto = xmlForecastHourly.get(i).dateto
                forecastItem.icon = xmlForecastHourly.get(i).icon
                forecastItem.weathernumber = xmlForecastHourly.get(i).weathernumber
                forecastItem.mintemp = xmlForecastHourly.get(i).mintemp
                forecastItem.maxtemp = xmlForecastHourly.get(i).maxtemp
                forecastItem.tempunit = Commonfx.currentUnits
                forecastItem.windspeed = xmlForecastHourly.get(i).windspeed
                forecastItem.winddirection = xmlForecastHourly.get(i).winddirection
                console.log("Hourly " + forecastItem.cityid + " " + forecastItem.datefrom + " " + forecastItem.dateto )
                DBcore.createHourlyForecast(forecastItem)
            }
        }
    }

    // ================================================
    // PAGE states to handle portrait/landscape orientation
    // ================================================
    states: [
        State {
            name: "LANDSCAPE"; when: ((screen.currentOrientation == Screen.Landscape) && (screen.height == 360))
            PropertyChanges { target: cityFlick; state: "LANDSCAPE" }
            PropertyChanges { target: forecastViewDaily; state: "LANDSCAPE" }
            PropertyChanges { target: forecastViewHourly; state: "LANDSCAPE" }
        },
        State {
            name: "PORTRAIT"; when: ((screen.currentOrientation == Screen.Portrait) && (screen.height == 640))
            PropertyChanges { target: cityFlick; state: "PORTRAIT" }
            PropertyChanges { target: forecastViewDaily; state: "PORTRAIT" }
            PropertyChanges { target: forecastViewHourly; state: "PORTRAIT" }
        },
        State {
            name: "E6"; when: ((screen.width == 640) && (screen.height == 480))
            PropertyChanges { target: cityFlick; state: "E6" }
            PropertyChanges { target: forecastViewDaily; state: "E6" }
            PropertyChanges { target: forecastViewHourly; state: "E6" }
        }
    ]

    // ================================================
    // OPEN DATABASE ON LOAD
    // ================================================
    Component.onCompleted: {
        //time zone offset
        var currentdate = new Date();
        var tzhours = -currentdate.getTimezoneOffset()/60;
        timezone = tzhours;

        DBcore.openDB()
        var configitem, cityHome;

        // read settings from db
        // language override from default locale
        configitem = DBcore.readConfig("language")
        if (configitem.configvalue == undefined) {
            // no config, create default: english, metric, m/s
            console.log("Creating default settings")
            DBcore.createDefaultConfig()
            configitem = DBcore.readConfig("language")
        }
        console.log("Loading settings")
        Commonfx.language = configitem.configvalue
        rootItem.selectLanguage(Commonfx.language) // important for dynamic translation!
        configitem = DBcore.readConfig("units")
        Commonfx.units = configitem.configvalue
        configitem = DBcore.readConfig("windunits")
        Commonfx.windunits = configitem.configvalue
        configitem = DBcore.readConfig("hourunits")
        Commonfx.hourunits = configitem.configvalue

        // set to daily or hourly view first
        configitem = DBcore.readConfig("firstpage")
        Commonfx.firstpage = configitem.configvalue
        if (Commonfx.firstpage == "hourly") { flipable.flipped = true }
        else { flipable.flipped = false }

        configitem = DBcore.readConfig("cityhome")
        cityHome = configitem.configvalue
        if (cityHome != undefined) { // last city recorded
            homeCity = cityHome
            cityActive = cityHome
            console.log("Loading cached city, forecast for " + cityHome)
            loadLocalDB()
            favoriteCity = modelCity.get(0).favoritecity

            // load online data if more than an hour has passed since last update
            if (Commonfx.getNewUpdate(modelCity.get(0).lastupdate, timezone) == true) {
                useGPSPosition = false
                console.log("Getting online data for " + cityHome)
                xmlCity.query = "/current"
                xmlCity.source = "http://api.openweathermap.org/data/2.5/weather?id=" + cityHome + "&units=metric&lang=en&mode=xml"
                xmlCity.reload()
            }
        }
        else {
            resetCityView()
            gpsSource.active = true
            gpsSource.update()
            }
        } // end component.oncompleted


    onStatusChanged: {
        if ( status == PageStatus.Activating  ) {
            // Reload all local data again
            savedCitiesDialog.model = 0
            DBcore.readCityList(modelSavedCities)
            savedCitiesDialog.model = modelSavedCities

            // reload data and translations if units, language changed
            if (Commonfx.settingsChanged == true) {
                rootItem.selectLanguage(Commonfx.language);
                loadLocalDB()
                Commonfx.settingsChanged = false
            }
        }
    }

    // ================================================
    // GPS POSITION SOURCE
    // ================================================
    GpsSource { id: gpsSource }


    // MISC LOCAL FUNCTIONS
    // ================================================
    // LOAD ALL LOCAL DATA INTO VIEWS
    // ================================================
    function loadLocalDB () {
        resetCityView()
        forecastViewDaily.model = 0
        forecastViewHourly.model = 0

        DBcore.readCity(modelCity, cityActive)
        DBcore.readDailyForecast(modelForecastDaily, cityActive)
        DBcore.readHourlyForecast(modelForecastHourly, cityActive)

        loadCityViewDB()
        forecastViewDaily.model = modelForecastDaily
        forecastViewHourly.model = modelForecastHourly

        Commonfx.currentUnits = modelCity.get(0).tempunit
        favoriteCity = modelCity.get(0).favoritecity
    }

    // ================================================
    // LOAD CITY DATA INTO VIEW FROM DB
    // ================================================
    function loadCityViewDB () {
        cityView.p_city = modelCity.get(0).city
        cityView.p_country = modelCity.get(0).country
        cityView.p_lastupdate = modelCity.get(0).lastupdate
        cityView.p_currenttemp = modelCity.get(0).currenttemp
        cityView.p_tempunit = modelCity.get(0).tempunit
        cityView.p_icon = modelCity.get(0).icon
        cityView.p_sunrise = modelCity.get(0).sunrise
        cityView.p_sunset = modelCity.get(0).sunset
        cityView.p_winddirection = modelCity.get(0).winddirection
        cityView.p_windspeed = modelCity.get(0).windspeed
        cityView.p_humidity = modelCity.get(0).humidity
        cityView.p_humidityunit = modelCity.get(0).humidityunit
    }

    // ================================================
    // RESET CITY VIEW
    // ================================================
    function resetCityView () {
        cityView.p_city = ""
        cityView.p_country = ""
        cityView.p_lastupdate = ""
        cityView.p_currenttemp = 0
        cityView.p_tempunit = ""
        cityView.p_icon = ""
        cityView.p_sunrise = ""
        cityView.p_sunset = ""
        cityView.p_winddirection = 0
        cityView.p_windspeed = 0
        cityView.p_humidity = 0
        cityView.p_humidityunit = ""
    }

} // end page
