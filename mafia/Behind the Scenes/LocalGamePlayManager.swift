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
    
//Make sure that when a mafia is killed his done_nominating is set to false

//    function to check if mafia are done should incorparate:
//    let allMafiaAreDone = livingMafia.count == finnishedMafia.count
}
