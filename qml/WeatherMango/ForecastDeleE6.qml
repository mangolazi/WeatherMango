// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1
import "fx.js" as Commonfx

// LANDSCAPE FORECAST COMPONENT FOR E6!
Component {
  ListItem {
      height: forecastViewDaily.height
      width: 128
      Text {
          id: dateTxt
          anchors.top: parent.top
          anchors.topMargin: 2
          anchors.horizontalCenter: parent.horizontalCenter
          text: Commonfx.getDayofweek(model.day)
          color: "lightgray"
          font.pixelSize: 18
          font.bold: true
      }
      Image {
          id: iconImage
          asynchronous: true
          height: 90
          width: 90
          anchors.top: dateTxt.bottom
          anchors.topMargin: 10
          anchors.horizontalCenter: parent.horizontalCenter
          source: Commonfx.getIcon(model.icon)
          smooth: true
      }
      Text {
          id: maxtempTxt
          anchors.top: iconImage.bottom
          anchors.right: parent.horizontalCenter
          anchors.rightMargin: 10
          verticalAlignment: Text.AlignVCenter
          horizontalAlignment: Text.AlignHCenter
          text: Commonfx.convertTemp(model.maxtemp, Commonfx.currentUnits)
          color: "orange"
          font.pixelSize: 30
          //font.bold: true
      }
      Text {
          id: mintempTxt
          anchors.top: iconImage.bottom
          anchors.left: parent.horizontalCenter
          anchors.leftMargin: 10
          verticalAlignment: Text.AlignVCenter
          horizontalAlignment: Text.AlignHCenter
          text: Commonfx.convertTemp(model.mintemp, Commonfx.currentUnits)
          color: "lightblue"
          font.pixelSize: 30
          //font.bold: true
      }

      Row {
          id: windRow
          anchors.top: maxtempTxt.bottom
          anchors.topMargin: 10
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

      onClicked: {
          var i = 0
          var datefrom
          if (forecastViewHourly.model == modelForecastHourly) {
              // go through db model to find first matching date
              datefrom = (Commonfx.getDateISO(modelForecastHourly.get(i).datefrom, timezone)).toString()
              while ((i < modelForecastHourly.count) && (model.day != datefrom.substring(0,10))) {
                  i++
                  datefrom = (Commonfx.getDateISO(modelForecastHourly.get(i).datefrom, timezone)).toString()
              }
          }
          else {
              // go through xml model to find first matching date
              datefrom = (Commonfx.getDateISO(xmlForecastHourly.get(i).datefrom, timezone)).toString()
              while ((i < xmlForecastHourly.count) && (model.day != datefrom.substring(0,10))) {
                  i++
                  datefrom = (Commonfx.getDateISO(xmlForecastHourly.get(i).datefrom, timezone)).toString()
              }
          }
          flipable.flipped = true
          forecastViewHourly.positionViewAtIndex(i, ListView.Beginning)
      }
  }
}
