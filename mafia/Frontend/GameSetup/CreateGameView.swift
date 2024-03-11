//
//  CreateGameView.swift
//  mafia
//
//  Created by Shmuli Feld on 3/10/24.
//

import SwiftUI
import FirebaseFirestore


struct CreateGameView: View {
    
    @State var showNextView: Bool = false
    
    var body: some View {
        VStack {
            Text("Game ID:")
                .font(.largeTitle)
                .bold()
                .frame(height: 150)
            Text("1111")
                .font(.largeTitle)
                .bold()
                .frame(height: 150)
                .padding(20)
            Button(action: {
                Task{
                    do {
                        //create game
                        try await GameDatabaseManager.shared.createNewGame(gameId: "1111")
                        //get current userId
                        let currentUser = try AuthenticationManager.shared.getAuthenticatedUser()
                        let userId = currentUser.uid
                        //add user to game
                        try await UserDatabaseManager.shared.linkUserToGame(auth: currentUser, gameId: "1111")
                        let player = try await UserDatabaseManager.shared.getUser(userId: userId)
                        try await GameDatabaseManager.shared.addPlayer(user: player)
                        showNextView.toggle()
                    } catch {
                        print(error)
                    }
                }
            }, label: {
                Text("Start Game")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(height: 55)
                    .frame(width: 150 )
                    .background(Color.gray)
                    .cornerRadius(10)
            })
            .fullScreenCover(isPresented: $showNextView, content:{
                WaitingForPlayersView(gameId: "1111")
            })
        
        }
    }
}

#Preview {
    CreateGameView()
}
