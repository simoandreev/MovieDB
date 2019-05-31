//
//  PersistantManager.swift
//  MovieDB
//
//  Created by Simeon Andreev on 22.05.19.
//  Copyright © 2019 Simeon Andreev. All rights reserved.
//

import UIKit
import CoreData

class PersistantManager {
	private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
	
	func safe(movies: [Movie]) {
		for movie in movies {
			let newItem = MovieCD(context: context)
			newItem.genre = movie.genre
			newItem.released = movie.released
			newItem.runtime = movie.runtime
			newItem.title = movie.title
			newItem.year = movie.year
			newItem.favorite = movie.favorite ?? false
			newItem.myMovie = movie.myMovie ?? false
			
			saveContext()
		}
	}
	
	func loadFavorites() -> [MovieCD] {
		let predicate = NSPredicate(format: "favorite == %@",  NSNumber(value: true))
		return loadMovies(with: predicate)
	}
	
	func loadMyMovies() -> [MovieCD] {
		let predicate = NSPredicate(format: "myMovie == %@",  NSNumber(value: true))
		return loadMovies(with: predicate)
	}
	
	private func loadMovies(with predicate: NSPredicate) -> [MovieCD] {
		let request: NSFetchRequest<MovieCD> = MovieCD.fetchRequest()
		var movies: [MovieCD] = []
		do {
			request.predicate = predicate
			movies = try context.fetch(request)
		} catch {
			print("Error fetching data from context \(error)")
		}
		return movies
	}
	
	func deleteItem(object: MovieCD) {
		context.delete(object)
		saveContext()
	}
	
	private func saveContext() {
		do {
			try context.save()
		} catch {
			print("Error saving context \(error)")
		}
	}
}
