//
//  HomeView.swift
//  mafia
//
//  Created by Shmuli Feld on 3/8/24.
//

import SwiftUI

struct HomeView: View {

    @State var name = "..."
    
    var body: some View {
        
        
        
        NavigationView{
            VStack{
                Text("Welcome \n"+name)
                    .font(.largeTitle)
                    .bold()
                    .frame(height: 150)
                    .multilineTextAlignment(.center)
                    .padding(50)
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
            .onAppear{
                Task {
                    let user = try? AuthenticationManager.shared.getAuthenticatedUser()
                    let userId = user?.uid
                    self.name = try await UserDatabaseManager.shared.getUserName(userId: userId ?? "no user found")
                }
            
            }
            .navigationBarHidden(true)
            .padding()
        }
    }
}

#Preview {
    HomeView()
}
