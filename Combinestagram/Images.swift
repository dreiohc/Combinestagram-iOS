//
//  Images.swift
//  Combinestagram
//
//  Created by Myron Dulay on 4/21/20.
//  Copyright © 2020 Underplot ltd. All rights reserved.
//

import RealmSwift

class Images: Object {
	@objc dynamic var imageName: String = ""
	let imageArray = List<String>()
}
