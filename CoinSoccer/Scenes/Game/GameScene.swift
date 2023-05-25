//
//  GameScene.swift
//  AirHockey
//
//  Created by Miguel Angel Lozano Ortega on 02/08/2019.
//  Copyright © 2019 Miguel Angel Lozano Ortega. All rights reserved.
//

import SpriteKit
import GameplayKit
import GameKit

enum GameState {
    case initial
    case redTurn
    case blueTurn
    case ballMoving
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private let preferences = UserDefaults()
    private let IS_FIRST_GOAL_ACCOMPLISHED = "IS_FIRST_GOAL_ACCOMPLISHED"
    private var isFirstGoalAccomplished = false

    // MARK: - Estado del juego
    private var gameState: GameState = .initial
   
    // MARK: - Referencias a nodos de la escena
    private var ball : SKSpriteNode?
    private var playerTouch : SKSpriteNode?
    private var blueScoreboard : SKLabelNode?
    private var redScoreboard : SKLabelNode?

    private var redWins: SKLabelNode?
    private var blueWins: SKLabelNode?
    
    // MARK: Marcadores de los jugadores
    private var blueScore : Int = 0
    private var redScore : Int = 0
    private let maxScore = 5

    // MARK: Colores de los jugadores
    private let redColor = #colorLiteral(red: 1, green: 0.2156862766, blue: 0.3725490272, alpha: 1)
    private let blueColor = #colorLiteral(red: 0.3727632761, green: 0.3591359258, blue: 0.8980184197, alpha: 1)
    
    // MARK: Categorias de los objetos fisicos
    private let playerCategoryMask : UInt32 = 0b0001
    private let ballCategoryMask : UInt32 = 0b0010
    private let limitsCategoryMask : UInt32 = 0b0100
    private let playersCategoryMask: UInt32 = 0b1000

    // MARK: Efectos de sonido
    // DONE [D02] Crear acciones para reproducir "goal.wav" y "hit.wav"
    private let actionSoundGoal = SKAction.playSoundFileNamed("goal.wav", waitForCompletion: true)
    private let actionSoundHit = SKAction.playSoundFileNamed("hit.wav", waitForCompletion: true)

    // MARK: Mapa de asociacion de touches con palas
    private var activeTouches : [UITouch : SKNode] = [:]
    
    // MARK: - Inicializacion de la escena
    
    override func didMove(to view: SKView) {
        
        isFirstGoalAccomplished = preferences.bool(forKey: "IS_FIRST_GOAL_ACCOMPLISHED")
        logInGameCenter()
        
        // DONE [B04] Obten las referencias a los nodos de la escena
        self.ball = self.childNode(withName: "ball") as? SKSpriteNode
        self.ball?.physicsBody!.contactTestBitMask = ballCategoryMask
        self.redScoreboard = self.childNode(withName: "red_score") as? SKLabelNode
        self.blueScoreboard = self.childNode(withName: "blue_score") as? SKLabelNode
        self.blueWins = self.childNode(withName: "blue_wins") as? SKLabelNode
        self.redWins = self.childNode(withName: "red_wins") as? SKLabelNode
        
        self.playerTouch = self.childNode(withName: "player_touch") as? SKSpriteNode
        self.playerTouch?.physicsBody?.contactTestBitMask = ballCategoryMask
        // TODO [D05] Establece esta clase como el contact delegate del mundo fisico de la escena
        physicsWorld.contactDelegate = self
        self.createSceneLimits()
        self.setPlayers()
        self.updateScore()
        self.selectInitialPlayer()
    }
    
    func selectInitialPlayer() {
        let isRedTurn = Int.random(in: 1...2) == 1
        if isRedTurn {
            gameState = .redTurn
        } else {
            gameState = .blueTurn
        }
        showPlayerTurn()
    }
    
    func showPlayerTurn(){
        if gameState == .redTurn {
            redWins?.isHidden = false
            redWins?.text = "Red turn"
            redWins?.run(SKAction.sequence([SKAction.repeat(SKAction.sequence([SKAction.scale(to: CGFloat(0.8), duration: 0.2), SKAction.scale(to: 1, duration: 0.2)]), count: 3), SKAction.hide()]))
        } else {
            blueWins?.isHidden = false
            blueWins?.text = "Blue turn"
            blueWins?.run(SKAction.sequence([SKAction.repeat(SKAction.sequence([SKAction.scale(to: CGFloat(0.8), duration: 0.2), SKAction.scale(to: 1, duration: 0.2)]), count: 3), SKAction.hide()]))
        }
    }
    
