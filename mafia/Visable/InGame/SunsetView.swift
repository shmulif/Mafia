//
//  SunsetView.swift
//  mafia
//
//  Created by Shmuli Feld on 4/28/24.
//

import SwiftUI

struct SunsetView: View {
    
    @Binding var userId: String
    @Binding var gameId: String
    
    @State var showNextView: Bool = false
    @State var endGame: Bool = false
    @State var isHost: Bool = false
    
    @State var winner: String? = nil
    @State var recentlyKilled: String = ""
    @State var showSecondAlert: Bool = false
    
    var body: some View {
        ZStack {
            Text("Loading..")
        }
            .onAppear {
                Task {
                    //check if isHost
                    let hostId = try? await GameDatabaseManager.shared.getHostId(gameId: gameId)
                    isHost = userId == hostId
                    setWinnerAndRecentlyKilledSunset()
                }
                
            }
            .alert(isPresented: $showSecondAlert, content: {
                displayRecentlyKilledAndWinnerSunset()
            })
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
    
    func setWinnerAndRecentlyKilledSunset() {
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
    
    func displayRecentlyKilledAndWinnerSunset() -> Alert {
        print("second alert showing")
        print("spot 1")
        if winner == nil {
            if recentlyKilled == "" {
                print("spot 2")
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
}

#Preview {
    SunsetView(userId: .constant("4l8al6EUyIMd1FhkBOmMMU4r2iB3"), gameId: .constant("party"))
}
