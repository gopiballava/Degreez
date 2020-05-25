//
//  ComplicationController.swift
//  Degreez WatchKit Extension
//
//  Created by Ajay Merchia on 5/24/20.
//  Copyright © 2020 Ajay Raj Merchia. All rights reserved.
//

import ClockKit


class ComplicationController: NSObject, CLKComplicationDataSource {
	
	// MARK: - Timeline Configuration
	var listeningComplications: [CLKComplicationFamily] = []
	
	
	func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
		handler([.forward, .backward])
	}
	
	func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
		handler(nil)
	}
	
	func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
		handler(nil)
	}
	
	func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
		handler(.showOnLockScreen)
	}
	
	// MARK: - Timeline Population
	
	func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
		// Call the handler with the current timeline entry
		
		if !listeningComplications.contains(complication.family) {
			listeningComplications.append(complication.family)
			WeatherAPI.shared.subscribeToWeather { (_, err) in
				print("Got an update")
				if err == nil {
					print("New weather data available")
					CLKComplicationServer.sharedInstance().reloadTimeline(for: complication)
				}
			}
		}
		
		let date = Date()
		var template: CLKComplicationTemplate!
		
		let temperature = WeatherAPI.shared.getWeatherSync()
		let faren = CLKSimpleTextProvider(text: "\(temperature.fahrenheit)")
		faren.tintColor = .wwPink
		
		let celz = CLKSimpleTextProvider(text: "\(temperature.celsius)")
		celz.tintColor = .wwBlue
		
		let label = CLKSimpleTextProvider(text: temperature.label)
		
		let allinone = CLKSimpleTextProvider(text: "\(temperature.fahrenheit)F • \(temperature.celsius)C")
		
		switch complication.family {
		case .circularSmall:
			let temp = CLKComplicationTemplateCircularSmallStackText()
			temp.line1TextProvider = faren
			temp.line2TextProvider = celz
			
			template = temp
			break;
		case .extraLarge:
			let temp = CLKComplicationTemplateExtraLargeStackText()
			temp.line1TextProvider = faren
			temp.line2TextProvider = celz
			
			template = temp
			break;
		case .modularSmall:
			let temp = CLKComplicationTemplateModularSmallStackText()
			temp.line1TextProvider = faren
			temp.line2TextProvider = celz
			
			template = temp
			break;
		case .modularLarge:
			let temp = CLKComplicationTemplateModularLargeStandardBody()
			temp.headerTextProvider = label
			temp.body1TextProvider = faren
			temp.body2TextProvider = celz
			
			template = temp
			break;
		case .utilitarianSmall:
			let temp = CLKComplicationTemplateUtilitarianSmallFlat()
			temp.textProvider = allinone
			
			template = temp
			break;
		case .utilitarianSmallFlat:
			let temp = CLKComplicationTemplateUtilitarianSmallFlat()
			temp.textProvider = allinone
			
			template = temp
		case .utilitarianLarge:
			let temp = CLKComplicationTemplateUtilitarianLargeFlat()
			temp.textProvider = allinone
			
			template = temp
			break;
		case .graphicCorner:
			let temp = CLKComplicationTemplateGraphicCornerStackText()
			temp.outerTextProvider = faren
			temp.innerTextProvider = celz
			template = temp
			break;
		case .graphicCircular:
			let temp = CLKComplicationTemplateGraphicCircularStackText()
			temp.line1TextProvider = faren
			temp.line2TextProvider = celz
			template = temp
			break;
		case .graphicBezel:
			let temp = CLKComplicationTemplateGraphicBezelCircularText()
			temp.textProvider = allinone
			template = temp
			break;
		case .graphicRectangular:
			let temp = CLKComplicationTemplateGraphicRectangularStandardBody()
			temp.body1TextProvider = faren
			temp.body2TextProvider = celz
			temp.headerTextProvider = label
			
			template = temp
			break;
		@unknown default:
			fatalError()
		}
		
		let entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
		handler(entry)
		
	}
	
	func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
		// Call the handler with the timeline entries prior to the given date
		handler(nil)
	}
	
	func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
		// Call the handler with the timeline entries after to the given date
		handler(nil)
	}
	
	// MARK: - Placeholder Templates
	
	func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
		// This method will be called once per supported complication, and the results will be cached
		handler(nil)
	}
	
}
