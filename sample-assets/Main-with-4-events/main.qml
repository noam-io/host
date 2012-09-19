import QtQuick 2.0
import Spalla 1.0

Rectangle {
    id: scene

    EventFilter {
        trigger: "event 1"
    }

    EventFilter {
        trigger: "event 2"
    }

    EventFilter {
        trigger: "event 3"
    }

    EventFilter {
        trigger: "event 4"
    }
}
