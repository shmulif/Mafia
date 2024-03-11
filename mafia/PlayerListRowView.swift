//
//  PlayerListRowView.swift
//  mafia
//
//  Created by Shmuli Feld on 3/10/24.
//

import SwiftUI

struct PlayerListRowView: View {
    
    let name: String
    
    var body: some View {
        Text(name)
    }
}

#Preview {
    PlayerListRowView(name: "sample name")
}
