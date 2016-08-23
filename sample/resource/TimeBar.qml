import QtQuick 2.0

Item {
    height: parent.height
    width: 100

    property color barColor: "black";
    property color textColor: "black";
    property double barOpacity: 0.3;
    property string label: "XX:XX"
    property int barThickness: 2;
    property bool labelVisible: true;

    Text {
        text: label
        font.pointSize: 10
        color: textColor
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        visible: labelVisible
    }

    Rectangle {
        width: barThickness
        color: barColor
        height: parent.height - 20
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        opacity: barOpacity;
    }
}
