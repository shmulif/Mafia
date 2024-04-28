//
//  DayListRowView.swift
//  mafia
//
//  Created by Shmuli Feld on 4/18/24.
//

import SwiftUI

struct DayListRowView: View {
    
    let gameId: String
    let voterId: String
    let player: Player
    let isAlive: Bool
    @Binding var done: Bool
    @Binding var showDeadAlert: Bool
    @State var pressed: Bool = false
    
    
    
    var body: some View {
        HStack {
            Button(action: {
                if !pressed && !done && isAlive {
                    Task{
                        do {
                            //Kill
                            try await GameDatabaseManager.shared.voteAgainst(gameId: gameId, voterId: voterId, victimId: player.user_id)
                            done = true
                            pressed = true
                        } catch {
                            print(error)
                        }
                    }
                } else if !isAlive {
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
                    .background(.orange)
                    .cornerRadius(5)
                }
                    
            })
        }
        
        
    }
}

//#Preview {
//    DayListRowView()
//}
