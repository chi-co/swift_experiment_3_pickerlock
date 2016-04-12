//
//  GameScene.swift
//  PickerLock
//
//  Created by Danila Bustamante on 12/04/16.
//  Copyright (c) 2016 Francisco Aso. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var circle = SKSpriteNode()
    var person = SKSpriteNode()
    var dot = SKSpriteNode()
    
    var path = UIBezierPath()
    var gameStarted = Bool()
    var movingClockWise = Bool()
    var intersected = false
    
    var levelLabel = UILabel()
    var currentLevel = Int()
    var currentScore = Int()
    var highLevel = Int()
    
    override func didMoveToView(view: SKView) {
        
        loadView()
        
        let defaults = NSUserDefaults.standardUserDefaults() as NSUserDefaults!
        if defaults.integerForKey("HighLevel") != 0 {
            highLevel = defaults.integerForKey("HighLevel") as Int!
            currentLevel = highLevel
            currentScore = currentLevel
            levelLabel.text = "\(currentScore)"
        }
        else {
            defaults.setInteger(1, forKey: "HighLevel")
        }
    }
    
    func loadView() {
        
        movingClockWise = true
        
        self.backgroundColor = UIColor.whiteColor()
        
        circle = SKSpriteNode(imageNamed: "Circle")
        circle.size = CGSize(width: 300, height: 300)
        circle.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        self.addChild(circle)
        
        person = SKSpriteNode(imageNamed: "Person")
        person.size = CGSize(width: 40, height: 7)
        person.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 + 123)
        person.zRotation = 3.14 / 2
        person.zPosition = 2.0
        self.addChild(person)
        
        addDot()
        
        levelLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 100))
        levelLabel.center = (self.view?.center)!
        levelLabel.text = "\(currentScore)"
        levelLabel.textColor = SKColor.blackColor()
        levelLabel.textAlignment = NSTextAlignment.Center
        levelLabel.font = UIFont.systemFontOfSize(40)
        self.view?.addSubview(levelLabel)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if gameStarted == false {
            moveClockWise()
            movingClockWise = true
            gameStarted = true
        }
        else if gameStarted == true {
            if movingClockWise == true {
                moveCounterClockWise()
                movingClockWise = false
            }
            else if movingClockWise == false {
                moveClockWise()
                movingClockWise = true
            }
            dotTouched()
        }
    }
    
    func addDot() {
        
        dot = SKSpriteNode(imageNamed: "Dot")
        dot.size = CGSize(width: 30, height: 30)
        dot.zPosition = 1.0
        
        let dx = person.position.x - self.frame.width / 2
        let dy = person.position.y - self.frame.height / 2
        
        let rad = atan2(dy, dx)
        
        if movingClockWise == true {
            let tempAngle = CGFloat.random(min: rad - 1.0, max: rad - 2.5)
            let path2 = UIBezierPath(arcCenter: CGPoint(x: self.frame.width / 2, y: self.frame.height / 2), radius: 123, startAngle: tempAngle, endAngle: tempAngle + CGFloat(M_PI * 4), clockwise: true)
            dot.position = path2.currentPoint
        }
        else if movingClockWise == false {
            let tempAngle = CGFloat.random(min: rad + 1.0, max: rad + 2.5)
            let path2 = UIBezierPath(arcCenter: CGPoint(x: self.frame.width / 2, y: self.frame.height / 2), radius: 123, startAngle: tempAngle, endAngle: tempAngle + CGFloat(M_PI * 4), clockwise: true)
            dot.position = path2.currentPoint
        }
        self.addChild(dot)
    }
    
    func moveClockWise() {
        
        let dx = person.position.x - self.frame.width / 2
        let dy = person.position.y - self.frame.height / 2
        
        let rad = atan2(dy, dx)
        
        path = UIBezierPath(arcCenter: CGPoint(x: self.frame.width / 2, y: self.frame.height / 2), radius: 123, startAngle: rad, endAngle: rad + CGFloat(M_PI * 4), clockwise: true)
        let follow = SKAction.followPath(path.CGPath, asOffset: false, orientToPath: true, speed: 200)
        person.runAction(SKAction.repeatActionForever(follow).reversedAction())
    }
    
    func moveCounterClockWise() {
    
        let dx = person.position.x - self.frame.width / 2
        let dy = person.position.y - self.frame.height / 2
        
        let rad = atan2(dy, dx)
        
        path = UIBezierPath(arcCenter: CGPoint(x: self.frame.width / 2, y: self.frame.height / 2), radius: 123, startAngle: rad, endAngle: rad + CGFloat(M_PI * 4), clockwise: true)
        let follow = SKAction.followPath(path.CGPath, asOffset: false, orientToPath: true, speed: 200)
        person.runAction(SKAction.repeatActionForever(follow))

    }
    
    func dotTouched() {
        if intersected == true {
            dot.removeFromParent()
            addDot()
            intersected = false
            
            currentScore -= 1
            levelLabel.text = "\(currentScore)"
            if currentScore <= 0 {
                nextLevel()
            }
        }
        else if intersected == false {
            died()
        }
    }
    
    func nextLevel() {
        
        currentLevel += 1
        currentScore = currentLevel
        levelLabel.text = "\(currentScore)"
        won()
        
        if currentLevel > highLevel {
            highLevel = currentLevel
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setInteger(highLevel, forKey: "HighLevel")
        }
    }
    
    func died() {
        
        self.removeAllChildren()
        let action1 = SKAction.colorizeWithColor(UIColor.orangeColor(), colorBlendFactor: 1.0, duration: 0.2)
        let action2 = SKAction.colorizeWithColor(UIColor.whiteColor(), colorBlendFactor: 1.0, duration: 0.2)
        self.scene?.runAction(SKAction.sequence([action1, action2]))
        intersected = false
        gameStarted = false
        levelLabel.removeFromSuperview()
        currentScore = currentLevel
        self.loadView()
    }
    
    func won() {
        
        self.removeAllChildren()
        let action1 = SKAction.colorizeWithColor(UIColor.greenColor(), colorBlendFactor: 1.0, duration: 0.2)
        let action2 = SKAction.colorizeWithColor(UIColor.whiteColor(), colorBlendFactor: 1.0, duration: 0.2)
        self.scene?.runAction(SKAction.sequence([action1, action2]))
        intersected = false
        gameStarted = false
        levelLabel.removeFromSuperview()
        self.loadView()
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        if person.intersectsNode(dot) {
            intersected = true
        }
        else {
            if intersected == true {
                if person.intersectsNode(dot) == false {
                    died()
                }
            }
        }
        
    }
}







