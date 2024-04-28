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
    var detectiveIsDone: Bool?
    var doctorIsDone: Bool?
    let gameId: String?
    var isDay: Bool?
    let gameStarted: Date?
    var mafiaAreDone: Bool?
    var mafiaHost: String?
    //var mafiaFinnishedChoosing: Bool?
    var mafiaUpdatedVote: Bool?
    var mafiaVotesMatch: Bool?
    var recentlyKilled: String?
    var saved: String?
    var shot: String?
    var winningTeam: String?
    var cycleStarted: Date?
}

struct Player: Hashable, Decodable {
    let currentGame: String?
    var done_voting: Bool?
    var isAlive: Bool?
    let joined: Date?
    let name: String
    var role: String?
    var selected_by: String?
    let user_id: String
    var voteCount: Int?
    var votedFor: String?
}

struct MafiaMember: Hashable, Decodable {
    
    var done_nominating: Bool?
    var is_alive: Bool?
    let joined: Date?
    let name: String
    var nominated_to_kill: String?
    let user_id: String
    
}


struct Message: Hashable, Decodable {
    
    let content: String
    let name: String
    let user_id: String?
    let time_sent: Date?

}

final class GameDatabaseManager {
    
    static let shared = GameDatabaseManager()
    private init() { }
    
    //MARK: New Game Functions
    
    //general setup
    func createNewGame(gameId: String) async throws {
        let userData: [String:Any] = [ //might need to be var
            "detective_is_done" : false,
            "doctor_is_done" : false,
            "game_id" : gameId,
            "is_day" : false,
            "game_started" : Timestamp(),
            "mafia_are_done" : false,
            "mafia_host" : "",
            "mafia_updated_vote" : false,
            "mafia_votes_match" : true,
            "recently_killed" : "",
            "saved" : "",
            "shot" : "",
            "updated_vote" : true,
            "winning_team" : "",
            "cycle_started" : Timestamp(),
        ]
        try await Firestore.firestore().collection("games").document(gameId).setData(userData, merge: false)
    }
    
    func addPlayer(user: DBUser) async throws {
        
        let playerData: [String:Any] = [
            "user_id" : user.userId,
            "name" : user.name,
            "role" : "",
            "is_alive" : true,
            "selected_by" : "",
            "voted_for" : "",
            "vote_count" : 0,
            "done_voting" : false,
            "joined" : Timestamp(),
        ]
        
        try await Firestore.firestore().collection("games").document(user.currentGame!)
            .collection("players").document(user.userId).setData(playerData, merge: true)
    }
    
    func setAsHost(user: DBUser) async throws {
        
        let hostData: [String:Any] = [
            "host" : user.userId,
        ]
        
        try await Firestore.firestore().collection("games").document(user.currentGame!).setData(hostData, merge: true)
    }
    
    func getAllPlayers(gameId: String) async throws -> [Player] {
        let snapshot = try await Firestore.firestore().collection("games").document(gameId).collection("players").getDocuments()
        
        var players: [Player] = []
        for document in snapshot.documents {
            
            let data = document.data()
            
            let name = data["name"] as? String
            let isAlive = data["is_alive"] as? Bool
            let joined = data["joined"] as? Date
            let role = data["role"] as? String
            let currentGame = data["role"] as? String
            let selectedBy = data["selected_by"] as? String
            let votedFor = data["voted_for"] as? String
            let voteCount = data["vote_count"] as? Int
            let userId = data["user_id"] as? String
            let doneVoting = data["done_voting"] as? Bool
            
            players.append(Player(currentGame: currentGame, done_voting: doneVoting, isAlive: isAlive, joined: joined, name: name ?? "<no name found>", role: role, selected_by: selectedBy, user_id: userId ?? "<no user id found>", voteCount: voteCount, votedFor: votedFor))
        }
        
        return players
    }
    
    func getLivingPlayers(gameId: String) async throws -> [Player] {
        let snapshot = try await Firestore.firestore().collection("games").document(gameId).collection("players").whereField("is_alive", isEqualTo: true).getDocuments()
        
        var players: [Player] = []
        for document in snapshot.documents {
            
            let data = document.data()
            
            let name = data["name"] as? String
            let isAlive = data["is_alive"] as? Bool
            let joined = data["joined"] as? Date
            let role = data["role"] as? String
            let currentGame = data["role"] as? String
            let selectedBy = data["selected_by"] as? String
            let votedFor = data["voted_for"] as? String
            let voteCount = data["vote_count"] as? Int
            let userId = data["user_id"] as? String
            let doneVoting = data["done_voting"] as? Bool
            
            players.append(Player(currentGame: currentGame, done_voting: doneVoting, isAlive: isAlive, joined: joined, name: name ?? "<no name found>", role: role, selected_by: selectedBy, user_id: userId ?? "<no user id found>", voteCount: voteCount, votedFor: votedFor))
        }
        
        return players
    }
    
