//
//  Platform.swift
//  Milkowski_Proj
//
//  Created by Bartlomiej Milkowski on 17/06/2024.
//

import SwiftUI

struct Platform: View {
    let platformWidth: CGFloat
    let platformHeight: CGFloat
    let position: CGPoint
    
    var body: some View {
        Rectangle()
            .frame(width: platformWidth, height: platformHeight)
            .position(position)
            .foregroundColor(.black)
    }
}

