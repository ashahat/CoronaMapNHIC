//
//  RegionContainerController.swift
//  Corona Tracker
//  Created by Mhd Hejazi on 3/13/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage


class RegionContainerController: UIViewController {
	var regionController: RegionController!
   private var phoneNumber = ""
	var isUpdating: Bool = false {
		didSet {
			//updateTime()
		}
	}
    
    
	@IBOutlet var effectViewBackground: UIVisualEffectView!
	@IBOutlet var effectViewHeader: UIVisualEffectView!
	@IBOutlet var labelTitle: UILabel!
	@IBOutlet var labelUpdated: UILabel!
    @IBOutlet var ergencyNumberBtn: UIButton!
    @IBOutlet var countryFlagImage: UIImageView!
    var countryName : String?
    
	override func viewDidLoad() {
		super.viewDidLoad()
        
        self.ergencyNumberBtn.addTarget(self, action:#selector(self.buttonClicked), for: .touchUpInside)
        
		if #available(iOS 13.0, *) {
			effectViewBackground.effect = UIBlurEffect(style: .systemMaterial)
			effectViewBackground.contentView.alpha = 0

			effectViewHeader.effect = UIBlurEffect(style: .systemMaterial)
		}
	}
    
    @objc func buttonClicked() {
        if let url = URL(string: "tel://\(phoneNumber)")
        {
            UIApplication.shared.open(url)
        }
        
    }

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.destination is RegionController {
			regionController = segue.destination as? RegionController
		}
	}
    
	func update(report: Report?) {
		
        UIView.transition(with: view, duration: 0.25, options: [.transitionCrossDissolve], animations: {
            if Constants.lang == "ar"
            {
                 self.labelTitle.text = report?.region.countryNameAr ?? "لا توجد معلومات"
            }
            else
            {
                 self.labelTitle.text = report?.region.countryName ?? "No information found"
            }
            
            if report?.region.emergencyNumber == nil || report?.region.emergencyNumber == "" || report?.region.emergencyNumber == "0"
            {
                self.ergencyNumberBtn.isHidden = true
                self.phoneNumber = ""
            }
            else
            {
                self.ergencyNumberBtn.isHidden = false
                self.phoneNumber = (report?.region.emergencyNumber)!
            }
            
            if let imageName = self.countryName
            {
                if imageName == "World Wide"
                {
                    self.countryFlagImage.image = UIImage(named: "globe")
                }
                else
                {
                     let countryName = imageName.replacingOccurrences(of: " ", with: "%20")
                    AF.request("").responseImage { response in
                    switch response.result {
                       case .success (let image):
                            self.countryFlagImage.image = image
                       case .failure:
                            self.countryFlagImage.image = nil
                       }
                
                    }
                }
            }
		}, completion: nil)
    }
}
