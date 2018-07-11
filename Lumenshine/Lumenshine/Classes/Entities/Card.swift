//
//  Card.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 3/16/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

enum CardType {
    case web
    case intern
    case chart
    case account
    case wallet(status: WalletStatus)
    
    static func fromInt(value: Int) -> CardType {
        switch value {
        case 0:
            return .web
        case 1:
            return .intern
        case 2:
            return .chart
        case 3:
            return .account
        case 4:
            return .wallet(status: .founded)
        case 5:
            return .wallet(status: .unfounded)
        default:
            fatalError("Invalid card type")
        }
    }
}

class Card: NSObject, Decodable {
    
    let type: CardType?
    let title: String?
    let descript: String?
    let detail: String?
    let imgUrl: String?
    let link: String?
    let data: Data?
    
    private enum CodingKeys: String, CodingKey {
        case type
        case title
        case description
        case detail
        case imgUrl
        case link
        case data = "data"
    }
    
    public required init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        type = try CardType.fromInt(value: values.decode(Int.self, forKey: .type))
        title = try values.decode(String.self, forKey: .title)
        descript = try values.decode(String.self, forKey: .description)
        detail = try values.decodeIfPresent(String.self, forKey: .detail)
        imgUrl = try values.decodeIfPresent(String.self, forKey: .imgUrl)
        link = try values.decodeIfPresent(String.self, forKey: .link)
        data = try values.decodeIfPresent(Data.self, forKey: .data)
    }
}

