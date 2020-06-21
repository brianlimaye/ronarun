//
//  HomeScene.swift
//  coronarun
//
//  Created by Brian Limaye on 5/31/20.
//  Copyright © 2020 Brian Limaye. All rights reserved.
//
//1. Try to add characters that cough/sneeze.
//2. Pick up facemasks, gloves, faceshield.
//3. Background from China.

import Foundation
import SpriteKit

var cameraNode: SKCameraNode = SKCameraNode()
var backGBlur: SKEffectNode = SKEffectNode()

struct levelData
{
    static var maxLevel: Int = 5
    static var currentLevel: Int = 1
    static var levelSelected: Int = -1
    static var handSanitizerCount: Int = 0
    static var didLoadFromHome: Bool = false
}

class HomeScene: SKScene
{
    var frozenBackground: SKSpriteNode = SKSpriteNode()
    var frozenPlatform: SKSpriteNode = SKSpriteNode()
    var idleCharacter: SKSpriteNode = SKSpriteNode()
    var greenSplat: SKSpriteNode = SKSpriteNode()
    var mainTitleScreen: SKLabelNode = SKLabelNode()
    var iconHolder: SKShapeNode = SKShapeNode()
    var rateButton: SKSpriteNode = SKSpriteNode()
    var rateButtonShape: SKShapeNode = SKShapeNode()
    var tutorialButton: SKSpriteNode = SKSpriteNode()
    var tutorialButtonShape: SKShapeNode = SKShapeNode()
    var soundButton: SKSpriteNode = SKSpriteNode()
    var soundButtonShape: SKShapeNode = SKShapeNode()
    var menuButton: SKSpriteNode = SKSpriteNode()
    var menuButtonShape: SKShapeNode = SKShapeNode()
    var clickToStart: SKLabelNode = SKLabelNode()
    
    var handSanitizerScore: Int = 0
    var scoreLabel: SKLabelNode = SKLabelNode()
    var miniHandSanitizer: SKSpriteNode = SKSpriteNode()
    var scoreLabelShape: SKShapeNode = SKShapeNode()
        
    override func didMove(to view: SKView) {
        
        //pullSavedData()
        
        GameScene.defaults.removeObject(forKey: "maxlevel")
        GameScene.defaults.removeObject(forKey: "handsanitizer")
        
        if((cameraNode.children.count > 0) && (backGBlur.children.count > 0))
        {
            cameraNode.removeAllChildren()
            backGBlur.removeAllChildren()
        }
        
        initBlurEffect()
        drawGreenSplat()
        initTitleScreen()
        addBackgFreezeFrame()
        addPlatformFreezeFrame()
        addIdleCharacter()
        drawSoundButton()
    }
    
    func pullSavedData() {
        
        let str = String(GameScene.defaults.integer(forKey: "maxlevel"))
        let count = GameScene.defaults.integer(forKey: "handsanitizer")
        
        if(Int(str) ?? 0 > 1)
        {
            levelData.currentLevel = GameScene.defaults.integer(forKey: "maxlevel")
        }
        
        levelData.handSanitizerCount = count
        

    }
    
    func convert(point: CGPoint)->CGPoint {
        return self.view!.convert(CGPoint(x: point.x, y:self.view!.frame.height-point.y), to:self)
    }
    
    func showScore() {
           
       scoreLabel = SKLabelNode(fontNamed: "KeyVirtueRegular")
       scoreLabel.text = String(handSanitizerScore)
       scoreLabel.fontColor = .white
       scoreLabel.fontSize = 84
       
       miniHandSanitizer = SKSpriteNode(imageNamed: "hand-sanitizer.png")
       miniHandSanitizer.size = CGSize(width: miniHandSanitizer.size.width / 8, height: miniHandSanitizer.size.height / 8)
       miniHandSanitizer.position = CGPoint(x: -150, y: -50)
       scoreLabel.position = CGPoint(x: -75, y: -75)
       
       scoreLabelShape = SKShapeNode(rect: CGRect(x: 0, y: 0, width: -200, height: -100), cornerRadius: 100)
       
       scoreLabelShape.addChild(scoreLabel)
       scoreLabelShape.addChild(miniHandSanitizer)
   
       
       if(UIDevice.current.userInterfaceIdiom == .pad)
       {
           scoreLabelShape.position.x = self.frame.width / 2
           scoreLabelShape.position.y = self.frame.height / 2.5
       }
       if(UIDevice.current.userInterfaceIdiom == .phone)
       {
           scoreLabelShape.position.x = self.frame.width / 2
           scoreLabelShape.position.y = self.frame.height / 2
       }

       //scoreLabelShape.fillColor = .
       scoreLabelShape.strokeColor = .green
       scoreLabelShape.lineWidth = 5
       scoreLabelShape.isAntialiased = true
       
       self.addChild(scoreLabelShape)
  }
    
