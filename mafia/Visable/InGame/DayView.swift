//
//  DayView.swift
//  mafia
//
//  Created by Shmuli Feld on 4/12/24.
//

import SwiftUI

@MainActor
final class DayViewModel: ObservableObject {
    
    @Published var players: [Player] = []
    @Published var isNight: Bool = false
    @Published var updatedVote: Bool = false
    
    func addListenerForUpdatedVote(gameId: String) {
        GameDatabaseManager.shared.addListenerForUpdatedVote(gameId: gameId) { [weak self] updatedVote in
            self?.updatedVote = updatedVote ?? true
        }
    }
    
    func addListenerForDay(gameId: String) {
        GameDatabaseManager.shared.addListenerForDay(gameId: gameId) { [weak self] isDay in
            self?.isNight = !(isDay ?? true)
        }
    }
}

struct DayView: View {
    
    @Binding var userId: String
    @Binding var gameId: String
    @State var isAlive: Bool = false
    @State var showDeadAlert: Bool = false
    
    @State var done: Bool = false
    @StateObject private var vm = DayViewModel()
    @State private var didAppear: Bool = false
    @State var isHost: Bool = false
    @State var endGame: Bool = false
    @State var winner: String? = nil
    @State var recentlyKilled: String = ""
    @State var showFirstAlert: Bool = false
    @State var alertAppeard: Bool = false
    
    var body: some View {
        VStack {
            Spacer(minLength: 30)
            Text("Day")
                .font(.largeTitle)
                .bold()
            Spacer(minLength: 30)
            Rectangle()
                .fill(.black)
                .frame(width: .infinity, height: 3)
            Spacer(minLength: 40)
            Text("Discuss among your fellow players who the mafia might be")
                .multilineTextAlignment(.center)
                .font(.title2)
                .italic()
                .padding()
            Spacer(minLength: 40)
            Text("Vote to eliminate:")
                .font(.title2)
            Text("(vote cannot be changed)")
            List {
                ForEach(vm.players, id: \.self) { player in
                    DayListRowView(gameId: gameId, voterId: userId, player: player, isAlive: isAlive, done: $done, showDeadAlert: $showDeadAlert)
                }
            }
            .padding()
            Rectangle()
                .fill(.black)
                .frame(width: .infinity, height: 3)
            Spacer(minLength: 15)
            
            

            if isHost && vm.updatedVote {
                let _ = updatedVoteActionSequence()
            }
            
        }
        .onAppear {
            let _ = print("showFirstAlert:")
            let _ = print(showFirstAlert)
            let _ = print("vm.isNight:")
            let _ = print(vm.isNight)
            //set up listeners on first appear
            if !didAppear {
                
                Task {
                    
                    vm.addListenerForDay(gameId: gameId)
                    
                    //get living status
                    isAlive = try await GameDatabaseManager.shared.checkIfAlive(gameId: gameId, userId: userId)
                    
                    
                    //get players
                    vm.players = try await  GameDatabaseManager.shared.getLivingPlayers(gameId: gameId)
                
                    //check if isHost
                    let hostId = try? await GameDatabaseManager.shared.getHostId(gameId: gameId)
                    isHost = userId == hostId
                    //listeners for host only
                    if isHost {
                        vm.addListenerForUpdatedVote(gameId: gameId)
                    }
                    
                    didAppear = true
                }
                    
            }
        }
        .onDisappear {
            GameDatabaseManager.shared.removeListenerDay()
            if isHost {
                GameDatabaseManager.shared.removeListenerForUpdatedVote()
            }
        }
        .fullScreenCover(isPresented: $vm.isNight, content: {
            NavigationStack {
                SunsetView(userId: $userId, gameId: $gameId)
            }
        })
        .fullScreenCover(isPresented: $endGame, content: {
            NavigationStack {
                HomeView()
            }
        })
        
        ZStack {}
            .alert(isPresented: $showDeadAlert, content: {
                displayDeadAlert()
            })
        

    }
    
    func displayDeadAlert() -> Alert {
        return Alert(title: Text("Dead players cannot participate"), dismissButton: .default(Text("OK"), action: {
            showDeadAlert.toggle()
        }))
    }
    
    func updatedVoteActionSequence() {
        Task {
            print("doing host code")
            let doneVoting = LocalGamePlayManager.shared.checkIfDoneVoting1(players: vm.players)
            if doneVoting {
                print("everyone done voting:")
                print(doneVoting)
                try? await LocalGamePlayManager.shared.killIfNeededAndCalculateWinnersDay(gameId: gameId, players: vm.players)
            }
            try? await GameDatabaseManager.shared.setUpdatedVoteToFalse(gameId: gameId)
        }
    }
    
    
    

    

    
}

#Preview {
    DayView(userId:
            .constant("4l8al6EUyIMd1FhkBOmMMU4r2iB3"), gameId: .constant("Friends"))
}
