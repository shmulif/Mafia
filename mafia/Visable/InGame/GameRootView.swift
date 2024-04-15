//
//  GameRootView.swift
//  mafia
//
//  Created by Shmuli Feld on 4/12/24.
//

import SwiftUI

@MainActor
final class DayCheckingViewModel: ObservableObject {
    @Published var isDay: Bool = false
    @Published var role: String = ""
    
    let gameId = "1234"

    func addListenerForDay() {
        GameDatabaseManager.shared.addListenerForDay(gameId: gameId) { [weak self] day in
            self?.isDay = day ?? false
        }
    }
    
}

struct GameRootView: View {
    

    @StateObject private var viewModel = DayCheckingViewModel()
    @State private var didAppear: Bool = false
    @State var userId: String = "qImj506kDGSW8JhcLAkHJevtmKD3"
    @State var gameId: String = "1234"
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
            
            if !didAppear {
                viewModel.addListenerForDay()
                didAppear = true
            }
            
            if role == nil {
                
                Task {
                    do {
                        role = try await GameDatabaseManager.shared.getRole(gameId: gameId, userId: userId)
                        print(viewModel.role)
                        showMafiaView = !viewModel.isDay && role == "mafia"
                        showDetectiveView = !viewModel.isDay && role == "detective"
                        showDoctorView = !viewModel.isDay && role == "doctor"
                        showCivillianView = !viewModel.isDay && role == "civillian"
                    } catch {
                        print(error)
                    }
                }
                
            } else {
                
                showMafiaView = !viewModel.isDay && role == "mafia"
                showDetectiveView = !viewModel.isDay && role == "detective"
                showDoctorView = !viewModel.isDay && role == "doctor"
                showCivillianView = !viewModel.isDay && role == "civillian"
                
            }
            
        }
        .fullScreenCover(isPresented: $viewModel.isDay, content: {
            NavigationStack {
                DayView()
            }
        })
        .fullScreenCover(isPresented: $showMafiaView, content: {
            NavigationStack {
                MafiaView()
            }
        })
        .fullScreenCover(isPresented: $showDetectiveView, content: {
            NavigationStack {
                DetectiveView()
            }
        })
        .fullScreenCover(isPresented: $showDoctorView, content: {
            NavigationStack {
                DoctorView()
            }
        })
        .fullScreenCover(isPresented: $showCivillianView, content: {
            NavigationStack {
                CivillianView()
            }
        })
    
    }
}


#Preview {
    NavigationStack{
        GameRootView()
    }
}
