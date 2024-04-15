//
//  MafiaView.swift
//  mafia
//
//  Created by Shmuli Feld on 4/14/24.
//

import SwiftUI

//    function to check if mafia are done should incorparate: let allMafiaAreDone = totalCount == finishedCount
@MainActor
final class MafiaDoneViewMode: ObservableObject {
    
    @Published var totalCount = 2
    @Published var finishedCount = 0

    let gameId = "1234"

    func addListenersForMafiaAreDone() {
        GameDatabaseManager.shared.addListenerForLivingMafiaCount(gameId: gameId) { [weak self] count in
            self?.totalCount = count
        }
        GameDatabaseManager.shared.addListenerForDoneNominatingMafiaCount(gameId: gameId) { [weak self] count in
            self?.finishedCount = count
        }
    }
    
}

struct MafiaView: View {
    
    var mafiaHost: String = "SampleMafiaId"
    var userId: String = "SampleUserId"
    
    var body: some View {
        Text("MafiaView")
    }
}

#Preview {
    MafiaView()
}
