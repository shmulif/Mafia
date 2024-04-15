//
//  LocalGamePlayManager.swift
//  mafia
//
//  Created by Shmuli Feld on 4/14/24.
//

import Foundation

final class LocalGamePlayManager {
    
    static let shared = LocalGamePlayManager()
    private init() { }
    
    
    //MARK: Moderator Functions
    
    func killIfNeeded(gameId: String) async throws {
        let shot = try await GameDatabaseManager.shared.getShot(gameId: gameId)
        let saved = try await GameDatabaseManager.shared.getSaved(gameId: gameId)
        if shot == saved {
            try await GameDatabaseManager.shared.setRecentlyKilledToNoOne(gameId: gameId)
        } else {
            try await GameDatabaseManager.shared.kill(gameId: gameId, userId: shot)
        }
        
    }
    
    func assignRoles(players: [Player]) -> [Player]{
        
    var updatedPlayers: [Player] = players
    var roles: [String] = ["mafia","mafia","doctor","detective","civillian","civillian"]
    roles.shuffle()
        
        if players.count != 6 {
            print("error: player count is not 6")
            return updatedPlayers
        }
    
        for i in 0..<6 {
            updatedPlayers[i].role = roles[i]
        }
        
        return updatedPlayers
    }
    
    //MARK: Mafia Functions
    
    
}
