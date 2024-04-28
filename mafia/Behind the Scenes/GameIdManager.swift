//
//  GameIdManager.swift
//  mafia
//
//  Created by Shmuli Feld on 3/11/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

//make more efficient by properly querying data based on boolean value of data
final class GameIdManager {
    
    static let shared = GameIdManager()
    private init() { }
    
    func getGameId() async throws -> String {
        
        let snapshot = try await Firestore.firestore().collection("game_ids").whereField("in_use", isEqualTo: false).limit(to: 1).getDocuments()
        
        var gameId: [String] = []
        for document in snapshot.documents {
            
            let data = document.data()
            
            let inUse = data["in_use"] as? Bool ?? true
            let newGameId = data["id"] as? String
            
            if !inUse {
                gameId.append(newGameId ?? "<id not found>")
                break;
            } else {
                print("error: failed to query documents not in use")
            }
        }
        
        if gameId.isEmpty {
            gameId.append("There was an error generating a game id\nPlease try again later")
        } else {
            let userData: [String:Any] = [
                "in_use" : true,
            ]
            try await Firestore.firestore().collection("game_ids").document(gameId[0]).setData(userData, merge: true)
        }
    

        
        return gameId[0]
    }
    
    func makeGameIdAvailable(gameId: String) async {
        let data: [String:Any] = [
            "in_use" : false
        ]
        try? await Firestore.firestore().collection("game_ids").document(gameId).updateData(data)
    }
}
