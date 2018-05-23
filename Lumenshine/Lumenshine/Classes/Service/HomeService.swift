//
//  HomeService.swift
//  Lumenshine
//
//  Created by Istvan Elekes on 3/19/18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

class HomeService: BaseService {
    
    func getCards(response: @escaping ([Card]) -> Void) {
        GETRequestWithPath(path: "/cards") { result in
            switch result {
            case .success(let data, _):
                do {
                    let dict = try self.jsonDecoder.decode(Dictionary<String, Array<Card>>.self, from: data)
                    let cards = dict["cards"] ?? []
                    response(cards)
                } catch (let error) {
                    print("JSON error: \(error.localizedDescription)")
                    response([])
                }
            case .failure:
                response([])
            }
        }
    }
}
