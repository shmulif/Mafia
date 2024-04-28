//
//  MafiaListRowView.swift
//  mafia
//
//  Created by Shmuli Feld on 4/17/24.
//

import SwiftUI

struct MafiaListRowView: View {
    
    let name: String
    let gameId: String
    let selectedId: String
    @State var selectedName: String = ""
    
    var body: some View {
        HStack {
            Text(name)
             Spacer()
            if selectedName != "" {
                Text("Chose: "+selectedName)
                    .foregroundColor(.white)
                    .background(.pink)
            }
        }
        .onAppear {
            Task {
                selectedName = try await GameDatabaseManager.shared.getPlayerName(gameId: gameId, userId: selectedId)
            }
        }
    }
}

//#Preview {
//    DetectiveListRowView(name: "sample name")
//}
