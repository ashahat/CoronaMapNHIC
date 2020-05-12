//
//  Report.swift
//  Corona Tracker
//  Created by Mhd Hejazi on 3/13/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import MapKit

struct Report: Codable {
	var region: Region
	//let lastUpdate: Date
	var stat: Statistic

	static func join(subReports: [Report]) -> Report {
		Report(region: Region.join(subRegions: subReports.map { $0.region }),
			   stat: Statistic.join(subData: subReports.map { $0.stat }))
        
        
	}
}
