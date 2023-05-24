//
//  Player.swift
//  AirHockey
//
//  Created by Gilberto Arguiz on 9/5/23.
//  Copyright © 2023 Miguel Angel Lozano Ortega. All rights reserved.
//

import SpriteKit
import GameplayKit

struct Player {
    var position: CGPoint
    func distance(to: CGPoint)-> Double{
        return sqrt(pow(position.x - to.x , 2) + pow(position.y - to.y, 2))
    }
}
