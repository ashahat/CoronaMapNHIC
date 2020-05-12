//
//  ReportAnnotationView.swift
//  Corona Tracker
//  Created by Mhd Hejazi on 3/13/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import MapKit

class InsetLabel: UILabel {

    let inset = UIEdgeInsets(top: -2, left: 10, bottom: -2, right: 10)

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: inset))
    }

    override var intrinsicContentSize: CGSize {
        var intrinsicContentSize = super.intrinsicContentSize
        intrinsicContentSize.width += inset.left + inset.right
        intrinsicContentSize.height += inset.top + inset.bottom
        return intrinsicContentSize
    }

}

 func heightForView(text:NSMutableAttributedString) -> CGFloat{
    let label:UILabel = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width:  CGFloat.greatestFiniteMagnitude, height:  CGFloat.greatestFiniteMagnitude)))
    label.numberOfLines = 10
    label.lineBreakMode = NSLineBreakMode.byWordWrapping
    label.attributedText = text

    label.sizeToFit()
    return label.frame.width
}


class ReportAnnotationView: MKAnnotationView
{
    let label:UILabel = InsetLabel()
   // label = InsetLabel.init(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 180, height: 150)))
    override func setSelected(_ selected: Bool, animated: Bool)
      {
          super.setSelected(false, animated: animated)
       
       
          if(selected)
          {
            var confirmedTitle = ""
            var recoveredTitle = ""
            var deathTitle = ""
            var totalTitle = ""
            var countryName = ""
            
            if Constants.lang == "ar"
            {
                confirmedTitle = Constants.confirmedTitleAr
                recoveredTitle = Constants.recoveredTitleAr
                deathTitle = Constants.deathTitleAr
                totalTitle = Constants.totalTitleAr
                countryName  = (report?.region.countryNameAr ?? "") as String
            }
            else
            {
                confirmedTitle = Constants.confirmedTitle
                recoveredTitle = Constants.recoveredTitle
                deathTitle = Constants.deathTitle
                totalTitle = Constants.totalTitle
                countryName  = (report?.region.countryName ?? "") as String
            }
            
             let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .footnote).withSymbolicTraits(.traitBold)
             let descriptorTilte = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title1)
             let boldFont = UIFont(descriptor: descriptor!, size: 0)
             let string = NSMutableAttributedString()
          
            string.append(NSAttributedString(string: countryName, attributes: [.foregroundColor: UIColor.black, .font:  UIFont(descriptor: descriptorTilte, size: 17)]))
            
              string.append(NSAttributedString(string: "\n"))
             
             string.append(NSAttributedString(string: (confirmedTitle)))
            
             string.append(NSAttributedString(string: ": "))
             string.append(NSAttributedString(string: report?.stat.existingCountString ?? "",
                 attributes: [.foregroundColor: UIColor.systemRed, .font: boldFont]))

             string.append(NSAttributedString(string: "\n"))
             
             string.append(NSAttributedString(string: (recoveredTitle)))
             
             string.append(NSAttributedString(string: ": "))
             string.append(NSAttributedString(string: report?.stat.recoveredCountString ?? "",
                 attributes: [.foregroundColor : UIColor.systemGreen, .font: boldFont]))

             string.append(NSAttributedString(string: "\n"))
             string.append(NSAttributedString(string: (deathTitle)))
             string.append(NSAttributedString(string: ": "))
             string.append(NSAttributedString(string: report?.stat.deathCountString ?? "",
                                              attributes: [.foregroundColor : UIColor.black, .font: boldFont]))
             
             string.append(NSAttributedString(string: "\n"))
             string.append(NSAttributedString(string: (totalTitle)))
             string.append(NSAttributedString(string: ": "))
                    string.append(NSAttributedString(string: report?.stat.confirmedCountString ?? "",
                                                     attributes: [.foregroundColor : UIColor(red: 35/255, green: 98/255, blue: 206/255, alpha: 1), .font: boldFont]))
              //string.append(NSAttributedString(string: "\n"))
            
            label.frame = CGRect(x: 0, y: 0, width: heightForView(text: string)+20, height:150) //
            label.textColor = .systemGray
            label.font = UIFont(descriptor: .preferredFontDescriptor(withTextStyle: .footnote), size: 0)
            
