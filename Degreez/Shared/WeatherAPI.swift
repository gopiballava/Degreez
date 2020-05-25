//
//  WeatherAPI.swift
//  WeatherWatch
//
//  Created by Ajay Merchia on 5/24/20.
//  Copyright © 2020 Ajay Raj Merchia. All rights reserved.
//

import Foundation
import CoreLocation

typealias WeatherError = String
typealias BlankClosure = ()->()
typealias Response<T> = ((T?, WeatherError?) -> ())
typealias PlaceName = String
typealias Kelvin = Double
struct Temperature {
	var fahrenheit: Int
	var celsius: Int
	var label: String
}

extension TimeInterval {
	static let second: TimeInterval = 1
	static let minute: TimeInterval = 60
	static let hour: TimeInterval = TimeInterval.minute * 60
}

class WeatherAPI: NSObject, CLLocationManagerDelegate {
	static let shared = WeatherAPI()
	
	static let ENDPOINT = "https://api.openweathermap.org/data/2.5/weather"
	static let API_KEY = "f0f42e58f56775682667e9febecc3ca3"
	
	let locationManager:CLLocationManager = CLLocationManager()
	var currentLocation = CLLocation()
	
	var lastUpdate = Date(timeIntervalSince1970: 0)
	let refreshThreshold: TimeInterval = 30 * TimeInterval.minute
	
	var kelvin: Kelvin = 233.15 {
		didSet {
			notifyListeners()
			
		}
	}
	var label: PlaceName = "Initializing..."
	
	var listeners: [Response<Temperature>] = []
	
	func notifyListeners() {
		for listener in listeners {
			notify(listener: listener)
		}
	}
	func notify(listener: Response<Temperature>) {
		let celsius = kelvin - 273.15
		let faren = celsius * 9/5 + 32
		
		let response = Temperature(fahrenheit: Int(round(faren)), celsius: Int(round(celsius)), label: label)
		listener(response, nil)
	}
		
		
		func getWeatherSync() -> Temperature {
			let celsius = kelvin - 273.15
			let faren = celsius * 9/5 + 32
			
			return Temperature(fahrenheit: Int(round(faren)), celsius: Int(round(celsius)), label: label)
		}
		
		override init() {
			super.init()
			self.locationManager.delegate = self
			self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
			self.locationManager.requestLocation()
			self.locationManager.requestWhenInUseAuthorization()
			self.locationManager.startUpdatingLocation()
		}
		
		func subscribeToWeather(completion: Response<Temperature>?) {
			if let c = completion {
				self.listeners.append(c)
			}
		}
		
		
		func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
			guard Date().timeIntervalSince(lastUpdate) > refreshThreshold, let location = locations.first else {
				// ignore
				return
			}
			lastUpdate = Date()
			self.label = "Location Unavailable"
			print("Looking up location for \(location.coordinate)")
			CLGeocoder().reverseGeocodeLocation(location) { (place, err) in
				guard let place = place?.first, err == nil else {
					print("ERROR", err)
					
					self.label = "Location Unavailable"
					return
				}
				
				print("Figured out location")
				
				self.label = [place.locality, place.administrativeArea].compactMap({$0}).joined(separator: ", ")
				print(self.label)
			}
			
			debugPrint("Got a new location")
			self.queryWeather(for: location.coordinate) { (kelvin, err) in
				guard let kelvin = kelvin, err == nil else {
					debugPrint("Failed to fetch weather for \(location.coordinate)")
					debugPrint(err)
					return
				}
				
				self.kelvin = kelvin
				
			}
		}
		
		func queryWeather(for coordinate: CLLocationCoordinate2D, completion: Response<Kelvin>?) {
			NetworkingLib.shared.get(url: WeatherAPI.ENDPOINT, params: [
				"lat": coordinate.latitude,
				"lon": coordinate.longitude,
				"appid": WeatherAPI.API_KEY
			]) { (data, err) in
				guard let json = data as? [String: Any?], err == nil else {
					print("API ERRORr")
					print(err)
					return
				}
				
				print("GOT A VALUE")
				
				if let main = json["main"] as? [String: Any?], let
					kelvin = main["temp"] as? Kelvin {
					
					completion?(kelvin, nil)
					
				} else {
					completion?(nil, "Failed to parse response from API")
				}
				
			}
		}
		
		func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
			debugPrint(error)
		}
		
}
