//
//  WaitingForDayView.swift
//  mafia
//
//  Created by Shmuli Feld on 4/16/24.
//

import SwiftUI

@MainActor
final class DayCheckingViewModel: ObservableObject {
    
    @Published var isDay: Bool = false
    @Published var everyoneIsDone: Bool = false

    func addListenerForDay(gameId: String) {
        GameDatabaseManager.shared.addListenerForDay(gameId: gameId) { [weak self] day in
            self?.isDay = day ?? false
        }
    }
    
    func addListenerForEveryoneIsDone(gameId: String) {
        GameDatabaseManager.shared.addListenerForEveryoneIsDone(gameId: gameId) { [weak self] result in
            self?.everyoneIsDone = result ?? false
        }
    }
    
    
    
}

struct WaitingForDayView: View {
    
    @Binding var userId: String
    @Binding var gameId: String
    
    @StateObject private var vm = DayCheckingViewModel()
    @State private var didAppear: Bool = false
    @State var isHost: Bool = false
    @State var winner: String? = ""
    
    var body: some View {
        VStack{
            Text("Waiting for other players to finish")
            //continiously call this
            if isHost {
                let _ = hostActions()
            }
        }
        .onAppear {
            
            
            if !didAppear {
                
                Task {
                    let hostId = try? await GameDatabaseManager.shared.getHostId(gameId: gameId)
                    isHost = userId == hostId
                    if isHost {
                        vm.addListenerForEveryoneIsDone(gameId: gameId)
                    }
                }
    
                vm.addListenerForDay(gameId: gameId)
                didAppear = true
                
            }
            
            
            
        }
        .onDisappear {
            GameDatabaseManager.shared.removeListenerDay()
            if isHost {
                GameDatabaseManager.shared.removeListenerEveryoneIsDone()
            }
        }
        .fullScreenCover(isPresented: $vm.isDay, content: {
            NavigationStack {
                SunriseView(userId: $userId, gameId: $gameId)
            }
        })
        
    }
    
    func hostActions() {
        Task {
            if vm.everyoneIsDone {
                try? await LocalGamePlayManager.shared.killIfNeededAndCalculateWinnersNight(gameId: gameId)
                try await GameDatabaseManager.shared.resetFields(gameId: gameId)
                try await GameDatabaseManager.shared.resetCylceClock(gameId: gameId)
                try? await GameDatabaseManager.shared.setAsDay(gameId: gameId)
            }
        }
    }
}

#Preview {
    WaitingForDayView(userId: .constant("4l8al6EUyIMd1FhkBOmMMU4r2iB3"), gameId: .constant("Friends"))
}