    func getRole(gameId: String, userId: String) async throws -> String {
        let snapshot = try await Firestore.firestore().collection("games").document(gameId).collection("players").document(userId).getDocument()
        
        guard let data = snapshot.data(), let role = data["role"] as? String else {
            throw URLError(.badServerResponse)
        }
        return role

    }
    
    //not used
    func getGame(gameId: String) async throws -> Game {
        let snapshot = try await Firestore.firestore().collection("games").document(gameId).getDocument()
        
        guard let data = snapshot.data(), let gameId = data["game_id"] as? String else {
            throw URLError(.badServerResponse)
        }
        
        let detectiveIsDone = data["detective_is_done"] as? Bool
        let doctorIsDone = data["doctor_is_done"] as? Bool
        let isDay = data["is_day"] as? Bool
        let gameStarted = data["game_started"] as? Date
        let mafiaAreDone = data["mafia_are_done"] as? Bool
        let mafiaHost = data["mafia_host"] as? String
        let mafiaUpdatedVote = data["mafia_updated_vote"] as? Bool
        let mafiaVotesMatch = data["mafia_votes_match"] as? Bool
        let recentlyKilled = data["recently_killed"] as? String
        let saved = data["saved"] as? String
        let shot = data["shot"] as? String
        let winningTeam = data["winning_team"] as? String
        let cycleStarted = data["cycle_started"] as? Date
        
        return Game(detectiveIsDone: detectiveIsDone, doctorIsDone: doctorIsDone, gameId: gameId, isDay: isDay, gameStarted: gameStarted, mafiaAreDone: mafiaAreDone, mafiaHost: mafiaHost, mafiaUpdatedVote: mafiaUpdatedVote, mafiaVotesMatch: mafiaVotesMatch, recentlyKilled: recentlyKilled, saved: saved, shot: shot, winningTeam: winningTeam, cycleStarted: cycleStarted)
    }
    
    //MARK: Listener Functions
    private var livingPlayerListener: ListenerRegistration? = nil
    
    func removeListenerForLivingPlayers(){
        self.livingPlayerListener?.remove()
    }
    
    private var playerListener: ListenerRegistration? = nil
    
    func removeListenerForPlayers(){
        self.playerListener?.remove()
    }
    
    private var dayListener: ListenerRegistration? = nil
    
    func removeListenerDay(){
        self.dayListener?.remove()
    }
    
    private var updatedVoteListener: ListenerRegistration? = nil
    
    func removeListenerForUpdatedVote(){
        self.updatedVoteListener?.remove()
    }
    
    private var everyoneIsDone: ListenerRegistration? = nil
    
    func removeListenerEveryoneIsDone(){
        self.everyoneIsDone?.remove()
    }
    
    func addListenerForLivingPlayers(gameId: String, completion: @escaping (_ players: [Player]) -> Void) {
        
        self.livingPlayerListener = Firestore.firestore().collection("games").document(gameId).collection("players").whereField("is_alive", isEqualTo: true).addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("No document")
                return
            }
            
            //lengthy version
            //            let players: [Player] = documents.compactMap { documentSnaphot in
            //                return try? documentSnaphot.data(as: Player.self)
            //            }
            
            //this is not finding players ever since i made user id not optional (for some reoson it may have only been retrieving names)
            //fixed it by changing Player.userId to player.user_id
            
