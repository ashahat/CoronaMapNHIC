//
//  PercentValueFormatter.swift
//  Corona Tracker
//  Created by Mhd Hejazi on 3/13/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import Foundation

import Charts

class PercentValueFormatter: DefaultValueFormatter {
	override init() {
		super.init(formatter: .percentFormatter)
	}

	override func stringForValue(_ value: Double,
								 entry: ChartDataEntry,
								 dataSetIndex: Int,
								 viewPortHandler: ViewPortHandler?) -> String {
		if value < 4 {
			return ""
		}

		return super.stringForValue(value, entry: entry, dataSetIndex: dataSetIndex, viewPortHandler: viewPortHandler)
	}
}
