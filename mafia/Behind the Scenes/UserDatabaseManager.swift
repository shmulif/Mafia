//
//  UserManager.swift
//  mafia
//
//  Created by Shmuli Feld on 3/9/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct DBUser {
    let userId: String
    let name: String
    let dateCreated: Date?
    var currentGame: String?
}

final class UserDatabaseManager {
    
    static let shared = UserDatabaseManager()
    private init() { }
    
    func createNewUser(auth: AuthDataResultModel, name: String) async throws {
        let userData: [String:Any] = [ //turorial used var
            "user_id" : auth.uid,
            "name" : name,
            "date_created" : Timestamp(),
            "current_game" : "",
        ]
        try await Firestore.firestore().collection("users").document(auth.uid).setData(userData, merge: false)
    }
    
    func linkUserToGame(auth: AuthDataResultModel, gameId: String) async throws {
        let userData: [String:Any] = [
            "current_game" : gameId,
        ]
        try await Firestore.firestore().collection("users").document(auth.uid).setData(userData, merge: true)
    }
    
    func unlinkUserFromGame(auth: AuthDataResultModel) async throws {
        let userData: [String:Any] = [
            "current_game" : "",
        ]
        try await Firestore.firestore().collection("users").document(auth.uid).updateData(userData)
    }
    
    func getUser(userId: String) async throws -> DBUser {
        let snapshot = try await Firestore.firestore().collection("users").document(userId).getDocument()
        
        guard let data = snapshot.data(), let userId = data["user_id"] as? String else {
            throw URLError(.badServerResponse)
        }
        
        let name = data["name"] as? String
        let dateCreated = data["date_created"] as? Date
        let currentGame = data["current_game"] as? String
        
        return DBUser(userId: userId, name: name ?? "Whoever you are (We don't have your name)", dateCreated: dateCreated, currentGame: currentGame)
    }
    
    func randomAlphanumericString(_ length: Int) -> String {
       let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
       let len = UInt32(letters.count)
       var random = SystemRandomNumberGenerator()
       var randomString = ""
       for _ in 0..<length {
          let randomIndex = Int(random.next(upperBound: len))
          let randomCharacter = letters[letters.index(letters.startIndex, offsetBy: randomIndex)]
          randomString.append(randomCharacter)
       }
       return randomString
    }
    
    func makeFakeUser(gameId: String, name: String) async throws -> DBUser {
        
        
        let userId = randomAlphanumericString(20)
        let dateCreated = Date.now
        let currentGame = gameId
        
        return DBUser(userId: userId, name: name, dateCreated: dateCreated, currentGame: currentGame)
    }
    
    func getUserName(userId: String) async throws -> String {
        let snapshot = try await Firestore.firestore().collection("users").document(userId).getDocument()
        
        guard let data = snapshot.data(), let name = data["name"] as? String else {
            throw URLError(.badServerResponse)
        }
    
        
        return name
    }
}
