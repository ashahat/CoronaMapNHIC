//
//  DataManager.swift
//  Corona Tracker
//  Created by Mhd Hejazi on 3/13/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import Foundation

import Disk

class DataManager {

	static let instance = DataManager()

	var allReports: [Report] = []
	var countryReports: [Report] = []
	var worldwideReport: Report?
	var topReports: [Report] = []

	var allTimeSerieses: [TimeSeries] = []
	var countryTimeSerieses: [TimeSeries] = []
	var worldwideTimeSeries: TimeSeries?
    
    func timeSeries(for region: Region) -> TimeSeries? {
        if let timeSeries = allTimeSerieses.first(where: { $0.region == region }) {
            return timeSeries
        }

        if worldwideTimeSeries?.region == region {
            return worldwideTimeSeries
        }

        return nil
    }
    
    func timeSeriesCountries(for region: Region) -> TimeSeries? {
       
        if let timeSeries = countryTimeSerieses.first(where: { $0.region == region }) {
            return timeSeries
        }

        return nil
    }
    
    func download(completion: @escaping (Bool) -> ()) {
        WebDataService.instance.fetchReports { (reports, error) in
            guard let reports = reports else {
                completion(false)
                return
            }
           
            self.allReports = reports
            self.generateOtherReports()
            self.downloadTimeSerieses(completion: completion)
        }
    }

    private func downloadTimeSerieses(completion: @escaping (Bool) -> ()) {
        WebDataService.instance.fetchTimeSerieses { (timeSerieses, error) in
            guard let timeSerieses = timeSerieses else {
                completion(false)
                return
            }
            self.allTimeSerieses = timeSerieses
            self.downloadCountriesTimeSerieses(completion: completion)
            //self.generateOtherTimeSerieses()

            completion(true)
        }
        
    }
    
    private func downloadCountriesTimeSerieses(completion: @escaping (Bool) -> ()) {
        WebDataService.instance.fetchCountriesTimeSerieses { (countriesTimeSerieses, error) in
            guard let countriesTimeSerieses = countriesTimeSerieses else {
                completion(false)
                return
            }
            self.countryTimeSerieses = countriesTimeSerieses
       
            completion(true)
        }
        
    }
    
    private func generateOtherReports() {
        /// Main reports
        var reports = [Report]()
        reports.append(contentsOf: allReports.filter({ !$0.region.isProvince }))
        Dictionary(grouping: allReports.filter({ report in
            report.region.isProvince
        }), by: { report in
            report.region.countryName
        }).forEach { (key, value) in
            let report = Report.join(subReports: value.map { $0 })
            reports.append(report)
        }
        countryReports = reports

        /// Global report
        worldwideReport = Report.join(subReports: allReports)
        if Constants.lang == "ar"
        {
            worldwideReport?.region  = .worldWideAr
        }
        else
        {
            worldwideReport?.region  = .worldWide
        }

        /// Top countries
        topReports = [Report](
            countryReports.filter({ $0.region.countryName != "Others"  && $0.region.IsCity != true})
                .sorted(by: { $0.stat.existingCount < $1.stat.existingCount })
                .reversed()
                .prefix(7)
        )
    }
    
    private func generateOtherTimeSerieses() {
        /*if allTimeSerieses.isEmpty {
            countryTimeSerieses = []
            worldwideTimeSeries = nil
            return
        }*/
        

        /// Main time serieses
        var timeSerieses = [TimeSeries]()
        timeSerieses.append(contentsOf: countryTimeSerieses.filter({ !$0.region.isProvince }))
        
        Dictionary(grouping: countryTimeSerieses.filter({ timeSeries in
            timeSeries.region.isProvince
        }), by: { timeSeries in
            timeSeries.region.countryName
        }).forEach { (key, value) in
            let timeSeries = TimeSeries.join(subSerieses: value.map { $0 })
            timeSerieses.append(timeSeries)
        }
        countryTimeSerieses = timeSerieses

        /// Global time series
        
       // worldwideTimeSeries = TimeSeries.join(subSerieses: allTimeSerieses)
        
        if Constants.lang == "ar"
        {
            worldwideTimeSeries?.region = .worldWideAr
        }
        else
        {
            worldwideTimeSeries?.region = .worldWide
        }
        
    }

}
