//
//  WebDataService.swift
//  Corona Tracker
//  Created by Mhd Hejazi on 3/13/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import Foundation
import Disk
import Alamofire

class WebDataService: DataService {
	enum FetchError: Error {
		case noNewData
		case invalidData
		case downloadError
	}

	private static let reportsURL = URL(string: "")!
	private static let globalTimeSeriesURL = URL(string: "")!
    private static let countriesTimeSeriesURL = URL(string: "")!

	static let instance = WebDataService()

	func fetchReports(completion: @escaping FetchReportsBlock) {
		let request = URLRequest(url: Self.reportsURL, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
      _ = URLSession.shared.dataTask(with: request) { (data, response, error) in
			guard let response = response as? HTTPURLResponse,
				response.statusCode == 200,
				let data = data else {

					//print("Failed API call")
					completion(nil, FetchError.downloadError)
					return
			}
      
			DispatchQueue.global(qos: .default).async {
			
				self.parseReports(data: data, completion: completion)
			}
		}.resume()
	}
    
    func fetchTimeSerieses(completion: @escaping FetchTimeSeriesesBlock) {
        let request = URLRequest(url: Self.globalTimeSeriesURL, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
        _ = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let response = response as? HTTPURLResponse,
                response.statusCode == 200,
                let data = data else {
                    completion(nil, FetchError.downloadError)
                    return
            }

            DispatchQueue.global(qos: .default).async {
              
                self.parseTimeSerieses(data: data, completion: completion)
            }
        }.resume()
    }
    
    func fetchCountriesTimeSerieses(completion: @escaping FetchCountriesTimeSeriesesBlock) {
        let request = URLRequest(url: Self.countriesTimeSeriesURL, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
        _ = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let response = response as? HTTPURLResponse,
                response.statusCode == 200,
                let data = data else {
                    completion(nil, FetchError.downloadError)
                    return
            }

            DispatchQueue.global(qos: .default).async {
                self.parseCountriesTimeSerieses(data: data, completion: completion)
            }
        }.resume()
    }

	private func parseReports(data: Data, completion: @escaping FetchReportsBlock) {
		do {
			
          
            let decoder = JSONDecoder()
            let result = try decoder.decode(ReportsCallResult.self, from: data)
            let reports = result.features.map { $0.items.report }
            completion(reports, nil)
		}
		catch {
            completion(nil, error)
		}
	}

	private func parseTimeSerieses(data: Data, completion: @escaping FetchTimeSeriesesBlock) {
		do {
			let decoder = JSONDecoder()
			let result = try decoder.decode(GlobalTimeSeriesCallResult.self, from: data)
            let timeSeries = result.timeSeries
           
			completion([timeSeries], nil)
            
		}
		catch {
			completion(nil, error)
		}
	}
    
    private func parseCountriesTimeSerieses(data: Data, completion: @escaping FetchCountriesTimeSeriesesBlock) {
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(CountriesTimeSeriesCallResult.self, from: data)
            let resultSorted = result.features.sorted(by: { ($0.items.Country_Region, $0.items.ReportDateString)
                                                            < ($1.items.Country_Region, $1.items.ReportDateString) })
            GlobalArray.shared.countriesTimeSeries = []
            for i in 0..<resultSorted.count
            {
                 
                let report_date = getTimeInterval(DateString: resultSorted[i].items.ReportDateString)
                let stringAndString = CountriesTimeSeries(Country_Region: resultSorted[i].items.Country_Region ,ReportDate: report_date, ConfirmedNumer: resultSorted[i].items.ConfirmedNumer!, RecoveredNumber: resultSorted[i].items.RecoveredNumber!, DeathsNumber: resultSorted[i].items.DeathsNumber!)
                GlobalArray.shared.countriesTimeSeries.append(stringAndString)
            }
        }
        catch {
            completion(nil, error)
        }
    }
}

func getTimeInterval(DateString: String) -> Int
{
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let timeInterval = dateFormatter.date(from: DateString)?.timeIntervalSince1970
    
    return Int(timeInterval!)
    
    
}



private struct ReportsCallResult: Decodable {
	let features: [ReportFeature]
}

private struct ReportFeature: Decodable {
	let items: ReportAttributes
}

private struct ReportAttributes: Decodable {
	
