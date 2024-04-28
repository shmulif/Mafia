//
//  DetectiveView.swift
//  mafia
//
//  Created by Shmuli Feld on 4/14/24.
//

import SwiftUI
@MainActor
final class DoctorViewModel: ObservableObject {
    
    @Published var players: [Player] = []
   
    
}

struct DoctorView: View {
    
    @Binding var userId: String
    @Binding var gameId: String
    @StateObject private var vm = DoctorViewModel()
    @State var selected: String = ""
    @State var isAlive: Bool

    @State var showNextScreen: Bool = false
    
    var body: some View {
        VStack {
            Spacer(minLength: 30)
            Text("Night")
                .font(.largeTitle)
                .bold()
            Text("Your Role: Doctor")
                .font(.title2)
            Spacer(minLength: 30)
            Rectangle()
                .fill(.black)
                .frame(width: .infinity, height: 3)
            Spacer(minLength: 15)
            Text("Select a player to save:")
            List {
                ForEach(vm.players, id: \.self) { player in
                    if selected == player.user_id {
                        DoctorListRowView(gameId: gameId, userId: userId, player: player, pressed: .constant(true), selected: $selected, showNextScreen: $showNextScreen)
                    } else {
                        DoctorListRowView(gameId: gameId, userId: userId, player: player, pressed: .constant(false), selected: $selected, showNextScreen: $showNextScreen)
                    }
                    
                }
            }
        }
        .onAppear {
            Task {
                if !isAlive {
                    try await GameDatabaseManager.shared.setDoctorAsDone(gameId: gameId)
                    showNextScreen = true
                }
                vm.players = try await  GameDatabaseManager.shared.getLivingPlayers(gameId: gameId)
            }
        }
        .fullScreenCover(isPresented: $showNextScreen, content: {
            NavigationStack {
                WaitingForDayView(userId: $userId, gameId: $gameId)
            }
        })
    }
}

#Preview {
    DoctorView(userId: .constant("qImj506kDGSW8JhcLAkHJevtmKD3"), gameId: .constant("1234"), isAlive: true)
}
