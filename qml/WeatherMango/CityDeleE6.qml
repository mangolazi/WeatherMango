// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1
import "fx.js" as Commonfx

// LANDSCAPE CITY COMPONENT FOR E6!
Rectangle {
    color: "#000000"

      Text {
          id: cityTxt
          anchors.top: parent.top
          anchors.horizontalCenter: parent.horizontalCenter
          text: p_city + ", " + p_country
          horizontalAlignment: Text.AlignHCenter
          color: "white"
          font.pixelSize: 32
          maximumLineCount: 2
          wrapMode: Text.WordWrap
          font.bold: true
      }
      Text {
          id: updateTxt
          anchors.top: cityTxt.bottom
          anchors.horizontalCenter: parent.horizontalCenter
          horizontalAlignment: Text.AlignHCenter
          text: qsTr("Updated ") + Commonfx.dateDifference(p_lastupdate, timezone)  + qsTr(" minutes ago")//"Updated " + Commonfx.getLocaldateUTC(p_lastupdate, timezone)
          color: "lightgray"
          font.pixelSize: 16
      }
      Image {
          id: sunriseImage
          asynchronous: true
          anchors.top: updateTxt.bottom
          anchors.topMargin: 5
          anchors.left: parent.left
          anchors.leftMargin: 20
          height: 30
          width: 30
          smooth: true
          source: "qrc:/icons/sunrise"
      }
      Text {
          id: sunriseTxt
          anchors.left: sunriseImage.right
          anchors.leftMargin: 10
          anchors.verticalCenter: sunriseImage.verticalCenter
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
          anchors.left: parent.left
          anchors.leftMargin: 20
          height: 30
          width: 30
          smooth: true
          source: "qrc:/icons/sunset"
      }
      Text {
          id: sunsetTxt
          anchors.left: sunsetImage.right
          anchors.leftMargin: 10
          anchors.verticalCenter: sunsetImage.verticalCenter
          verticalAlignment: Text.AlignVCenter
          horizontalAlignment: Text.AlignLeft
          text: Commonfx.getForecasthour(p_sunset, timezone)
          color: "lightgray"
          font.pixelSize: 18
      }
      Image {
          id: winddirectionImage
          asynchronous: true
          anchors.top: sunsetImage.bottom
          anchors.topMargin: 5
          anchors.left: parent.left
          anchors.leftMargin: 20
          height: 30
          width: 30
          smooth: true
          source: "qrc:/icons/wind_arrow"
          rotation: Math.round(p_winddirection)
      }
      Text {
          id: windspeedTxt
          anchors.left: winddirectionImage.right
          anchors.leftMargin: 10
          anchors.verticalCenter: winddirectionImage.verticalCenter
          verticalAlignment: Text.AlignVCenter
          horizontalAlignment: Text.AlignLeft
          text: Commonfx.convertWindspeed(p_windspeed)
          color: "lightgray"
          font.pixelSize: 18
      }
      Image {
          id: iconImage
          asynchronous: true
          anchors.top: updateTxt.bottom
          anchors.horizontalCenter: parent.horizontalCenter
          height: 128
          width: 128
          smooth: true
          source: Commonfx.getIcon(p_icon)
      }
      Text {
          id: weatherTxt
          anchors.right: parent.right
          anchors.rightMargin: 20
          anchors.bottom: iconImage.verticalCenter
          verticalAlignment: Text.AlignVCenter
          horizontalAlignment: Text.AlignLeft
          text: Commonfx.convertTemp(p_currenttemp, p_tempunit) + " °" + Commonfx.getTempunit(p_tempunit)
          color: "white"
          font.pixelSize: 42
          font.bold:  true
      }
      Image {
          id: humidityImage
          asynchronous: true
          anchors.right: humidityTxt.left
          anchors.verticalCenter: humidityTxt.verticalCenter
          height: 30
          width: 30
          smooth: true
          source: "qrc:/icons/humid"
      }
      Text {
          id: humidityTxt
          anchors.top: weatherTxt.bottom
          anchors.topMargin: 10
          anchors.right: parent.right
          anchors.rightMargin: 20
          verticalAlignment: Text.AlignVCenter
          horizontalAlignment: Text.AlignLeft
          text: p_humidity + p_humidityunit
          color: "lightgray"
          font.pixelSize: 18
      }

  }
