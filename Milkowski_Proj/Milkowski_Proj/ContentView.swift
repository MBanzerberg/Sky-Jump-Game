//
//  ContentView.swift
//  Milkowski_Proj
//
//  Created by Bartlomiej Milkowski on 17/06/2024.
//

import SwiftUI

struct ContentView: View {

    
    //Variables to set a level
    let levels = ["Po prostu zabawa", "Wyzwanie", "Krew, pot i łzy", "Droga ku zagładzie"]
    @State var selectedLevel = 0
    
    
    //Variables to set a runner
    let players = ["Football", "Spiderman", "Ninja", "Lego Man"]
    @State var selectedPlayer = 0
    @State var selectedPlayerString: String = "Football"

    
    // Start positions of player and platforms
    @State private var playerPosition = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
    @State private var platforms = [
        CGPoint(x: 90, y: 100),
        CGPoint(x: 100, y: 250),
        CGPoint(x: 200, y: 400),
        CGPoint(x: 150, y: 550),
        CGPoint(x: 100, y: 700),
        CGPoint(x: 200, y: 850),
        CGPoint(x: 250, y: 700),
        CGPoint(x: 300, y: 800),
        CGPoint(x: 100, y: 900),
        CGPoint(x: 200, y: 1000)
    ]
    
    //Game View States
    @State private var isGameOver = false
    @State private var isGameStarted = true
    
    
    //Game parameters
    @State private var velocity: CGFloat = 0
    @State private var lastScore = 0
    @State private var bestScore = 0
    @State private var lastPlatformIndex: Int? = nil
    @State private var timer: Timer?
    @State private var gravity: CGFloat = 0.3
    @State private var jumpHeight: CGFloat = -8
    @State private var platformWidth: CGFloat = 80
    
    let playerSize: CGFloat = 35
    let platformHeight: CGFloat = 15
    let platformMoveDistance: CGFloat = 40
    let platformSpacing: CGFloat = 150
    

