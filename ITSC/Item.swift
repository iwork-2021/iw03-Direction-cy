//
//  Item.swift
//  ITSC
//
//  Created by nju on 2021/11/8.
//

import UIKit

class Item: NSObject {
    var title:String
    var date:String
    var href:String
    init(title:String, date:String, href:String) {
        self.title = title
        self.date = date
        self.href = href
    }
}
