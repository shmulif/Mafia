//
//  LocalGamePlayManager.swift
//  mafia
//
//  Created by Shmuli Feld on 4/14/24.
//

import Foundation
import SwiftUI

final class LocalGamePlayManager {
    
    static let shared = LocalGamePlayManager()
    private init() { }
    
    
    //MARK: Moderator Functions
    
    func killIfNeededAndCalculateWinnersNight(gameId: String) async throws {
        let shot = try await GameDatabaseManager.shared.getShot(gameId: gameId)
        let saved = try await GameDatabaseManager.shared.getSaved(gameId: gameId)
        if shot == saved {
            try await GameDatabaseManager.shared.setRecentlyKilledToNoOne(gameId: gameId)
        } else {
            try await GameDatabaseManager.shared.kill(gameId: gameId, userId: shot)
            try? await GameDatabaseManager.shared.calculateAndSetWinner(gameId: gameId)
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
    
    func addMafiMembers(gameId: String, players: [Player]) async {
        var hostWasSet = false
        for player in players {
            if player.role == "mafia" {
                try? await GameDatabaseManager.shared.addMafiaMember(gameId: gameId, player: player)
                if !hostWasSet {
                    try? await GameDatabaseManager.shared.setAsMafiaHost(gameId: gameId, player: player)
                    hostWasSet = true
            }
        }
        
    }
        
    }
    //MARK: Host_Mafia Functions
    
    func checkIfMafiaAreDoneChoosing(gameId: String, mafiaMembers: [MafiaMember]) -> Bool {
        
        if mafiaMembers.count < 1 {
            print("error, no mafia members found")
            return false
        }
        
        for member in mafiaMembers {
            if member.nominated_to_kill == "" {
                return false
            }
        }
        
        return true
        
    }
    
    func checkIfMafiaChoseSamePerson(gameId: String, mafiaMembers: [MafiaMember]) -> Bool {
        if mafiaMembers.count < 1 {
            print("error, no mafia members found")
            return false
        }
        
        let reference = mafiaMembers[0].nominated_to_kill
        for member in mafiaMembers {
            if member.nominated_to_kill != reference {
                return false
            }
        }
        
        return true
        
    }
    
    func setMafiaVotesMatchingStatusAndSetDoneStatus(gameId: String, players: [Player], mafiaMembers: [MafiaMember]) async {
        let mafiaChoseSamePerson = self.checkIfMafiaChoseSamePerson(gameId: gameId, mafiaMembers: mafiaMembers)
//        try? await GameDatabaseManager.shared.setMafiaVotesMatch(gameId: gameId, inputBool: mafiaChoseSamePerson)
        if mafiaChoseSamePerson {
            let victimId = mafiaMembers[0].nominated_to_kill
            try? await GameDatabaseManager.shared.mafiaShoot(gameId: gameId, userId: victimId ?? "<No id found>")
            try? await GameDatabaseManager.shared.resetAllMafiaVotes(gameId: gameId, players: players, mafiaMembers: mafiaMembers)
            try? await GameDatabaseManager.shared.setMafiaAsDone(gameId: gameId)
        }
    }
    
    //MARK: Day Functions
    
    //moderator
    func checkIfDoneVoting1(players: [Player]) -> Bool {
        print("checking if done voting:")
        var doneVoting = true
        for player in players {
            print(player.name)
            print("done voting:")
            print(player.done_voting)
            if player.done_voting == false {
                doneVoting = false
                break
            }
        }
        return doneVoting
    }
    
    func checkIfDoneVoting2(players: [Player], donePlayers: [Player]) -> Bool {
        return donePlayers.count == players.count
    }
    
    func calculateVotes(players: [Player]) -> String? {
        print("calculating votes")
        var mostVotes: Int = Int(UInt.min)
        var personWithMostVotes: String = ""
        var tied: Bool = false
        //get person with most votes
        for player in players {
            if mostVotes < player.voteCount ?? Int(UInt.min) {
                mostVotes = player.voteCount ?? mostVotes
                personWithMostVotes = player.user_id
                print(personWithMostVotes)
            }
        }
        //check for ties
        for player in players {
            if player.user_id != personWithMostVotes && player.voteCount == mostVotes {
                tied = true
                break
            }
        }
        
        if tied {
            return nil
        } else {
            return personWithMostVotes
        }
    }
    
    func killIfNeededAndCalculateWinnersDay(gameId: String, players: [Player]) async throws {
        print("starting end of day function")
        let personToKill = self.calculateVotes(players: players)
        //print(personToKill)
        if personToKill == nil {
            try await GameDatabaseManager.shared.setRecentlyKilledToNoOne(gameId: gameId)
            try await GameDatabaseManager.shared.resetAllPlayerVotes(gameId: gameId, players: players)
        } else {
            try await GameDatabaseManager.shared.kill(gameId: gameId, userId: personToKill ?? "<victim not found>")
            try? await GameDatabaseManager.shared.calculateAndSetWinner(gameId: gameId)
            try await GameDatabaseManager.shared.resetAllPlayerVotes(gameId: gameId, players: players)
        }
        try await GameDatabaseManager.shared.resetCylceClock(gameId: gameId)
        try? await GameDatabaseManager.shared.setAsNight(gameId: gameId)
    }
    
}
