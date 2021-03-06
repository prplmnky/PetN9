import QtQuick 2.2
import QtQuick.Controls 1.1
import com.blogspot.iamboke 1.0
import "/QmlLogger/Logger.js" as Console

/**
  Splash.qml

  Presents the game logo and start options to the user.
  */
DefaultPage {

    property string world
    property variant worldObject

    content: Item {
        id: splash
        anchors.fill: parent

        Text {
            anchors.horizontalCenter: splash.horizontalCenter
            anchors.verticalCenter: splash.verticalCenter
            color: "#ffffff"
            text: qsTr("PetN9")
            font.pointSize: 60
        }

        Column {
            spacing: 10
            anchors.horizontalCenter: splash.horizontalCenter
            anchors.bottom: splash.bottom
            anchors.bottomMargin: 20

            Button {
                onClicked: {
                    if(!Manager.pets.length) {
                        Console.info("Splash.qml: empty pets. Creating first run wizard.")
			Console.debug("appwindow: " + appWindow)
			Console.debug("pagestack: " + appWindow.pageStack)
                        appWindow.pageStack.push(Qt.resolvedUrl("PetSelection.qml"))
                    } else {
                        Console.info("Splash.qml: has pets, creating game")
                        appWindow.pageStack.push(Qt.resolvedUrl("Game.qml"))
                    }
                }

                Component.onCompleted: {
                    text = !!Manager.pets.length ? qsTr("Resume") : qsTr("Start")
                }
            }
        }
    }
}
