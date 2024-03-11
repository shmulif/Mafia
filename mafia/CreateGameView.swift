//
//  CreateGameView.swift
//  mafia
//
//  Created by Shmuli Feld on 3/10/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

final class FindUserViewModel: ObservableObject {
    
    func getAuthenticatedUser() throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        
        return AuthDataResultModel(user: user)
    }
}

struct CreateGameView: View {
    
    @StateObject private var viewModel = FindUserViewModel()
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
                        try await GameManager.shared.createNewGame(gameId: "1111")
                        //add current user to game
                        let currentUser = try viewModel.getAuthenticatedUser()
                        try await UserManager.shared.linkUserToGame(auth: currentUser, gameId: "1111")
                        let userId = currentUser.uid
                        let player = try await UserManager.shared.getUser(userId: userId)
                        try await GameManager.shared.addPlayer(user: player)
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
