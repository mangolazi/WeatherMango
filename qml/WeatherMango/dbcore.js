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

var db;

function openDB()
{
    db = openDatabaseSync("WeatherDB","1.2","Weather Database",10000);
    createTable();
}

function createTable()
{
    db.transaction(
                function(tx) {
                    tx.executeSql("CREATE TABLE IF NOT EXISTS city (cityid TEXT PRIMARY KEY, city TEXT, country TEXT, lat TEXT, long TEXT, sunrise DATETIME, sunset DATETIME, currenttemp TEXT, tempunit TEXT, humidity TEXT, humidityunit TEXT, weathernumber TEXT, icon TEXT, windspeed TEXT, winddirection TEXT, lastupdate DATETIME, favoritecity INTEGER)");
                    tx.executeSql("CREATE TABLE IF NOT EXISTS dailyforecast (cityid TEXT, day TEXT, icon TEXT, weathernumber TEXT, mintemp TEXT, maxtemp TEXT, tempunit TEXT, windspeed TEXT, winddirection TEXT, lastupdate DATETIME)");
                    tx.executeSql("CREATE TABLE IF NOT EXISTS hourlyforecast (cityid TEXT, datefrom TEXT, dateto TEXT, icon TEXT, weathernumber TEXT, mintemp TEXT, maxtemp TEXT, tempunit TEXT, windspeed TEXT, winddirection TEXT, lastupdate DATETIME)");
                    tx.executeSql("CREATE TABLE IF NOT EXISTS config (configkey TEXT PRIMARY KEY, configvalue TEXT)");
                }
                )
}

// new City item with current data
function createCity(cityItem)
{
    db.transaction(
                function(tx) {
                    tx.executeSql("INSERT INTO city (cityid, city, country, lat, long, sunrise, sunset, currenttemp, tempunit, humidity, humidityunit, icon, weathernumber, windspeed, winddirection, lastupdate, favoritecity) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
                                  [cityItem.cityid, cityItem.city, cityItem.country, cityItem.lat, cityItem.long, cityItem.sunrise, cityItem.sunset, cityItem.currenttemp, cityItem.tempunit, cityItem.humidity, cityItem.humidityunit, cityItem.icon, cityItem.weathernumber, cityItem.windspeed, cityItem.winddirection, cityItem.lastupdate, cityItem.favoritecity]);
                }
                )
}

// new Daily Forecast item with forecast data, 5 days
function createDailyForecast(forecastItem)
{
    db.transaction(
                function(tx) {
                    tx.executeSql("INSERT INTO dailyforecast (cityid, day, icon, weathernumber, mintemp, maxtemp, tempunit, windspeed, winddirection) VALUES(?,?,?,?,?,?,?,?,?)",
                                  [forecastItem.cityid, forecastItem.day, forecastItem.icon, forecastItem.weathernumber, forecastItem.mintemp, forecastItem.maxtemp, forecastItem.tempunit, forecastItem.windspeed, forecastItem.winddirection]);
                }
                )
}

// new Hourly Forecast item with forecast data, every 3 hours for 5 days
function createHourlyForecast(forecastItem)
{
    db.transaction(
                function(tx) {
                    tx.executeSql("INSERT INTO hourlyforecast (cityid, datefrom, dateto, icon, weathernumber, mintemp, maxtemp, tempunit, windspeed, winddirection) VALUES(?,?,?,?,?,?,?,?,?,?)",
                                  [forecastItem.cityid, forecastItem.datefrom, forecastItem.dateto, forecastItem.icon, forecastItem.weathernumber, forecastItem.mintemp, forecastItem.maxtemp, forecastItem.tempunit, forecastItem.windspeed, forecastItem.winddirection]);
                }
                )
}

// DELETE ALL CITY DATA
function deleteCity(cityid)
{
    db.transaction(
                function(tx) {
                    tx.executeSql("DELETE FROM city WHERE cityid = ?", [cityid]);
                    tx.executeSql("DELETE FROM dailyforecast WHERE cityid = ?", [cityid]);
                    tx.executeSql("DELETE FROM hourlyforecast WHERE cityid = ?", [cityid]);
                }
                )
}

// LOAD SINGLE CITY DATA, CURRENT CACHE
function readCity(model, cityid) {
    model.clear();
    var sqlstring = "SELECT * FROM city WHERE cityid = '" + cityid + "'";
    db.readTransaction(
                function(tx) {
                    var rs;
                    rs = tx.executeSql(sqlstring);
                    for (var i = 0; i < rs.rows.length; i++) {
                        model.append(rs.rows.item(i))
                    }
                }
                )
}

