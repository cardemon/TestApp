//
//  Picture.swift
//  Technical task iOS
//
//  Created by Ruslan Pitula on 5/15/19.
//  Copyright © 2019 Ruslan Pitula. All rights reserved.
//

import Foundation
struct Picture: ExpressibleByJSONDictionary {
    var urls: PictureUrls
}

struct PictureUrls: ExpressibleByJSONDictionary {
    var raw: String?
    var full: String?
    var regular: String?
    var small: String?
    var thumb: String?
}