            let players: [Player] = documents.compactMap({ try? $0.data(as: Player.self) })
            completion(players)
        }
    }
    
    func addListenerForPlayers(gameId: String, completion: @escaping (_ players: [Player]) -> Void) {
        
        self.playerListener = Firestore.firestore().collection("games").document(gameId).collection("players").addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("No document")
                return
            }
            
            //lengthy version
            //            let players: [Player] = documents.compactMap { documentSnaphot in
            //                return try? documentSnaphot.data(as: Player.self)
            //            }
            
            //this is not finding players ever since i made user id not optional (for some reoson it may have only been retrieving names)
            //fixed it by changing Player.userId to player.user_id
            
            let players: [Player] = documents.compactMap({ try? $0.data(as: Player.self) })
            completion(players)
        }
    }
    
    func addListenerForDay(gameId: String, completion: @escaping (_ day: Bool?) -> Void) {
        
        self.dayListener = Firestore.firestore().collection("games").document(gameId).addSnapshotListener { querySnapshot, error in
            guard let data = querySnapshot?.data() else {
                print("game not found in addListenerForDay")
                return
            }
            let day = data["is_day"] as? Bool ?? false
            completion(day)
        }
    }
    
    func addListenerForEveryoneIsDone(gameId: String, completion: @escaping (_ everyoneIsDone: Bool?) -> Void) {
        
        self.everyoneIsDone = Firestore.firestore().collection("games").document(gameId).addSnapshotListener { querySnapshot, error in
            guard let data = querySnapshot?.data() else {
                print("game not found in addListenerForEveryoneIsDone")
                return
            }
            
            let mafiaAreDone = data["mafia_are_done"] as? Bool ?? false
            let doctorIsDone = data["doctor_is_done"] as? Bool ?? false
            let detectiveIsDone = data["detective_is_done"] as? Bool ?? false
            
            let everyoneIsDone = mafiaAreDone && doctorIsDone && detectiveIsDone
            completion(everyoneIsDone)
        }
        
    }
    
    
    func addListenerForUpdatedVote(gameId: String, completion: @escaping (_ mafiaUpdatedVote: Bool?) -> Void) {
        
        self.updatedVoteListener = Firestore.firestore().collection("games").document(gameId).addSnapshotListener { querySnapshot, error in
            guard let data = querySnapshot?.data() else {
                print("game not found in UpdatedVote")
                return
            }
            let mafiaUpdatedVote = data["updated_vote"] as? Bool ?? true
            completion(mafiaUpdatedVote)
        }
    }
    
    //MARK: Moderator Functions
    func setAsMafiaHost(gameId: String, player: Player) async throws {
        
        let data: [String:Any] = [
            "mafia_host" : player.user_id,
        ]
        
        try await Firestore.firestore().collection("games").document(gameId).setData(data, merge: true)
    }
    
    func getPlayerName(gameId: String, userId: String) async throws -> String {
        let snapshot = try await Firestore.firestore().collection("games").document(gameId).collection("players").whereField("user_id", isEqualTo: userId).getDocuments()
        
        var name = ""
        
        for document in snapshot.documents {
            
            let data = document.data()
            name = data["name"] as? String ?? "no name found"
            
        }
        
        return name
    }
    
    func getHostId(gameId: String) async throws -> String {
        let snapshot = try await Firestore.firestore().collection("games").document(gameId).getDocument()
        
        let data = snapshot.data()
        
        let host = data?["host"] as? String
        
        return host ?? "<no host found>"
    }
    
    
    func getShot(gameId: String) async throws -> String {
        let snapshot = try await Firestore.firestore().collection("games").document(gameId).getDocument()
        
        let data = snapshot.data()
        
        let shot = data?["shot"] as? String
        
        return shot ?? "<no shot found>"
    }
    
    func getSaved(gameId: String) async throws -> String {
        let snapshot = try await Firestore.firestore().collection("games").document(gameId).getDocument()
        
        let data = snapshot.data()
        
        let saved = data?["saved"] as? String
        
        return saved ?? "<no saved found>"
    }
    
    func updateAllPlayerRoles(gameId: String, players: [Player]) async throws {
        
        for player in players {
            
            let data: [String: String] = [
                "role" : player.role ?? "error: no role found"
            ]
            
            try await Firestore.firestore().collection("games").document(gameId)
                .collection("players").document(player.user_id).updateData(data)
        }
        
    }
    
    func addMafiaMember(gameId: String, player: Player) async throws {
        
        let memberData: [String:Any] = [
            "user_id" : player.user_id,
            "name" : player.name,
            "is_alive" : true,
            "nominated_to_kill" : "",
            "done_nominating" : false,
            "joined" : Timestamp(),
        ]
        
        try await Firestore.firestore().collection("games").document(gameId)
            .collection("mafia_members").document(player.user_id).setData(memberData, merge: true)
        
    }
    
    
    func calculateAndSetWinner(gameId: String) async throws {
        
        let snapshot1 = try await Firestore.firestore().collection("games").document(gameId).collection("players").whereField("role", isNotEqualTo: "mafia").whereField("is_alive", isEqualTo: true).getDocuments()
        let nonMafiaCount = snapshot1.count
        print("non_mafia count:")
        print(nonMafiaCount)
        let snapshot2 = try await Firestore.firestore().collection("games").document(gameId).collection("mafia_members").whereField("is_alive", isEqualTo: true).getDocuments()
        let mafiaCount = snapshot2.count
        print("mafia count:")
        print(mafiaCount)
        
        if nonMafiaCount <= mafiaCount {
            let winnerData: [String:Any] = [
                "winning_team" : "mafia"
            ]
            try await Firestore.firestore().collection("games").document(gameId).updateData(winnerData)
        } else if mafiaCount == 0 {
            let winnerData: [String:Any] = [
                "winning_team" : "non-mafia"
            ]
            try await Firestore.firestore().collection("games").document(gameId).updateData(winnerData)
        }
    }
    
    func setAsNight(gameId: String) async throws {
        let data: [String:Any] = [
            "is_day" : false
        ]
        try await Firestore.firestore().collection("games").document(gameId).updateData(data)
    }
    
    func setAsDay(gameId: String) async throws {
        let data: [String:Any] = [
            "is_day" : true
        ]
        try await Firestore.firestore().collection("games").document(gameId).updateData(data)
    }
    
    func kill(gameId: String, userId: String) async throws {
        let data1: [String:Any] = [
            "recently_killed" : userId
        ]
        let data2: [String:Any] = [
            "is_alive" : false
        ]
        let data3: [String:Any] = [
            "is_alive" : false,
            //not entirely neccacery to reset because data is not taken from dead mafia but may prevent mistakes
            "nominated_to_kill" : "",
            "done_nominating" : false,
        ]
        
        try await Firestore.firestore().collection("games").document(gameId).updateData(data1)
        try await Firestore.firestore().collection("games").document(gameId).collection("players").document(userId).updateData(data2)
        
        let role = try await getRole(gameId: gameId, userId: userId)
        if role == "mafia" {
            try await Firestore.firestore().collection("games").document(gameId).collection("mafia_members").document(userId).updateData(data3)
        }
    }
    
    
    //call at beggining of night and beginning of day
    func resetCylceClock(gameId: String) async throws {
        let data: [String:Any] = [
            "cycle_started" : Timestamp()
        ]
        try await Firestore.firestore().collection("games").document(gameId).updateData(data)
    }
    //resetAllPlayerVoteCountAndSelectedby should be called at beginning and end of day, reset "voted_for" can be called once every 24 hours but doesnt hurt to call extra
    //can be reset 24 hours bc mafi votes are reset seperatly
    
    //resets "vote_count" and "selected_by"
    func resetAllPlayerVoteCountAndSelectedby(gameId: String, players: [Player]) async throws {
        
        for player in players {
            
            let data: [String: Any] = [
                "vote_count" : 0,
                "selected_by" : "",
            ]
            
            try await Firestore.firestore().collection("games").document(gameId)
                .collection("players").document(player.user_id).updateData(data)
        }
        
    }
    //resets both "vote_count" and "voted_for"
    func resetAllPlayerVotes(gameId: String, players: [Player]) async throws {
        
        for player in players {
            
            let data: [String: Any] = [
                "vote_count" : 0,
                "voted_for" : "",
                "selected_by" : "",
            ]
            
            
            try await Firestore.firestore().collection("games").document(gameId)
                .collection("players").document(player.user_id).updateData(data)
        }
        
    }
    
    //call at end of day
    func resetFields(gameId: String) async throws {
        //not sure if we should reset "recently_killed"
        let data: [String:Any] = [
            "detective_is_done" : false,
            "doctor_is_done" : false,
            "mafia_are_done" : false,
            "mafia_updated_vote" : false,
            "mafia_votes_match" : true,
            "updated_vote" : false,
            "saved" : "",
            "shot" : "",
        ]
        try await Firestore.firestore().collection("games").document(gameId).updateData(data)
        
    }
    
    func setRecentlyKilledToNoOne(gameId: String) async throws {
        print("setting recently killed to no one")
        let data: [String:Any] = [
            "recently_killed" : ""
        ]
        try await Firestore.firestore().collection("games").document(gameId).updateData(data)
    }
    
    //not used
    func setIndividualRole(player: Player, role: String) async throws {
        let data: [String:Any] = [
            "role" : role
        ]
        try await Firestore.firestore().collection("games").document(player.currentGame ?? "no game found")
            .collection("players").document(player.user_id).updateData(data)
    }
    
    //MARK: Mafia Functions
    
    //mafia host functions
    func mafiaShoot(gameId: String, userId: String) async throws {
        let data: [String:Any] = [
            "shot" : userId
        ]
        try await Firestore.firestore().collection("games").document(gameId).updateData(data)
    }
    func setMafiaAsDoneVoting(gameId: String, userId: String) async {
        let data: [String:Any] = [
            "done_nominating" : true,
        ]
        
        try? await Firestore.firestore().collection("games").document(gameId).collection("mafia_members").document(userId).updateData(data)

    }
    func setMafiaAsDone(gameId: String) async throws {
        let data: [String:Bool] = [
            "mafia_are_done" : true
        ]
        try await Firestore.firestore().collection("games").document(gameId).updateData(data)
    }
    
    //Mafia general functions
    func getMafiaHost(gameId: String) async throws -> String {
        
        let snapshot = try await Firestore.firestore().collection("games").document(gameId).getDocument()
        
        guard let data = snapshot.data(), let mafiaHost = data["mafia_host"] as? String else {
            throw URLError(.badServerResponse)
        }
        
        return mafiaHost
    }
    
    func setMafiaUpdatedVoteToFalse(gameId: String) async throws {
        let data: [String:Any] = [
            "mafia_updated_vote" : false
        ]
        try await Firestore.firestore().collection("games").document(gameId).updateData(data)
    }
    
    func setMafiaVotesMatch(gameId: String, inputBool: Bool) async throws {
        let data: [String:Any] = [
            "mafia_votes_match" : inputBool
        ]
        try await Firestore.firestore().collection("games").document(gameId).updateData(data)
    }
    func mafiaUnvote(gameId: String, userId: String) async throws {
        
        let snapshot1 = try await Firestore.firestore().collection("games").document(gameId).collection("mafia_members").document(userId).getDocument()
        
        let data1 = snapshot1.data()
    
        let previousVote = data1?["nominated_to_kill"] as? String
        
        let input: [String:Any] = [
            "vote_count" : FieldValue.increment(Int64(-1)),
        ]
        
        if previousVote != "" {
            try await Firestore.firestore().collection("games").document(gameId).collection("players").document(previousVote ?? "<no id found>").updateData(input)
        }
        
    }
    func mafiaVoteAgainst(gameId: String, voterId: String, victimId: String) async throws {
        
        try await mafiaUnvote(gameId: gameId, userId: voterId)
        let data1: [String:Any] = [
            "nominated_to_kill" : victimId,
            "done_nominating" : true,
        ]
        let data2: [String:Any] = [
            "vote_count" : FieldValue.increment(Int64(1)),
            "selected_by" : voterId,
        ]
        let data3: [String:Any] = [
            "mafia_updated_vote" : true
        ]
        
        try await Firestore.firestore().collection("games").document(gameId).collection("mafia_members").document(voterId).updateData(data1)
        try await Firestore.firestore().collection("games").document(gameId).collection("players").document(victimId).updateData(data2)
        try await Firestore.firestore().collection("games").document(gameId).updateData(data3)
    }
    
    func getAllMafiaMembers(gameId: String) async throws -> [MafiaMember] {
        let snapshot = try await Firestore.firestore().collection("games").document(gameId).collection("mafia_members").getDocuments()
        
        var mafiaMembers: [MafiaMember] = []
        for document in snapshot.documents {
            
            let data = document.data()
            
            let done_nominating = data["done_nominating"] as? Bool
            let is_alive = data["is_alive"] as? Bool
            let joined = data["joined"] as? Date
            let name = data["name"] as? String ?? "<no name>"
            let nominated_to_kill = data["nominated_to_kill"] as? String
            let user_id = data["user_id"] as? String ?? "<no user_id>"
            
            mafiaMembers.append(MafiaMember(done_nominating: done_nominating, is_alive: is_alive, joined: joined, name: name, nominated_to_kill: nominated_to_kill, user_id: user_id))
        }
        
        return mafiaMembers
    }
    func resetAllMafiaVotes(gameId: String, players: [Player], mafiaMembers: [MafiaMember]) async throws {
        
        for player in players {
            
            let data: [String: Any] = [
                "vote_count" : 0,
                "selected_by" : "",
            ]
            
            try await Firestore.firestore().collection("games").document(gameId)
                .collection("players").document(player.user_id).updateData(data)
        }
        
        for member in mafiaMembers {
            
            let data: [String: Any] = [
                "nominated_to_kill" : "",
                "done_nominating" : false,
            ]
            
            try await Firestore.firestore().collection("games").document(gameId)
                .collection("mafia_members").document(member.user_id).updateData(data)
        }
        
    }
    
    func sendMafiaMessage(user: DBUser, content: String) async throws {
        
        let messageData: [String:Any] = [
            "content" : content,
            "name" : user.name,
            "time_sent" : Timestamp(),
            "user_id" : user.userId,
        ]
        
        try await Firestore.firestore().collection("games").document(user.currentGame!)
            .collection("mafia_chat").document().setData(messageData, merge: true)
        
    }
    
    //Mafia Listeners
    private var MafiaMembersListener: ListenerRegistration? = nil
    
    private var MafiaUpdatedVoteListener: ListenerRegistration? = nil
    
    private var MafiaVotesMatchListener: ListenerRegistration? = nil
    
    private var MafiaAreDoneListener: ListenerRegistration? = nil
    
    private var mafiaChatListener: ListenerRegistration? = nil
    
    
