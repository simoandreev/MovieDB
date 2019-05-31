//
//  AddContentViewController.swift
//  MovieDB
//
//  Created by Simeon Andreev on 23.05.19.
//  Copyright © 2019 Simeon Andreev. All rights reserved.
//

import UIKit

protocol AddContentViewControllerDelegate: AnyObject {
	func saveItemToContext(_ item: Movie)
}

class AddContentViewController: UIViewController {
	
	weak var delegate: AddContentViewControllerDelegate?
	
	@IBOutlet weak private var movieTitle: UITextField!
	@IBOutlet weak private var movieRuntime: UITextField!
	@IBOutlet weak private var movieYear: UITextField!
	@IBOutlet weak private var movieReleased: UITextField!
	@IBOutlet weak private var movieGenre: UITextField!
	
	@IBAction func saveButtonPressed(_ sender: UIButton) {
		if let title = movieTitle.text, let year = movieYear.text, let released = movieReleased.text, let runtime = movieRuntime.text, let genre = movieGenre.text  {
			let newitem = Movie(title: title, year: year, released: released, runtime: runtime, genre: genre, myMovie: true, favorite: false)
			self.delegate?.saveItemToContext(newitem)
			self.navigationController?.popViewController(animated: true)
		}
	}
	
}
