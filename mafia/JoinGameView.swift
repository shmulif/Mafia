//
//  JoinGameView.swift
//  mafia
//
//  Created by Shmuli Feld on 3/9/24.
//

import SwiftUI

final class GameIdModel: ObservableObject {
    
    @Published var gameId = ""

}

struct JoinGameView: View {
    
    @StateObject private var viewModel = GameIdModel()
    @State var showNextView: Bool = false
    
    var body: some View {

        VStack(){
            Text("Join Game")
                .font(.largeTitle)
                .bold()
                .frame(height: 100)
                .padding(20)
            TextField("Enter game ID..", text: $viewModel.gameId )
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
            Button(action: {
                showNextView.toggle()
            }, label: {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                    .background(Color.blue)
                    .cornerRadius(10)
            })
            .fullScreenCover(isPresented: $showNextView, content:{
                HomeView()
            })
            Spacer()
            .padding()
        }
        .padding()
    }
}

#Preview {
    JoinGameView()
}