//    private var LivingMafiaMembersListener: ListenerRegistration? = nil
//    
//    private var MafiDoneNominatingListener: ListenerRegistration? = nil
//    
//    private var LivingMafiaCountListener: ListenerRegistration? = nil
//    
//    private var MafiDoneNominatingCountListener: ListenerRegistration? = nil
//    
//    private var LML: ListenerRegistration? = nil
//    private var MDL: ListenerRegistration? = nil

    
    func removeListenerForMafiaMembers(){
        self.MafiaMembersListener?.remove()
    }
    
    func removeListenerForMafiaUpdatedVote(){
        self.MafiaUpdatedVoteListener?.remove()
    }

    func removeListenerForMafiaVotesMatch(){
        self.MafiaVotesMatchListener?.remove()
    }
    
    func removeListenerForMafiaAreDone(){
        self.MafiaAreDoneListener?.remove()
    }
    
    func removeListenerForMafiaChat(){
        self.mafiaChatListener?.remove()
    }
    
//    func removeListenerForAllLivingMafia(){
//        self.LivingMafiaMembersListener?.remove()
//    }
//    
//    
//    func removeBothCountListeners(){
//        self.MafiDoneNominatingListener?.remove()
//        self.LivingMafiaCountListener?.remove()
//    }
//    
//    func removeListenerForFinnishedMafia(){
//        self.MafiDoneNominatingListener?.remove()
//    }
//    
//    func removeListenerForAllMafiaFinnished(){
//        self.LML?.remove()
//        self.MDL?.remove()
//    }
    
    func addListenerForMafiaMembers(gameId: String, completion: @escaping (_ mafiaMembers: [MafiaMember]) -> Void) {
        
        
        self.MafiaMembersListener =  Firestore.firestore().collection("games").document(gameId).collection("mafia_members").whereField("is_alive", isEqualTo: true).addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("No document")
                return
            }
            
            
            let mafiaMembers: [MafiaMember] = documents.compactMap({ try? $0.data(as: MafiaMember.self) })
            
            
            completion(mafiaMembers)
            
        }
    }
    
        func addListenerForMafiaUpdatedVote(gameId: String, completion: @escaping (_ mafiaUpdatedVote: Bool?) -> Void) {
            
            self.MafiaUpdatedVoteListener = Firestore.firestore().collection("games").document(gameId).addSnapshotListener { querySnapshot, error in
                guard let data = querySnapshot?.data() else {
                    print("game not found in MafiaUpdatedVote")
                    return
                }
                let mafiaUpdatedVote = data["mafia_updated_vote"] as? Bool ?? true
                completion(mafiaUpdatedVote)
            }
        }
        
        func addListenerForMafiaVotesMatch(gameId: String, completion: @escaping (_ mafiaVotesMatch: Bool?) -> Void) {
            
            self.MafiaVotesMatchListener = Firestore.firestore().collection("games").document(gameId).addSnapshotListener { querySnapshot, error in
                guard let data = querySnapshot?.data() else {
                    print("game not found in MafiaUpdatedVote")
                    return
                }
                let mafiaVotesMatch = data["mafia_votes_match"] as? Bool ?? true
                completion(mafiaVotesMatch)
            }
        }
        
        func addListenerForMafiaAreDone(gameId: String, completion: @escaping (_ mafiaAreDone: Bool?) -> Void) {
            
            self.MafiaAreDoneListener = Firestore.firestore().collection("games").document(gameId).addSnapshotListener { querySnapshot, error in
                guard let data = querySnapshot?.data() else {
                    print("game not found in MafiaUpdatedVote")
                    return
                }
                let mafiaAreDone = data["mafia_are_done"] as? Bool ?? false
                completion(mafiaAreDone)
            }
        }
        
        func addListenerForMafiaChat(gameId: String, completion: @escaping (_ players: [Message]) -> Void) {
            
            self.mafiaChatListener = Firestore.firestore().collection("games").document(gameId).collection("mafia_chat").order(by: "time_sent").addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("No document")
                    return
                }
                
                //lengthy version
                //                        let livingMafia: [Message] = documents.compactMap { documentSnaphot in
                //                            return try? documentSnaphot.data(as: Message.self)
                //                        }
                
                
                
                let messages: [Message] = documents.compactMap({ try? $0.data(as: Message.self) })
                completion(messages)
            }
        }
        
