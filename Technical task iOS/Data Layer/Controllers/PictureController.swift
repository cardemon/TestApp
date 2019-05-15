//
//  PictureController.swift
//  Technical task iOS
//
//  Created by Ruslan Pitula on 5/15/19.
//  Copyright © 2019 Ruslan Pitula. All rights reserved.
//

import Foundation
import RxSwift

class PictureController {
    func loadPicturePerPage(page: Int) -> Single<[Picture]> {
        let params = ["page": page,
                      "per_page": 11]
        return NetworkService.shared.get(endpoint: "photos", queries: "", params: params).flatMap { (jsonData) -> Single<[Picture]> in
            var pictures = [Picture]()
            for data in jsonData {
                if let data = try? JSONSerialization.data(withJSONObject: data) {
                    if let picture = try? JSONDecoder().decode(Picture.self, from: data) {
                        pictures.append(picture)
                    }
                    
                }
            }
            return Single.just(pictures)
        }
    }
    
    func getPicturesBySearch(page: Int, search: String) -> Single<[Picture]> {
        return NetworkService.shared.getForSearch(endpoint: "search/photos",queries: "&query=\(search)&page=\(page)",params: nil).flatMap { (jsonData) -> Single<[Picture]> in
            var pictures = [Picture]()
            for (key,value) in jsonData {
                if key == "results" {
                    for data in value as! [[String: Any]] {
                        if let data = try? JSONSerialization.data(withJSONObject: data) {
                            if let picture = try? JSONDecoder().decode(Picture.self, from: data) {
                                pictures.append(picture)
                            }
                            
                        }
                    }
                }
                
            }
            return Single.just(pictures)
        }
    }
}
