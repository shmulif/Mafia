//
//  ContentView.swift
//  mafia
//
//  Created by Shmuli Feld on 2/6/24.
//

import SwiftUI
import SwiftData

enum helloWorld: String, CaseIterable {
   case Hello_World, שלום_עולם, Hola_Mundo
}

struct StartScreen1: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    
    @State var selection: helloWorld = .Hello_World

    var body: some View {
        NavigationView {
            VStack{
                Text(selection.rawValue)
                    .font(.system(size: 125))
                Picker("Select Laungauge", selection: $selection) {
                    ForEach(helloWorld.allCases, id: \.self){
                        helloWorld in Text(helloWorld.rawValue)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    StartScreen1()
        .modelContainer(for: Item.self, inMemory: true)
}
