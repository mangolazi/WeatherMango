// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1
import QtMobility.location 1.1
import "dbcore.js" as DBcore
import "fx.js" as Commonfx

// POSITIONING ELEMENT FOR GPS
PositionSource {
    updateInterval: 500
    active: false
    signal goodfix() // good fix
    signal badfix() // bad fix, no position

    onActiveChanged: {
        infoBanner.showText(qsTr("Getting current GPS position..."))
        if ((position.latitudeValid == true) && (position.longitudeValid == true)) {
            console.log("GPS valid fix!")
            goodfix()
        }
    }

    onGoodfix: {
        // load xml data
        stop()
        useGPSPosition = true
        console.log("Good fix, now load data")
        var configitem = DBcore.defaultConfigItem();
        // copy any good fix to db
        console.log("GPS fix is good, copy position to db " + position.coordinate.latitude + " " + position.coordinate.longitude)
        configitem.configkey = "lathome";
        configitem.configvalue = position.coordinate.latitude;
        DBcore.deleteConfig(configitem.configkey)
        DBcore.createConfig(configitem);
        configitem.configkey = "lonhome";
        configitem.configvalue = position.coordinate.longitude;
        DBcore.deleteConfig(configitem.configkey)
        DBcore.createConfig(configitem);
        xmlCity.query = "/cities/list/item"
        xmlCity.source = "http://api.openweathermap.org/data/2.5/find?lat=" + position.coordinate.latitude + "&lon=" + position.coordinate.longitude + "&units=metric&lang=en&mode=xml"
        xmlCity.reload()
    }

    onBadfix: {
        infoBanner.showText(qsTr("GPS position not found, please try again"))
    }
}
