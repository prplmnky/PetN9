import QtQuick 2.2
import com.blogspot.iamboke 1.0

/**
 * Food
 * 
 * Represents a pet food.
 */
GameObject {
    type: SpriteModel.FOOD
    Image {
        id: image1
        anchors.fill: parent
        source: "qrc:/images/food.png"
    }
}