    func initBlurEffect() {
        
        let filter = CIFilter(name: "CIGaussianBlur")
        // Set the blur amount. Adjust this to achieve the desired effect
        let blurAmount = 20.0
        filter?.setValue(blurAmount, forKey: kCIInputRadiusKey)

        backGBlur.filter = filter
        backGBlur.shouldEnableEffects = false
        backGBlur.blendMode = .alpha
        cameraNode.addChild(backGBlur)
        self.addChild(cameraNode)
    }
    
    func addBackgFreezeFrame()
    {
        if(cameraNode.contains(frozenBackground))
        {
            return
        }
        
        let backgTexture = SKTexture(imageNamed: "seamless-background.png")
            
        let backgAnimation = SKAction.move(by: CGVector(dx: -backgTexture.size().width, dy: 0), duration: 3)
        
        let backgShift = SKAction.move(by: CGVector(dx: backgTexture.size().width, dy: 0), duration: 0)
        let bgAnimation = SKAction.sequence([backgAnimation, backgShift])
        let infiniteBackg = SKAction.repeatForever(bgAnimation)
                
        var i: CGFloat = 0

        while i < 2 {
            
            frozenBackground = SKSpriteNode(texture: backgTexture)
            frozenBackground.name = "background" + String(format: "%.0f", Double(i))
            frozenBackground.position = CGPoint(x: backgTexture.size().width * i, y: self.frame.midY)
            frozenBackground.size.height = self.frame.height
            frozenBackground.run(infiniteBackg, withKey: "background")

            backGBlur.addChild(frozenBackground)

            i += 1

            // Set background first
            frozenBackground.zPosition = -2
            frozenBackground.speed = 0
        }
    }
    
    func addPlatformFreezeFrame() {
        
        if(cameraNode.contains(frozenPlatform))
        {
            return
        }
        
        frozenPlatform = SKSpriteNode(imageNamed: "world1.png")
        let pfTexture = SKTexture(imageNamed: "world1.png")
        
        let movePfAnimation = SKAction.move(by: CGVector(dx: -pfTexture.size().width, dy: 0), duration: 3)
        let shiftPfAnimation = SKAction.move(by: CGVector(dx: pfTexture.size().width, dy: 0), duration: 0)
        
        let pfAnimation = SKAction.sequence([movePfAnimation, shiftPfAnimation])
        let movePfForever = SKAction.repeatForever(pfAnimation)
                
        var i: CGFloat = 0
        
        while i < 2 {
                
            frozenPlatform = SKSpriteNode(imageNamed: "world1.png")
            
            frozenPlatform.position = CGPoint(x: i * pfTexture.size().width, y: -(self.frame.height / 2.5))
            frozenPlatform.name = "platform" + String(format: "%.0f", Double(i))
            frozenPlatform.size = CGSize(width: self.frame.width * 2, height: self.frame.height / 3.5)
    
            frozenPlatform.run(movePfForever, withKey: "platform")
            
            cameraNode.addChild(frozenPlatform)
            
            i += 1

            // Set platform first
            frozenPlatform.zPosition = 0;
            frozenPlatform.speed = 0
        }
    }
    
