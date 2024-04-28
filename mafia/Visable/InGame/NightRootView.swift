//
//  GameRootView.swift
//  mafia
//
//  Created by Shmuli Feld on 4/12/24.
//

import SwiftUI
//on every screen check if player is alive before allowing them to participate
struct NightRootView: View {
    
    @Binding var userId: String
    @Binding var gameId: String
    
    @State private var didAppear: Bool = false
    @State var role: String? = nil
    @State var showMafiaView: Bool = false
    @State var showDetectiveView: Bool = false
    @State var showDoctorView: Bool = false
    @State var showCivillianView: Bool = false
    
    var body: some View {
        ZStack {
            NavigationStack {
                Text("Loading...")
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)

            }
        }
        .onAppear {
    
            
            if role == nil {
                getRoleAndSetView()
            } else {
                setView()
            }
    
            
        }
        .fullScreenCover(isPresented: $showMafiaView, content: {
            NavigationStack {
                MafiaView(userId: $userId, gameId: $gameId)
            }
        })
        .fullScreenCover(isPresented: $showDetectiveView, content: {
            NavigationStack {
                DetectiveView(userId: $userId, gameId: $gameId)
            }
        })
        .fullScreenCover(isPresented: $showDoctorView, content: {
            NavigationStack {
                DoctorView(userId: $userId, gameId: $gameId)
            }
        })
        .fullScreenCover(isPresented: $showCivillianView, content: {
            NavigationStack {
                CivillianView(userId: $userId, gameId: $gameId)
            }
        })
    
    }
    func getRoleAndSetView(){
        Task {
            do {
                self.role = try await GameDatabaseManager.shared.getRole(gameId: gameId, userId: userId)
                setView()
            } catch {
                print(error)
            }
        }
    }
    func setView(){
        showMafiaView = role == "mafia"
        showDetectiveView = role == "detective"
        showDoctorView = role == "doctor"
        showCivillianView = role == "civillian"
    }
}


#Preview {
    NavigationStack{
        NightRootView(userId: .constant("C76F3lyQ4wuuWDvKeDbC"), gameId: .constant("boom"))
    }
}
