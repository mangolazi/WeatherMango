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

Page {
    id: about
    tools: mainToolbar
    property string version: "25"

    // Default toolbar
    ToolBarLayout {
        id: mainToolbar
        ToolButton {
            id: toolbarbtnBack
            flat: true
            iconSource: "toolbar-back"
            anchors.left: parent.left
            onClicked: {
                    window.pageStack.pop()
            }
        }
   }

    Flickable {
         width: parent.width
         height: parent.height
         contentWidth: parent.width
         contentHeight: logoImage.height + versionTxt.paintedHeight + aboutTxt.paintedHeight

    Image {
        id: logoImage
        anchors.top: parent.top
        anchors.left: parent.left
        width: 80
        height: 80
        fillMode: Image.PreserveAspectFit
        smooth: true
        source: "WeatherMango2.svg"
    }

    Text {
        id: versionTxt
        anchors.left: logoImage.right
        anchors.leftMargin: 8
        anchors.right: parent.right
        anchors.verticalCenter: logoImage.verticalCenter
        horizontalAlignment: Text.AlignLeft
        text: "WeatherMango R" + version + "\nby Mangolazi"
        font.pointSize: 10
        font.bold: true
        color: "white"
    }
    Text {
        id: weblinkTxt
        anchors.top: logoImage.bottom
        anchors.topMargin: 5
        anchors.left: parent.left
        anchors.right: parent.right
        text: qsTr("Visit openweathermap.org for more detailed weather info")
        font.pointSize: 8
        font.bold: true
        color: "lightblue"
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignLeft
        MouseArea {
            anchors.fill: parent
            onClicked: Qt.openUrlExternally("http://openweathermap.org")
        }
    }
    Text {
        id: aboutTxt
        anchors.top: weblinkTxt.bottom
        anchors.topMargin: 5
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5
        anchors.leftMargin: 5
        anchors.rightMargin: 5
        width: parent.width
        text: qsTr("AboutText")
        font.pointSize: 8
        font.bold: false
        color: "white"
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignLeft
    }

    } // end flickable

} // end page
