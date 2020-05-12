//
//  Region.swift
//  Corona Tracker
//  Created by Mhd Hejazi on 3/13/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import Foundation

struct Region: Equatable, Codable
{
    
    static let worldWide = Region(countryName: "World Wide", countryNameAr: "", provinceName: "", location: .zero, emergencyNumber: "", IsCity: false)
    static let worldWideAr = Region(countryName: "World Wide", countryNameAr: "دول العالم", provinceName: "", location: .zero, emergencyNumber: "", IsCity: false)

    
	let countryName: String
    let countryNameAr: String
    let provinceName: String
	let location: Coordinate
    let emergencyNumber: String
    let IsCity : Bool
    var isProvince: Bool { !provinceName.isEmpty }
    
	var name: String { isProvince ? "\(provinceName), \(countryName)" : countryName }

	static func join(subRegions: [Region]) -> Region {
		assert(!subRegions.isEmpty)

		let countryName = subRegions.first!.countryName
        let countryNameAr = subRegions.first!.countryNameAr
		let provinceName = ""
        let emergencyNumber = subRegions.first!.emergencyNumber
        let IsCity = subRegions.first!.isProvince
		let coordinates = subRegions.map { $0.location }
		let totals = coordinates.reduce((latitude: 0.0, longitude: 0.0)) {
			($0.latitude + $1.latitude, $0.longitude + $1.longitude)
		}
		var location = Coordinate(latitude: totals.latitude / Double(coordinates.count),
								  longitude: totals.longitude / Double(coordinates.count))

		location = subRegions.min {
			location.distance(from: $0.location) < location.distance(from: $1.location)
		}!.location

        return Region(countryName: countryName, countryNameAr: countryNameAr, provinceName: provinceName, location: location, emergencyNumber: emergencyNumber, IsCity: IsCity)
	}

	func equals(other: Region) -> Bool {
		(self.countryName == other.countryName && self.provinceName == other.provinceName) ||
		self.location == other.location
	}

	static func == (lhs: Region, rhs: Region) -> Bool {
		return lhs.equals(other: rhs)
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(countryName)
		hasher.combine(provinceName)
	}
}
