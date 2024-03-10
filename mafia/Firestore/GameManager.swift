//
//  GameManager.swift
//  mafia
//
//  Created by Shmuli Feld on 3/10/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Game {
    let gameId: String
    var day: Bool
    let dateCreated: Date?
    var playerCount: Int?
}

struct Player {
    let userId: String
    var alive: Bool
    let name: String
    let dateCreated: Date?
    let currentGame: String?
}

final class GameManager {
    
    static let shared = GameManager()
    private init() { }
    
    func createNewGame(gameId: String) async throws {
        let userData: [String:Any] = [ //might need to be var
            "game_id" : gameId,
            "day" : false,
            "date_created" : Timestamp(),
            "player_count" : 0,
        ]
        try await Firestore.firestore().collection("games").document(gameId).setData(userData, merge: false)
    }
    //fix exclamation marks
    func getGame(gameId: String) async throws -> Game {
        let snapshot = try await Firestore.firestore().collection("games").document(gameId).getDocument()
        
        guard let data = snapshot.data(), let gameId = data["game_id"] as? String else {
            throw URLError(.badServerResponse)
        }
        
        let day = data["day"] as? Bool
        let dateCreated = data["date_created"] as? Date
        let playerCount = data["player_count"] as? Int
        
        return Game(gameId: gameId, day: day!, dateCreated: dateCreated, playerCount: playerCount)
    }
    
    func getAllPlayers(gameId: String) async throws -> [Player] {
        let snapshot = try await Firestore.firestore().collection("games").document(gameId).collection("players").getDocuments()
        
        var players: [Player] = []
        for document in snapshot.documents {
            
            let data = document.data()
            
            let name = data["name"] as? String
            let alive = data["alive"] as? Bool
            let dateCreated = data["date_created"] as? Date
            let currentGame = data["current_game"] as? String
            let userId = data["user_id"] as? String
            
            players.append(Player(userId: userId!, alive: alive!, name: name!, dateCreated: dateCreated, currentGame: currentGame))
        }
        
        return players
    }
    
    func addPlayer(user: DBUser) async throws {
        
        let playerData: [String:Any] = [
            "user_id" : user.userId,
            "alive" : true,
            "name" : user.name,
            "date_created" : Timestamp(),
        ]
        
        try await Firestore.firestore().collection("games").document(user.currentGame!)
            .collection("players").document(user.userId).setData(playerData, merge: true)
    }
    
    func setRole(player: Player, role: String) async throws {
        let data: [String:Any] = [
            "role" : role
        ]
        try await Firestore.firestore().collection("games").document(player.currentGame!)
            .collection("players").document(player.userId).updateData(data)
    }
    
}
