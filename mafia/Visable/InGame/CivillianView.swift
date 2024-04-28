//
//  CivillianView.swift
//  mafia
//
//  Created by Shmuli Feld on 4/14/24.
//

import SwiftUI

struct CivillianView: View {
    
    @Binding var userId: String
    @Binding var gameId: String
    @State var showNextView: Bool = false
    
    var body: some View {
        VStack {
            Spacer(minLength: 30)
            Text("Night")
                .font(.largeTitle)
                .bold()
            Text("Your Role: Civillian")
                .font(.title2)
            Spacer(minLength: 30)
            Rectangle()
                .fill(.black)
                .frame(width: .infinity, height: 3)
            Spacer()
            Button(action: {
                showNextView.toggle()
            }, label: {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(height: 55)
                    .frame(width: 150 )
                    .background(Color.gray)
                    .cornerRadius(10)
            })
            Spacer()
            
        }
        .fullScreenCover(isPresented: $showNextView, content: {
            NavigationStack {
                WaitingForDayView(userId: $userId, gameId: $gameId)
            }
        })
    }
    
}

#Preview {
    CivillianView(userId: .constant("qImj506kDGSW8JhcLAkHJevtmKD3"), gameId: .constant("1234"))
}