//        func addListenerForLivingMafiaCount(gameId: String, completion: @escaping (_ livingMafiaCount: Int) -> Void) {
//            
//            
//            self.LivingMafiaCountListener =  Firestore.firestore().collection("games").document(gameId).collection("mafia_members").whereField("is_alive", isEqualTo: true).addSnapshotListener { querySnapshot, error in
//                guard let documents = querySnapshot?.documents else {
//                    print("No document")
//                    return
//                }
//                
//                //lengthy version
//                //                        let livingMafia: [Mafia] = documents.compactMap { documentSnaphot in
//                //                            return try? documentSnaphot.data(as: Mafia.self)
//                //                        }
//                
//                
//                
//                let mafiaMembers: [MafiaMember] = documents.compactMap({ try? $0.data(as: MafiaMember.self) })
//                let mafiaCount = mafiaMembers.count
//                
//                
//                completion(mafiaCount)
//                
//            }
//            
//            
//        }
//        
//        
//        func addListenerForDoneNominatingMafiaCount(gameId: String, completion: @escaping (_ livingMafiaCount: Int) -> Void) {
//            
//            
//            self.MafiDoneNominatingCountListener =  Firestore.firestore().collection("games").document(gameId).collection("mafia_members").whereField("done_nominating", isEqualTo: true).whereField("is_alive", isEqualTo: true).addSnapshotListener { querySnapshot, error in
//                guard let documents = querySnapshot?.documents else {
//                    print("No document")
//                    return
//                }
//                
//                //lengthy version
//                //                        let livingMafia: [Mafia] = documents.compactMap { documentSnaphot in
//                //                            return try? documentSnaphot.data(as: Mafia.self)
//                //                        }
//                
//                
//                
//                let mafiaMembers: [MafiaMember] = documents.compactMap({ try? $0.data(as: MafiaMember.self) })
//                let mafiaCount = mafiaMembers.count
//                
//                
//                completion(mafiaCount)
//                
//            }
//            
//        }
//        
//        func addListenerForLivingMafiaMembers(gameId: String, completion: @escaping (_ mafiaMembers: [MafiaMember]) -> Void) {
//            
//            
//            self.LivingMafiaMembersListener =  Firestore.firestore().collection("games").document(gameId).collection("mafia_members").whereField("is_alive", isEqualTo: true).addSnapshotListener { querySnapshot, error in
//                guard let documents = querySnapshot?.documents else {
//                    print("No document")
//                    return
//                }
//                
//                //lengthy version
//                //                        let livingMafia: [Mafia] = documents.compactMap { documentSnaphot in
//                //                            return try? documentSnaphot.data(as: Mafia.self)
//                //                        }
//                
//                
//                
//                let mafiaMembers: [MafiaMember] = documents.compactMap({ try? $0.data(as: MafiaMember.self) })
//                
//                
//                completion(mafiaMembers)
//                
//            }
//            
//            
//        }
//        
//        
//        func addListenerForDoneNominatingMafiaMembers(gameId: String, completion: @escaping (_ mafiaMembers: [MafiaMember]) -> Void) {
//            
//            
//            self.MafiDoneNominatingListener =  Firestore.firestore().collection("games").document(gameId).collection("mafia_members").whereField("done_nominating", isEqualTo: true).whereField("is_alive", isEqualTo: true).addSnapshotListener { querySnapshot, error in
//                guard let documents = querySnapshot?.documents else {
//                    print("No document")
//                    return
//                }
//                
//                //lengthy version
//                //                        let livingMafia: [Mafia] = documents.compactMap { documentSnaphot in
//                //                            return try? documentSnaphot.data(as: Mafia.self)
//                //                        }
//                
//                
//                
//                let mafiaMembers: [MafiaMember] = documents.compactMap({ try? $0.data(as: MafiaMember.self) })
//                
//                
//                completion(mafiaMembers)
//                
//            }
//            
//        }
//        
//        //not sure if this will work might have to impleement local version
//        func addListenerForAllMafiaDoneNominating(gameId: String, completion: @escaping (_ allMafiaAreDone: Bool) -> Void) {
//            
//            
//            self.LML =  Firestore.firestore().collection("games").document(gameId).collection("mafia_members").whereField("is_alive", isEqualTo: true).addSnapshotListener { querySnapshot, error in
//                guard let livingDocuments = querySnapshot?.documents else {
//                    print("No document")
//                    return
//                }
//                
//                self.MDL =  Firestore.firestore().collection("games").document(gameId).collection("mafia_members").whereField("is_alive", isEqualTo: true).whereField("done_nominating", isEqualTo: true).addSnapshotListener { querySnapshot, error in
//                    guard let finnishedDocuments = querySnapshot?.documents else {
//                        print("No document")
//                        return
//                    }
//                    
//                    //lengthy version
//                    //                        let livingMafia: [Mafia] = documents.compactMap { documentSnaphot in
//                    //                            return try? documentSnaphot.data(as: Mafia.self)
//                    //                        }
//                    
//                    
//                    
//                    let livingMafia: [MafiaMember] = livingDocuments.compactMap({ try? $0.data(as: MafiaMember.self) })
//                    let finnishedMafia: [MafiaMember] = finnishedDocuments.compactMap({ try? $0.data(as: MafiaMember.self) })
//                    
//                    let allMafiaAreDone = livingMafia.count == finnishedMafia.count
//                    completion(allMafiaAreDone)
//                    
//                }
//                
//            }
//            
//        }
        
        
        
        //MARK: Detective Functions
        
        //use getRole function from "new game functions" section
        
        func setDetectiveAsDone(gameId: String) async throws {
            let data: [String:Bool] = [
                "detective_is_done" : true
            ]
            try await Firestore.firestore().collection("games").document(gameId).updateData(data)
        }
        
        
        //MARK: Doctor Functions
        
        func save(gameId: String, userId: String) async throws {
            let data: [String:Any] = [
                "saved" : userId
            ]
            try await Firestore.firestore().collection("games").document(gameId).updateData(data)
        }
        
        func setDoctorAsDone(gameId: String) async throws {
            let data: [String:Bool] = [
                "doctor_is_done" : true
            ]
            try await Firestore.firestore().collection("games").document(gameId).updateData(data)
        }
        
        
        //MARK: Day Functions
    func checkIfAlive(gameId: String, userId: String) async throws -> Bool {
        let snapshot = try await Firestore.firestore().collection("games").document(gameId).collection("players").document(userId).getDocument()
        
        guard let data = snapshot.data(), let isAlive = data["is_alive"] as? Bool else {
            throw URLError(.badServerResponse)
        }
        return isAlive

    }
    
    func setUpdatedVoteToFalse(gameId: String) async throws {
        let data: [String:Any] = [
            "updated_vote" : false
        ]
        try await Firestore.firestore().collection("games").document(gameId).updateData(data)
    }
    
        func voteAgainst(gameId: String, voterId: String, victimId: String) async throws {
            let data1: [String:Any] = [
                "voted_for" : victimId,
                //may set sepearatly if we allow changing votes
                "done_voting" : true
            ]
            let data2: [String:Any] = [
                "vote_count" : FieldValue.increment(Int64(1))
            ]
            let data3: [String:Any] = [
                "updated_vote" : true
            ]
            
            try await Firestore.firestore().collection("games").document(gameId).collection("players").document(voterId).updateData(data1)
            try await Firestore.firestore().collection("games").document(gameId).collection("players").document(victimId).updateData(data2)
            try await Firestore.firestore().collection("games").document(gameId).updateData(data3)
        }
        func getRecentlyKilled(gameId: String) async throws -> String {
            let snapshot = try await Firestore.firestore().collection("games").document(gameId).getDocument()
            
            let data = snapshot.data()
            
            let killed = data?["recently_killed"] as? String
            
            return killed ?? "<no killed found>"
        }
        
        func checkForWinner(gameId: String) async throws -> String? {
            let snapshot = try await Firestore.firestore().collection("games").document(gameId).getDocument()
            
            let data = snapshot.data()
            
            let winningTeam = data?["winning_team"] as? String
            
            if winningTeam == "" {
                return nil
            } else {
                return winningTeam
            }
        }
        
        //MARK: Day Chat Functions
        
//        private var chatListener: ListenerRegistration? = nil
//        
//        
//        func removeListenerForChat(){
//            self.chatListener?.remove()
//        }
        
        func addListenerForChat(gameId: String, completion: @escaping (_ players: [Message]) -> Void) {
            
            //self.chatListener =
            Firestore.firestore().collection("games").document(gameId).collection("chat").order(by: "time_sent").addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("No document")
                    return
                }
                
                //lengthy version
                //                        let livingMafia: [Message] = documents.compactMap { documentSnaphot in
                //                            return try? documentSnaphot.data(as: Message.self)
                //                        }
                
                
                
                let messages: [Message] = documents.compactMap({ try? $0.data(as: Message.self) })
                completion(messages)
            }
        }
        
        func sendMessage(user: DBUser, content: String) async throws {
            
            let messageData: [String:Any] = [
                "content" : content,
                "name" : user.name,
                "time_sent" : Timestamp(),
                "user_id" : user.userId,
            ]
            
            try await Firestore.firestore().collection("games").document(user.currentGame!)
                .collection("mafia_chat").document().setData(messageData, merge: true)
            
        }
        
    }
