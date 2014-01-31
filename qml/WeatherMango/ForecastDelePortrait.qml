// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1
import "fx.js" as Commonfx

// PORTRAIT FORECAST COMPONENT
Component {
  ListItem {
      //property variant myData: model
      height: 65

      Text {
          id: dateTxt
          anchors.verticalCenter: iconImage.verticalCenter
          anchors.left: parent.left
          anchors.leftMargin: 5
          text: Commonfx.getDayofweek(model.day)
          verticalAlignment: Text.AlignVCenter
          color: "white"
          font.pixelSize: 20
          font.bold: true
      }
      Image {
          id: iconImage
          asynchronous: true
          height: 65
          width: 65
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.verticalCenter: parent.verticalCenter
          source: Commonfx.getIcon(model.icon)
          smooth: true
      }
      Text {
          id: maxtempTxt
          anchors.right: mintempTxt.left
          anchors.rightMargin: 20
          width: 40
          anchors.verticalCenter: iconImage.verticalCenter
          verticalAlignment: Text.AlignVCenter
          horizontalAlignment: Text.AlignHCenter
          text: Commonfx.convertTemp(model.maxtemp, Commonfx.currentUnits)
          color: "orange"
          font.pixelSize: 28
          font.bold: true
      }
      Text {
          id: mintempTxt
          anchors.right: parent.right
          anchors.rightMargin: 5
          width: 40
          anchors.verticalCenter: iconImage.verticalCenter
          verticalAlignment: Text.AlignVCenter
          horizontalAlignment: Text.AlignHCenter
          text: Commonfx.convertTemp(model.mintemp, Commonfx.currentUnits)
          color: "lightblue"
          font.pixelSize: 28
          font.bold: true
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
