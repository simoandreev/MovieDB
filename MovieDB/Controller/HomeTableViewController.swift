//
//  ViewController.swift
//  MovieDB
//
//  Created by Simeon Andreev on 22.05.19.
//  Copyright © 2019 Simeon Andreev. All rights reserved.
//

import UIKit
import CoreData

class HomeTableViewController: UITableViewController {
	
	private enum Constant {
		static let cellHeight = 150
		static let addContentSegue = "addContent"
		static let edit = "Edit"
		static let done = "Done"
		static let delete = "Delete"
	}
	
	private enum SelectedViewController: String {
		case Home = "home"
		case Favorite = "favorite"
		case MyMovies = "myMovies"
	}
	
	private var movie: Movie?
	private var movieCD: MovieCD?
	private let cellIdentifier = "MovieTableViewCell"
	private let movieService = ApiService.shared
	private var currentViewController: SelectedViewController?
	var favoriteMovies = [MovieCD]() {
		didSet {
			tableView?.reloadData()
		}
	}
	var sortedMoviesArray = [Movie]() {
		didSet {
			tableView?.reloadData()
		}
	}
	var myMovies = [MovieCD]() {
		didSet {
			tableView?.reloadData()
		}
	}
	
	private let persistanceManager: PersistantManager = PersistantManager()
	
	@IBOutlet weak private var editBtn: UIBarButtonItem!
	@IBOutlet weak private var favoriteBtn: UIBarButtonItem! {
		didSet {
			self.favoriteBtn.isEnabled = false
		}
	}
	@IBAction func startEditing(_ sender: Any) {
		isEditing = !isEditing
		self.favoriteBtn.isEnabled = isEditing
		self.editBtn.title = isEditing ? Constant.done : Constant.edit
	}
	
	@IBAction func addToFavorite(_ sender: Any) {
		if let selectedRows = tableView.indexPathsForSelectedRows {
			
			var movies = [Movie]()
			for indexPath in selectedRows  {
				var movie = sortedMoviesArray[indexPath.row]
				movie.favorite = true
				movies.append(movie)
			}
			
			persistanceManager.safe(movies: movies)
			isEditing = false
			favoriteBtn.isEnabled = false
			self.editBtn.title = Constant.edit
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super .viewDidAppear(animated)
		loadItems()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		if let vcID = self.restorationIdentifier {
			if vcID  == SelectedViewController.Home.rawValue {
				currentViewController = SelectedViewController.Home
			} else if vcID == SelectedViewController.Favorite.rawValue {
				currentViewController = SelectedViewController.Favorite
			} else if vcID == SelectedViewController.MyMovies.rawValue {
				currentViewController = SelectedViewController.MyMovies
			}
		}
		setupTableView()
		fetchMovies()
	}
	
	private func loadItems() {
		if currentViewController == SelectedViewController.Favorite {
			favoriteMovies = persistanceManager.loadFavorites()
		} else if currentViewController == SelectedViewController.MyMovies {
			myMovies = persistanceManager.loadMyMovies()
		}
		tableView.reloadData()
	}
	
	private func deleteItem(array: inout [MovieCD], indexPath: IndexPath) {
		let object = array[indexPath.row]
		persistanceManager.deleteItem(object: object)
		array.remove(at: indexPath.row)
		tableView.reloadData()
	}
	
	private func fetchMovies() {
		movieService.fetchMovies(successHandler: { [unowned self] movies in
			self.sortedMoviesArray = movies.sorted {
				$0.title < $1.title
			}
		}) { error in
			print(error.localizedDescription)
		}
	}
	
	private func setupTableView() {
		tableView.allowsMultipleSelectionDuringEditing = true
		tableView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if currentViewController ==  SelectedViewController.Home {
			return sortedMoviesArray.count
		} else if currentViewController ==  SelectedViewController.Favorite {
			return favoriteMovies.count
		} else if currentViewController ==  SelectedViewController.MyMovies {
			return myMovies.count
		} else {
			return 0
		}
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MovieTableViewCell
		
		if currentViewController ==  SelectedViewController.Home {
			let movie = sortedMoviesArray[indexPath.row]
			cell.configure(title: movie.title, relesed: movie.released, genre: movie.genre, runtime: movie.runtime)
		} else if currentViewController ==  SelectedViewController.Favorite {
			movieCD = favoriteMovies[indexPath.row]
		} else if currentViewController ==  SelectedViewController.MyMovies {
			movieCD = myMovies[indexPath.row]
		}
		if currentViewController ==  SelectedViewController.Favorite || currentViewController ==  SelectedViewController.MyMovies{
			cell.configure(title: movieCD?.title, relesed: movieCD?.released, genre: movieCD?.genre, runtime: movieCD?.runtime)
		}
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return CGFloat(Constant.cellHeight)
	}
	
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}
	
	override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		if currentViewController == SelectedViewController.Favorite || currentViewController == SelectedViewController.MyMovies {
			let delete = UITableViewRowAction(style: .destructive, title: Constant.delete) { (action, indexPath) in
				if self.currentViewController == SelectedViewController.Favorite {
					self.deleteItem(array: &self.favoriteMovies, indexPath: indexPath)
				} else {
					self.deleteItem(array: &self.myMovies, indexPath: indexPath)
				}
			}
			return [delete]
		} else {
			return []
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == Constant.addContentSegue {
			let destination = segue.destination as! AddContentViewController
			destination.delegate = self
		}
	}
}

//MARK: - Protocol Delegate Methods
extension HomeTableViewController: AddContentViewControllerDelegate {
	func saveItemToContext(_ item: Movie) {
		persistanceManager.safe(movies: [item])
	}
}
