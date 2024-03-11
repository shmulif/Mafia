//
//  UserManager.swift
//  mafia
//
//  Created by Shmuli Feld on 3/9/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseFirestoreInternalWrapper

struct DBUser {
    let userId: String
    let name: String
    let dateCreated: Date?
    var currentGame: String?
}

final class UserManager {
    
    static let shared = UserManager()
    private init() { }
    
    func createNewUser(auth: AuthDataResultModel, name: String) async throws {
        var userData: [String:Any] = [
            "user_id" : auth.uid,
            "name" : name,
            "date_created" : Timestamp(),
            "current_game" : "",
        ]
        try await Firestore.firestore().collection("users").document(auth.uid).setData(userData, merge: false)
    }
    
    func linkUserToGame(auth: AuthDataResultModel, gameId: String) async throws {
        var userData: [String:Any] = [
            "current_game" : gameId,
        ]
        try await Firestore.firestore().collection("users").document(auth.uid).setData(userData, merge: true)
    }
    
    func getUser(userId: String) async throws -> DBUser {
        let snapshot = try await Firestore.firestore().collection("users").document(userId).getDocument()
        
        guard let data = snapshot.data(), let userId = data["user_id"] as? String else {
            throw URLError(.badServerResponse)
        }
        
        let name = data["name"] as? String
        let dateCreated = data["date_created"] as? Date
        let currentGame = data["current_game"] as? String
        
        return DBUser(userId: userId, name: name!, dateCreated: dateCreated, currentGame: currentGame)
    }
}
