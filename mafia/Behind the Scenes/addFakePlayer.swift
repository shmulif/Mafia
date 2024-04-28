//
//  addFakePlayer.swift
//  mafia
//
//  Created by Shmuli Feld on 4/22/24.
//

import SwiftUI

struct nameAndId: Hashable {
    let name: String
    let id: String
}
final class addFakePlayerViewModel: ObservableObject {
    
    @Published var list: [nameAndId] = []
    @Published var gameId = ""
    @Published var name = ""
    
    func makeEntry(name: String, id: String) -> nameAndId{
        return nameAndId(name: name, id: id)
    }
    func addToList(name: String, id: String){
        let entry = makeEntry(name: name, id: id)
        list.append(entry)
    }

}

struct addFakePlayer: View {
    
    @StateObject private var viewModel = addFakePlayerViewModel()
    @State var showAlert: Bool = false
    
    var body: some View {

        VStack(){
            Spacer()
            Text("Add fake player")
                .font(.largeTitle)
                .bold()
                .padding()
            Text("Enter game ID")
                .font(.title3)
                .bold()
            TextField("Enter game ID..", text: $viewModel.gameId )
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
            Text("Enter name")
                .font(.title3)
                .bold()
            TextField("Enter name..", text: $viewModel.name )
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
            Button(action: {
                Task {
                    do {
                        //add current user to game
                        let player = try await UserDatabaseManager.shared.makeFakeUser(gameId: viewModel.gameId, name: viewModel.name)
                        viewModel.addToList(name: player.name, id: player.userId)
                        try await GameDatabaseManager.shared.addPlayer(user: player)
                        showAlert.toggle()
                    } catch {
                        print(error)
                    }
                }
            }, label: {
                Text("Add")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                    .background(Color.blue)
                    .cornerRadius(10)
            })
            .alert(isPresented: $showAlert, content: {
                Alert(title: Text("Added"), dismissButton: .default(Text("OK"), action: {
                    viewModel.name = ""
                    showAlert = false
                }))
            })
            Spacer()
            List {
                ForEach(viewModel.list, id: \.self) { entry in
                    VStack {
                        Text("name: "+entry.name)
                        Text("id: "+entry.id)
                    }
                    
                }
            }
            .padding()
        }
        .padding()
    }
}

#Preview {
    addFakePlayer()
}
