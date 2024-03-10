//
//  CreateProfile.swift
//  mafia
//
//  Created by Shmuli Feld on 3/8/24.
//

import SwiftUI
import FirebaseAnalyticsSwift
import FirebaseAuth

final class NameViewModel: ObservableObject {
    
    @Published var name = ""
    
    func signIn(){
        guard !name.isEmpty else {
            print("Please enter your name to continue")
            return
        }
        Task {
            //Create user with email
        }
       
    }
    
    func signInAnonymous() async throws {
        guard !name.isEmpty else {
            print("Please enter your name to continue")
            return
        }
        Task {
            do {
                let returnedUserData = try await AuthenticationManeger.shared.signInAnonymus()
                print("Sucess")
                print(returnedUserData)
            } catch {
                print("Error: \(error)")
            }
            
        }
    }
}

struct CreateProfile: View {
    
    
    @StateObject private var viewModel = NameViewModel()
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
                            try await viewModel.signInAnonymous()
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
        .analyticsScreen(name: "\(CreateProfile.self)")
    }
}

#Preview {
    CreateProfile()
}

//Sign in
struct AuthDataResultModel{
    let uid: String
    let email: String?
    let photoUrl: String?
    let isAnonymous: Bool
    
    init(user: User){
        self.uid = user.uid
        self.email = user.email
        self.photoUrl = user.photoURL?.absoluteString
        self.isAnonymous = user.isAnonymous
    }
}

final class AuthenticationManeger {
    
    static let shared = AuthenticationManeger()
    private init(){}
    
    func getAuthenticatedUser() throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        
        return AuthDataResultModel(user: user)
    }
    
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
}

//Sign in Anoonymously
extension AuthenticationManeger {
    
    @discardableResult
    func signInAnonymus() async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signInAnonymously()
        return AuthDataResultModel(user: authDataResult.user)
    }
}


