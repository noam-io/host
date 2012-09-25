import QtQuick 2.0
import Spalla 1.0

Rectangle {
    id: scene
    width: 1200
    height: 720
    color: Qt.darker("darkgrey",5)

    EventFilter {
        trigger: "speed"
        onNewEvent: speed.gaugeAmount = value
    }

    EventFilter {
        trigger: "rpms"
        onNewEvent: rpms.gaugeAmount = value
    }

    LineArray{
        anchors.fill:parent
        spacing: -3
        thickness:40
        angle: 45
        bgColor: Qt.tint(Qt.darker("slategrey",3),"#209ACD12")
        opacity: .2
    }

    LineArray{
        anchors.horizontalCenter: scene.horizontalCenter
        anchors.bottom: scene.bottom
        spacing: -3
        thickness:40
        angle: -45
        bgColor: Qt.tint(Qt.darker("slategrey", 3), "#308B4503")
        opacity: .3
    }

    focus: true
    Keys.onPressed: {
        if( event.key == Qt.Key_Q )
        {
            event.accepted = true
            Qt.quit()
        }
    }

    Gauge {
        id: speed
        maxValue: 150
        redLine: 90
        anchors.left: parent.left
        anchors.leftMargin: 350
        anchors.bottom: parent.bottom
        suffix: "mph"
    }

    Gauge {
        id: rpms
        maxValue: 9000
        redLine: 7000
        suffix: "rpms"
        anchors.right: parent.right
        anchors.rightMargin: 350
        anchors.bottom: parent.bottom
    }
}
