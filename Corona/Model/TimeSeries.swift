//
//  TimeSeries.swift
//  Corona Tracker
//  Created by Mhd Hejazi on 3/13/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import MapKit

struct TimeSeries: Codable {
	var region: Region
	let series: [Date : Statistic]

	static func join(subSerieses: [TimeSeries]) -> TimeSeries {
		assert(!subSerieses.isEmpty)

		let region = Region.join(subRegions: subSerieses.map { $0.region })

		var series: [Date : Statistic] = [:]
		let subSeries = subSerieses.first!
		subSeries.series.keys.forEach { key in
			let subData = subSerieses.compactMap { $0.series[key] }
			let superData = Statistic.join(subData: subData)
			series[key] = superData
		}

		return TimeSeries(region: region, series: series)
	}
}
