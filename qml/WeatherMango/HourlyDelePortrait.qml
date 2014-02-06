// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1
import "fx.js" as Commonfx

// PORTRAIT HOURLY FORECAST COMPONENT
Component {
  ListItem {
      //property variant myData: model
      height: 70

      Text {
          id: dateTxt
          anchors.verticalCenter: parent.verticalCenter
          anchors.left: parent.left
          anchors.leftMargin: 5
          text: Commonfx.getForecastdayhour(model.datefrom, timezone)
          verticalAlignment: Text.AlignVCenter
          color: "white"
          font.pixelSize: 20
          font.bold: true
      }
      Image {
          id: iconImage
          asynchronous: true
          height: 70
          width: 70
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.verticalCenter: parent.verticalCenter
          source: Commonfx.getIcon(model.icon)
          smooth: true
      }
      Text {
          id: tempTxt
          anchors.verticalCenter: parent.verticalCenter
          anchors.left: iconImage.right
          //anchors.leftMargin: 15
          //width: 50
          anchors.right: windTxt.left
          verticalAlignment: Text.AlignVCenter
          horizontalAlignment: Text.AlignHCenter
          text: Commonfx.convertTemp(model.maxtemp, Commonfx.currentUnits)
          color: "lightgreen"
          font.pixelSize: 28
          font.bold: true
      }
      Image {
          id: windspeedImage
          asynchronous: true
          //anchors.verticalCenter: iconImage.verticalCenter
          //anchors.right: windTxt.left
          //anchors.right: parent.right
          anchors.bottom: windTxt.top
          anchors.horizontalCenter: windTxt.horizontalCenter
          height: 30
          width: 30
          smooth: true
          source: "qrc:/icons/wind_arrow"
          rotation: Math.round(model.winddirection)
      }
      Text {
          id: windTxt
          //anchors.verticalCenter: iconImage.verticalCenter
          anchors.top: parent.verticalCenter
          anchors.topMargin: 5
          anchors.right: parent.right
          anchors.rightMargin: 5
          verticalAlignment: Text.AlignVCenter
          horizontalAlignment: Text.AlignHCenter
          text: Commonfx.convertWindspeed(model.windspeed)
          color: "lightgray"
          font.pixelSize: 16
          wrapMode: Text.WordWrap
      }

  }
}
