//
//  CurrentStateChart.swift
//  Corona Tracker
//  Created by Mhd Hejazi on 3/13/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit

import Charts

class HistoryChartView: LineChartView
{
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)

        
		xAxis.gridColor = .lightGray
		xAxis.gridLineDashLengths = [3, 3]
		xAxis.labelPosition = .bottom
		xAxis.labelTextColor = SystemColor.secondaryLabel
		xAxis.valueFormatter = DayAxisValueFormatter(chartView: self)

//		leftAxis.drawGridLinesEnabled = false
		leftAxis.gridColor = .lightGray
		leftAxis.gridLineDashLengths = [3, 3]
		leftAxis.labelTextColor = SystemColor.secondaryLabel
		leftAxis.valueFormatter = DefaultAxisValueFormatter() { value, axis in
			value.kmFormatted
		}

		rightAxis.enabled = false

		dragEnabled = false
		scaleXEnabled = false
		scaleYEnabled = false

		noDataTextColor = .systemGray
		noDataFont = .systemFont(ofSize: 15)

		marker = SimpleMarkerView(chartView: self)

		initializeLegend(legend)
	}

	private func initializeLegend(_ legend: Legend) {
		legend.textColor = SystemColor.secondaryLabel
		legend.font = .systemFont(ofSize: 12, weight: .regular)
		legend.form = .circle
		legend.formSize = 12
		legend.horizontalAlignment = .center
		legend.xEntrySpace = 10
	}

    func update(series: TimeSeries?, countryName : String?)
    {
        //var deathTitle : String
        var recoveredTitle : String
        var confirmedTitle : String
        if Constants.lang == "ar"
        {
            //deathTitle = (Constants.deathTitleAr)
            recoveredTitle = (Constants.recoveredTitleAr)
            confirmedTitle = (Constants.confirmedTitleAr)
        }
        else
        {
            //deathTitle = (Constants.deathTitle)
            recoveredTitle = (Constants.recoveredTitle)
            confirmedTitle = (Constants.confirmedTitle)
        }
       
        
         guard let series = series else {
                  data = nil
                  return
              }
         
              let dates = series.series.keys.sorted()
             
              let confirmedEntries = dates.map {
                  ChartDataEntry(x: Double($0.referenceDays), y: Double(series.series[$0]?.existingCount ?? 0))
              }
              let recoveredEntries = dates.map {
                  ChartDataEntry(x: Double($0.referenceDays), y: Double(series.series[$0]?.recoveredCount ?? 0))
              }
              /*let deathsEntries = dates.map {
                  ChartDataEntry(x: Double($0.referenceDays), y: Double(series.series[$0]?.deathCount ?? 0))
              }*/

              let entries = [recoveredEntries, confirmedEntries] //deathsEntries,
              let colors = [UIColor.systemGreen, .systemRed] //.black,
              var dataSets = [LineChartDataSet]()
              
              let labels = [(recoveredTitle), (confirmedTitle)] //(deathTitle),
              for i in entries.indices
              {
                 let dataSet = LineChartDataSet(entries: entries[i], label: labels[i])
                 dataSet.mode = .cubicBezier
                 dataSet.drawValuesEnabled = false
                 dataSet.colors = [colors[i]]
                 dataSet.circleRadius = 2.5
                 dataSet.circleColors = [colors[i].withAlphaComponent(0.75)]

                 dataSet.drawCircleHoleEnabled = false
                 dataSet.circleHoleRadius = 1

                 dataSet.lineWidth = 1
                 dataSet.highlightLineWidth = 0

                 dataSets.append(dataSet)
               }

                 data = LineChartData(dataSets: dataSets)
                 animate(xAxisDuration: 2)
        
	}
    
    func updateCountries(countryName : String?, IsCity : Bool)
    {
        if IsCity
        {
            
        }
        else
        {
            //var deathTitle : String
            var recoveredTitle : String
            var confirmedTitle : String
            if Constants.lang == "ar"
            {
                //deathTitle = (Constants.deathTitleAr)
                recoveredTitle = (Constants.recoveredTitleAr)
                confirmedTitle = (Constants.confirmedTitleAr)
            }
            else
            {
                //deathTitle = (Constants.deathTitle)
                recoveredTitle = (Constants.recoveredTitle)
                confirmedTitle = (Constants.confirmedTitle)
            }
           
                var confirmedArray = [Int] ()
                var recoveredArray = [Int] ()
                //var deathsArray = [Int] ()
                var datesArray = [Date] ()
               
                let array  =  GlobalArray.shared.countriesTimeSeries.filter({ $0.Country_Region == countryName })
            
                for i in 0 ..< array.count
                {
                    confirmedArray.append((array[i].ConfirmedNumer - array[i].RecoveredNumber - array[i].DeathsNumber))
                    recoveredArray.append(array[i].RecoveredNumber)
                   // deathsArray.append(array[i].DeathsNumber)
                    datesArray.append(NSDate(timeIntervalSince1970: TimeInterval(array[i].ReportDate)) as Date)
                }
                
            
                let labels = [(recoveredTitle), (confirmedTitle)] //(deathTitle),
              
                var confirmedEntries : [ChartDataEntry] = [ChartDataEntry]()
                var recoveredEntries : [ChartDataEntry] = [ChartDataEntry]()
                //var deathsEntries : [ChartDataEntry] = [ChartDataEntry]()
                let colors = [UIColor.systemGreen, .systemRed] //.black,
                var dataSets = [LineChartDataSet]()
            
                for i in 0 ..< datesArray.count
                {
                    confirmedEntries.append(ChartDataEntry(x: Double(datesArray[i].referenceDays), y: Double(confirmedArray[i])))
                    recoveredEntries.append(ChartDataEntry(x: Double(datesArray[i].referenceDays), y: Double(recoveredArray[i])))
                    //deathsEntries.append(ChartDataEntry(x: Double(datesArray[i].referenceDays), y: Double(deathsArray[i])))
                }
            
                let entries = [recoveredEntries, confirmedEntries] //deathsEntries
                
                for i in entries.indices
                {
                
                    let dataSet = LineChartDataSet(entries: entries[i], label: labels[i])
                    dataSet.mode = .cubicBezier
                    dataSet.drawValuesEnabled = false
                    dataSet.colors = [colors[i]]
                    dataSet.circleRadius = 2.5
                    dataSet.circleColors = [colors[i].withAlphaComponent(0.75)]

                    dataSet.drawCircleHoleEnabled = false
                    dataSet.circleHoleRadius = 1

                    dataSet.lineWidth = 1
                    dataSet.highlightLineWidth = 0
                    
                    dataSets.append(dataSet)
                }

                    data = LineChartData(dataSets: dataSets)
                    animate(xAxisDuration: 2)
        }
    }
}
