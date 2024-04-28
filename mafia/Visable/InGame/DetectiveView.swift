//
//  DetectiveView.swift
//  mafia
//
//  Created by Shmuli Feld on 4/14/24.
//

import SwiftUI
@MainActor
final class DetectiveViewModel: ObservableObject {
    
    @Published var players: [Player] = []
   
    
}

struct DetectiveView: View {
    
    @Binding var userId: String
    @Binding var gameId: String
    @State var isAlive: Bool

    @StateObject private var vm = DetectiveViewModel()
    
    @State var showNextView: Bool = false
    @State var done: Bool = false
    @State var selected: String = ""
    @State var role: String = ""
    @State var isPresented: Bool = false
    @State var showNextScreen: Bool = false
    
    var body: some View {
        VStack {
            Spacer(minLength: 30)
            Text("Night")
                .font(.largeTitle)
                .bold()
            Text("Your Role: Detective")
                .font(.title2)
            Spacer(minLength: 30)
            Rectangle()
                .fill(.black)
                .frame(width: .infinity, height: 3)
            Spacer(minLength: 15)
            Text("Select the player who's role you want to see:")
            List {
                ForEach(vm.players, id: \.self) { player in
                    if selected == player.user_id {
                        DetectiveListRowView(gameId: gameId, player: player, pressed: .constant(true), selected: $selected, role: $role, done: $done)
                            .popover(isPresented: .constant(true), content: {
                                Text(role)
                                    .presentationCompactAdaptation(.popover)
                            })
                    } else {
                        DetectiveListRowView(gameId: gameId, player: player, pressed: .constant(false), selected: $selected, role: $role, done: $done)
                    }
                    
                }
            }
            if done {
                Button(action: {
                    Task {
                        try? await GameDatabaseManager.shared.setDetectiveAsDone(gameId: gameId)
                    }
                    showNextView = true
                    
                }, label: {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(height: 55)
                        .frame(width: 150 )
                        .background(Color.gray)
                        .cornerRadius(10)
                })
            }
            
        }
        .onAppear {
            Task {
                if !isAlive {
                    try await GameDatabaseManager.shared.setDetectiveAsDone(gameId: gameId)
                    showNextScreen = true
                }
                vm.players = try await  GameDatabaseManager.shared.getLivingPlayers(gameId: gameId)
            }
        }
        .fullScreenCover(isPresented: $showNextView, content:{
            WaitingForDayView(userId: $userId, gameId: $gameId)
        })
    }
}

#Preview {
    DetectiveView(userId: .constant("qImj506kDGSW8JhcLAkHJevtmKD3"), gameId: .constant("1234"), isAlive: true)
}
