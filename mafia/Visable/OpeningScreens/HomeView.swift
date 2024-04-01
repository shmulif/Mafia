//
//  HomeView.swift
//  mafia
//
//  Created by Shmuli Feld on 3/8/24.
//

import SwiftUI

struct HomeView: View {

    
    var body: some View {
        NavigationView{
            VStack{
                Text("Welcome")
                    .font(.largeTitle)
                    .bold()
                    .frame(height: 150)
                    .padding(20)
                Spacer()
                NavigationLink("Host Game", destination: CreateGameView())
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(height: 55)
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                    .background(Color.gray)
                    .cornerRadius(10)
                    .padding()
                NavigationLink("Join Game", destination: JoinGameView())
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(height: 55)
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                    .background(Color.gray)
                    .cornerRadius(10)
                    .padding()
                Spacer()
            }
            .navigationBarHidden(true)
            .padding()
        }
    }
}

#Preview {
    HomeView()
}
