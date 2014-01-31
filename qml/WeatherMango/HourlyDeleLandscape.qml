// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1
import "fx.js" as Commonfx

// LANDSCAPE HOURLY COMPONENT
Component {
  ListItem {
      height: forecastViewDaily.height
      width: 128

      Text {
          id: dateTxt
          anchors.top: parent.top
          anchors.topMargin: 2
          anchors.horizontalCenter: parent.horizontalCenter
          horizontalAlignment: Text.AlignHCenter
          text: Commonfx.getForecastdayhour(model.datefrom, timezone)
          color: "white"
          font.pixelSize: 18
          font.bold: true
      }
      Image {
          id: iconImage
          asynchronous: true
          height: 65
          width: 65
          anchors.top: dateTxt.bottom
          anchors.horizontalCenter: parent.horizontalCenter
          source: Commonfx.getIcon(model.icon)
          smooth: true
      }
      Text {
          id: tempTxt
          anchors.top: iconImage.bottom
          anchors.horizontalCenter: parent.horizontalCenter
          verticalAlignment: Text.AlignVCenter
          horizontalAlignment: Text.AlignHCenter
          text: Commonfx.convertTemp(model.maxtemp, Commonfx.currentUnits)
          color: "lightgreen"
          font.pixelSize: 28
          //font.bold: true
      }     
      Row {
          id: windRow
          anchors.top: tempTxt.bottom
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.bottom: parent.bottom
          spacing: 5
          Image {
              id: windspeedImage
              asynchronous: true
              height: 30
              width: 30
              smooth: true
              source: "qrc:/icons/wind_arrow"
              rotation: Math.round(model.winddirection)
          }
          Text {
              id: windTxt
              anchors.top: parent.top
              anchors.bottom: parent.bottom
              verticalAlignment: Text.AlignVCenter
              horizontalAlignment: Text.AlignLeft
              text: Commonfx.convertWindspeed(model.windspeed)
              color: "lightgray"
              font.pixelSize: 16
          }
      }
  }
}
