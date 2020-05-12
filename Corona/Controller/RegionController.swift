//
//  RegionController.swift
//  Corona Tracker
//  Created by Mhd Hejazi on 3/13/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit
import Charts

class RegionController: UITableViewController {
	static let numberPercentSwitchInterval: TimeInterval = 3 /// Seconds

	var report: Report? {
		didSet {
			if report == nil {
				report = DataManager.instance.worldwideReport
			}

			if let region = report?.region {
				timeSeries = DataManager.instance.timeSeries(for: region)
			}
		}
	}
	private var timeSeries: TimeSeries?
	private var showPercents = false
	private var switchPercentsTask: DispatchWorkItem?

    @IBOutlet var shcBtn: UIButton!
    @IBOutlet var nhicBtn: UIButton!
	@IBOutlet var stackViewStats: UIStackView!
	@IBOutlet var labelTitle: UILabel!
    @IBOutlet var statusTitle: UILabel!
    @IBOutlet var countTitle: UILabel!
    @IBOutlet var newTitle: UILabel!
	@IBOutlet var labelConfirmed: UILabel!
    @IBOutlet var labelConfirmedNew: UILabel!
    @IBOutlet var labelConfirmedTitle: UILabel!
	@IBOutlet var labelRecovered: UILabel!
    @IBOutlet var labelRecoveredNew: UILabel!
    @IBOutlet var labelRecoveredTitle: UILabel!
	@IBOutlet var labelDeaths: UILabel!
    @IBOutlet var labelDeathsNew: UILabel!
    @IBOutlet var labelDeathsTitle: UILabel!
    @IBOutlet var labelTotal: UILabel!
    @IBOutlet var labelTotalTitle: UILabel!
    @IBOutlet var labelinformation: UILabel!
    
    
	@IBOutlet var chartViewCurrent: CurrentStateChartView!
	@IBOutlet var chartViewHistory: HistoryChartView!
	@IBOutlet var chartViewTopCountries: TopCountriesChartView!
	@IBOutlet var labelUpdated: UILabel!

	override func viewDidLoad() {
		super.viewDidLoad()
        
		view.backgroundColor = .clear
		tableView.tableFooterView = UIView()
        
    
		update()
	}

	override func didMove(toParent parent: UIViewController?) {
		super.didMove(toParent: parent)

		//updateParent()
	}

	func update() {
      
		if report == nil {
			report = DataManager.instance.worldwideReport
		}
        
        if Constants.lang == "ar"
        {
            tableView.semanticContentAttribute = .forceRightToLeft
            self.labelTitle.text = self.report?.region.countryNameAr ?? "-"
            self.statusTitle.text = Constants.statusTitleAr
            self.countTitle.text = Constants.countTitleAr
            self.newTitle.text = Constants.newTitleAr
        }
        else
        {
            tableView.semanticContentAttribute = .forceLeftToRight
            self.labelTitle.text = self.report?.region.countryName ?? "-"
            self.statusTitle.text = Constants.statusTitle
            self.countTitle.text = Constants.countTitle
            self.newTitle.text = Constants.newTitle
        }
        
        
          self.statusTitle.textAlignment = .center
          self.countTitle.textAlignment = .center
          self.newTitle.textAlignment = .left
       
        
        self.labelConfirmed.text = self.report?.stat.existingCountString ?? "-"
        self.labelRecovered.text = self.report?.stat.recoveredCountString ?? "-"
        self.labelDeaths.text = self.report?.stat.deathCountString ?? "-"
        self.labelTotal.text = self.report?.stat.confirmedCountString ?? "-"
        
        if self.report?.region.countryName == "World Wide"
        {
            self.labelConfirmedNew.text = NumberFormatter.groupingFormatter.string(from: NSNumber(value: ((self.report?.stat.existingPrevCount ?? 0))))
            self.labelRecoveredNew.text =  NumberFormatter.groupingFormatter.string(from: NSNumber(value: ((self.report?.stat.recoveredPrevCount ?? 0))))
            self.labelDeathsNew.text =  NumberFormatter.groupingFormatter.string(from: NSNumber(value: ((self.report?.stat.deathsPrevCount ?? 0))))
        }
        else
        {
            self.labelConfirmedNew.text = self.report?.stat.existingPrevCountString ?? "-"
            self.labelRecoveredNew.text = self.report?.stat.recoveredPrevCountString ?? "-"
            self.labelDeathsNew.text = self.report?.stat.deathPrevCountString ?? "-"
        }
       
        if self.report?.stat.existingPrevCount == 0  || self.report?.stat.recoveredPrevCount == 0  || self.report?.stat.deathsPrevCount == 0
       {
        
           self.labelDeathsNew.isHidden = true
           self.labelConfirmedNew.isHidden = true
           self.labelRecoveredNew.isHidden = true
           self.newTitle.isHidden = true
       }
       else if self.report?.stat.existingPrevCount != self.report?.stat.existingCount  || self.report?.stat.recoveredPrevCount != self.report?.stat.recoveredCount  || self.report?.stat.deathsPrevCount != self.report?.stat.deathCount
        {
            self.labelDeathsNew.isHidden = false
            self.labelConfirmedNew.isHidden = false
            self.labelRecoveredNew.isHidden = false
            self.newTitle.isHidden = false
        }
        else
        {
            self.labelDeathsNew.isHidden = true
            self.labelConfirmedNew.isHidden = true
            self.labelRecoveredNew.isHidden = true
            self.newTitle.isHidden = true
        }
        
       /* UIView.transition(with: stackViewStats, duration: 0.25, options: [.transitionCrossDissolve], animations: {
            
		}, completion: nil)*/

     
		chartViewCurrent.update(report: report)
        if report != nil
        {
            if report!.region.IsCity
            {
                chartViewHistory.isHidden = true
            }
            else
            {
                chartViewHistory.isHidden = false
                if  report?.region.countryName == "World Wide"
                   {
                       chartViewHistory.update(series: timeSeries, countryName: report!.region.countryName)
                   }
                   else
                   {
                        chartViewHistory.updateCountries(countryName: report!.region.countryName, IsCity: report!.region.IsCity)
                   }
            }
        }
       
        
		chartViewTopCountries.update()

		updateParent()

		updateStats(reset: true)
	}

