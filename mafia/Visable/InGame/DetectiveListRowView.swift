//
//  DetectiveListRowView.swift
//  mafia
//
//  Created by Shmuli Feld on 4/18/24.
//

import SwiftUI

struct DetectiveListRowView: View {

    @State var gameId: String
    let player: Player
    @Binding var pressed: Bool
    @Binding var selected: String
    @Binding var role: String
    @Binding var done: Bool
    
    
    var body: some View {
        HStack {
            Button(action: {
                if !pressed && !done {
                    Task {
                        role = player.role ?? "<No role found>"
                        //for allowing changes
                        selected = player.user_id
                        pressed = true
                        done = true
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
                    .background(.green)
                    .cornerRadius(5)
                }
                    
            })
        }
        
        
    }
}

//#Preview {
//    DetectiveListRowView(name: "sample name")
//}
