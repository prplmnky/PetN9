import "elements"


/**
 * MountainRange
 * 
 * An abstract world that looks like a mountain plain.
 */

AbstractWorld {
    color: "#b1c2c2"
    spriteBottom: height - field.height;

    SnowyField {
        id: field
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
    }

    Sun {
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.top: parent.top
        anchors.topMargin: 20
    }

    Cloud {
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.top: parent.top
        anchors.topMargin: 20
    }

    Mountain {
        anchors.bottom: field.top
        anchors.left: parent.left
        anchors.leftMargin: 50
    }
}