    func addIdleCharacter() -> Void {
        
        if(cameraNode.contains(idleCharacter))
        {
            return
        }
        //idleCharacter.removeAllActions()
        idleCharacter = SKSpriteNode(imageNamed: "(b)obby-1.png")
        
        idleCharacter.position = CGPoint(x: self.frame.minX / 3, y: self.frame.minY / 1.71)
        idleCharacter.name = "character"
        idleCharacter.size = CGSize(width: idleCharacter.size.width / 2, height: idleCharacter.size.height / 2)
        idleCharacter.color = .black
        idleCharacter.colorBlendFactor = 0.1
        idleCharacter.zPosition = 2;
        
        let idleFrames: [SKTexture] = [SKTexture(imageNamed: "idle-1"), SKTexture(imageNamed: "idle-2")/*, SKTexture(imageNamed: "idle-3"),*/]//, SKTexture(imageNamed: "idle-4")]
        
        let idleAnim = SKAction.animate(with: idleFrames, timePerFrame: 0.25)
        
        let idleForever = SKAction.repeatForever(idleAnim)
        
        cameraNode.addChild(idleCharacter)
        idleCharacter.run(idleForever)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            
            let location = touch.previousLocation(in: self)
            let node = self.nodes(at: location).first
            
            if((node?.name == "menuicon") || (node?.name == "menubutton"))
            {
                cleanUp()
                let menuScene = MenuScene(fileNamed: "MenuScene")
                menuScene?.scaleMode = .aspectFill
                self.view?.presentScene(menuScene)
            }
            /*
            else
            {
                cleanUp()
                let gameScene = GameScene(fileNamed: "GameScene")
                gameScene?.scaleMode = .aspectFill
                self.view?.presentScene(gameScene)
            }
 */
        }
        
        
        cleanUp()
        levelData.didLoadFromHome = true
        let gameScene = GameScene(fileNamed: "GameScene")
        gameScene?.scaleMode = .aspectFill
        self.view?.presentScene(gameScene!, transition: SKTransition.crossFade(withDuration: 0.5))
    }
    
    func initTitleScreen() {
        
        drawGreenSplat()
        drawMainText()
        drawIconRect()
        drawLikeButton()
        drawTutorialButton()
        drawMenuButton()
        drawClickToStart()
    }
    
    func drawGreenSplat() {
        
        greenSplat = SKSpriteNode(imageNamed: "green-splat.png")
        greenSplat.zPosition = 3
        if UIDevice.current.userInterfaceIdiom == .pad {
          
        greenSplat.size = CGSize(width: (self.frame.width - greenSplat.size.width) * 3.75, height: (self.frame.width - greenSplat.size.height) * 3.75)
        greenSplat.position = CGPoint(x: self.frame.midX - 20, y: self.frame.midY + 320)
        }
        
        if(UIDevice.current.userInterfaceIdiom == .phone) {
            
           greenSplat.size = CGSize(width: (self.frame.width - greenSplat.size.width) * 4, height: (self.frame.width - greenSplat.size.height) * 4)
            greenSplat.position = CGPoint(x: self.frame.midX - 20, y: self.frame.midY + 400)
        }
        self.addChild(greenSplat)
    }
    
    func drawMainText() {
        
        mainTitleScreen = SKLabelNode(fontNamed: "MaassslicerItalic")
        
        mainTitleScreen.position = CGPoint(x: self.frame.midX, y: self.frame.maxY / 1.85)
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            mainTitleScreen.position.y = self.frame.maxY / 2.3
        }
        
        mainTitleScreen.fontColor = .black
        mainTitleScreen.fontSize = 100
        mainTitleScreen.numberOfLines = 1
        mainTitleScreen.text = "Corona Run"
        mainTitleScreen.zPosition = 4
        
        self.addChild(mainTitleScreen)
    }
    
    func drawIconRect() {
        
        iconHolder = SKShapeNode(rect: CGRect(x: -self.frame.width, y: self.frame.midY, width: (2 * self.frame.width), height: self.frame.height / 13))
        
        iconHolder.fillColor = .clear
        iconHolder.lineWidth = 5
        iconHolder.isAntialiased = true
        iconHolder.strokeColor = .black
        
        self.addChild(iconHolder)
    }
    
    func drawLikeButton() {
        
        rateButton = SKSpriteNode(imageNamed: "like-icon.png")
        rateButton.size = CGSize(width: rateButton.size.width / 19, height: rateButton.size.height / 19)
        rateButton.position = CGPoint(x: 0, y: 0)
        
        rateButtonShape = SKShapeNode(circleOfRadius: 55)
        rateButtonShape.fillColor = .white
        rateButtonShape.isAntialiased = true
        rateButtonShape.isUserInteractionEnabled = false
        rateButtonShape.lineWidth = 5
        rateButtonShape.strokeColor = .black
        rateButtonShape.addChild(rateButton)
        
        iconHolder.addChild(rateButtonShape)
        
        rateButtonShape.position = CGPoint(x: -self.size.width / 3, y: 50)
    }
    
    func drawTutorialButton() {
        
        tutorialButton = SKSpriteNode(imageNamed: "question-mark.png")
        tutorialButton.size = CGSize(width: tutorialButton.size.width / 7 , height: tutorialButton.size.height / 7)
        tutorialButton.position = CGPoint(x: 0, y: 0)
        
        tutorialButtonShape = SKShapeNode(circleOfRadius: 55)
        tutorialButtonShape.fillColor = .white
        tutorialButtonShape.isAntialiased = true
        tutorialButtonShape.isUserInteractionEnabled = false
        tutorialButtonShape.lineWidth = 5
        tutorialButtonShape.strokeColor = .black
        tutorialButtonShape.addChild(tutorialButton)
        
        iconHolder.addChild(tutorialButtonShape)
        
        tutorialButtonShape.position = CGPoint(x: -self.size.width / 9, y: 50)
    }
    
    func drawSoundButton() {
        
        soundButton = SKSpriteNode(imageNamed: "volume-on.png")
        soundButton.size = CGSize(width: soundButton.size.width / 6 , height: soundButton.size.height / 6)
        soundButton.position = CGPoint(x: 0, y: 0)
        
        soundButtonShape = SKShapeNode(circleOfRadius: 55)
        soundButtonShape.fillColor = .white
        soundButtonShape.isAntialiased = true
        soundButtonShape.isUserInteractionEnabled = false
        soundButtonShape.lineWidth = 5
        soundButtonShape.strokeColor = .black
        soundButtonShape.addChild(soundButton)
        
        iconHolder.addChild(soundButtonShape)
        
        soundButtonShape.position = CGPoint(x: self.size.width / 3, y: 50)
    }
    
    func drawMenuButton() {
        
        menuButton = SKSpriteNode(imageNamed: "menu-icon.png")
        menuButton.size = CGSize(width: menuButton.size.width / 5 , height: menuButton.size.height / 5)
        menuButton.name = "menuicon"
        menuButton.isUserInteractionEnabled = false
        
        menuButtonShape = SKShapeNode(circleOfRadius: 55)
        menuButtonShape.fillColor = .white
        menuButtonShape.name = "menubutton"
        menuButtonShape.isAntialiased = true
        menuButtonShape.isUserInteractionEnabled = false
        menuButtonShape.lineWidth = 5
        menuButtonShape.strokeColor = .black
        menuButtonShape.addChild(menuButton)
        menuButton.position = CGPoint(x: 15, y: 0)
        
        iconHolder.addChild(menuButtonShape)
        
        menuButtonShape.position = CGPoint(x: self.size.width / 9, y: 50)
    }
    
    func drawClickToStart() {
        
        clickToStart = SKLabelNode(fontNamed: "Balibold-Regular")
        clickToStart.fontColor = .white
        clickToStart.fontSize = 30
        clickToStart.text = "Click to start"
        clickToStart.position = CGPoint(x: 0, y: self.frame.minY / 3)
        clickToStart.alpha = 1
        
        let fadeIn = SKAction.fadeIn(withDuration: 1)
        let fadeOut = SKAction.fadeOut(withDuration: 1)
       
        let fadeSequence = SKAction.sequence([fadeIn, fadeOut])
        
        let fadeForever = SKAction.repeatForever(fadeSequence)
        
        self.addChild(clickToStart)
        clickToStart.run(fadeForever)
    }
    
    func cleanUp() -> Void {
        
        let children = self.children
        
        for child in children
        {
            if(!child.isEqual(to: cameraNode))
            {
                child.removeAllActions()
            }
        }
        self.removeAllChildren()
    }

    func getBackground() -> SKSpriteNode {
        
        return frozenBackground
    }
    
    func getPlatform() -> SKSpriteNode {
        
        return frozenPlatform
    }
}