    func createSceneLimits() {
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        let goalWidth = self.frame.width / 2

        let bottomRight = CGPoint(x: self.frame.maxX, y: self.frame.minY)
        let topRight = CGPoint(x: self.frame.maxX, y: self.frame.maxY)
        
        let bottomLeft = CGPoint(x: self.frame.minX, y: self.frame.minY)
        let topLeft = CGPoint(x: self.frame.minX, y: self.frame.maxY)
       
        let goalBottomRight = CGPoint(x: self.frame.origin.x + (self.frame.width + goalWidth)/2,
                                      y: self.frame.minY)
        
        let goalTopRight = CGPoint(x: self.frame.origin.x + (self.frame.width + goalWidth)/2,
                                   y: self.frame.maxY)
        
        let goalBottomLeft = CGPoint(x: self.frame.maxX - (self.frame.width + goalWidth)/2,
                                      y: self.frame.minY)
        let goalTopLeft = CGPoint(x: self.frame.maxX - (self.frame.width + goalWidth)/2,
                                   y: self.frame.maxY)


        let pathRight = CGMutablePath()
        pathRight.addLines(between: [goalTopRight, topRight,
                                     bottomRight, goalBottomRight])
        

        let pathLeft = CGMutablePath()
        pathLeft.addLines(between: [goalTopLeft, topLeft,
                                     bottomLeft, goalBottomLeft])


        let bodyRight = SKPhysicsBody(edgeChainFrom: pathRight)
        bodyRight.categoryBitMask = limitsCategoryMask

        let bodyLeft = SKPhysicsBody(edgeChainFrom: pathLeft)
        bodyRight.categoryBitMask = limitsCategoryMask
        
        let goalKeeperRed = SKShapeNode(rectOf: CGSize(width: goalWidth, height: goalWidth))
        goalKeeperRed.fillColor = redColor
        goalKeeperRed.position = CGPoint(x: (self.frame.origin.x + self.frame.maxX) / 2,
                                         y: self.frame.maxY)
        goalKeeperRed.physicsBody?.isDynamic = false
        
        scene?.addChild(goalKeeperRed)
        
        
        let goalKeeperBlue = SKShapeNode(rectOf: CGSize(width: goalWidth, height: goalWidth))
        goalKeeperBlue.fillColor = blueColor
        
        goalKeeperBlue.position = CGPoint(x: (self.frame.origin.x + self.frame.maxX) / 2, y: self.frame.minY)
        goalKeeperBlue.physicsBody?.isDynamic = false
        
        
        scene?.addChild(goalKeeperBlue)
        
        let midCamp = SKShapeNode(rect: CGRect(x: self.frame.origin.x, y: (self.frame.maxY + self.frame.minY) / 2, width: self.frame.width, height: 1))
        midCamp.strokeColor = .black
        midCamp.lineWidth = CGFloat(1)
        
        scene?.addChild(midCamp)
        
        let midCircunference = SKShapeNode(circleOfRadius: self.frame.maxX / 2)
        midCircunference.strokeColor = .black
        midCircunference.lineWidth = 1
        midCircunference.position = CGPoint(x: (self.frame.minX + self.frame.maxX) / 2, y: (self.frame.maxY + self.frame.minY) / 2)
        
        scene?.addChild(midCircunference)
        
        self.physicsBody = .init(bodies: [bodyRight, bodyLeft])
        self.physicsBody?.isDynamic = false
        
    }
    
    // MARK: - Set players
    
