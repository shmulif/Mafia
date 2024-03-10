//
//  GameRootView.swift
//  mafia
//
//  Created by Shmuli Feld on 3/8/24.
//

import SwiftUI
//import FirebaseAuth

struct NewGameView: View {
    
    @State var showNewScreen: Bool = false

    var body: some View {
        VStack {
            Text("Game ID:")
                .font(.largeTitle)
                .bold()
                .frame(height: 150)
            Text("1234")
                .font(.largeTitle)
                .bold()
                .frame(height: 150)
                .padding(20)
            Button(action: {
                showNewScreen.toggle()
//                Task {
//                    do {
//                        try await GameManager.shared.createNewGame(gameId: "1234")
//                        guard let userID = Auth.auth().currentUser?.uid else { return }
//                        let currentUser = try await UserManager.shared.getUser(userId: userID)
//                        try await GameManager.shared.addPlayer(user: currentUser)
//                    } catch {
//                        print("Error: \(error)")
//                    }
//                }
            }, label: {
                Text("Start").frame(width: 100, height: 50, alignment: .center).background(.gray).foregroundColor(.black).cornerRadius(50)
            })
            .fullScreenCover(isPresented: $showNewScreen, content:{
                HomeView()
            })
        }
    }
}

#Preview {
    NewGameView()
}
