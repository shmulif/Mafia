//
//  WaitingForPlayersView.swift
//  mafia
//
//  Created by Shmuli Feld on 3/10/24.
//

import SwiftUI

struct WaitingForPlayersView: View {
    
    @State var gameId: String
    @State var players: [Player] = []
    
//    List {
//        ForEach(players, id: \.self) { player<#_#> in
//            PlayerListRowView(title: player.name)
//        }
//    }
    
    
    var body: some View {
        VStack{
                Text("Current Players")
                .font(.largeTitle)
                .bold()
                .frame(height: 150)
                .padding(20)
                Button {
                    Task{
                        do {
                            players = try await GameManager.shared.getAllPlayers(gameId: gameId)
                        } catch {
                            print(error)
                        }
                    }
                } label: {
                    Text("refresh")
                        .font(.headline)
                        .frame(height: 55)
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                        .cornerRadius(10)
                        .padding()
                }
            List {
                ForEach(players, id: \.self) { player in
                    PlayerListRowView(name: player.name)
                }
            }
        }
        .onAppear {
            
        }
    }
}

#Preview {
    WaitingForPlayersView(gameId: "1111")
}