    func setPlayers() {
        let redPlayers = RedPlayers(frame: self.frame)
        let bluePlayers = BluePlayers(frame: self.frame)
        
        for index in 0...(redPlayers.players.count - 1) {
            let redSize = 38 * 0.6
            let blueSize = 26 * 0.6
            
            let redTexture = SKTexture(imageNamed: "red_player.png")
            let redPlayer = SKSpriteNode(texture: redTexture)
            redPlayer.name = "red_player_\(index)"
            redPlayer.position = redPlayers.players[index].position
            redPlayer.size = CGSize(width: redSize, height:redSize)
            redPlayer.physicsBody = SKPhysicsBody(texture: redTexture, size: CGSize(width: redSize, height: redSize))
            redPlayer.physicsBody?.affectedByGravity = false
            redPlayer.physicsBody?.isDynamic = false
            redPlayer.physicsBody?.categoryBitMask = playersCategoryMask
            scene?.addChild(redPlayer)
            
            let blueTexture = SKTexture(imageNamed: "blue_player.png")
            let bluePlayer = SKSpriteNode(texture: blueTexture)
            bluePlayer.name = "blue_player_\(index)"
            bluePlayer.position = bluePlayers.players[index].position
            bluePlayer.size = CGSize(width: blueSize, height: blueSize)
            bluePlayer.physicsBody = SKPhysicsBody(texture: blueTexture, size: CGSize(width: blueSize, height: blueSize))
            bluePlayer.physicsBody?.affectedByGravity = false
            bluePlayer.physicsBody?.isDynamic = false
            bluePlayer.physicsBody?.categoryBitMask = playersCategoryMask
            scene?.addChild(bluePlayer)
            
            
        }
        
       
    }

    // MARK: - Metodos del ciclo del juego
    
    override func update(_ currentTime: TimeInterval) {
       let spawnPos = CGPoint(x:(self.frame.minX + self.frame.maxX) / 2,
                               y:(self.frame.minY + self.frame.maxY) / 2)
      
        if let ball = ball {
            let isBallMoving = ball.physicsBody!.velocity.dy > 4 || ball.physicsBody!.velocity.dx > 4
            if Int(ball.position.y) > Int(scene!.frame.maxY) {
                self.blueScore += 1
                
                goal(score: self.blueScore,
                     marcador: self.blueScoreboard!,
                     textoWin: "BLUE WINS!",
                     colorTexto: self.blueColor,
                     spawnPos: spawnPos)
            }
            
            if Int(ball.position.y) < Int(scene!.frame.minY) {
                self.redScore += 1
                
                goal(score: self.redScore,
                     marcador: self.redScoreboard!,
                     textoWin: "RED WINS!",
                     colorTexto: self.redColor,
                     spawnPos: spawnPos)
            }
            
            if ball.position.x > frame.maxX || ball.position.x < frame.minX {
                resetPuck(pos: CGPoint(x: 0, y:0))
                showPlayerTurn()
            }
            
            
            if gameState != .ballMoving && isBallMoving {
                gameState = .ballMoving
            }
            
            if gameState == .ballMoving && !isBallMoving {
                self.selectNextPlayer()
            }
            
        }
       
    }
    
    func selectNextPlayer() {
        if let ball = ball {
            
            let ballPosition = ball.position
            let redPlayers = RedPlayers(frame: self.frame)
            let bluePlayers = BluePlayers(frame: self.frame)
            
            let closestRedPlayer: Double = redPlayers.closestPlayer(to: ballPosition)
            let closestBluePlayer: Double = bluePlayers.closestPlayer(to: ballPosition)
            
            if closestRedPlayer < closestBluePlayer {
                gameState = .redTurn
            } else {
                gameState = .blueTurn
            }
            
            showPlayerTurn()
        }
    }

    func updateScore() {
        self.redScoreboard?.text = String(redScore)
        self.blueScoreboard?.text = String(blueScore)
    }
    
    func resetPuck(pos : CGPoint) {
        ball?.physicsBody?.velocity = CGVector(dx: 0.0, dy: 0.0)
        ball?.physicsBody?.angularVelocity = 0
        ball?.position = pos
        
    }
    
    func goToTitle() {
        if let scene = SKScene(fileNamed: "MenuScene"),
           let view = self.view
        {
            scene.scaleMode = .aspectFill
            scene.resizeWithFixedHeightTo(viewportSize: view.frame.size)
            view.presentScene(scene, transition: .flipHorizontal(withDuration: 0.25))
        }
    }