    var body: some View {
        
        ZStack {
            
            //-----Start Game View------
            if isGameStarted {
                //Background
                Image("nature-bg")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text("Sky Jump")
                        .font(.system(size:40).bold())
                        .foregroundColor(.black)
                        .shadow(radius: 0.2)
                    
                    //Game Pickers
                    HStack {
                        Text("Poziom Trudności: ")
                            .font(.system(size:20).bold())
                            .foregroundColor(.black)
                            .shadow(radius: 0.2)
                        
                        Picker(selection: $selectedLevel, label: Text("Pick Level")) {
                            ForEach(0..<levels.count, id: \.self) { index in
                                Text(self.levels[index])
                            }
                        }
                        .foregroundColor(.white)
                        .onChange(of: selectedLevel) { _ in
                            adjustDifficulty()
                        }
                    }
                    
                    HStack {
                        Text("Wybierz Avatara: ")
                            .font(.system(size:20).bold())
                            .foregroundColor(.black)
                            .shadow(radius: 0.2)
                        
                        Picker(selection: $selectedPlayer, label: Text("Pick Player")) {
                            ForEach(0..<players.count, id: \.self) { index in
                                Text(self.players[index])
                            }
                        }
                        .foregroundColor(.white)
                        .onChange(of: selectedPlayer) { _ in
                            choosePlayer()
                        }
                    }
                    
                    VStack {
                        Button(action: gameView) {
                            Text("Start")
                                .font(.title)
                                .padding(10)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }
                
                
            // -----Game Over View------
            } else if isGameOver {
                GameOverView(lastScore: lastScore, bestScore: bestScore, restartGame: restartGame, startGameMenu: startGameMenu)
                

            
            // -----Game View------
            } else {
                
                //Background Image
                Image("clouds-at-sky")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                
                // Platforms Display
                ForEach(0..<platforms.count, id: \.self) { index in
                    Platform(platformWidth: platformWidth, platformHeight: platformHeight, position: platforms[index])
                }
                
                //Player Display
                Player(playerSize: playerSize, playerName: selectedPlayerString, playerPosition: $playerPosition)

                VStack {
                    HStack {
                        Text("Score: \(lastScore)")
                            .font(.title)
                            .foregroundColor(.black)
                            .padding()
                            .background(Color.white.opacity(0.7))
                            .cornerRadius(10)
                            .shadow(radius: 10)
                            .blur(radius: 0.5)
                    }
                    Spacer()
                }
                .padding()
            }
        }
        //Player Controller
        .gesture(
            DragGesture()
                .onChanged { value in
                    playerPosition.x = value.location.x
                }
        )
        .onAppear {
            startGame()
        }
    }

    
    //Function to choose Avatar of Player
    func choosePlayer() {
        switch selectedPlayer {
        case 0:
            selectedPlayerString = "Football"
        case 1:
            selectedPlayerString = "spiderman"
        case 2:
            selectedPlayerString = "ninja"
        case 3:
            selectedPlayerString = "player"
        default:
            selectedPlayerString = "Football"
        }
    }
    
    //Function to choose dificulty level
    func adjustDifficulty() {
        switch selectedLevel {
        case 0:
            gravity = 0.3
            jumpHeight = -8
            platformWidth = 80
        case 1:
            gravity = 0.4
            jumpHeight = -9
            platformWidth = 70
        case 2:
            gravity = 0.6
            jumpHeight = -11
            platformWidth = 60
        case 3:
            gravity = 0.8
            jumpHeight = -12
            platformWidth = 40
        default:
            gravity = 0.3
            jumpHeight = -8
            platformWidth = 80
        }
    }

    
    //Start Game Setup
    func startGame() {
        adjustDifficulty() 
        choosePlayer()
        velocity = 0
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { timer in
            updatePlayer()
            checkCollisions()

            if isGameOver {
                timer.invalidate()
            }
        }
    }

    
    //Updates Player Position
    func updatePlayer() {
        velocity += gravity
        playerPosition.y += velocity

        if playerPosition.y > UIScreen.main.bounds.height - playerSize / 2 {
            if bestScore < lastScore {
                bestScore = lastScore
            }
            isGameOver = true
        }

        if playerPosition.y < playerSize {
            moveDownAllElements()
        }
    }
    

    //Checking collisions with platforms
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
                    lastScore += 1 // Increment steps counter only if it's a different platform
                    lastPlatformIndex = index
                }
                velocity = jumpHeight
                playerPosition.y = platforms[index].y - platformHeight / 2 - playerSize / 2
                movePlatformsDown()
                addNewPlatform()
            }
        }
    }

    
    //Function that moves all elements if player is too close to upper screen border
    func moveDownAllElements() {
        let moveDistance = UIScreen.main.bounds.height / 2

        withAnimation(.easeInOut(duration: 0.8)) {
            playerPosition.y += moveDistance

            for index in platforms.indices {
                platforms[index].y += moveDistance
            }
        }
    }
    
    
    //Function that moves platforms one step down each player bump
    func movePlatformsDown() {
        withAnimation(.easeInOut(duration: 0.3)) {
            for index in platforms.indices {
                platforms[index].y += platformMoveDistance
            }
        }

        platforms.removeAll { $0.y + 30 > UIScreen.main.bounds.height }
    }
    
    
    //Function that generates new platforms
    func addNewPlatform() {
        let highestPlatformY = platforms.map { $0.y }.min() ?? UIScreen.main.bounds.height
        let newPlatformX = CGFloat.random(in: platformWidth / 2...(UIScreen.main.bounds.width - platformWidth / 2))
        let newPlatformY = (highestPlatformY - platformSpacing) + 30
        platforms.append(CGPoint(x: newPlatformX, y: newPlatformY))
    }

    
    // Resets Games Settings
    func restartGame() {
        playerPosition = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
        platforms = [
            CGPoint(x: 90, y: 100),
            CGPoint(x: 100, y: 250),
            CGPoint(x: 200, y: 400),
            CGPoint(x: 150, y: 550),
            CGPoint(x: 100, y: 700),
            CGPoint(x: 200, y: 850),
            CGPoint(x: 250, y: 700),
            CGPoint(x: 300, y: 800),
            CGPoint(x: 100, y: 900),
            CGPoint(x: 200, y: 1000)

        ]
        velocity = 0 // Reset velocity here too
        isGameOver = false
        lastScore = 0
        lastPlatformIndex = nil
        startGame()
    }
    
    
    //Starts a game
    func gameView() {
        isGameStarted = false
        bestScore = 0
        restartGame()
    }

    
    //Returns to start menu
    func startGameMenu() {
        isGameStarted = true
        isGameOver = false
        startGame()
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

