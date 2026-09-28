//
//  Member.swift
//  Lofeo
//
//  Created by Anita Barman Lalani on 14/03/26.
//

struct Member: Codable ,Equatable  {
    var name: String
    
    var phone: String?
   }

enum ContactType : String, Codable{
    case contact
    case member
    case header
}

struct Contact : Codable ,Equatable {
    var name: String
    var phone: String
    var type: ContactType = .contact // ✅ default
}