    func goal(score: Int, marcador: SKLabelNode, textoWin : String, colorTexto : UIColor, spawnPos: CGPoint) {
        run(actionSoundGoal)
        updateScore()
        
        let actionSeq = SKAction.repeat(SKAction.sequence([SKAction.scale(to: CGFloat(1.2), duration: 0.1), SKAction.scale(to: CGFloat(1.0), duration: 0.01)]), count: 3)
        
        marcador.run(actionSeq)
        resetPuck(pos: spawnPos)
        
     
            self.showFirstGoalAccomplish()
        if( score == maxScore ){
             let labelNode = colorTexto == self.redColor ? self.redWins : self.blueWins
            labelNode?.isHidden = false
            
            self.ball?.removeFromParent()
            self.ball = nil
            
            marcador.run(SKAction.repeat(SKAction.sequence([SKAction.scale(to: 1.2, duration: 0.5), SKAction.scale(to: 1.0, duration: 0.5) ]), count: 3)){
                self.goToTitle()
            }
            
        } else {
            gameState = colorTexto == self.redColor ? .blueTurn : .redTurn
            showPlayerTurn()
        }
       
       
    }
    
    func logInGameCenter(){
        let player : GKLocalPlayer = GKLocalPlayer.local
        player.authenticateHandler = {(vc : UIViewController!, error : Error!) -> Void in
            if(vc != nil) {
                // No hay usuario de GameCenter, presenta interfaz de autenticación
                guard let controller = self.view?.window?.rootViewController as? GameViewController else {return}
                
                controller.present(vc, animated: true)

            } else if(player.isAuthenticated) {
               
            } else {
                // Error en la autenticación
            }
        }
    }
    func showFirstGoalAccomplish(){
        let player : GKLocalPlayer = GKLocalPlayer.local
        player.authenticateHandler = {(vc : UIViewController!, error : Error!) -> Void in
            if(vc != nil) {
                // No hay usuario de GameCenter, presenta interfaz de autenticación
            } else if(player.isAuthenticated) {
                let achievement = GKAchievement(identifier: "get_first_goal")
                achievement.percentComplete = 100
                achievement.showsCompletionBanner = true
                GKAchievement.report([achievement]) { (error) in
                    if error != nil {
                        print("\(error)")
                    } else {
                    }
                }
                 //
            } else {
                // Error en la autenticación
            }
        }
    }
    
    
    // MARK: - Eventos de la pantalla tactil
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(withTouch: t) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(withTouch: t) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(withTouch: t) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(withTouch: t) }
    }
    
    func touchDown(withTouch t : UITouch) {
        if gameState != .ballMoving {
            let coordinates = t.location(in: scene!)
            
            self.playerTouch?.physicsBody = SKPhysicsBody(circleOfRadius: 20)
            self.playerTouch?.physicsBody?.categoryBitMask = playerCategoryMask
            self.playerTouch?.physicsBody?.collisionBitMask = 3
            self.playerTouch?.position = coordinates
            self.activeTouches[t] = createDragNode(linkedTo: self.playerTouch!)
        }
        
    }
    
    func touchMoved(withTouch t : UITouch) {
        if gameState != .ballMoving {
            let coordinates = t.location(in: scene!)
            
            if(self.activeTouches[t] != nil){
                self.activeTouches[t]?.position = coordinates
            }
        }
    }
    
    func touchUp(withTouch t : UITouch) {
        let node = activeTouches[t]
        if(node != nil){
            node?.removeFromParent()
            activeTouches.removeValue(forKey: t)
        }
        playerTouch?.physicsBody?.categoryBitMask = 1000
    }
    
    
    func createDragNode(linkedTo paddle: SKNode) -> SKNode {
        let circularNode = SKShapeNode(circleOfRadius: 20)
        circularNode.position = paddle.position
        scene?.addChild(circularNode)

        circularNode.physicsBody = .init(circleOfRadius: 20)
        circularNode.physicsBody?.isDynamic = false
        circularNode.isUserInteractionEnabled = false

        let joint = SKPhysicsJointSpring.joint(withBodyA: paddle.physicsBody!, bodyB: circularNode.physicsBody!, anchorA: paddle.position, anchorB: circularNode.position)
        joint.damping = 10.0
        joint.frequency = 100.0
        
        scene?.physicsWorld.add(joint)
  
        return circularNode
    }
    
    
    // MARK: - Metodos de SKPhysicsContactDelegate
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.name == "ball" || contact.bodyB.node?.name == "ball" {
            run(actionSoundHit)
        }
    }

}
