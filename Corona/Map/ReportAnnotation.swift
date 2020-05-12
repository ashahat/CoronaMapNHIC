//
//  ReportAnnotation.swift
//  Corona Tracker
//  Created by Mhd Hejazi on 3/13/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import MapKit

class ReportAnnotation: NSObject, MKAnnotation {
	static let reuseIdentifier = String(describing: ReportAnnotation.self)

	let report: Report
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
	let title: String?
    

	init(report: Report)
    {
        self.report = report
		let region = report.region
		self.coordinate = region.location.clLocation
        self.title = report.region.countryNameAr
        self.subtitle = ""
        
		super.init()
	}
    
}
