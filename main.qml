import QtQuick 2.1
import QtQuick.Window 2.0
import QtSensors 5.1
import IOSMail 1.0

Window {
    id: mainWindow
    color: "white"

    IOSMail {
        id: mail
    }

    Image {
        id: img
        width: 200
        height: 200
        source: "qt.png"

        MouseArea {
            anchors.fill: parent
            onClicked: mail.sendDb()
        }
    }
}
