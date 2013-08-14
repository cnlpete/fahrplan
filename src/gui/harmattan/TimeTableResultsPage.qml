/****************************************************************************
**
**  This file is a part of Fahrplan.
**
**  This program is free software; you can redistribute it and/or modify
**  it under the terms of the GNU General Public License as published by
**  the Free Software Foundation; either version 2 of the License, or
**  (at your option) any later version.
**
**  This program is distributed in the hope that it will be useful,
**  but WITHOUT ANY WARRANTY; without even the implied warranty of
**  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
**  GNU General Public License for more details.
**
**  You should have received a copy of the GNU General Public License along
**  with this program.  If not, see <http://www.gnu.org/licenses/>.
**
****************************************************************************/

import Fahrplan 1.0
import QtQuick 1.1
import com.nokia.meego 1.1
import com.nokia.extras 1.1
import "components"

Page {
    property alias timetableTitleText: timetableTitle.text
    property alias searchIndicatorVisible: searchIndicator.visible

    id: searchResultsPage

    tools: timetableResultsToolbar
    Item {
        id: searchResults

        width:  parent.width
        height: parent.height

        Item {
            id: titleBar

            width: parent.width
            height: 70

            Label {
                id: timetableTitle
                text: fahrplanBackend.mode === FahrplanBackend.ArrivalMode ? qsTr("Arrivals") : qsTr("Departures")
                font.bold: true;
                font.pixelSize: 32
                anchors {
                    left: parent.left
                    leftMargin: 10
                    right: parent.right
                    rightMargin: 10
                    verticalCenter: parent.verticalCenter
                }
                width: parent.width
            }
        }

        BusyIndicator {
            id: searchIndicator
            anchors {
                top: titleBar.bottom
                topMargin: 50;
                horizontalCenter: parent.horizontalCenter
            }
            running: true
            visible: false

            platformStyle: BusyIndicatorStyle { size: "large" }
        }

        ListView {
            id: listView
            anchors {
                top: titleBar.bottom
                topMargin: 10
            }
            height: parent.height - titleBar.height - 20
            width: parent.width
            model: timetableResultModel
            delegate:  timetableResultDelegate
            clip: true

            visible: !searchIndicator.visible
        }

        ScrollDecorator {
            flickableItem: listView
        }
    }

    Component {
        id: timetableResultDelegate

        Item {
            id: delegateItem
            width: listView.width
            height: 40 + lbl_destination.height + (lbl_station.height > lbl_type.height ? lbl_station.height : lbl_type.height) + (lbl_miscinfo.visible ? lbl_miscinfo.height : 0)

            Rectangle {
                anchors.fill: parent
                color: {
                    if (theme.inverted)
                        return itemNum % 2 ? "#111" : "#333"
                    else
                        return itemNum % 2 ? "White" : "LightGrey"
                }
            }

            Rectangle {
                id: background
                anchors.fill: parent
                color: "DarkGrey"
                visible: mouseArea.pressed
            }

            Item {
                anchors {
                    verticalCenter: parent.verticalCenter
                    top: parent.top
                    topMargin: 10
                }

                width: parent.width
                height: parent.height

                Grid {
                    columns: 2
                    spacing: 10

                    anchors {
                        leftMargin: 10
                        left: parent.left
                    }

                    width: parent.width
                    height: parent.height

                    Label {
                        id: lbl_time
                        text: time
                        font.bold: true
                        width: (parent.width  - 40) / 3
                    }

                    Label {
                        id: lbl_destination
                        text: destination
                        width: ((parent.width  - 40) / 3) * 2
                    }

                    Label {
                        id: lbl_type
                        text: trainType
                        font.bold: true
                        width: (parent.width  - 40) / 3
                    }

                    Label {
                        id: lbl_station
                        text: stationplatform
                        width: ((parent.width  - 40) / 3) * 2
                    }


                    Label {
                        id: lbl_miscinfo_title
                        visible: (miscInfo == "") ? false : true
                        text: ""
                        width: (parent.width  - 40) / 3
                    }

                    Label {
                        id: lbl_miscinfo
                        visible: (miscInfo == "") ? false : true
                        text: miscInfo
                        width: ((parent.width  - 40) / 3)  * 2
                        font.bold: true
                    }
                }


            }
        }
    }

    ListModel {
        id: timetableResultModel
    }

    InfoBanner{
            id: banner
            objectName: "fahrplanInfoBanner"
            text: ""
            anchors.top: parent.top
            anchors.topMargin: 10
    }

    Connections {
        target: fahrplanBackend

        onParserErrorOccured: {
            banner.text = msg;
            banner.show();
        }

        onParserTimeTableResult: {
            console.log("Got results");
            console.log(result.count);

            searchIndicatorVisible = false;

            timetableResultModel.clear();
            for (var i = 0; i < result.count; i++) {
                var item = result.getItem(i);

                var stationplatform = item.stationName;

                if (item.platform) {
                    stationplatform = qsTr("Pl.") + " " + item.platform;
                    if (item.stationName) {
                        stationplatform += " / " + item.stationName;
                    }
                }

                var dirlabel = "";
                if (fahrplanBackend.mode === FahrplanBackend.ArrivalMode)
                    dirlabel = qsTr("from <b>%1</b>").arg(item.destinationName);
                else
                    dirlabel = qsTr("to <b>%1</b>").arg(item.destinationName);                    dirlabel = "\u2013"

                timetableResultModel.append({
                    "time": Qt.formatTime( item.time, qsTr("hh:mm")),
                    "trainType": item.trainType,
                    "destination": dirlabel,
                    "stationplatform": stationplatform,
                    "miscInfo": item.miscInfo,
                    "itemNum" : i
                });
            }
        }
    }

    ToolBarLayout {
        id: timetableResultsToolbar

        ToolIcon {
            id : backIcon;
            iconId: "toolbar-back"
            onClicked: {
                pageStack.pop();
                fahrplanBackend.parser.cancelRequest();
            }
        }
    }
}