// LOAD DAILY FORECAST DATA
function readDailyForecast(model, cityid) {
    model.clear();
    var sqlstring = "SELECT * FROM dailyforecast WHERE cityid = '" + cityid + "'";
    db.readTransaction(
                function(tx) {
                    var rs;
                    rs = tx.executeSql(sqlstring);
                    for (var i = 0; i < rs.rows.length; i++) {
                        model.append(rs.rows.item(i))
                    }
                }
                )
}

// LOAD HOURLY FORECAST DATA
function readHourlyForecast(model, cityid) {
    model.clear();
    var sqlstring = "SELECT * FROM hourlyforecast WHERE cityid = '" + cityid + "'";
    db.readTransaction(
                function(tx) {
                    var rs;
                    rs = tx.executeSql(sqlstring);
                    for (var i = 0; i < rs.rows.length; i++) {
                        model.append(rs.rows.item(i))
                    }
                }
                )
}

// LOAD LIST OF FAVORITE CITIES
function readCityList(model)
{
    model.clear()
    db.readTransaction(
                function(tx) {
                    var rs;
                    rs = tx.executeSql("SELECT cityid, city, country, lat AS lats, long AS longs FROM city WHERE favoritecity = 1 ORDER BY city ASC");
                    for (var i = 0; i < rs.rows.length; i++) {
                        model.append(rs.rows.item(i))
                    }
                }
                )
}

// SET CITY AS FAVORITE
function setFavorite(cityid, favorite)
{
    db.transaction(
                function(tx) {
                    tx.executeSql("UPDATE city SET favoritecity = ? WHERE cityid = ?", [favorite, cityid]);
                }
                )
}

// CREATE CONFIG VALUE
function createConfig(configItem)
{
    db.transaction(
                function(tx) {
                    tx.executeSql("INSERT INTO config (configkey, configvalue) VALUES(?,?)",[configItem.configkey, configItem.configvalue]);
                }
                )
}

// DELETE CONFIG VALUE
function deleteConfig(configkey)
{
    db.transaction(
                function(tx) {
                    tx.executeSql("DELETE FROM config WHERE configkey = ?", [configkey]);
                }
                )
}

// READ CONFIG VALUE
function readConfig(configkey) {
    var data = {}
    db.readTransaction(
                function(tx) {
                    var rs = tx.executeSql("SELECT * FROM config WHERE configkey = ?", [configkey])
                    if(rs.rows.length === 1) {
                        data = rs.rows.item(0)
                    }
                }
                )
    return data;
}


// DEFAULT CITY  ITEM
function defaultCityItem()
{
    return {cityid: "", city: "", country: "", lat: "", long: "", sunrise: "", sunset: "", currenttemp: "", tempunit: "", humidity: "", humidityunit: "", icon: "", weathernumber: "", windspeed: "", winddirection: "", lastupdate: new Date(), favoritecity: 0}
}

// DEFAULT FORECAST ITEM
function defaultDailyForecastItem()
{
    return {cityid: "", day: "", icon: "", weathernumber: "", mintemp: "", maxtemp: "", tempunit: "", windspeed: "", winddirection: "", lastupdate: new Date()}
}

function defaultHourlyForecastItem()
{
    return {cityid: "", datefrom: "", dateto: "", icon: "", weathernumber: "", mintemp: "", maxtemp: "", tempunit: "", windspeed: "", winddirection: "", lastupdate: new Date()}
}

// DEFAULT CONFIG ITEM
function defaultConfigItem()
{
    return {configkey: "", configvalue: ""}
}

// DEFAULT CONFIG SETUP
function createDefaultConfig(configItem)
{
    db.transaction(
                function(tx) {
                    tx.executeSql("INSERT INTO config (configkey, configvalue) VALUES('language','en')");
                    tx.executeSql("INSERT INTO config (configkey, configvalue) VALUES('language_name','English')");
                    tx.executeSql("INSERT INTO config (configkey, configvalue) VALUES('units','celsius')");
                    tx.executeSql("INSERT INTO config (configkey, configvalue) VALUES('units_name','Celsius')");
                    tx.executeSql("INSERT INTO config (configkey, configvalue) VALUES('windunits','ms')");
                    tx.executeSql("INSERT INTO config (configkey, configvalue) VALUES('windunits_name','meters per second')");
                }
                )
}
