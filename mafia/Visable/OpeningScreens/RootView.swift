//
//  RootView.swift
//  mafia
//
//  Created by Shmuli Feld on 3/8/24.
//

import SwiftUI
import FirebaseAuth

//set up a system that checks if user is authenticated, if not it prompts them to create profile, otherwise it goes straight to home screen

struct RootView: View {
    
    @State private var showFirstTimeView: Bool = false
    @State var userId: String? = ""
    var body: some View {
        NavigationStack {
            ZStack {
                HomeView()
            }
            .onAppear {
                let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
                userId = authUser?.uid
                self.showFirstTimeView = authUser == nil
            }
            .fullScreenCover(isPresented: $showFirstTimeView, content: {
                NavigationStack {
                    FirstTimeView()
                }
            })
        }
    }
}

#Preview {
    NavigationStack{
        RootView()
    }
}
