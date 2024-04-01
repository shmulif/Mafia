//
//  CreateProfile.swift
//  mafia
//
//  Created by Shmuli Feld on 3/8/24.
//

import SwiftUI
import FirebaseAuth

final class UserViewModel: ObservableObject {
    
    @Published var name = ""
    
    func createAnonymousUser(name: String) async throws {
        guard !name.isEmpty else {
            print("No name entered")
            return
        }
        Task {
            do {
                let returnedUserData = try await AuthenticationManager.shared.signInAnonymous()
                try await UserDatabaseManager.shared.createNewUser(auth: returnedUserData, name: name)
            } catch {
                print("Error: \(error)")
            }
            
        }
    }

}

struct CreateProfile: View {
    
    
    @StateObject private var viewModel = UserViewModel()
    @Environment(\.presentationMode)  var presentationMode
    @State var showHomeView: Bool = false
    
    var body: some View {
        ZStack{
            VStack{
                HStack{
                    Spacer()
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Image(systemName: "xmark")
                            .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                            .font(.largeTitle)
                            .padding(20)
                    })
                    .padding()
                }
                Spacer()
            }
            VStack(){
                Text("Create Profile")
                    .font(.largeTitle)
                    .bold()
                    .frame(height: 100)
                    .padding(20)
                TextField("Enter your name..", text: $viewModel.name )
                    .padding()
                    .background(Color.gray.opacity(0.4))
                    .cornerRadius(10)
                Button(action: {
                    Task{
                        do {
                            try await viewModel.createAnonymousUser(name: viewModel.name)
                            showHomeView.toggle()
                        } catch {
                            print(error)
                        }
                    }
                }, label: {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(height: 55)
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                        .background(Color.blue)
                        .cornerRadius(10)
                })
                .fullScreenCover(isPresented: $showHomeView, content:{
                    HomeView()
                })
                Spacer()
                .padding()
            }
            .padding()
        }
    }
}

#Preview {
    CreateProfile()
}


