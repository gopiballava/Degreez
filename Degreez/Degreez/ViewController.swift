//
//  ViewController.swift
//  WeatherWatch
//
//  Created by Ajay Merchia on 5/24/20.
//  Copyright © 2020 Ajay Raj Merchia. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	
	var statusLabel = UILabel()
	var farenLabel = UILabel()
	var celzLabel = UILabel()
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		initUI()
		//		 Do any additional setup after loading the view.
		WeatherAPI.shared.subscribeToWeather { (temp, err) in
			guard let temp = temp, err == nil else { return }
			
			self.statusLabel.text = temp.label
			self.farenLabel.text = "\(temp.fahrenheit)"
			self.celzLabel.text = "\(temp.celsius)"
			
		}
	}
	
	
	
	func initUI() {
		self.view.backgroundColor = .black
		view.addSubview(statusLabel)
		statusLabel.translatesAutoresizingMaskIntoConstraints = false
		//		statusLabel.topAnchor.constraint(equalToSystemSpacingBelow: self.view.safeAreaLayoutGuide.topAnchor, multiplier: 3).isActive = true
		statusLabel.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor).isActive = true
		statusLabel.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor).isActive = true
		statusLabel.textColor = .white
		statusLabel.text = "Initializing..."
		statusLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
		
		let PADDING: CGFloat = 20
		
		let font = UIFont.systemFont(ofSize: 180, weight: .black)
		
		view.addSubview(farenLabel)
		farenLabel.translatesAutoresizingMaskIntoConstraints = false
		farenLabel.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor, constant: 0).isActive = true
		farenLabel.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor, constant: PADDING * 2).isActive = true
		farenLabel.font = font
		farenLabel.textColor = .wwPink
		farenLabel.textAlignment = .left
		
		
		view.addSubview(celzLabel)
		celzLabel.translatesAutoresizingMaskIntoConstraints = false
		celzLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor, constant: 0).isActive = true
		celzLabel.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor, constant: -PADDING * 2).isActive = true
		
		celzLabel.font = font
		celzLabel.textColor = .wwBlue
		celzLabel.textAlignment = .right
		
		
		
		farenLabel.text = "00"
		celzLabel.text = "00"
		
		let button = UIButton()
		view.addSubview(button)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: PADDING).isActive = true
		button.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor, constant: -PADDING).isActive = true
		button.widthAnchor.constraint(equalToConstant: 30).isActive = true
		button.heightAnchor.constraint(equalTo: button.widthAnchor, multiplier: 1).isActive = true
		button.setBackgroundImage(UIImage(named: "refresh"), for: .normal)
		button.addTarget(self, action: #selector(refresh), for: .touchUpInside)
		
		
		
	}
	
	@objc func refresh() {
		WeatherAPI.shared.lastUpdate = Date(timeIntervalSince1970: 0)
		WeatherAPI.shared.locationManager.stopUpdatingLocation()
		WeatherAPI.shared.locationManager.startUpdatingLocation()
	}
	
	
}

