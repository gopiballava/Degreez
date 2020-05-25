//
//  NetworksAPI.swift
//  WeatherWatch
//
//  Created by Ajay Merchia on 5/24/20.
//  Copyright © 2020 Ajay Raj Merchia. All rights reserved.
//

import Foundation

func onMain(exec: BlankClosure?) {
	DispatchQueue.global().async {
		DispatchQueue.main.async {
			exec?()
		}
	}
}

class NetworkingLib {
	static let shared = NetworkingLib()
	let session = URLSession.shared
	
	func post(url: String? , params: [String: Any]?, completion: Response<Any>?) {
		guard
			let urlString = url,
			let url = URL(string: urlString)
			else { completion?(nil, "Invalid URL provided"); return }
		
		guard let jsonData = try? JSONSerialization.data(withJSONObject: params ?? [:], options: [])
			else { completion?(nil, "Invalid body params provided"); return }
		
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.addValue("application/json", forHTTPHeaderField: "Accept")
		request.httpBody = jsonData
		
		let task = session.uploadTask(with: request, from: nil) { (data, resp, err) in
			onMain {
				guard let data = data, let resp = resp, err == nil else {
					completion?(nil, err?.localizedDescription)
					return
				}
				guard let mime = resp.mimeType else {
					completion?(nil, "Unable to recognize format of response")
					return
				}
				
				guard let httpResponse = resp as? HTTPURLResponse,
					(200...299).contains(httpResponse.statusCode) else {
						// can try to extract more info from the error here
						if mime == "text/html", let txt = String(data: data, encoding: .utf8) {
							completion?(nil, txt)
						} else {
							completion?(nil, "Invalid Response Code \((resp as? HTTPURLResponse)?.statusCode ?? 0)")
						}
						
						return
				}
				
				if mime == "application/json", let json = try? JSONSerialization.jsonObject(with: data, options: []) {
					completion?(json, nil)
				} else if mime == "text/html", let txt = String(data: data, encoding: .utf8) {
					completion?(txt, nil)
				} else {
					completion?(nil, "Unable to parse response (Type: \(mime))")
				}
			}
		}
		
		task.resume()
		
	}
	
	func get(url: String?, params: [String: Any]?, completion: Response<Any>?) {
		guard
			let urlString = url,
			let url = URL(string: urlString),
			var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
			else { completion?(nil, "Invalid URL provided"); return }
		
		if let params = params {
			components.queryItems = params.map({ URLQueryItem(name: $0.key, value: "\($0.value)")})
		}
		
		guard let targetURL = components.url else { completion?(nil, "Invalid URL provided"); return }
		print("QUERYING: \(targetURL)")
		let task = session.dataTask(with: targetURL) { (data, resp, err) in
			onMain {
				guard let data = data, let resp = resp, err == nil else {
					completion?(nil, err?.localizedDescription)
					return
				}
				guard let httpResponse = resp as? HTTPURLResponse,
					(200...299).contains(httpResponse.statusCode) else {
						// can try to extract more info from the error here
						completion?(nil, "Invalid Response Code \((resp as? HTTPURLResponse)?.statusCode ?? 0)")
						return
				}
				
				
				guard let mime = resp.mimeType else {
					completion?(nil, "Unable to recognize format of response")
					return
				}
				if mime == "application/json", let json = try? JSONSerialization.jsonObject(with: data, options: []) {
					completion?(json, nil)
				} else if mime == "text/html", let txt = String(data: data, encoding: .utf8) {
					completion?(txt, nil)
				} else {
					completion?(nil, "Unable to parse response (Type: \(mime))")
				}
			}
		}
		
		task.resume()
		
	}
	
}
