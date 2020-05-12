//
//  CurrentStateChart.swift
//  Corona Tracker
//  Created by Mhd Hejazi on 3/13/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit

import Charts

class TopCountriesChartView: BarChartView {
	var isLogarithmic = false {
		didSet {
			self.clear()
			self.update()
		}
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)

		xAxis.drawGridLinesEnabled = false
		xAxis.labelPosition = .bottom
		xAxis.labelTextColor = SystemColor.secondaryLabel
		xAxis.valueFormatter = DefaultAxisValueFormatter(block: { value, axis in
        guard let entry = self.barData?.dataSets.first?.entryForIndex(Int(value)) as? BarChartDataEntry,
            let report = entry.data as? Report else
            {
                return value.description
            }

            if Constants.lang == "ar"
            {
                return report.region.countryNameAr.replacingOccurrences(of: " ", with: "\n")
            }
            else
            {
                return report.region.countryName.replacingOccurrences(of: " ", with: "\n")
            }
		})

		leftAxis.gridColor = .lightGray
		leftAxis.gridLineDashLengths = [3, 3]
		leftAxis.labelTextColor = SystemColor.secondaryLabel
		leftAxis.valueFormatter = DefaultAxisValueFormatter() { value, axis in
			self.isLogarithmic ? pow(10, value).kmFormatted : value.kmFormatted
		}

		rightAxis.enabled = false

		dragEnabled = false
		scaleXEnabled = false
		scaleYEnabled = false

		fitBars = true

		noDataTextColor = .systemGray
		noDataFont = .systemFont(ofSize: 15)
        noDataTextAlignment = .right

		let simpleMarker = SimpleMarkerView(chartView: self) { (entry, highlight) in
        guard let report = entry.data as? Report else { return entry.y.kmFormatted }
            if Constants.lang == "ar"
            {
                return report.stat.descriptionAr
            }
            else
            {
                return report.stat.description
            }
            
		}
        
		simpleMarker.timeout = 5
		marker = simpleMarker

		initializeLegend(legend)
	}

	private func initializeLegend(_ legend: Legend) {
		legend.textColor = SystemColor.secondaryLabel
		legend.font = .systemFont(ofSize: 12, weight: .regular)
		legend.form = .none
		legend.formSize = 0
		legend.horizontalAlignment = .center
		legend.xEntrySpace = 0
		legend.formToTextSpace = 0
		legend.stackSpace = 0
	}

	func update() {
		let reports = DataManager.instance.topReports

		var entries = [BarChartDataEntry]()
		for i in reports.indices {
			let report = reports[i]
			var value = Double(report.stat.existingCount)
			if isLogarithmic {
				value = log10(value)
			}
			let entry = BarChartDataEntry(x: Double(i), y: value)
			entry.data = report
			entries.append(entry)
		}
        
        if Constants.lang == "ar"
        {
            let label = "اكثر الدول المتأثرة (المصابون)"
            let dataSet = BarChartDataSet(entries: entries, label: label)
            dataSet.colors = ChartColorTemplates.pastel()

    //        dataSet.drawValuesEnabled = false
            dataSet.valueTextColor = SystemColor.secondaryLabel
            dataSet.valueFont = .systemFont(ofSize: 12, weight: .regular)
            dataSet.valueFormatter = DefaultValueFormatter(block: { value, entry, dataSetIndex, viewPortHandler in
                guard let report = entry.data as? Report else { return value.kmFormatted }
                return report.stat.existingCount.kmFormatted
                })
            
            if isLogarithmic {
                leftAxis.axisMinimum = 2
                leftAxis.axisMaximum = 6
                leftAxis.labelCount = 4
            }
            else {
                leftAxis.resetCustomAxisMin()
                leftAxis.resetCustomAxisMax()
            }

            data = BarChartData(dataSet: dataSet)

            animate(yAxisDuration: 2)
        }
        else
        {
            let label = "Most affected countries (Active Patients)"
                    let dataSet = BarChartDataSet(entries: entries, label: label)
                    dataSet.colors = ChartColorTemplates.pastel()

            //        dataSet.drawValuesEnabled = false
                    dataSet.valueTextColor = SystemColor.secondaryLabel
                    dataSet.valueFont = .systemFont(ofSize: 12, weight: .regular)
                    dataSet.valueFormatter = DefaultValueFormatter(block: { value, entry, dataSetIndex, viewPortHandler in
                        guard let report = entry.data as? Report else { return value.kmFormatted }
                        return report.stat.existingCount.kmFormatted
                    })
                
            if isLogarithmic {
                leftAxis.axisMinimum = 2
                leftAxis.axisMaximum = 6
                leftAxis.labelCount = 4
            }
            else {
                leftAxis.resetCustomAxisMin()
                leftAxis.resetCustomAxisMax()
            }

            data = BarChartData(dataSet: dataSet)

            animate(yAxisDuration: 2)
        }
		

		
	}
}
