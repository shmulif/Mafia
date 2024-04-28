//
//  MafiaView.swift
//  mafia
//
//  Created by Shmuli Feld on 4/14/24.
//

import SwiftUI

//figure out hoe to make a constanly running function to check if mafia are done as follows
//var mafiaAreDone: Bool = vm.totalCount == vm.finishedCount

@MainActor
final class MafiaDoneViewMode: ObservableObject {
    
    @Published var totalCount = 2
    @Published var finishedCount = 0

    let gameId = "1234"
    
    //listen if mafia are done, then go to wait screen and wait for day

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
    
    @StateObject private var vm = MafiaDoneViewMode()
    var mafiaHost: String = "SampleMafiaId"
    var userId: String = "SampleUserId"
    var gameId: String = "1234"
    @State var mafiaAreDone: Bool = false
    @State var mafiaChoseSamePerson: Bool = false
    @State var mafiaAreReady: Bool = false
    
    
    var body: some View {
        Text("MafiaView")
        
        if mafiaHost == userId {
            if vm.finishedCount == vm.totalCount {
                //mafiaChoseSamePerson = LocalGamePlayManager.shared.mafiaChoseSamePerson(gameId: gameId)
                if(mafiaChoseSamePerson){
                    
                } else {
                    //popup("All mafia must chose same person")
                    //check for change
                    //check again
                }
            }
        
        
//        .onAppear {
//            if mafiaHost == userId {
//                vm.addListenersForMafiaAreDone()
//                while(!mafiaAreDone && !mafiaChoseSamePerson){
//
//                    while(!mafiaAreDone) {
//                        mafiaAreDone = vm.finishedCount == vm.totalCount
//                        }
//
//                    //mafiaChoseSamePerson = LocalGamePlayManager.shared.mafiaChoseSamePerson(gameId: gameId)
//                    if(!mafiaChoseSamePerson){
//                        print("All mafia must chose same person")
//                    }
//
//
//                }
//                //if mafiaAreReady {
//                //try await GameDatabaseManager.shared.setMafiaAsDone(gameId: gameId)
//
//                //}
//            }
//                .fullScreenCover(isPresented: $mafiaAreReady, content: {
//                    NavigationStack {
//                        WaitingForDayView()
//                    }
//                })

        }
        
    }
    
    
    
        
    
}

#Preview {
    MafiaView()
}
