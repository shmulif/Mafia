//
//  DoctorListRowView.swift
//  mafia
//
//  Created by Shmuli Feld on 4/18/24.
//

import SwiftUI

struct DoctorListRowView: View {
    let gameId: String
    let userId: String
    let player: Player
    @Binding var pressed: Bool
    @Binding var selected: String
    @Binding var showNextScreen: Bool
    
    
    var body: some View {
        HStack {
            Button(action: {
                if !pressed {
                    Task{
                        do {
                            //Kill
                            try await GameDatabaseManager.shared.save(gameId: gameId, userId: player.user_id)
                            try await GameDatabaseManager.shared.setDoctorAsDone(gameId: gameId)
                            showNextScreen = true
                            //for allowing changes
                            selected = player.user_id
                            pressed = true
                        } catch {
                            print(error)
                        }
                    }
                }
            }, label: {
                if !pressed {
                    Text(player.name)
                    .foregroundColor(.black)
                    .frame(width: .infinity, height: .infinity)
                } else {
                    Text(player.name)
                    .foregroundColor(.white)
                    .background(.blue)
                    .cornerRadius(5)
                }
                    
            })
        }
        
        
    }
}

//#Preview {
//    DoctorListRowView(name: "sample name")
//}
