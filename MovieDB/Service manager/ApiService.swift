//
//  ApiService.swift
//  MovieDB
//
//  Created by Simeon Andreev on 22.05.19.
//  Copyright © 2019 Simeon Andreev. All rights reserved.
//

import UIKit

class ApiService: NSObject {
	
	public enum MovieError: Error {
		case apiError
		case invalidEndpoint
		case invalidResponse
		case noData
		case serializationError
	}
	
	private let jsonDecoder: JSONDecoder = {
		let jsonDecoder = JSONDecoder()
		return jsonDecoder
	}()
	
	public static let shared = ApiService()
	
	public func fetchMovies(successHandler: @escaping (_ response: [Movie]) -> Void,
							errorHandler: @escaping(_ error: Error) -> Void) {
		
		guard let url = URL(string: "http://tasks.upnetix.tech/mobile/movies-json.txt") else {
			handleError(errorHandler: errorHandler, error: MovieError.invalidEndpoint)
			return
		}
		
		let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
		urlSession.dataTask(with: url) { (data, response, error) in
			if error != nil {
				self.handleError(errorHandler: errorHandler, error: MovieError.apiError)
				return
			}
			
			guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
				self.handleError(errorHandler: errorHandler, error: MovieError.invalidResponse)
				
				return
			}
			
			guard let data = data else {
				self.handleError(errorHandler: errorHandler, error: MovieError.noData)
				return
			}
			
			do {
				let movies = try self.jsonDecoder.decode([Movie].self, from: data)
				DispatchQueue.main.async {
					successHandler(movies)
				}
			} catch {
				self.handleError(errorHandler: errorHandler, error: MovieError.serializationError)
			}
			}.resume()
		
	}
	
	private func handleError(errorHandler: @escaping(_ error: Error) -> Void, error: Error) {
		DispatchQueue.main.async {
			errorHandler(error)
		}
	}
}

extension ApiService: URLSessionDelegate {
	func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
		if(challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
			if(challenge.protectionSpace.host == "tasks.upnetix.tech") {
				if let trust = challenge.protectionSpace.serverTrust {
					let credential = URLCredential(trust: trust)
					completionHandler(URLSession.AuthChallengeDisposition.useCredential, credential)
				}
			}
		}
	}
}
