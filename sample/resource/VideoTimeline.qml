import QtQuick 2.2
import QtQuick.Controls 1.4
import Gantt 1.0
import "timeutils.js" as TimeUtils

Item {

    property int currentZoom: 1;

    signal positionChanged(int position);



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

                    // check the ctrl for zoom
                    if (wheel.modifiers & Qt.ControlModifier) {

                        if(wheel.angleDelta.y > 0) {
                            zoomIn();
                        } else {
                            zoomOut();
                        }

                    } else {
                        var newContentY = ganttView.contentY -= wheel.angleDelta.y / 6
                        if ( newContentY > ganttView.contentHeight - ganttView.height )
                            ganttView.contentY = ganttView.contentHeight - ganttView.height
                        else if ( newContentY < 0 )
                            ganttView.contentY = 0
                        else
                            ganttView.contentY = newContentY
                    }


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
                zoomOut();

                //timeSlider.width = ganttModelList.contentWidth
            }

            if(event.key === Qt.Key_X) {
                zoomIn();

                // debug
                //console.log("sw", timeSlider.width, "cw", ganttModelList.contentWidth);

                //timeSlider.width = ganttModelList.contentWidth
                //console.log("cw", ganttModelList.contentWidth);
            }

            if(event.key === Qt.Key_B) {
                currentZoom = 1;
                ganttModelList.setZoomFactor(currentZoom);
                centerGanttView();
            }
        }

        ScrollView {
            id: mainScroll
            height: parent.height - 40
            width: parent.width
            horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff

            ListView{
                id: ganttView

                function addItemToGannt(item, index) {
                    var dele = ganttView.getDelegateInstanceAt(index);
                    dele.addItem(item);
                }

                // see for an explanation: http://stackoverflow.com/questions/9039497/how-to-get-an-instantiated-delegate-component-from-a-gridview-or-listview-in-qml

                // Uses black magic to hunt for the delegate instance with the given
                // index.  Returns undefined if there's no currently instantiated
                // delegate with that index.
                function getDelegateInstanceAt(index) {
                    for(var i = 0; i < contentItem.children.length; ++i) {
                        var item = contentItem.children[i];
                        // We have to check for the specific objectName we gave our
                        // delegates above, since we also get some items that are not
                        // our delegates here.
                        if (item.objectName == "ganttDelegate" && item.index == index)
                            return item;
                        }
                    return undefined;
                }

                function moveItemInModel(uuid, direction) {
                    // lets do the freaky
                    //console.log(ganttModelList);
                    ganttModelList.moveItem(uuid, direction);
                }

                height: parent.height
                contentWidth: ganttModelList.contentWidth
                model: ganttModelList
                delegate: Rectangle{
                    objectName: "ganttDelegate"
                    property int index: model.index
                    height: 40
                    width: ganttLine.width
                    color: "#fff"

                    function addItem(item) {
                        //console.log("puta do item", item);
                        ganttLine.addItem(item);
                    }

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
                            onMoveItem: {
                                var newIndex = index;
                                if(direction == "up") {
                                    newIndex -= 1;
                                } else {
                                    newIndex += 1;
                                }
                                //console.log("d", direction, "old", index, "new", newIndex);
                                ganttView.addItemToGannt(item, newIndex);
                            }
                            onMoveItemByUuid: {
                                /*var newIndex = index;
                                if(direction == "up") {
                                    newIndex -= 1;
                                } else {
                                    newIndex += 1;
                                }*/
                                //console.log("d", direction, "old", index, "new", newIndex);
                                //ganttView.addItemToGannt(item, newIndex);
                                ganttView.moveItemInModel(uuid, direction);

                            }

                            zoomScale: currentZoom
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: mouse.accepted = false;
                    onPressed: mouse.accepted = false;
                    onReleased: mouse.accepted = false
                    onDoubleClicked: mouse.accepted = false;
                    onPositionChanged: mouse.accepted = false;
                    onPressAndHold: mouse.accepted = false;
                    onWheel: {
                        // check the ctrl for zoom
                        if (wheel.modifiers & Qt.ControlModifier) {
                            if(wheel.angleDelta.y > 0) {
                                zoomIn();
                            } else {
                                zoomOut();
                            }
                        } else {
                            var newContentY = ganttView.contentY -= wheel.angleDelta.y / 6
                            if ( newContentY > ganttView.contentHeight - ganttView.height )
                                ganttView.contentY = ganttView.contentHeight - ganttView.height
                            else if ( newContentY < 0 )
                                ganttView.contentY = 0
                            else
                                ganttView.contentY = newContentY
                        }
                    }
                }
            }
        }

        ScrollView {
            id: timeScroll
            height: 40
            width: parent.width - 20
            anchors.bottom: parent.bottom
            flickableItem.onContentXChanged: {
                //console.log("CONTENT X CHANGED");
                ganttView.contentX = flickableItem.contentX;
                updateBars();
            }

            Slider {
                id: timeSlider
                minimumValue: 0
                maximumValue: 4600
                value: 2000
                width: ganttModelList.contentWidth
                tickmarksEnabled: true
                stepSize: 1
                onValueChanged: {
                    updateBars();
                    positionChanged(value);
                }
            }
        }

        /* move this fucker up to not obscure the items ?? */
        Item {
            id: timeIndicatorContainer
            height: parent.height
        }

        TimeBar {
            x: 700
            id: timePositionBar
            barColor: "red"
            barOpacity: 1.0
            textColor: "red"
            label: "00:00"
        }
    }


    GanttEditWindow{
        id: ganttEditWindow
    }
    GanttHelpWindow{
        id: ganttHelpWindow
    }

    function updateBars()
    {
        placePositionBar();

        var big = 60 * 60;
        var med = 60 * 10;
        var sml = 60 * 2;

        /*
        var big = 60 * 60;
        var med = Math.max(1,Math.floor((60 * 5) / currentZoom));
        var sml = (60 * 10) / (currentZoom);
        */

        //console.log("b", big, "m", med, "s", sml);


        placeTimeBars(big, med, sml);

    }

    function placeTimeBars(large, medium, small)
    {
        // remove all children and redo them?
        // or just reuse them?
        for(var i = timeIndicatorContainer.children.length; i > 0 ; i--) {
                //console.log("destroying: " + i)
                timeIndicatorContainer.children[i-1].destroy()
              }

        // now we need to check on which seconds are we placing this

        // so first find thew starting second and ending second
        var startTime = Math.floor(timeSlider.maximumValue * timeScroll.flickableItem.visibleArea.xPosition);
        var endTime = Math.floor(timeSlider.maximumValue *
                                 (timeScroll.flickableItem.visibleArea.xPosition + timeScroll.flickableItem.visibleArea.widthRatio));
        //console.log("s", startTime, "e", endTime);

        // new in each interval we do it
        for (var time = startTime; time < endTime; time++) {


            var realX = ((((time / timeSlider.maximumValue) - timeScroll.flickableItem.visibleArea.xPosition)
                         / timeScroll.flickableItem.visibleArea.widthRatio) * timeScroll.flickableItem.width) - 50;

            if(time % large == 0) {
                var big = Qt.createComponent("TimeBar.qml");
                big.createObject(timeIndicatorContainer, {"x": realX, "label": TimeUtils.secondsToMinutes(time), "barTickness": 4,
                                 "barOpacity": 0.7, "labelVisible": true});

            } else

            if(time % medium == 0) {
                 //console.log("time", time);
                var med = Qt.createComponent("TimeBar.qml");
                med.createObject(timeIndicatorContainer, {"x": realX, "label": TimeUtils.secondsToMinutes(time), "barTickness": 2});
            } else

            if(time % small == 0) {
                var sml = Qt.createComponent("TimeBar.qml");
                sml.createObject(timeIndicatorContainer, {"x": realX, "label": TimeUtils.secondsToMinutes(time), "barTickness": 1,
                                 "barOpacity": 0.1, "labelVisible": false});
            }
        }
        //var test = Qt.createComponent("TimeBar.qml");
        //test.createObject(timeIndicatorContainer, {"x": 400, "label": TimeUtils.secondsToMinutes(123)});

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
            timePositionBar.barColor = "red"
            // put the bar on top of the slider thumb
            var realX = ((percInSlider - startX) / timeScroll.flickableItem.visibleArea.widthRatio) * timeScroll.flickableItem.width;
            timePositionBar.x = realX - 50;

        } else if (startX < percInSlider) {
            // after
            timePositionBar.barColor = "blue";
            timePositionBar.x = timeContainer.width - 20 - 50;
        } else {
            // before
            timePositionBar.barColor = "green";
            timePositionBar.x = 0 - 50;
        }

        timePositionBar.label = TimeUtils.secondsToMinutes(timeSlider.value);
    }

    function centerGanttView()
    {
        // place it at the slider value content x, and subtract half of the real width so it centers
        var percInSlider = timeSlider.value / timeSlider.maximumValue;
        timeScroll.flickableItem.contentX =
                (percInSlider * timeScroll.flickableItem.contentWidth) -
                (timeScroll.flickableItem.width / 2);

    }

    function updateValue(value) {
        timeSlider.value = value;
        //centerGanttView();
    }

    function zoomIn()
    {
        currentZoom = Math.min(1024, currentZoom * 2);
        ganttModelList.setZoomFactor(currentZoom);
        //console.log("curr zoom", currentZoom);
        centerGanttView();
    }

    function zoomOut()
    {
        currentZoom = Math.max(1, currentZoom / 2);
        ganttModelList.setZoomFactor(currentZoom);
        centerGanttView();
    }

}
