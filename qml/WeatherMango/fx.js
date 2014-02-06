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

.pragma library
var language = "";
var units = "";
var windunits = "";
var currentUnits = "celsius";
var firstpage = "";
var hourunits = ""; // "am pm" or "24"
var settingsChanged = false;

// COMMON FUNCTIONS
// ==============================

// get matching icon file according to weather report
function getIcon(input) {
    var iconFile = "";

    switch (input) {
    case "900" : iconFile = "tornado.png"; break;
    case "901" : iconFile = "tropicalstorm.png"; break;
    case "902" : iconFile = "hurricane.png"; break;
    case "903" : iconFile = "903.png"; break; // hot
    case "904" : iconFile = "904.png"; break; // cold
    case "905" : iconFile = "905.png"; break; // windy
    case "906" : iconFile = "906.png"; break; // hail
    default: iconFile = input + ".png"; break;
    }

    return "icons/" + iconFile;
}

// convert date string to local day string, assuming ISO yyyy-mm-dd input
function getDayofweek(datestring) {
    var inputdate = new Date(datestring.substring(0,4),  datestring.substring(5,7) - 1, datestring.substring(8,10), 0, 0, 0, 0);
    var dayofweek = Qt.formatDate(inputdate, "dddd");
    return dayofweek;
}

// convert UTC date string to local date (shortdate)
function getLocaldate(datestring) {
    //2013-12-31T03:44:37 crazyass bug on months???
    var inputdate = new Date(datestring.substring(0,4), datestring.substring(5,7) - 1, datestring.substring(8,10), datestring.substring(11,13), datestring.substring(14,16), 0, 0);
    var localdate = Qt.formatDateTime(inputdate, Qt.DefaultLocaleShortDate)
    return localdate;
}

// convert UTC date string to local date/time according to timezone (longdate)
function getLocaldateUTC(datestring, timezone) {
    //2013-12-31T03:44:37 crazyass bug on months???
    var inputdate = new Date(datestring.substring(0,4), datestring.substring(5,7) - 1, datestring.substring(8,10), datestring.substring(11,13), datestring.substring(14,16), 0, 0);
    inputdate.setHours(inputdate.getHours() + timezone);
    var outputdate = Qt.formatDateTime(inputdate, Qt.DefaultLocaleLongDate);
    return outputdate;
}

// convert UTC date string to day of week according to timezone (short day string)
function getForecastday(datestring, timezone) {
    //2013-12-31T03:44:37 crazyass bug on months???
    var inputdate = new Date(datestring.substring(0,4), datestring.substring(5,7) - 1, datestring.substring(8,10), datestring.substring(11,13), datestring.substring(14,16), 0, 0);
    inputdate.setHours(inputdate.getHours() + timezone);
    var outputdate = Qt.formatDateTime(inputdate, "ddd");
    return outputdate;
}

// convert UTC date string to date and time according to timezone
function getForecastdayhour(datestring, timezone) {
    //2013-12-31T03:44:37 crazyass bug on months???
    var inputdate = new Date(datestring.substring(0,4), datestring.substring(5,7) - 1, datestring.substring(8,10), datestring.substring(11,13), datestring.substring(14,16), 0, 0);
    inputdate.setHours(inputdate.getHours() + timezone);
    var outputdate; // = Qt.formatDateTime(inputdate, "ddd h ap");
    if (hourunits == "24") {
        outputdate = Qt.formatDateTime(inputdate, "ddd hh:mm");
    }
    else {
        outputdate = Qt.formatDateTime(inputdate, "ddd h ap");
    }
    return outputdate;
}

// convert UTC date string to time according to timezone
function getForecasthour(datestring, timezone) {
    //2013-12-31T03:44:37 crazyass bug on months???
    var inputdate = new Date(datestring.substring(0,4), datestring.substring(5,7) - 1, datestring.substring(8,10), datestring.substring(11,13), datestring.substring(14,16), 0, 0);
    inputdate.setHours(inputdate.getHours() + timezone);
    var outputdate;
    if (hourunits == "24") {
        outputdate = Qt.formatDateTime(inputdate, "hh:mm");
    }
    else {
        outputdate = Qt.formatDateTime(inputdate, "h:mm ap");
    }
    return outputdate;
}


