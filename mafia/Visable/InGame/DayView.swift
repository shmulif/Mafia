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
    
    func addListenerForNight(gameId: String) {
        GameDatabaseManager.shared.addListenerForDay(gameId: gameId) { [weak self] isDay in
            self?.isNight = !(isDay ?? true)
        }
    }
}

struct DayView: View {
    
    @Binding var userId: String
    @Binding var gameId: String
    
    @State var done: Bool = false
    @StateObject private var vm = DayViewModel()
    @State private var didAppear: Bool = false
    @State var isHost: Bool = false
    @State var showNextView: Bool = false
    @State var endGame: Bool = false
    
    @State var winner: String? = ""
    @State var recentlyKilled: String = ""
    @State var showFirstAlert: Bool = false
    @State var showSecondAlert: Bool = false
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
            Spacer(minLength: 15)
            Text("Chat:")
                .font(.title2)
            Rectangle()
                .fill(.gray)
                .padding()
            Text("Vote to eliminate:")
                .font(.title2)
            Text("(vote cannot be changed)")
                .alert(isPresented: $showSecondAlert, content: {
                    displayRecentlyKilledAndWinnerSunset()
                })
                .alert(isPresented: $showFirstAlert, content: {
                    displayRecentlyKilledAndWinnerSunrise()
                })
            List {
                ForEach(vm.players, id: \.self) { player in
                    DayListRowView(gameId: gameId, voterId: userId, player: player, done: $done)
                }
            }
            .padding()
            Rectangle()
                .fill(.black)
                .frame(width: .infinity, height: 3)
            Spacer(minLength: 15)
            
            
            if vm.isNight {
                let _ = setWinnerAndRecentlyKilled()
            }
            if isHost && vm.updatedVote {
                let _ = updatedVoteActionSequence()
            }
            
        }
        .onAppear {
            //set up listeners on first appear
            if !didAppear {
                Task {
                    setWinnerAndRecentlyKilled()
                    showFirstAlert = true
                }
                vm.addListenerForNight(gameId: gameId)
                        
                    //get players
                    Task {
                        vm.players = try await  GameDatabaseManager.shared.getLivingPlayers(gameId: gameId)
                    }
                    //check if isHost
                    Task {
                        let hostId = try? await GameDatabaseManager.shared.getHostId(gameId: gameId)
                        isHost = userId == hostId
                        //listeners for host only
                        if isHost {
                            vm.addListenerForUpdatedVote(gameId: gameId)
                        }
                    }
                
                        
                    didAppear = true
            }
        }
        .fullScreenCover(isPresented: $showNextView, content: {
            NavigationStack {
                NightRootView(userId: $userId, gameId: $gameId)
            }
        })
        .fullScreenCover(isPresented: $endGame, content: {
            NavigationStack {
                HomeView()
            }
        })
    }
    
    func updatedVoteActionSequence() {
        Task {
            print("doing code")
            let doneVoting = LocalGamePlayManager.shared.checkIfDoneVoting1(players: vm.players)
            if doneVoting {
                print(doneVoting)
                try? await LocalGamePlayManager.shared.killIfNeededAndCalculateWinnersDay(gameId: gameId, players: vm.players)
            }
            try? await GameDatabaseManager.shared.setUpdatedVoteToFalse(gameId: gameId)
        }
    }
    
    
    func setWinnerAndRecentlyKilled() {
        Task {
            winner = try? await GameDatabaseManager.shared.checkForWinner(gameId: gameId)
            //not sure why it's making me force handle error
            let recentlyKilledUserId = try! await GameDatabaseManager.shared.getRecentlyKilled(gameId: gameId)
            if recentlyKilledUserId != "" {
                recentlyKilled = try! await GameDatabaseManager.shared.getPlayerName(gameId: gameId, userId: recentlyKilledUserId)
            }
            showSecondAlert = true
        }
    }
    
    func displayRecentlyKilledAndWinnerSunrise() -> Alert {
        if winner == nil {
            if recentlyKilled == "" {
                return Alert(title: Text("No one was killed"), dismissButton: .default(Text("OK"), action: {
                    showFirstAlert = false
                }))
            } else {
                return Alert(title: Text((recentlyKilled)+" was killed"), dismissButton: .default(Text("OK"), action: {
                    showFirstAlert = false
                }))
            }
        } else {
            if recentlyKilled == "" {
                print((winner ?? "<error>")+" win")
                return Alert(title: Text((winner ?? "<error>")+" win!"), message: Text("No one was killed"), dismissButton: .default(Text("leave game"), action: {
                    if isHost {
                        Task {
                            await GameIdManager.shared.makeGameIdAvailable(gameId: gameId)
                        }
                    }
                    endGame.toggle()
                }))
            } else {
                return Alert(title: Text((winner ?? "<error>")+" win!"), message: Text((recentlyKilled)+" was killed"), dismissButton: .default(Text("leave game"), action: {
                    if isHost {
                        Task {
                            await GameIdManager.shared.makeGameIdAvailable(gameId: gameId)
                        }
                    }
                    endGame.toggle()
                }))
            }
        }
    }

    
    func displayRecentlyKilledAndWinnerSunset() -> Alert {
        if winner == nil {
            if recentlyKilled == "" {
                return Alert(title: Text("No one was killed"), dismissButton: .default(Text("continue"), action: {
                    showNextView.toggle()
                }))
            } else {
                return Alert(title: Text((recentlyKilled)+" was killed"), dismissButton: .default(Text("continue"), action: {
                    showNextView.toggle()
                }))
            }
        } else {
            if recentlyKilled == "" {
                print((winner ?? "<error>")+" win")
                return Alert(title: Text((winner ?? "<error>")+" win!"), message: Text("No one was killed"), dismissButton: .default(Text("leave game"), action: {
                    endGame.toggle()
                }))
            } else {
                return Alert(title: Text((winner ?? "<error>")+" win!"), message: Text((recentlyKilled)+" was killed"), dismissButton: .default(Text("leave game"), action: {
                    endGame.toggle()
                }))
            }
        }
    }
    
}

#Preview {
    DayView(userId:
        .constant("RFlpKtlCFYby1Heq1X6T"), gameId: .constant("crackle"))
}
