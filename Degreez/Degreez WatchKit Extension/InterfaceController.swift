//
//  InterfaceController.swift
//  Degreez WatchKit Extension
//
//  Created by Ajay Merchia on 5/24/20.
//  Copyright © 2020 Ajay Raj Merchia. All rights reserved.
//

import WatchKit
import Foundation
import ClockKit

class WeatherInterfaceController: WKInterfaceController {
	
	@IBOutlet var farenLabel: WKInterfaceLabel!
	@IBOutlet var celzLabel: WKInterfaceLabel!
	@IBOutlet var statusLabel: WKInterfaceLabel!
		
	
	override func awake(withContext context: Any?) {
		super.awake(withContext: context)
		
		WeatherAPI.shared.subscribeToWeather { (temperature, err) in
			guard let temp = temperature, err == nil else {
				return
			}
			print("Fetched weather: \(temperature!)")

			
			self.farenLabel.setText("\(temp.fahrenheit)")
			self.celzLabel.setText("\(temp.celsius)")
			self.statusLabel.setText(temp.label)
		}
		
		// Configure interface objects here.
	}
	
	override func willActivate() {
		// This method is called when watch view controller is about to be visible to user
		super.willActivate()
	}
	
	override func didDeactivate() {
		// This method is called when watch view controller is no longer visible
		super.didDeactivate()
	}
	
}
