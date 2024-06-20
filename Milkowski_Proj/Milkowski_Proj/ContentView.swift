//
//  ContentView.swift
//  Milkowski_Proj
//
//  Created by Bartlomiej Milkowski on 17/06/2024.
//

import SwiftUI


struct ContentView: View {
    
    let levels = ["Po prostu zabawa", "Wyzwanie", "Krew, pot i łzy", "Droga ku zagładzie"]
    
    @State var selectedLevel = 0
    
    // Positions
    @State private var playerPosition = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
    @State private var platforms = [
        CGPoint(x: 90, y: 100),
        CGPoint(x: 100, y: 200),
        CGPoint(x: 200, y: 300),
        CGPoint(x: 150, y: 400),
        CGPoint(x: 300, y: 500)
    ]
    @State private var velocity: CGFloat = 0.1
    @State private var isGameOver = false
    @State private var isGameStarted = true
    @State private var stepsCounter = 0
    @State private var lastPlatformIndex: Int? = nil
    
    // Parameters
    let gravity: CGFloat = 0.3
    let jumpHeight: CGFloat = -8
    let playerSize: CGFloat = 25
    let platformHeight: CGFloat = 15
    let platformWidth: CGFloat = 80
    let platformMoveDistance: CGFloat = 40
    let platformSpacing: CGFloat = 150
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            if isGameStarted {
                VStack {
                    Text("Sky Jump")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    Button(action: gameView) {
                        Text("Start")
                            .font(.title)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                HStack {
                    Picker(selection: $selectedLevel, label: Text("Pick Level")) {
                        ForEach(0..<4) { index in
                            Text(self.levels[index])
                            
                        }
                    }
                }
            }
            
            // Game Over View
            else if isGameOver {
                VStack {
                    Text("GameOver")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    Button(action: restartGame) {
                        Text("Restart")
                            .font(.title)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    Button(action: startGameMenu) {
                        Text("Wyjdź")
                            .font(.title)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            // Game View
            } else {
                
            
                
                // Platforms
                ForEach(0..<platforms.count, id: \.self) { index in
                    Rectangle()
                        .frame(width: platformWidth, height: platformHeight)
                        .position(platforms[index])
                        .foregroundColor(.green)
                }
                // Player
                Circle()
                    .fill(Color.blue)
                    .frame(width: playerSize, height: playerSize)
                    .position(playerPosition)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                playerPosition.x = value.location.x
                            }
                    )
                
                // Steps Counter
                VStack {
                    HStack {
                        Text("Score: \(stepsCounter)")
                            .font(.title)
                            .foregroundColor(.black)
                            .padding()
                            .background(Color.white.opacity(0.7))
                            .cornerRadius(10)
                            .shadow(radius: 10)
                            .blur(radius: 0.5)
                            //.Spacer()
                    }
                    Spacer()
                }
                .padding()
            }
        }
        .onAppear {
            startGame()
        }
    }
    
    // Start Game Setup
    func startGame() {
        Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { timer in
            updatePlayer()
            checkCollisions()
            
            if isGameOver {
                timer.invalidate()
            }
        }
    }
    
    // Update Player Position
    func updatePlayer() {
        velocity += gravity
        playerPosition.y += velocity
        
        if playerPosition.y > UIScreen.main.bounds.height - playerSize / 2 {
            isGameOver = true
        }
    }
    
    // Checking collisions with platforms
    func checkCollisions() {
        for index in platforms.indices {
            guard index < platforms.count else { continue } // Ensure the index is valid
            let platformFrame = CGRect(
                x: platforms[index].x - platformWidth / 2,
                y: platforms[index].y - platformHeight / 2,
                width: platformWidth,
                height: platformHeight
            )
            let playerFrame = CGRect(
                x: playerPosition.x - playerSize / 2,
                y: playerPosition.y - playerSize / 2,
                width: playerSize,
                height: playerSize
            )
            
            if playerFrame.intersects(platformFrame) && velocity > 0 {
                if lastPlatformIndex != index {
                    stepsCounter += 1 // Increment steps counter only if it's a different platform
                    lastPlatformIndex = index
                }
                
                velocity = jumpHeight
                playerPosition.y = platforms[index].y - platformHeight / 2 - playerSize / 2
                movePlatformsDown()
                addNewPlatform()
            }
        }
    }
    
    func movePlatformsDown() {
        for index in platforms.indices {
            platforms[index].y += platformMoveDistance
        }
        platforms.removeAll { $0.y > UIScreen.main.bounds.height }
    }
    
    func addNewPlatform() {
        let highestPlatformY = platforms.map { $0.y }.min() ?? UIScreen.main.bounds.height
        if highestPlatformY > 250 {
            let newPlatformX = CGFloat.random(in: platformWidth / 2...(UIScreen.main.bounds.width - platformWidth / 2))
            let newPlatformY = (highestPlatformY - platformSpacing) + 20
            platforms.append(CGPoint(x: newPlatformX, y: newPlatformY))
        }
    }
    
    // Resets Game
    func restartGame() {
        playerPosition = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
        platforms = [
            CGPoint(x: 90, y: 100),
            CGPoint(x: 100, y: 200),
            CGPoint(x: 200, y: 300),
            CGPoint(x: 150, y: 400),
            CGPoint(x: 300, y: 500)
        ]
        velocity = 0
        isGameOver = false
        stepsCounter = 0 // Reset steps counter
        lastPlatformIndex = nil // Reset last platform index
        startGame()
    }
    
    func gameView() {
        isGameStarted = false
        //restartGame()
    }
    
    func startGameMenu() {
        isGameStarted = true
        isGameOver = false
    }
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
