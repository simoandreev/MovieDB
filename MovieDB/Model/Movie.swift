//
//  Movie.swift
//  MovieDB
//
//  Created by Simeon Andreev on 22.05.19.
//  Copyright © 2019 Simeon Andreev. All rights reserved.
//

import Foundation

public struct Movie: Codable {
	public let title: String
	public let year: String
	public let released: String
	public let runtime: String
	public let genre: String
	public var myMovie: Bool?
	public var favorite: Bool?
	
	enum CodingKeys: String, CodingKey {
		case title = "Title"
		case year = "Year"
		case released = "Released"
		case runtime = "Runtime"
		case genre = "Genre"
		case myMovie
		case favorite
	}
}
