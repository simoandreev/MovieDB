//
//  MovieTableViewCell.swift
//  MovieDB
//
//  Created by Simeon Andreev on 22.05.19.
//  Copyright © 2019 Simeon Andreev. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {
	
	@IBOutlet private weak var title: UILabel!
	@IBOutlet private weak var released: UILabel!
	@IBOutlet private weak var genre: UILabel!
	@IBOutlet private weak var runtime: UILabel!
	
	func configure(title: String?,
				   relesed: String?,
				   genre: String?,
				   runtime: String?) {
		
		self.title.text = title
		self.released.text = relesed
		self.genre.text = genre
		self.runtime.text = runtime
	}
}
