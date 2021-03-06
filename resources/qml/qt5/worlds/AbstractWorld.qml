import QtQuick 2.2
import QtQuick.Dialogs 1.1
import com.blogspot.iamboke 1.0
import "../pets"

import "/QmlLogger/Logger.js" as Console
import "/js/_private.js" as JObjects
import "/js/SpriteFunctions.js" as SpriteFunctions
import "/js/UIConstants.js" as UI

/**
  AbstractWorld.qml

  This is the element that paints the scenery and Pet element on screen. Has common objects which specific worlds use.

  Properties
  spriteBottom (real) - bottom boundary for the pet (suggested to override)
  spriteTop (real) - bottom boundary for the pet
  spriteLeft (real) - left boundary for the pet
  spriteRight (real) - right boundary for the pet
  pet (Pet) - the QtObject backed model
  petItem (AbstractPet) - the visual pet representation
  */

Rectangle {
    id:world

    property PetModel pet

    /** Must be defined by sub-elements to provide Sprite boundaries*/
    property real spriteBottom: appWindow.height
    property real spriteTop: 0
    property real spriteLeft: 0
    property real spriteRight: appWindow.width
    property AbstractPet petItem

    signal exitWorld
    signal exitGame
    signal removeFromGame (int spriteId)
    
    MessageDialog {
        id: restartGame
        title: qsTr("Game Over")
        detailedText: qsTr("Back to Title")
        standardButtons: StandardButton.Ok 
        
        onAccepted: {
            Console.info("AbstractWorld.qml: do over")
            exitWorld()
        }
    }


    Component.onCompleted: {
        pet = Manager.currentPet
        if(!!pet)
	  Console.info(pet.dead)
        initSpriteObjectArray()
        spawnSprites();
    }

    Timer {
        id: poopTimer
        interval: UI.PET_POOP_TIMER
        running: true
        repeat: true
        onTriggered: {
            spawnPoop()
        }
    }

    Timer {
        id: statTimer
        interval: UI.STAT_TIMER
        running: true
        repeat: true
        onTriggered: {
            Manager.updateStatus()
        }
    }

    Rectangle {
        x: 20
        y: spriteBottom + 20
        id: petStatus
        z: 100
        
        property PetModel pet

        color: "#00000000"
        visible: false

        width: 500
        height: 500
    }

    Timer {
        id: statusTimer
        triggeredOnStart: false
        interval: UI.PET_STATUS_BAR_TIMER
        running: petStatus.visible
        repeat: false
        onTriggered: {
            petStatus.visible = false
        }
    }

    //Property Handlers
    onSpriteBottomChanged: {
        Console.debug("AbstractWorld.qml: new sprite bottom: " + spriteBottom)
        if(!!petItem) {
            petItem.y = spriteBottom - petItem.height
            Console.debug("AbstractWorld.qml: pet y " + petItem.y)
        }

        var spriteObjectArray = JObjects.register(world).spriteObjectArray;
	
	if(!!spriteObjectArray)
	  Console.debug("Sprite numbers: " + spriteObjectArray.length);

        for(var i = 0; !!spriteObjectArray && i < spriteObjectArray.length; i++) {
            var s = spriteObjectArray[i]
            s.y = spriteBottom - (!!s.height ? s.height : UI.GAME_OBJECT_HEIGHT)
        }
    }
    
    onSpriteRightChanged: {
        Console.debug("AbstractWorld.qml: new sprite right: " + spriteRight)
        if(!!petItem && petItem.x - petItem.width > spriteRight) {
            petItem.x = spriteRight - petItem.width
            Console.debug("AbstractWorld.qml: pet x " + petItem.x)
        }

        var spriteObjectArray = JObjects.register(world).spriteObjectArray;

        for(var i = 0; !!spriteObjectArray && i < spriteObjectArray.length; i++) {
            var s = spriteObjectArray[i]
            if(s.x > spriteRight)
                s.x = spriteRight - (!!s.width ? s.width : UI.GAME_OBJECT_WIDTH)
        }
    }

    onPetItemChanged: {
        petItem.isDead = pet.dead
        Console.info("AbstractWorld.qml: pet object obtained")
        if(!!petItem) {
            petItem.setCollisionCallback(isCollisionFree)
            petItem.setFoodCallback(hasFood)
            petItem.doStandardAnimations = true
            petItem.doStatusAnimation = true
        }
        petItem.x = (spriteRight - petItem.width) / 2
        petItem.y = spriteBottom - petItem.height
        petItem.petClicked.connect(petClicked)
        Console.debug("AbstractWorld.qml: pet position ("+ petItem.x +"," + petItem.y+")")
        Console.debug("AbstractWorld.qml: pet is " + (pet.dead ? "dead" : "alive"))

        var foodObjectArray = JObjects.register(world).foodObjectArray
        if(!!foodObjectArray && !!foodObjectArray.length) {
            petItem.doFeedingAnimation = true
        }
    }

    onPetChanged: {
        pet.deadChanged.connect(updatePetStatus)
        SpriteFunctions.createPet("/qml/qt5/pets/", pet.type, world, {"z": 100}, createPetHandler)
    }

    // Javascript Functions
    function updatePetStatus() {
        Console.info("AbstractWorld.qml: status changed")
        if(!!petItem) {
            petItem.isDead = pet.dead
        }
        petItem.isHungry = pet.hungry
        petItem.isSad = pet.sad
    }

    function clearSprites() {
        //reset sprite map
        Console.debug("AbstractWorld.qml: clearing sprites")
        var newSpriteModels = Manager.sprites;
        var spriteObjectArray = JObjects.register(world).spriteObjectArray;

        for(var i = 0; i < spriteObjectArray.length; i++) {
            var s = spriteObjectArray[i]
            Console.debug("AbstractWorld.qml: Checking model " + s.spriteId)
            var found = false
            for(var j = 0; j < newSpriteModels.length; j++) {
                var t = newSpriteModels[j]
                if(s.spriteId == t.id) {
                    found = true
                    break;
                }
            }
            if(!found) {
                Console.debug("deleting item " + s)
                s.destroy() //Remove Item from view
                spriteObjectArray.splice(i,1) //Remove item from store

                var foodObjectArray = JObjects.register(world).foodObjectArray

                for(var k = 0; k < foodObjectArray.length; k++) {
                    var u = foodObjectArray[k]
                    if(s.spriteId = u.spriteId) {
                        foodObjectArray.splice(k,1)
                        break;
                    }
                }

                i -= 1 //Reset accumulator
            }
        }
    }

    function petClicked() {
        Console.info("AbstractWorld.qml: Pet clicked")
        petStatus.visible = true
        petStatus.pet = pet
        statusTimer.start()

        if(pet.dead) {
            restartGame.open()
            return
        }
    }

    function createPetHandler(component) {
        Console.info("AbstractWorld.qml: Pet callback handler with pet " + component)
        world.petItem = component
    }

    function isCollisionFree(x) {
        Console.trace("AbstractWorld.qml: pet collision detection at " + x)
        return spriteLeft <= x && x <= spriteRight
    }

    function hasFood(x) {

        var collision = isCollisionFree(x)

        var foodObjectArray = JObjects.register(world).foodObjectArray;
        var foodExists = !!foodObjectArray.length
        Console.trace("AbstractWorld.qml: foodExists " + foodExists)
        var firstFood = foodObjectArray[0]
        var dir = null
        if(!!firstFood) {
            dir = firstFood.x - petItem.x < 0 ? petItem.moveLeft : petItem.moveRight
            dir = Math.abs(firstFood.x - petItem.x) <= petItem.width ? null : dir
        }

        if(dir === null && !!firstFood && !petItem.isDead) {
            Console.debug("AbstractWorld.qml: removing from game " + firstFood.spriteId)
            removeFromGame(firstFood.spriteId)
            Manager.updateFed()
        }

        return {
            canMove: collision,
            gotFood: foodExists,
            direction: dir
        }
    }

    function spawnSprites() {
        Console.verbose("AbstractWorld.qml: drawing left oversprites ")
        var spriteModels = Manager.sprites
        Console.debug("AbstractWorld.qml: retrieved sprite models " + spriteModels)
        if(!spriteModels) return
        Console.debug("AbstractWorld.qml: spriteModels.length " + spriteModels.length)
        for(var i = 0; i < spriteModels.length; i++) {
            var currentModel = spriteModels[i]
            Console.debug("AbstractWorld.qml: sprite Id " + currentModel.id)
            var sX = currentModel.x == -1 ? Math.random() * (appWindow.width - UI.GAME_OBJECT_WIDTH) : currentModel.x
            var sY = currentModel.y
            Console.info("AbstractWorld: new sprite " + sX + " " + sY)
            SpriteFunctions.createSprite(UI.QML_QT5_OBJS, currentModel.typeId, world, {"x": sX, "y": sY, "z": 5, "spriteId": currentModel.id}, spriteCreated)
        }
    }

    function spawnPoop() {
        Console.debug("AbstractWolrd.qml: spawning poop action ")

        var rand = Math.random()
        var spriteModels = Manager.sprites
        if (rand <= UI.PET_POOP_CHANCE) {
            if(spriteModels.length >= UI.MAX_POOP_OBJECTS) {
                Console.info("AbstractPet.qml: Max poop objects reached")
                return
            }

            Console.debug("AbstractPet.qml: pet just pooped " + UI.PET_POOP_CHANCE)
            SpriteFunctions.createSprite(UI.QML_QT5_OBJS, SpriteModel.POOP, world.parent, {"z": 5}, poopCreated)
            Manager.updateLastPoop();
        }
    }

    function feedPet() {
        if(petItem.isDead) return
        Console.debug("AbstractWolrd.qml: feeding pet action ")
        SpriteFunctions.createSprite(UI.QML_QT5_OBJS, SpriteModel.FOOD, world.parent, {"z": 5}, foodCreated)
    }

    function spriteCreated(spriteItem) {
        var spriteObjectArray = JObjects.register(world).spriteObjectArray
        spriteObjectArray[spriteObjectArray.length] = spriteItem
        Console.debug("AbstractWorld: sprite object array " + spriteObjectArray)

        if(spriteItem.type == SpriteModel.FOOD) {
            var foodObjectArray = JObjects.register(world).foodObjectArray
            foodObjectArray[foodObjectArray.length] = spriteItem
            Console.debug("AbstractWorld.qml: food object array " + foodObjectArray)
            if(!!petItem) {
                petItem.doFeedingAnimation = true
            }
        }
    }

    function poopCreated(spriteItem) {
        spriteItem.x = petItem.x
        spriteItem.y = petItem.y + spriteItem.height
        var spriteModel = Manager.createSprite(spriteItem.type, spriteItem.x, spriteItem.y)
        Console.debug("AbstractWorld.qml: poop created " + spriteModel.id)
        spriteItem.spriteId = spriteModel.id
        spriteCreated(spriteItem)
    }

    function foodCreated(spriteItem) {
        Console.debug("Abstract.qml: food item " + spriteItem)
        spriteItem.x = world.width - petItem.x - petItem.width
        spriteItem.y = petItem.y + spriteItem.height
        var spriteModel = Manager.createSprite(spriteItem.type, spriteItem.x, spriteItem.y)
        Console.debug("AbstractWorld.qml: food created " + spriteModel.id)
        spriteItem.spriteId = spriteModel.id
        spriteCreated(spriteItem)
    }

    function initSpriteObjectArray() {
        var spriteObjectArray = JObjects.register(world).spriteObjectArray
        if(!spriteObjectArray) {
            JObjects.register(world).spriteObjectArray = []
            JObjects.register(world).foodObjectArray = []
        }
    }

}
