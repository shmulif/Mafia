//
//  HomeView.swift
//  mafia
//
//  Created by Shmuli Feld on 3/8/24.
//

import SwiftUI

struct HomeView: View {
    
    @State var showNewScreen: Bool = false
    
    var body: some View {
        NavigationView{
            VStack{
                Text("Welcome")
                    .font(.largeTitle)
                    .bold()
                    .frame(height: 150)
                    .padding(20)
                Spacer()
                NavigationLink("Start Game", destination: NewGameView())
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(height: 55)
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                    .background(Color.gray)
                    .cornerRadius(10)
                    .padding()
                NavigationLink("Join Game", destination: NewGameView())
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
