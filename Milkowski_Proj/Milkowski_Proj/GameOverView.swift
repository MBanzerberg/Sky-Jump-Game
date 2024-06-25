//
//  GameOverView.swift
//  Milkowski_Proj
//
//  Created by Bartlomiej Milkowski on 17/06/2024.
//

import SwiftUI

struct GameOverView: View {
    let lastScore: Int
    let bestScore: Int
    let restartGame: () -> Void
    let startGameMenu: () -> Void

    var body: some View {
        ZStack {
            Image("night-sky")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            VStack {
            
                VStack {
                    Text("GameOver")
                        .font(.system(size:40).bold())
                        .foregroundColor(.white)
                        .shadow(radius: 0.2)
                }

                HStack {
                    Button(action: restartGame) {
                        Text("Restart")
                            .font(.title)
                            .padding(10)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    Button(action: startGameMenu) {
                        Text("Wyjdź")
                            .font(.title)
                            .padding(10)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }

                VStack {
                    Text("Last Score: \(lastScore)")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()

                    Text("Best Score: \(bestScore)")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()
                }
            }
        }
    }
}
