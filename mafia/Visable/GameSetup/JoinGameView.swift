//
//  JoinGameView.swift
//  mafia
//
//  Created by Shmuli Feld on 3/9/24.
//

import SwiftUI
import FirebaseAuth

final class GameIdModel: ObservableObject {
    
    @Published var gameId = ""
    
    func getAuthenticatedUser() throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        
        return AuthDataResultModel(user: user)
    }

}

struct JoinGameView: View {
    
    @StateObject private var viewModel = GameIdModel()
    @State var showNextView: Bool = false
    
    var body: some View {

        VStack(){
            Text("Join Game")
                .font(.largeTitle)
                .bold()
                .frame(height: 100)
                .padding(20)
            TextField("Enter game ID..", text: $viewModel.gameId )
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
            Button(action: {
                Task {
                    do {
                        //add current user to game
                        let currentUser = try viewModel.getAuthenticatedUser()
                        let userId = currentUser.uid
                        try await UserDatabaseManager.shared.linkUserToGame(auth: currentUser, gameId: viewModel.gameId)
                        let player = try await UserDatabaseManager.shared.getUser(userId: userId)
                        try await GameDatabaseManager.shared.addPlayer(user: player)
                        showNextView.toggle()
                    } catch {
                        print(error)
                    }
                }
            }, label: {
                Text("Join")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                    .background(Color.blue)
                    .cornerRadius(10)
            })
            .fullScreenCover(isPresented: $showNextView, content:{
                WaitingForPlayersView(gameId: $viewModel.gameId)
            })
            Spacer()
            .padding()
        }
        .padding()
    }
}

#Preview {
    JoinGameView()
}