	 func updateStats(reset: Bool = false) {
		
        if Constants.lang == "ar"
        {
            labelConfirmedTitle.text = Constants.confirmedTitleAr
            labelRecoveredTitle.text = Constants.recoveredTitleAr
            labelDeathsTitle.text = Constants.deathTitleAr
            labelTotalTitle.text = Constants.totalTitleAr
            labelinformation.text = Constants.informationAr
            labelinformation.textAlignment = .right
        }
        else
        {
            labelConfirmedTitle.text = Constants.confirmedTitle
            labelRecoveredTitle.text = Constants.recoveredTitle
            labelDeathsTitle.text = Constants.deathTitle
            labelTotalTitle.text = Constants.totalTitle
            labelinformation.text = Constants.information
            labelinformation.textAlignment = .left
        }
        
        switchPercentsTask?.cancel()
		let task = DispatchWorkItem {
			self.showPercents = !self.showPercents
			self.updateStats()
		}
		DispatchQueue.main.asyncAfter(deadline: .now() + Self.numberPercentSwitchInterval, execute: task)
		switchPercentsTask = task

		if reset {
			showPercents = false
			return
		}

		guard let report = report else { return }
        
        labelRecovered.transition {
            self.labelRecovered.text = self.showPercents ?
                report.stat.recoveredPercent.percentFormatted :
                report.stat.recoveredCountString
        }
        labelDeaths.transition {
            self.labelDeaths.text = self.showPercents ?
                report.stat.deathPercent.percentFormatted :
                report.stat.deathCountString
        }
        labelConfirmed.transition {
            self.labelConfirmed.text = self.showPercents ?
                report.stat.existingPercent.percentFormatted :
                report.stat.existingCountString
        }
        
        if report.region.countryName == "World Wide"
        {
            labelRecoveredNew.transition {
                self.labelRecoveredNew.text = self.showPercents ?
                    (100.0 * Double(report.stat.recoveredPrevCount) / Double(report.stat.recoveredCount)).percentFormatted :
                    NumberFormatter.groupingFormatter.string(from: NSNumber(value: ((report.stat.recoveredPrevCount))))
            }
            labelDeathsNew.transition {
                self.labelDeathsNew.text = self.showPercents ?
                    (100.0 * Double(report.stat.deathsPrevCount) / Double(report.stat.deathCount)).percentFormatted :
                    NumberFormatter.groupingFormatter.string(from: NSNumber(value: ((report.stat.deathsPrevCount))))
            }
            labelConfirmedNew.transition {
                self.labelConfirmedNew.text = self.showPercents ?
                    (100.0 * Double(report.stat.existingPrevCount) / Double(report.stat.existingCount)).percentFormatted :
                    NumberFormatter.groupingFormatter.string(from: NSNumber(value: ((report.stat.existingPrevCount))))
            }
        }
        
        else
        {
            labelRecoveredNew.transition {
                self.labelRecoveredNew.text = self.showPercents ?
                    report.stat.recoveredPrevPercent.percentFormatted :
                    report.stat.recoveredPrevCountString
            }
            labelDeathsNew.transition {
                self.labelDeathsNew.text = self.showPercents ?
                    report.stat.deathPrevPercent.percentFormatted :
                    report.stat.deathPrevCountString
            }
            labelConfirmedNew.transition {
                self.labelConfirmedNew.text = self.showPercents ?
                    report.stat.existingPrevPercent.percentFormatted :
                    report.stat.existingPrevCountString
            }
        }
        

	}

	func updateParent()
    {
        (parent as? RegionContainerController)?.countryName =  self.report?.region.countryName ?? ""
		(parent as? RegionContainerController)?.update(report: report)
	}
}

extension RegionController {
	@IBAction func labelStatTapped(_ sender: Any) {
		self.showPercents = !self.showPercents
		updateStats()
	}

	@IBAction func buttonLogarithmicTapped(_ sender: Any) {
		UIView.transition(with: chartViewTopCountries, duration: 0.25, options: [.transitionCrossDissolve], animations: {
			self.chartViewTopCountries.isLogarithmic = !self.chartViewTopCountries.isLogarithmic
		}, completion: nil)
	}

    @IBAction func shcBTNTapped(_ sender: Any)
    {
        guard let url = URL(string: "https://shc.gov.sa") else { return }
        UIApplication.shared.open(url)
    }
    
    @IBAction func nhicBTNTapped(_ sender: Any)
    {
        guard let url = URL(string: "https://nhic.gov.sa") else { return }
        UIApplication.shared.open(url)
    }
    
	@IBAction func buttonInfoTapped(_ sender: Any)
    {
		guard let url = URL(string: "https://coronamap.sa") else { return }
        UIApplication.shared.open(url)
	}
}
