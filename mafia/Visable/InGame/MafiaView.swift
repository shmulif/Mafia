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
final class MafiaMembersViewMode: ObservableObject {
    
    
//    @Published var staticMafiaMembers: [MafiaMember] = []
    @Published var players: [Player] = []
    @Published var mafiaAreDone: Bool = false
    //for mafia_host
    @Published var mafiaMembers: [MafiaMember] = []
    @Published var mafiaUpdatedVote: Bool = false
    @Published var mafiaDoneChoosing: Bool = false
    
    func addListenerForPlayers(gameId: String) {
        GameDatabaseManager.shared.addListenerForLivingPlayers(gameId: gameId) { [weak self] players in
            self?.players = players
        }
    }

    func addListenerForMafiaAreDone(gameId: String) {
        GameDatabaseManager.shared.addListenerForMafiaAreDone(gameId: gameId) { [weak self] done in
            self?.mafiaAreDone = done ?? false
        }
    }
    //for mafia_host
    func addListenerForMafiaMembers(gameId: String) {
        GameDatabaseManager.shared.addListenerForMafiaMembers(gameId: gameId) { [weak self] member in
            self?.mafiaMembers = member
        }
    }
    func addListenerForMafiaUpdatedVote(gameId: String) {
        GameDatabaseManager.shared.addListenerForMafiaUpdatedVote(gameId: gameId) { [weak self] updated in
            self?.mafiaUpdatedVote = updated ?? false
        }
    }
    
    //may not use this
//    @Published var mafiaVotesMatch: Bool = true
//    func addListenerForMafiaVotesMatch(gameId: String) {
//        GameDatabaseManager.shared.addListenerForMafiaVotesMatch(gameId: gameId) { [weak self] votesMatch in
//            self?.mafiaVotesMatch = votesMatch ?? true
//        }
//    }
    
}

struct MafiaView: View {
    
    @Binding var userId: String
    @Binding var gameId: String
    @State var isAlive: Bool
    @State var showDeadAlert: Bool = false
    
    @State var selected: String = ""
    @StateObject private var vm = MafiaMembersViewMode()
    @State private var didAppear: Bool = false
    @State var isMafiaHost: Bool = false
    
    
    
    var body: some View {
        VStack {
            Spacer(minLength: 30)
            Text("Night")
                .font(.largeTitle)
                .bold()
            Text("Your Role: Mafia")
                .font(.title2)
            Spacer(minLength: 30)
            Rectangle()
                .fill(.black)
                .frame(width: .infinity, height: 3)
            Spacer(minLength: 15)
            Text("Other mafia:")

            List {
                ForEach(vm.mafiaMembers, id: \.self) { member in
                    if member.user_id != userId {
                        MafiaListRowView(name: (member.name), gameId: gameId, selectedId: member.nominated_to_kill ?? "unknown")
                    }
//                    MafiaListRowView(name: (member.name))
                }
                
            }
            .padding()
            Text("Select who you want to kill:")
                .font(.title2)
            Text("Murder is carried out when all mafia chose the same person")
                List {
                    ForEach(vm.players, id: \.self) { player in
                        if selected == player.user_id {
                            VictimListRowView(gameId: gameId, voterId: userId, player: player, pressed: .constant(true), selected: $selected, isAlive: isAlive, showDeadAlert: $showDeadAlert)
                        } else {
                            VictimListRowView(gameId: gameId, voterId: userId, player: player, pressed: .constant(false), selected: $selected,isAlive: isAlive, showDeadAlert: $showDeadAlert)
                        }
                        
                    }
                }
            
                .padding()
            Spacer(minLength: 30)
            Rectangle()
                .fill(.black)
                .frame(width: .infinity, height: 3)
            Spacer(minLength: 15)
//                if !vm.mafiaVotesMatch {
//                    Text("All mafia must vote for the same person")
//                }
                
                
                if isMafiaHost && vm.mafiaUpdatedVote {
                    let _ = updatedVoteActionSequence()
                }
                
            
            
            
        }
        .onAppear {
           
        
            
            //set up listeners on first appear
            if !didAppear {
                //check if current user is mafia_host
                Task {
                    let mafiaHostId = try? await GameDatabaseManager.shared.getMafiaHost(gameId: gameId)
                    isMafiaHost = userId == mafiaHostId
                    //listener for host only
                    if isMafiaHost {
                        vm.addListenerForMafiaUpdatedVote(gameId: gameId)
                    }
                    if !isAlive {
                        await GameDatabaseManager.shared.setMafiaAsDoneVoting(gameId: gameId, userId: userId)
                    }
                }
                
//                Task {
//                    vm.staticMafiaMembers = try await  GameDatabaseManager.shared.getAllMafiaMembers(gameId: gameId)
//                }
                
                vm.addListenerForPlayers(gameId: gameId)
//                    vm.addListenerForMafiaVotesMatch(gameId: gameId)
                vm.addListenerForMafiaAreDone(gameId: gameId)
                vm.addListenerForMafiaMembers(gameId: gameId)
                
                
                didAppear = true
            }
        }
        .onDisappear {
            GameDatabaseManager.shared.removeListenerForPlayers()
            GameDatabaseManager.shared.removeListenerForMafiaAreDone()
            GameDatabaseManager.shared.removeListenerForMafiaMembers()
            if isMafiaHost {
                GameDatabaseManager.shared.removeListenerForMafiaUpdatedVote()
            }
        }
        .fullScreenCover(isPresented: $vm.mafiaAreDone, content: {
            NavigationStack {
                WaitingForDayView(userId: $userId, gameId: $gameId)
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
    
    //for host
    func updatedVoteActionSequence(){
        Task {
            try? await GameDatabaseManager.shared.setMafiaUpdatedVoteToFalse(gameId: gameId)
        }
        if !vm.mafiaDoneChoosing {
            vm.mafiaDoneChoosing = LocalGamePlayManager.shared.checkIfMafiaAreDoneChoosing(gameId: gameId, mafiaMembers: vm.mafiaMembers)
        }
        
        if vm.mafiaDoneChoosing {
            Task {
                await LocalGamePlayManager.shared.setMafiaVotesMatchingStatusAndSetDoneStatus(gameId: gameId, players: vm.players, mafiaMembers: vm.mafiaMembers)
            }
        }
    }
    
}

struct VictimListRowView: View {
    
    let gameId: String
    let voterId: String
    let player: Player
    @Binding var pressed: Bool
    @Binding var selected: String
    let isAlive: Bool
    @Binding var showDeadAlert: Bool
    
    
    var body: some View {
        HStack {
            Button(action: {
                if !pressed && isAlive {
                    Task{
                        do {
                            //Kill
                            try await GameDatabaseManager.shared.mafiaVoteAgainst(gameId: gameId, voterId: voterId, victimId: player.user_id)
                            selected = player.user_id
                            pressed = true
                        } catch {
                            print(error)
                        }
                    }
                }  else if !isAlive {
                    showDeadAlert.toggle()
                }
            }, label: {
                if !pressed {
                    Text(player.name)
                    .foregroundColor(.black)
                    .frame(width: .infinity, height: .infinity)
                } else {
                    Text(player.name)
                    .foregroundColor(.white)
                    .background(.pink)
                    .cornerRadius(5)
                }
                    
            })
        }
        
        
    }
}

#Preview {
    MafiaView(userId: .constant("FZkml9gdkMmrldqJs8hP"), gameId: .constant("cocoa"), isAlive: true, selected: "")
}
