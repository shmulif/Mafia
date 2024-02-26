//
//  ContentView.swift
//  mafia
//
//  Created by Shmuli Feld on 2/6/24.
//

import SwiftUI
import SwiftData

struct StartScreen1: View {
    var body: some View {
        NavigationView {
            ZStack{
                VStack(spacing: 40) {
                    Spacer()
                    Text("Mafia").font(.system(size: 65)).bold().padding(.top)
                    Image(.manWithHat)
                }
                VStack{
                    NavigationLink(destination: CreateProfile()) {
                        Text("Play").frame(width: 100, height: 50, alignment: .center).background(.gray).foregroundColor(.black).cornerRadius(50)
                    }.frame(alignment: .centerLastTextBaseline)
                }
                
            }
              }
        .padding()
    }
}
    
struct StartScreen1_Previews: PreviewProvider {
    static var previews: some View {
        StartScreen1()
    }
}

struct CreateProfile: View {
    var body: some View {
        VStack {
                    Image(systemName: "globe")
                        .imageScale(.large)
                        .foregroundColor(.accentColor)
                    Text("Hello, world!")
                }
                .padding()
    }
}
