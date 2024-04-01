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
    var isDay: Bool
    let dateCreated: Date?
}

struct Player: Hashable {
    let userId: String
    var isAlive: Bool
    let name: String
    let dateCreated: Date?
    let currentGame: String?
}

final class GameDatabaseManager {
    
    static let shared = GameDatabaseManager()
    private init() { }
    
    func createNewGame(gameId: String) async throws {
        let userData: [String:Any] = [ //might need to be var
            "game_id" : gameId,
            "is_day" : false,
            "date_created" : Timestamp(),
        ]
        try await Firestore.firestore().collection("games").document(gameId).setData(userData, merge: false)
    }
    //fix exclamation marks
    func getGame(gameId: String) async throws -> Game {
        let snapshot = try await Firestore.firestore().collection("games").document(gameId).getDocument()
        
        guard let data = snapshot.data(), let gameId = data["game_id"] as? String else {
            throw URLError(.badServerResponse)
        }
        
        let isDay = data["is_day"] as? Bool
        let dateCreated = data["date_created"] as? Date
        
        return Game(gameId: gameId, isDay: isDay!, dateCreated: dateCreated)
    }
    
    func getAllPlayers(gameId: String) async throws -> [Player] {
        let snapshot = try await Firestore.firestore().collection("games").document(gameId).collection("players").getDocuments()
        
        var players: [Player] = []
        for document in snapshot.documents {
            
            let data = document.data()
            
            let name = data["name"] as? String ?? "<not found>"
            let isAlive = data["is_alive"] as? Bool ?? true
            let dateCreated = data["date_created"] as? Date ?? Date(timeIntervalSinceNow: 0)
            let currentGame = data["current_game"] as? String ?? "<not found>"
            let userId = data["user_id"] as? String ?? "<not found>"
            
            players.append(Player(userId: userId, isAlive: isAlive, name: name, dateCreated: dateCreated, currentGame: currentGame))
        }
        
        return players
    }
    
    func addPlayer(user: DBUser) async throws {
        
        let playerData: [String:Any] = [
            "user_id" : user.userId,
            "is_alive" : true,
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
