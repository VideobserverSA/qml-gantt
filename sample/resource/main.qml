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
import Gantt 1.0

ApplicationWindow {
    visible: true
    width: 1500
    height: 480
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

    property int currentZoom: 1;

    Rectangle{
        height: parent.height - 14
        clip: true
        width: 150

        ListView{
            id: ganttNameView

            anchors.fill: parent

            interactive: false
            contentY: ganttView.contentY

            model: ganttModelList
            delegate: Rectangle{
                width: parent.width
                height: 40
                Rectangle{
                    color: "#ccc"
                    width: parent.width
                    height: 38
                    Text{
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        text: name
                        font.family: "Arial, Helvetica, open-sans"
                        font.pixelSize: 13
                        color: "#000"
                    }
                    MouseArea{
                        anchors.fill: parent
                        onDoubleClicked: {
                            trackEditBox.visible = true
                            trackEdit.selectAll()
                            trackEdit.forceActiveFocus()
                        }
                    }
                    Rectangle{
                        id: trackEditBox
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.fill: parent
                        anchors.margins: 5
                        visible: false
                        color: "#aaa"
                        border.color: "#6666cc"
                        border.width: 1
                        TextInput{
                            id: trackEdit
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 5
                            width: parent.width - 10
                            text: name
                            color: "#000"
                            font.pixelSize: 13
                            font.bold: false
                            font.family: "Arial, Helvetica, sans-serif"
                            selectByMouse: true
                            selectionColor: "#444499"
                            onActiveFocusChanged: {
                                if ( !activeFocus ){
                                    name = text
                                    trackEditBox.visible = false
                                }
                            }
                            Keys.onReturnPressed: {
                                name = text
                                event.accepted = true
                                trackEditBox.visible = false
                            }
                            Keys.onEnterPressed: {
                                name = text
                                event.accepted = true
                                trackEditBox.visible = false
                            }

                            Keys.onEscapePressed: {
                                text = name
                                event.accepted = true
                                trackEditBox.visible = false
                            }
                            MouseArea{
                                anchors.fill: parent
                                acceptedButtons: Qt.NoButton
                                cursorShape: Qt.IBeamCursor
                            }
                        }
                    }
                }
            }

            MouseArea{
                anchors.fill: parent
                onWheel: {
                    wheel.accepted = true
                    var newContentY = ganttView.contentY -= wheel.angleDelta.y / 6
                    if ( newContentY > ganttView.contentHeight - ganttView.height )
                        ganttView.contentY = ganttView.contentHeight - ganttView.height
                    else if ( newContentY < 0 )
                        ganttView.contentY = 0
                    else
                        ganttView.contentY = newContentY
                }
                onClicked: mouse.accepted = false;
                onPressed: mouse.accepted = false;
                onReleased: mouse.accepted = false
                onDoubleClicked: mouse.accepted = false;
                onPositionChanged: mouse.accepted = false;
                onPressAndHold: mouse.accepted = false;
            }
        }
    }

    Rectangle{
        id: timeContainer
        height: parent.height
        width: parent.width - 152
        x: 152

        focus: true
        Keys.onPressed: {
            //console.log("GOT KEY?");
            if (event.key === Qt.Key_D) {
                timeSlider.value += 1;
                centerGanttView();
            }

            if(event.key === Qt.Key_Z) {
                currentZoom = Math.max(1, currentZoom - 1);
                //timeSlider.width = ganttModelList.contentWidth
            }

            if(event.key === Qt.Key_X) {
                currentZoom += 1;
                //timeSlider.width = ganttModelList.contentWidth
            }

            console.log("vpw", ganttLine.viewportWidth);
        }

        ScrollView {
            id: mainScroll
            height: parent.height - 40
            width: parent.width
            horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff

            ListView{
                id: ganttView

                height: parent.height
                contentWidth: ganttModelList.contentWidth
                model: ganttModelList
                delegate: Rectangle{
                    height: 40
                    width: ganttLine.width
                    color: "#fff"

                    Rectangle{
                        height: 38
                        width: ganttLine.width
                        color: "#ccc"
                        GanttLine{
                            id: ganttLine
                            color: "#ccc"
                            height: 24
                            anchors.centerIn: parent
                            viewportX: ganttView.contentX / ganttLine.zoomScale
                            viewportWidth: ganttView.width / ganttLine.zoomScale
                            model: ganttModel
                            onEditItem: {
                                ganttEditWindow.ganttItem = item
                                ganttEditWindow.visible = true
                            }
                            zoomScale: currentZoom
                        }
                    }
                }
            }
        }

        ScrollView {
            id: timeScroll
            height: 40
            width: parent.width
            anchors.bottom: parent.bottom
            flickableItem.onContentXChanged: {
                //console.log("CONTENT X CHANGED");
                ganttView.contentX = flickableItem.contentX;
                placePositionBar();
            }

            Slider {
                id: timeSlider
                minimumValue: 0
                maximumValue: 1000
                value: 500
                width: ganttModelList.contentWidth
                tickmarksEnabled: true
                stepSize: 1
                onValueChanged: {
                    placePositionBar();
                }
            }
        }

        Rectangle {
            id: timePositionBar
            width: 2
            height: parent.height
            color: "red"
            x: 200
        }
    }


    GanttEditWindow{
        id: ganttEditWindow
    }
    GanttHelpWindow{
        id: ganttHelpWindow
    }

    function placePositionBar()
    {
        // get the percentage within the slider
        var percInSlider = timeSlider.value / timeSlider.maximumValue;

        // is it in the visible viewport??
        var startX = timeScroll.flickableItem.visibleArea.xPosition;
        var endX = timeScroll.flickableItem.visibleArea.xPosition + timeScroll.flickableItem.visibleArea.widthRatio;

        if(startX < percInSlider && endX > percInSlider) {
            // we are in the middle
            timePositionBar.color = "red"
            // put the bar on top of the slider thumb
            var realX = ((percInSlider - startX) / timeScroll.flickableItem.visibleArea.widthRatio) * timeScroll.flickableItem.width;
            timePositionBar.x = realX;

        } else if (startX < percInSlider) {
            // after
            timePositionBar.color = "blue";
            timePositionBar.x = timeContainer.width - 20;
        } else {
            // before
            timePositionBar.color = "green";
            timePositionBar.x = 0;
        }
    }

    function centerGanttView()
    {
        // place it at the slider value content x, and subtract half of the real width so it centers
        var percInSlider = timeSlider.value / timeSlider.maximumValue;
        timeScroll.flickableItem.contentX =
                (percInSlider * timeScroll.flickableItem.contentWidth) -
                (timeScroll.flickableItem.width / 2);

    }
}