    let Country_Region: String
    let ArabicName: String
    let ConfirmedNumer: Int?
    let DeathsNumber: Int?
    let RecoveredNumber: Int?
    let ConfirmedPrevNumer: Int?
    let DeathsPrevNumber: Int?
    let RecoveredPrevNumber: Int?
    let Lat: Double
    let Long: Double
    let EmergencyNumber: String
    let IsCity : Bool
   
	var report: Report {
		let location = Coordinate(latitude: Lat, longitude: Long)
		
        if Constants.lang == "ar"
        {
           let region = Region(countryName: Country_Region, countryNameAr: ArabicName, provinceName: "", location: location, emergencyNumber: EmergencyNumber, IsCity: IsCity)
           let stat = Statistic(confirmedCount: ConfirmedNumer ?? 0, recoveredCount: RecoveredNumber ?? 0, deathCount: DeathsNumber ?? 0,confirmedPrevCount: ConfirmedPrevNumer ?? 0, recoveredPrevCount: RecoveredPrevNumber ?? 0, deathsPrevCount: DeathsPrevNumber ?? 0, country_Name : ArabicName, IsCity: IsCity)
           return Report(region: region,  stat: stat)
           
        }
        else
        {
           let region = Region(countryName: Country_Region, countryNameAr: ArabicName, provinceName: "", location: location, emergencyNumber: EmergencyNumber, IsCity: IsCity)
           
            let stat = Statistic(confirmedCount: ConfirmedNumer ?? 0, recoveredCount: RecoveredNumber ?? 0, deathCount: DeathsNumber ?? 0,confirmedPrevCount: ConfirmedPrevNumer ?? 0, recoveredPrevCount: RecoveredPrevNumber ?? 0, deathsPrevCount: DeathsPrevNumber ?? 0, country_Name : Country_Region, IsCity: IsCity)
           return Report(region: region,  stat: stat)
           
        }
	}
    
}

private struct GlobalTimeSeriesCallResult: Decodable {
	let features: [GlobalTimeSeriesFeature]

    
	var timeSeries: TimeSeries
     {
        if Constants.lang == "ar"
        {
            let region = Region.worldWideAr
                   let series = [Date : Statistic](
                       uniqueKeysWithValues: zip(
                           features.map({ $0.items.date }),
                           features.map({ $0.items.stat })
                       )
                   )
                   return TimeSeries(region: region, series: series)
        }
        else
        {
            let region = Region.worldWide
                   let series = [Date : Statistic](
                       uniqueKeysWithValues: zip(
                           features.map({ $0.items.date }),
                           features.map({ $0.items.stat })
                       )
                   )
                   return TimeSeries(region: region, series: series)
        }
       
	}
}

private struct CountriesTimeSeriesCallResult: Decodable {
    let features: [CountiresTimeSeriesFeature]
   
}

private struct GlobalTimeSeriesFeature: Decodable {
	let items: GlobalTimeSeriesAttributes
}

private struct CountiresTimeSeriesFeature: Decodable {
    let items: CountriesTimeSeriesAttributes
}

private struct GlobalTimeSeriesAttributes: Decodable {
	let ReportDateString: String
	let ConfirmedNumer: Int?
	let RecoveredNumber: Int?
    let DeathsNumber: Int?
	
	var date: Date
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let timeInterval = dateFormatter.date(from: ReportDateString)
        
        return timeInterval!
	}
	var stat: Statistic {
		Statistic(confirmedCount: ConfirmedNumer ?? 0, recoveredCount: RecoveredNumber ?? 0, deathCount: DeathsNumber ?? 0, confirmedPrevCount: 0, recoveredPrevCount: 0, deathsPrevCount: 0 ,country_Name: "World Wide", IsCity: false)
	}
}


struct CountriesTimeSeries {
     var Country_Region: String
     var ReportDate: Int
     var ConfirmedNumer: Int
     var RecoveredNumber: Int
     var DeathsNumber: Int
}


private struct CountriesTimeSeriesAttributes: Decodable {
    let ReportDateString: String
    let Country_Region: String
    let ConfirmedNumer: Int?
    let RecoveredNumber: Int?
    let DeathsNumber: Int?
    
    var name : String
    {
        return Country_Region
    }
    var date: Date
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let timeInterval = dateFormatter.date(from: ReportDateString)
        
        return timeInterval!
    }
}
