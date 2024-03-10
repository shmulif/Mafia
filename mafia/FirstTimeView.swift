//
//  ContentView.swift
//  mafia
//
//  Created by Shmuli Feld on 2/6/24.
//

import SwiftUI
import SwiftData

struct FirstTimeView: View {
    
    @State var showNewScreen: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack{
                VStack(spacing: 40) {
                    Spacer()
                    Text("Mafia").font(.system(size: 65)).bold().padding(.top)
                    Image(.manWithHat)
                }
                VStack{
                    Button(action: {
                        showNewScreen.toggle()
                    }, label: {
                        Text("Play").frame(width: 100, height: 50, alignment: .center).background(.gray).foregroundColor(.black).cornerRadius(50)
                    })
                    .sheet(isPresented: $showNewScreen, content:{
                        CreateProfile()
                    }).frame(alignment: .centerLastTextBaseline)
                }
                
            }
              }
        .padding()
    }
}
    
struct FirstTimeView_Previews: PreviewProvider {
    static var previews: some View {
        FirstTimeView()
    }
}