// convert UTC date string to date and time according to timezone (ISO date)
function getDateISO (datestring, timezone) {
    //2013-12-31T03:44:37 crazyass bug on months???
    var inputdate = new Date(datestring.substring(0,4), datestring.substring(5,7) - 1, datestring.substring(8,10), datestring.substring(11,13), datestring.substring(14,16), 0, 0);
    inputdate.setHours(inputdate.getHours() + timezone);
    var outputdate = Qt.formatDateTime(inputdate, Qt.ISODate);
    return outputdate;
}


// convert UTC date string to color
function getForecastcolor(datestring, timezone) {
    //2013-12-31T03:44:37 crazyass bug on months???
    var inputdate = new Date(datestring.substring(0,4), datestring.substring(5,7) - 1, datestring.substring(8,10), datestring.substring(11,13), datestring.substring(14,16), 0, 0);
    inputdate.setHours(inputdate.getHours() + timezone);
    var outputcolor;
    var outputdate =  Qt.formatDateTime(inputdate, "hh");

    switch (outputdate.toString()) {
    case "02" : outputcolor = "#2b8cbe"; break;
    case "05" : outputcolor = "#08589e"; break;
    case "08" : outputcolor = "#f7fcf0"; break;
    case "11" : outputcolor = "#e0f3db"; break;
    case "14" : outputcolor = "#ccebc5"; break;
    case "17" : outputcolor = "#a8ddb5"; break;
    case "20" : outputcolor = "#7bccc4"; break;
    case "23" : outputcolor = "#4eb3d3"; break;
    default: outputcolor = "red"; break;
    }
    console.log("Color " + outputdate + " " + outputcolor)
    return outputcolor;
}

// get temperature unit
function getTempunit() {
    if (units == "celsius") return "C";
    if (units == "fahrenheit") return "F";
}

// convert temperature unit (C to F)
// all input units in Celsius
function convertTemp(temp, inputunit) {
    var outputtemp = 0.0;
    if (inputunit == "celsius") {
        if (units == "celsius") {
            outputtemp = Math.round(temp);
        }
        if (units == "fahrenheit") {
            // Multiply by 9, then divide by 5, then add 32
            outputtemp = Math.round((((temp * 9) / 5) + 32));
        }
    }
    return outputtemp;
}

// convert wind m/s to whatever unit
function convertWindspeed(windspeed) {
    /*
                    ListElement { name: "meters per second"; windunits: "ms" }
                    ListElement { name: "kilometers per hour"; windunits: "kph" }
                    ListElement { name: "feet per second"; windunits: "fs" }
                    ListElement { name: "miles per hour"; windunits: "mph" }
*/
    var outputwindspeed = 0.0;
    var speedlabel = "";
    if (windunits == "ms") {
        outputwindspeed = (Math.round(windspeed)).toString()
        speedlabel = "m/s"
    }
    if (windunits == "kph") {
        outputwindspeed = (Math.round(windspeed * 3.6)).toString()
        speedlabel = "km/h"
    }
    if (windunits == "fs") {
        outputwindspeed = (Math.round(windspeed * 3.28)).toString()
        speedlabel = "ft/s"
    }
    if (windunits == "mph") {
        outputwindspeed = (Math.round(windspeed * 2.237)).toString()
        speedlabel = "mph"
    }

    return outputwindspeed + " " + speedlabel;
}


// check if current time > 1 hour since last update
function getNewUpdate(datestring, timezone) {
    // load online data if more than an hour has passed since last update
    var lastupdate = new Date(datestring.substring(0,4), datestring.substring(5,7) - 1, datestring.substring(8,10), datestring.substring(11,13), datestring.substring(14,16), 0, 0);
    lastupdate.setHours(lastupdate.getHours() + (timezone + 1.5));
    var currentdate = new Date();
    if (currentdate > lastupdate) {
        return true;
    }
    else {
        return false;
    }
}

// return difference between current date and last update
function dateDifference(datestring, timezone) {
    // load online data if more than an hour has passed since last update
    var lastupdate = new Date(datestring.substring(0,4), datestring.substring(5,7) - 1, datestring.substring(8,10), datestring.substring(11,13), datestring.substring(14,16), 0, 0);
    lastupdate.setHours(lastupdate.getHours() + (timezone));
    var currentdate = new Date();
    return Math.round(((currentdate - lastupdate)/1000)/60);
}