            label.attributedText = string
            label.adjustsFontSizeToFitWidth = true
            if Constants.lang == "ar"
            {
                label.textAlignment = .right
            }
            else
            {
                label.textAlignment = .left
            }
            label.numberOfLines = 0
            label.layer.masksToBounds = true

            label.center.x = 0.5 * self.frame.size.width
            label.center.y = -0.5 * label.frame.height
            label.backgroundColor = UIColor.white
            label.layer.cornerRadius = 10
            
            self.addSubview(label)
          }
          else
          {
              label.removeFromSuperview()
          }
      }
    
	private lazy var countLabel: UILabel = {
		let countLabel = UILabel()
		countLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		countLabel.backgroundColor = .clear
		countLabel.font = .boldSystemFont(ofSize: 13)
		countLabel.textColor = .white
		countLabel.textAlignment = .center
		countLabel.adjustsFontSizeToFitWidth = true
		countLabel.minimumScaleFactor = 0.5
		countLabel.baselineAdjustment = .alignCenters
		self.addSubview(countLabel)
		return countLabel
        
	}()

	private var radius: CGFloat {
		guard let annotation = annotation as? ReportAnnotation else { return 1 }
		let number = CGFloat(annotation.report.stat.confirmedCount)
		return 10 + log( 1 + number) * CGFloat(mapZoomLevel - 2.2)
	}

	private var color: UIColor {
		guard let annotation = annotation as? ReportAnnotation else { return .clear }
		let number = CGFloat(annotation.report.stat.confirmedCount)
		let level = log10(number + 10) * 2
		let brightness = max(0, 255 - level * 40) / 255;
		let saturation = brightness > 0 ? 1 : max(0, 255 - ((level * 40) - 255)) / 255;
		return UIColor(red: saturation, green: brightness, blue: brightness * 0.4, alpha: 0.8)
	}

	var report: Report? {
		(annotation as? ReportAnnotation)?.report
	}

	var mapZoomLevel: CGFloat = 1 {
		didSet {
			if mapZoomLevel.rounded() == oldValue.rounded() {
				return
			}

			configure()
		}
	}

	override var annotation: MKAnnotation? {
		didSet {
			configure()
		}
	}

	private lazy var rightAccessoryView: UIView? = {
		let button = UIButton(type: .detailDisclosure)
		button.addAction {
			MapController.instance.updateRegionScreen(report: self.report)
			MapController.instance.showRegionScreen()
		}
		return button
	}()

	override init(annotation: MKAnnotation?, reuseIdentifier: String?)
    {
		super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

		//canShowCallout = true

		layer.borderColor = UIColor.white.cgColor
		layer.borderWidth = 2
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func configure() {
		guard let report = report else { return }
		if self.mapZoomLevel > 4 {
			self.countLabel.text = NumberFormatter.groupingFormatter.string(from: NSNumber(value: report.stat.existingCount))!
            
			self.countLabel.font = .boldSystemFont(ofSize: 13 * max(1, log(self.mapZoomLevel - 2)))
			self.countLabel.alpha = 1
		}
		else {
			self.countLabel.alpha = 0
		}

		let diameter = self.radius * 2
		self.frame.size = CGSize(width: diameter, height: diameter)

        if(report.stat.existingCount < 500)
        {
            self.backgroundColor = UIColor(red: 242/255, green: 157/255, blue: 57/255, alpha: 1)
        }
        else if(report.stat.existingCount >= 500 && report.stat.existingCount < 1000)
        {
            self.backgroundColor = UIColor(red: 238/255, green: 112/255, blue: 45/255, alpha: 1)
        }
        else if(report.stat.existingCount >= 1000 && report.stat.existingCount < 10000)
        {
            self.backgroundColor = UIColor(red: 235/255, green: 50/255, blue: 36/255, alpha: 1)
        }
        else
        {
            self.backgroundColor = UIColor(red: 188/255, green: 39/255, blue: 27/255, alpha: 1)
        }
        
		
		self.layer.cornerRadius = self.frame.width / 2
	}
    

	override func layoutSubviews() {
		super.layoutSubviews()

		countLabel.frame = bounds
	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)
      
	}

}
