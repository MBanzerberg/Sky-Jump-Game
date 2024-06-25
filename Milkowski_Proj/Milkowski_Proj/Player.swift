//
//  Player.swift
//  Milkowski_Proj
//
//  Created by Bartlomiej Milkowski on 17/06/2024.
//

import SwiftUI

struct Player: View {
    let playerSize: CGFloat
    let playerName: String
    
    @Binding var playerPosition: CGPoint
    
    var body: some View {
        Image(playerName)
            .resizable()
            .frame(width: playerSize, height: playerSize)
            .position(playerPosition)
    }
}
