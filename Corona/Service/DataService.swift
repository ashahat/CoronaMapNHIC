//
//  DataService.swift
//  Corona Tracker
//  Created by Mhd Hejazi on 3/13/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import Foundation

protocol DataService {
	typealias FetchReportsBlock = ([Report]?, Error?) -> Void
	typealias FetchTimeSeriesesBlock = ([TimeSeries]?, Error?) -> Void
    typealias FetchCountriesTimeSeriesesBlock = ([TimeSeries]?, Error?) -> Void

	func fetchReports(completion: @escaping FetchReportsBlock)

	func fetchTimeSerieses(completion: @escaping FetchTimeSeriesesBlock)
}
