//
//  Statistic.swift
//  Corona Tracker
//  Created by Mhd Hejazi on 3/13/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import Foundation

struct Statistic: CustomStringConvertible, Codable {
	
    let confirmedCount: Int
	let recoveredCount: Int
	let deathCount: Int
    let confirmedPrevCount: Int
    let recoveredPrevCount: Int
    let deathsPrevCount: Int
    let country_Name: String
    let IsCity: Bool
    
	var existingCount: Int { confirmedCount - recoveredCount - deathCount }
    var existingPrevCount: Int { confirmedPrevCount - recoveredPrevCount - deathsPrevCount }
    
    var recoveredPercent: Double { recoveredCount == 0 ? 0 : 100.0 * Double(recoveredCount) / Double(confirmedCount) }
	var deathPercent: Double { deathCount == 0 ? 0 :  100.0 * Double(deathCount) / Double(confirmedCount) }
	var existingPercent: Double { existingCount == 0 ? 0 :  100.0 * Double(existingCount) / Double(confirmedCount) }
    
    var recoveredPrevPercent: Double { recoveredCount == 0 ? 0 : 100.0 * Double(recoveredCount - recoveredPrevCount) / Double(recoveredCount)}
    var deathPrevPercent: Double { deathCount == 0 ? 0 :  100.0 * Double(deathCount - deathsPrevCount)  / Double(deathCount)}
    var existingPrevPercent: Double { confirmedCount == 0 ? 0 :  100.0 * Double(confirmedCount - confirmedPrevCount) / Double(confirmedCount) }

	var confirmedCountString: String { NumberFormatter.groupingFormatter.string(from: NSNumber(value: confirmedCount))! }
	
    var recoveredCountString: String { NumberFormatter.groupingFormatter.string(from: NSNumber(value: recoveredCount))! }
	var deathCountString: String { NumberFormatter.groupingFormatter.string(from: NSNumber(value: deathCount))! }
    var existingCountString: String { NumberFormatter.groupingFormatter.string(from: NSNumber(value: existingCount))! }
    
    var confirmedPrevCountString: String { NumberFormatter.groupingFormatter.string(from: NSNumber(value: (confirmedCount - confirmedPrevCount)))! }
    
    var recoveredPrevCountString: String { NumberFormatter.groupingFormatter.string(from: NSNumber(value: (recoveredCount - recoveredPrevCount)))! }
    var deathPrevCountString: String { NumberFormatter.groupingFormatter.string(from: NSNumber(value: (deathCount - deathsPrevCount)))! }
    var existingPrevCountString: String { NumberFormatter.groupingFormatter.string(from: NSNumber(value: (confirmedCount - confirmedPrevCount)))! }

    var descriptionAr: String {
        """
          \(Constants.confirmedTitleAr) : \(existingCountString)  (\(existingPercent.percentFormatted))
          \(Constants.recoveredTitleAr) : \(recoveredCountString) (\(recoveredPercent.percentFormatted))
          \(Constants.deathTitleAr) : \(deathCountString) (\(deathPercent.percentFormatted))
          \(Constants.totalTitleAr) : \(confirmedCountString)
        """
    }
    
    var description: String {
        """
        \(Constants.confirmedTitle) : \(existingCountString)  (\(existingPercent.percentFormatted))
        \(Constants.recoveredTitle) : \(recoveredCountString) (\(recoveredPercent.percentFormatted))
        \(Constants.deathTitle) : \(deathCountString) (\(deathPercent.percentFormatted))
        \(Constants.totalTitle) : \(confirmedCountString)
        """
    }
    
	static func join(subData: [Statistic]) -> Statistic
    {
        
        return   Statistic(
            confirmedCount: subData.reduce(0)
            {
                $1.IsCity ? $0 : $0 + $1.confirmedCount
            },
            recoveredCount: subData.reduce(0)
            {
                $1.IsCity ? $0 : $0 + $1.recoveredCount
            },
            deathCount: subData.reduce(0)
            {
                $1.IsCity ? $0 : $0 + $1.deathCount
                
            },
            confirmedPrevCount: subData.reduce(0)
            {
                $1.IsCity ? $0 : $0 + ($1.confirmedCount - $1.confirmedPrevCount)
            },
            recoveredPrevCount: subData.reduce(0)
            {
                $1.IsCity ? $0 : $0 + ($1.recoveredCount - $1.recoveredPrevCount)
            },
            deathsPrevCount: subData.reduce(0)
            {
                $1.IsCity ? $0 : $0 + ($1.deathCount - $1.deathsPrevCount)
                
            },
            country_Name: "" , IsCity: false )
        
       
	}
}
