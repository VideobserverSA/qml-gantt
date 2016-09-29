/****************************************************************************
**
** Copyright (C) 2015-2016 Dinu SV.
** (contact: mail@dinusv.com)
** This file is part of QML Gantt library.
**
** GNU Lesser General Public License Usage
** This file may be used under the terms of the GNU Lesser
** General Public License version 3 as published by the Free Software
** Foundation and appearing in the file LICENSE.LGPLv3 included in the
** packaging of this file. Please review the following information to
** ensure the GNU Lesser General Public License version 3 requirements
** will be met: https://www.gnu.org/licenses/lgpl.html.
**
****************************************************************************/

import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import Gantt 1.0
//import QtAV 1.6
import QtMultimedia 5.5
import "timeutils.js" as TimeUtils

ApplicationWindow {
    visible: true
    width: 1500
    height: 600
    title: qsTr("QML Gantt Sample")

    menuBar: MenuBar {
        Menu {
            title: qsTr("File")
            MenuItem {
                text: qsTr("Exit")
                onTriggered: Qt.quit();
            }
        }
        Menu {
            title: qsTr("Help")
            MenuItem {
                text: qsTr("Usage...")
                onTriggered: ganttHelpWindow.show()
            }
        }
    }


    SplitView {
        anchors.fill: parent
        orientation: Qt.Vertical

        Rectangle {
            Layout.minimumHeight: 200

            Video {
                id: video
                height: 150
                autoLoad: true
                //autoPlay: true
                muted: true
                source: "file:///d:\\VIDEOS TESTE\\braga.mp4"
                onPositionChanged: {
                    console.log("pos ch video", position);
                    timeline.updateValue( (position / 1000) + 400)
                }
            }


            Button {
                text: "DEBUG 1"
                x: 0
                y:0
                onClicked: {
                    timeline.debOne();
                    //console.log(myTestModel.toJsonString());
                }
            }

            Button {
                text: "DEBUG 2"
                x: 0
                y: 30
                onClicked:  {
                    //timeline.debTwo();
                }
            }


        }



        Item {
            Layout.minimumHeight: 300
            VideoTimeline {
                id: timeline
                anchors.fill: parent
                visible: true
                onPositionChanged: {
                    console.log("pos ch timeline", position);
                    //video.seek(position);
                }
            }


        }


    }


}
