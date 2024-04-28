//
//  WaitingForPlayersView.swift
//  mafia
//
//  Created by Shmuli Feld on 3/10/24.
//

import SwiftUI

@MainActor
final class PlayerCheckingViewModel: ObservableObject {
    
    @Published var players: [Player] = []
    

    func addListenerForPlayers(gameId: String) {
        GameDatabaseManager.shared.addListenerForPlayers(gameId: gameId) { [weak self] players in
            self?.players = players
        }
    }
    
}

struct WaitingForPlayersView: View {
    
    
    @Binding var gameId: String
    
    @StateObject private var viewModel = PlayerCheckingViewModel()
    @State private var didAppear: Bool = false
    @State var showNextView: Bool = false
    @State var isHost: Bool = false
    @State var userId: String = ""
    
    var body: some View {
        VStack{
                Text("Current Players")
                .font(.largeTitle)
                .bold()
                .frame(height: 150)
                .padding(5)
            Button(action: {
                Task {
                    do {
                        try await viewModel.players = GameDatabaseManager.shared.getAllPlayers(gameId: gameId)
                    } catch {
                        print(error)
                    }
                }
            }, label: {
                Text("Reload players")
            }
            )
            .padding(20)
            List {
                ForEach(viewModel.players, id: \.self) { player in
                    PlayerListRowView(name: (player.name))
                }
            }
            if viewModel.players.count == 6 {
                
                if isHost {
                    Button(action: {
                        if viewModel.players.count == 6 {

                            Task{
                                do {
                                    //asign roles
                                    viewModel.players = LocalGamePlayManager.shared.assignRoles(players: viewModel.players)
                                    //update database
                                    try await GameDatabaseManager.shared.updateAllPlayerRoles(gameId: gameId, players: viewModel.players)
                                    //add mafia members
                                    await LocalGamePlayManager.shared.addMafiMembers(gameId: gameId, players: viewModel.players)
                                    //set mafia host
                                    
                                    showNextView.toggle()
                                } catch {
                                    print(error)
                                }
                            }
                        
                            
                        } else {
                            print("error: must have 6 players")
                        }
                    }, label: {
                        Text("Start Game")
                            .foregroundColor(.black)
                            .font(.largeTitle)
                            .padding(20)
                        
                    })
                } else {
                    Text("Waiting for host to begin game")
                        .foregroundColor(.black)
                        .font(.title3)
                        .padding(20)
                }
                
            } else if viewModel.players.count < 6  {
                
                Text("Waiting for players \n (six required)")
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .font(.title3)
                    .padding(20)
                
            } else { //if 6 < viewModel.players.count
                Text("Too many players \n (six required)")
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .font(.title3)
                    .padding(20)
            }
            
        }
        .onAppear {
                if !didAppear {
                    viewModel.addListenerForPlayers(gameId: gameId)
                    didAppear = true
            }
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            if authUser?.uid != nil {
                userId = authUser!.uid
            } else {
                print("error: no user id found")
            }
            
            Task {
                let hostId = try? await GameDatabaseManager.shared.getHostId(gameId: gameId)
                isHost = userId == hostId ?? "<no host id>"
            }
            
        }
        .onDisappear {
            GameDatabaseManager.shared.removeListenerForPlayers()
        }
        .fullScreenCover(isPresented: $showNextView, content:{
            NightRootView(userId: $userId, gameId: $gameId)
        })
    }
}

#Preview {
    WaitingForPlayersView(gameId: .constant("boom"))
}
