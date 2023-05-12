//
//  GameScene.swift
//  AirHockey
//
//  Created by Miguel Angel Lozano Ortega on 02/08/2019.
//  Copyright © 2019 Miguel Angel Lozano Ortega. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - Referencias a nodos de la escena
    private var ball : SKSpriteNode?
    private var playerTouch : SKSpriteNode?
    private var blueScoreboard : SKLabelNode?
    private var redScoreboard : SKLabelNode?

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
        
        
        // DONE [B04] Obten las referencias a los nodos de la escena
        self.ball = self.childNode(withName: "ball") as? SKSpriteNode
        self.ball?.physicsBody!.contactTestBitMask = ballCategoryMask
        self.redScoreboard = self.childNode(withName: "red_score") as? SKLabelNode
        self.blueScoreboard = self.childNode(withName: "blue_score") as? SKLabelNode
        
        self.playerTouch = self.childNode(withName: "player_touch") as? SKSpriteNode
        self.playerTouch?.physicsBody?.contactTestBitMask = ballCategoryMask
        // TODO [D05] Establece esta clase como el contact delegate del mundo fisico de la escena
        physicsWorld.contactDelegate = self
        self.createSceneLimits()
        self.setPlayers()
        self.updateScore()
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
        // DONE [D03] Reproducir sobre la escena la acción `actionSoundGoal`
        run(actionSoundGoal)
        updateScore()
        
        let actionSeq = SKAction.repeat(SKAction.sequence([SKAction.scale(to: CGFloat(1.2), duration: 0.1), SKAction.scale(to: CGFloat(1.0), duration: 0.01)]), count: 3)
        
        marcador.run(actionSeq)
         resetPuck(pos: spawnPos)
        
        if( score == maxScore ){
             let labelNode = colorTexto == self.redColor ? scene?.childNode(withName: "red_wins") : scene?.childNode(withName: "blue_wins")
            labelNode?.isHidden = false
            
            //      - Eliminamos el disco de la escena (eliminandolo de su nodo padre) y lo ponemos a nil
            self.ball?.removeFromParent()
            self.ball = nil
            
             //      - Ejecutamos una accion que repita 3 veces: escalar a 1.2 durante 0.5s, escalar a 1.0 durante 0.5s, y tras las 3 repeticiones, que ejecute goToTitle().
            marcador.run(SKAction.repeat(SKAction.sequence([SKAction.scale(to: 1.2, duration: 0.5), SKAction.scale(to: 1.0, duration: 0.5) ]), count: 3)){
                self.goToTitle()
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
        let coordinates = t.location(in: scene!)
        
        self.playerTouch?.physicsBody = SKPhysicsBody(circleOfRadius: 20)
        self.playerTouch?.physicsBody?.categoryBitMask = playerCategoryMask
        self.playerTouch?.physicsBody?.collisionBitMask = 3
        self.playerTouch?.position = coordinates
        self.activeTouches[t] = createDragNode(linkedTo: self.playerTouch!)

    }
    
    func touchMoved(withTouch t : UITouch) {
        // DONE [C06]
        //  - Obten las coordenadas de t en la escena
        let coordinates = t.location(in: scene!)
        //  - Comprueba si hay algun nodo vinculado a t en self.activeTouches
        if(self.activeTouches[t] != nil){
            //  - Si es asi, mueve el nodo a la posicion de t
            self.activeTouches[t]?.position = coordinates
        }
        
    }
    
    func touchUp(withTouch t : UITouch) {
        // DONE [C07]
        //  - Elimina la entrada t del diccionario self.activeTouches.
       
        // DONE [C10] Comprueba si hay algun nodo vinculado a t, y en tal caso eliminalo de la escena
        let node = activeTouches[t]
        if(node != nil){
            node?.removeFromParent()
        }
        playerTouch?.physicsBody?.categoryBitMask = 1000
    }
    
    
    func createDragNode(linkedTo paddle: SKNode) -> SKNode {
        // DONE [C08]
        //  - Crea un nodo de tipo forma circular con radio `20`, situado en la posición del nodo paddle, añadelo a la escena.
        let circularNode = SKShapeNode(circleOfRadius: 20)
        circularNode.position = paddle.position
        scene?.addChild(circularNode)
        //  - Asocia a dicho nodo un cuerpo físico estático, y desactiva su propiedad `isUserInteractionEnabled`
        circularNode.physicsBody = .init(circleOfRadius: 20)
        circularNode.physicsBody?.isDynamic = false
        circularNode.isUserInteractionEnabled = false
        //  - Crea una conexión de tipo `SKPhysicsJointSpring` que conecte el nodo creado con paddle, con frequency 100.0 y damping 10.0.

        let joint = SKPhysicsJointSpring.joint(withBodyA: paddle.physicsBody!, bodyB: circularNode.physicsBody!, anchorA: paddle.position, anchorB: circularNode.position)
        joint.damping = 10.0
        joint.frequency = 100.0
        
        //  - Agrega la conexión al `physicsWorld` de la escena.
        scene?.physicsWorld.add(joint)
        //  - Devuelve el nodo que hemos creado
  
        return circularNode
    }
    
    
    // MARK: - Metodos de SKPhysicsContactDelegate
    
    // TODO [D06] Define el método didBegin(:). En caso de que alguno de los cuerpos que intervienen en el contacto sea el disco (' puck'), reproduce el audio `actionSoundHit`
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.name == "ball" || contact.bodyB.node?.name == "ball" {
            run(actionSoundHit)
        }
    }

}
