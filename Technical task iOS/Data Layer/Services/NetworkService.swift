//
//  NetworkService.swift
//  Technical task iOS
//
//  Created by Ruslan Pitula on 5/15/19.
//  Copyright © 2019 Ruslan Pitula. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

class NetworkService {
    static let shared = NetworkService()
    private init() {}
    
    private let apiPath = "https://api.unsplash.com/"
    
    private func apiURL(forEndpoint endpoint: String, customQueries: String) -> URL {
        let authQuery = "?client_id=4c9fbfbbd92c17a2e95081cec370b4511659666240eb4db9416c40c641ee843b"
        let urlComps = URLComponents(string: apiPath + endpoint + authQuery + customQueries)!
        return try! urlComps.asURL()
    }
    
    func get(endpoint:String, queries: String, params:[String: Any]?) -> Single<[[String: Any]]> {
        return Single.create { single in
            Alamofire.request(self.apiURL(forEndpoint: endpoint, customQueries: queries), parameters:params).responseJSON(completionHandler: { (response) in
                switch response.result {
                case .success:
                    let json = (response.result.value as? [[String: Any]]) ?? [[String: Any]]()
                        if let code = json[0]["code"] as? Int, let message = json[0]["message"] as? String {
                            single(.error(NSError(domain: "com.testapp", code: code, userInfo: [NSLocalizedDescriptionKey: message])))
                        }
                        else {
                            single(.success(json))
                        }
                    
                case .failure(let error):
                    single(.error(error))
                }
            })
            return Disposables.create()
        }
    }
    
    func getForSearch(endpoint:String, queries: String, params:[String: Any]?) -> Single<[String: Any]> {
        return Single.create { single in
            Alamofire.request(self.apiURL(forEndpoint: endpoint, customQueries: queries), parameters:params).responseJSON(completionHandler: { (response) in
                switch response.result {
                case .success:
                    let json = (response.result.value as? [String: Any]) ?? [String: Any]()
                    if let code = json["code"] as? Int, let message = json["message"] as? String {
                        single(.error(NSError(domain: "com.testapp", code: code, userInfo: [NSLocalizedDescriptionKey: message])))
                    }
                    else {
                        single(.success(json))
                    }
                    
                case .failure(let error):
                    single(.error(error))
                }
            })
            return Disposables.create()
        }
    }
}
