// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1
import "fx.js" as Commonfx

// PORTRAIT CITY COMPONENT
Rectangle {
    color: "#000000"

    Text {
        id: cityTxt
        anchors.top: parent.top
        anchors.topMargin: 2
        anchors.horizontalCenter: parent.horizontalCenter
        verticalAlignment: Text.AlignBottom
        horizontalAlignment: Text.AlignHCenter
        text: p_city + ", " + p_country
        //text: p_city
        color: "white"
        font.pixelSize: 24
        maximumLineCount: 2
        wrapMode: Text.WordWrap
        font.bold: true
    }
    Text {
        id: updateTxt
        anchors.top: iconImage.top
        anchors.bottom: iconImage.bottom
        anchors.right: iconImage.left
        anchors.rightMargin: 5
        anchors.left: parent.left
        anchors.leftMargin: 5
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        text: qsTr("Updated ") + Commonfx.dateDifference(p_lastupdate, timezone)  + qsTr(" minutes ago") + rootItem.emptyString
        color: "white"
        wrapMode: Text.WordWrap
        font.pixelSize: 18
    }
    Image {
        id: iconImage
        asynchronous: true
        anchors.top: cityTxt.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        height: 128
        width: 128
        smooth: true
        source: Commonfx.getIcon(p_icon)
    }
    Text {
        id: weatherTxt
        anchors.verticalCenter: iconImage.verticalCenter
        anchors.left: iconImage.right
        anchors.leftMargin: 10
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        text: Commonfx.convertTemp(p_currenttemp, p_tempunit) + " °" + Commonfx.getTempunit(p_tempunit)
        color: "white"
        font.pixelSize: 38
        font.bold:  true
    }
    Image {
        id: sunriseImage
        asynchronous: true
        anchors.top: iconImage.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: -120
        height: 30
        width: 30
        smooth: true
        source: "qrc:/icons/sunrise"
    }
    Text {
        id: sunriseTxt
        anchors.verticalCenter: sunriseImage.verticalCenter
        anchors.left: sunriseImage.right
        anchors.leftMargin: 5
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        text: Commonfx.getForecasthour(p_sunrise, timezone)
        color: "lightgray"
        font.pixelSize: 18
    }
    Image {
        id: sunsetImage
        asynchronous: true
        anchors.top: sunriseImage.bottom
        anchors.topMargin: 5
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: -120
        height: 30
        width: 30
        smooth: true
        source: "qrc:/icons/sunset"
    }
    Text {
        id: sunsetTxt
        anchors.verticalCenter: sunsetImage.verticalCenter
        anchors.left: sunsetImage.right
        anchors.leftMargin: 5
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        text: Commonfx.getForecasthour(p_sunset, timezone)
        color: "lightgray"
        font.pixelSize: 18
    }
    Image {
        id: winddirectionImage
        asynchronous: true
        anchors.top: iconImage.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: 40
        height: 30
        width: 30
        smooth: true
        source: "qrc:/icons/wind_arrow"
        rotation: Math.round(p_winddirection)
    }
    Text {
        id: windspeedTxt
        anchors.verticalCenter: winddirectionImage.verticalCenter
        anchors.left: winddirectionImage.right
        anchors.leftMargin: 5
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        text: Commonfx.convertWindspeed(p_windspeed)
        color: "lightgray"
        font.pixelSize: 18
    }
    Image {
        id: humidityImage
        asynchronous: true
        anchors.top: winddirectionImage.bottom
        anchors.topMargin: 5
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: 40
        height: 30
        width: 30
        smooth: true
        source: "qrc:/icons/humid"
    }
    Text {
        id: humidityTxt
        anchors.verticalCenter: humidityImage.verticalCenter
        anchors.left: humidityImage.right
        anchors.leftMargin: 5
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        text: p_humidity + p_humidityunit
        color: "lightgray"
        font.pixelSize: 18
    }

} // end rectangle
