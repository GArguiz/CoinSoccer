//
//  RedPlayers.swift
//  AirHockey
//
//  Created by Gilberto Arguiz on 9/5/23.
//  Copyright © 2023 Miguel Angel Lozano Ortega. All rights reserved.
//

import Foundation

class RedPlayers {
    var players: [Player] = [
    ]
    
    init(frame: CGRect) {
        self.players = [
            Player(position: CGPoint(x: 0, y: frame.maxY * 0.75)),
            Player(position: CGPoint(x: frame.minX * 0.75, y: frame.maxY * 0.65)),
            Player(position: CGPoint(x: 0, y: frame.maxY * 0.5)),
            Player(position: CGPoint(x: frame.maxX * 0.75, y: frame.maxY * 0.65)),
            Player(position: CGPoint(x: frame.minX * 0.5, y: frame.maxY * 0.25)),
            Player(position: CGPoint(x: frame.maxX * 0.5, y: frame.maxY * 0.25)),
            Player(position: CGPoint(x: frame.minX * 0.8, y: frame.minY * 0.1)),
            Player(position: CGPoint(x: frame.maxX * 0.8, y: frame.minY * 0.1)),
            Player(position: CGPoint(x: 0, y: frame.minY * 0.3)),
         //   Player(position: CGPoint(x: frame.minX * 0.5, y: frame.minY * 0.4)),
         //   Player(position: CGPoint(x: frame.maxX * 0.5, y: frame.minY * 0.4)),
        ]
    }
    
}

