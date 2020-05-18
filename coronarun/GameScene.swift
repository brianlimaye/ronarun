//
//  GameScene.swift
//  coronarun
//
//  Created by Brian Limaye on 5/13/20.
//  Copyright © 2020 Brian Limaye. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate
{
    let playerSpeedPerFrame = 0.25
    let playerJumpPerFrame = 1.0
    let maxTimeMoving: CGFloat = 2
    let bgAnimatedInSecs: TimeInterval = 3
    let MIN_THRESHOLD_MS: Double = 1000
    
    var characterSprite: SKSpriteNode = SKSpriteNode()
    var background: SKSpriteNode = SKSpriteNode()
    var platform: SKSpriteNode = SKSpriteNode()
    var scoreLabel: SKSpriteNode = SKSpriteNode()
    var score: Int = 0
    var lives: Int = 1
    var gameOver: Bool = false
    var gameOverDisplay: SKLabelNode = SKLabelNode()
    var timer: Timer = Timer()
    var runAction: SKAction = SKAction()
    var lastTime: Double = 0
    

    override func didMove(to view: SKView) -> Void {
        self.physicsWorld.contactDelegate = self
        drawBackground()
        drawPlatform()
        drawCharacter()
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(jumpUp))
        swipeUp.direction = .up
        self.view?.addGestureRecognizer(swipeUp)

        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(jumpDown))
        swipeDown.direction = .down
        self.view?.addGestureRecognizer(swipeDown)
        
}

    @objc func timerAction(){
       print("timer fired!")
    }
    
    func isReady() -> Bool{
        
        var isReady: Bool = true
        let currentTime = currentTimeInMilliSeconds()
    
        if((lastTime > 0) && (currentTime - lastTime) <= 1000)
        {
            isReady = false
        }
        lastTime = currentTime
        return isReady
    }
    
    
    func currentTimeInMilliSeconds()-> Double

    {
        let currentDate = Date()

        let since1970 = currentDate.timeIntervalSince1970

        return (since1970 * 1000)
    }
    
    
    
    func pauseRunning() -> Void{
        
        let runningAction: SKAction? = characterSprite.action(forKey: "running")
        
        if let tmp = runningAction{
            
            characterSprite.removeAction(forKey: "running")
            self.runAction = runningAction!
        }
        
    }
    
    func resumeRunning() -> Void{
        
        characterSprite.run(runAction, withKey: "running")
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {

        if let swipeGesture = gesture as? UISwipeGestureRecognizer {

            switch swipeGesture.direction {
            case .right:
                print("Swiped right")
            case .down:
                print("Swiped down")
            case .left:
                print("Swiped left")
            case .up:
                print("Swiped up")
            default:
                break
            }
        }
    }
    
    @objc func jumpUp() {
        
        if(!isReady())
        {
            print("Cooldown on button")
            return
        }
        
        print("jumpUp")
        pauseRunning()
        jumpCharacter()
        let seconds = 1.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds)
        {
            self.resumeRunning()
        }
    }
    
    @objc func jumpDown(sender: UIButton!) {
        
        if(!isReady())
        {
            print("Cooldown on button")
            return
        }
        print("jumpDown")
        pauseRunning()
        duckCharacter()
        let seconds = 1.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds)
        {
            self.resumeRunning()
        }
    }

    func initializeGame() -> Void{
            
            timer = Timer.scheduledTimer(
                timeInterval: 3,
                 target: self,
                 selector: #selector(timerAction),
                 userInfo: nil,
                 repeats: true
            )
        
            //drawBackground()
            drawCharacter()
    }
    
    func drawBackground() -> Void{
        
        let backgTexture = SKTexture(imageNamed: "seamless-background.png")
        
        let backgAnimation = SKAction.move(by: CGVector(dx: -backgTexture.size().width, dy: 0), duration: bgAnimatedInSecs)
        
        let backgShift = SKAction.move(by: CGVector(dx: backgTexture.size().width, dy: 0), duration: 0)
        let bgAnimation = SKAction.sequence([backgAnimation, backgShift])
        let infiniteBackg = SKAction.repeatForever(bgAnimation)

        var i: CGFloat = 0

        while i < maxTimeMoving {
            background = SKSpriteNode(texture: backgTexture)
            
            background.position = CGPoint(x: backgTexture.size().width * i, y: self.frame.midY)
            background.size.height = self.frame.height
            background.run(infiniteBackg, withKey: "background")

            self.addChild(background);

            i += 1

            // Set background first
            background.zPosition = -2;
        }
    }
    
    func drawPlatform() -> Void{
        
        let pfTexture = SKTexture(imageNamed: "grounds.png")
        
        let movePfAnimation = SKAction.move(by: CGVector(dx: -pfTexture.size().width, dy: 0), duration: bgAnimatedInSecs)
        let shiftPfAnimation = SKAction.move(by: CGVector(dx: pfTexture.size().width, dy: 0), duration: 0)
        
        let pfAnimation = SKAction.sequence([movePfAnimation, shiftPfAnimation])
        let movePfForever = SKAction.repeatForever(pfAnimation);
        
        var i: CGFloat = 0
        
        
        
        while i < maxTimeMoving{
            
            platform = SKSpriteNode(imageNamed: "grounds.png")
            
            platform.position = CGPoint(x: i * pfTexture.size().width, y: -(scene?.size.height)! / 2.73)
            platform.size.height = 400;
    
            platform.run(movePfForever, withKey: "platform")
            
            self.addChild(platform)
            
            i += 1

            // Set background first
            background.zPosition = -1;
        }
    }
    
    func drawCharacter() -> Void{
        
        let runAnimations:[SKTexture] = [SKTexture(imageNamed: "row-1-col-1.png"), SKTexture(imageNamed: "row-1-col-2.png"), SKTexture(imageNamed: "row-1-col-3.png"), SKTexture(imageNamed: "row-2-col-1.png"), SKTexture(imageNamed: "row-2-col-2.png"), SKTexture(imageNamed: "row-2-col-3.png")]
        
        let mainAnimated = SKAction.animate(with: runAnimations, timePerFrame: 0.25)
        let mainRepeater = SKAction.repeatForever(mainAnimated)
        
        characterSprite = SKSpriteNode(imageNamed: "row-1-col-1.png")
        characterSprite.zPosition = 2;
        characterSprite.position = CGPoint(x: self.frame.minX / 3, y: self.frame.minY / 1.70)
        
        self.addChild(characterSprite)
        characterSprite.run(mainRepeater, withKey: "running")
        
        /*
        let seconds = 5.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds)
        {
            self.characterSprite.removeAction(forKey: "running")
            self.jumpCharacter()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds + 1.0)
        {
            self.characterSprite.run(mainRepeater, withKey: "running")
        }
 */

    }
    
    func jumpCharacter() -> Void{
                
        let upAction = SKAction.move(to: CGPoint(x: self.frame.minX / 3, y: self.frame.midY), duration: 0.5)
        let downAction = SKAction.move(to: CGPoint(x: self.frame.minX / 3, y: self.frame.minY / 1.70), duration: 0.5)
    
        let upRepeater = SKAction.repeat(upAction, count: 1)
        let downRepeater = SKAction.repeat(downAction, count: 1)
        
        characterSprite.texture = SKTexture(imageNamed: "row-3-col-1.png")
        characterSprite.run(upRepeater, withKey: "up")
        
        let seconds = 0.50
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            
            self.characterSprite.texture = SKTexture(imageNamed: "row-3-col-2.png")
            self.characterSprite.removeAction(forKey: "up")
            self.characterSprite.run(downRepeater, withKey: "down")
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds){
                
                self.characterSprite.removeAction(forKey: "down")
                self.characterSprite.texture = SKTexture(imageNamed: "row-1-col-1.png")
            }
        }
    }
    
    func duckCharacter() -> Void {
        
       let duckFrames:[SKTexture] = [SKTexture(imageNamed: "row-4-col-1.png")]
        
       characterSprite.texture = SKTexture(imageNamed: "row-4-col-1.png")
    
        let duckAnimation = SKAction.animate(with: duckFrames, timePerFrame: 0.25)
        
        let repeatDuck = SKAction.repeatForever(duckAnimation)

        characterSprite.run(repeatDuck, withKey: "ducking")
        
        let seconds = 1.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds)
        {
            self.characterSprite.removeAction(forKey: "ducking")
            self.characterSprite.texture = SKTexture(imageNamed: "row-1-col-1.png")
        }
    }

    /*
func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        
        self.lastUpdateTime = currentTime
    }
 */
}

