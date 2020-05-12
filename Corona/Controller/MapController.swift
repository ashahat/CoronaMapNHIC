//
//  ViewController.swift
//  Corona Tracker
//  Created by Mhd Hejazi on 3/13/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

import FloatingPanel
import PKHUD
import ExpandingMenu
import Assistant
import SCLAlertView



class MapController: UIViewController, CLLocationManagerDelegate
{
	private static let cityZoomLevel = CGFloat(5)
	private static let updateInterval: TimeInterval = 60 * 30 /// 30 mins

	static var instance: MapController!

	private var allAnnotations: [ReportAnnotation] = []
	private var countryAnnotations: [ReportAnnotation] = []
	private var currentAnnotations: [ReportAnnotation] = []

	private var panelController: FloatingPanelController!
	private var regionContainerController: RegionContainerController!
    private var regionController: RegionController!
    
    var location: CLLocation!
    
    var chatTitle = ""
    var langTitle = ""
    var settingsTitle = ""
    var okTitle = ""
    var cancelTitle = ""
    var aboutTitle = ""
    var updateTitle = ""

	@IBOutlet var mapView: MKMapView!
	@IBOutlet var effectView: UIVisualEffectView!
    @IBOutlet var appTitle: UILabel!
    
    fileprivate let locationManager:CLLocationManager = CLLocationManager()
    override func viewDidLoad() {
		super.viewDidLoad()
     
        
        if UserDefaults.standard.string(forKey: "lang") == nil
        {
            UserDefaults.standard.set("ar", forKey: "lang")
            Constants.lang = "ar"
        }
        else
        {
            Constants.lang = UserDefaults.standard.string(forKey: "lang")!
        }
        
        if UserDefaults.standard.string(forKey: "showCity") == nil
        {
            UserDefaults.standard.set(true, forKey: "showCity")
        }
        
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled()
        {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = kCLDistanceFilterNone
            locationManager.startUpdatingLocation()
           
        }
       
        mapView.showsUserLocation = true
        mapView.delegate = self
        mapView.mapType = .standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
    
		MapController.instance = self
        configureExpandingMenuButton()
       
        if Constants.lang == "ar"
        {
            self.appTitle.text = Constants.appTitleAr
        }
        else
        {
            self.appTitle.text = Constants.appTitle
        }

		if #available(iOS 13.0, *) {
			effectView.effect = UIBlurEffect(style: .systemThinMaterial)
		}

		let identifier = String(describing: RegionContainerController.self)
		regionContainerController = storyboard?.instantiateViewController(withIdentifier: identifier) as? RegionContainerController
		initializeBottomSheet()
        mapView.register(ReportAnnotationView.self,forAnnotationViewWithReuseIdentifier: ReportAnnotation.reuseIdentifier)
         
        self.locationManager.requestAlwaysAuthorization()

        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled()
        {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
		
        
           // Do any additional setup after loading the view, typically from a nib.
                
        self.updateMap()
        addMapTrackingButton()
        
        
        //createPolyline()
	}
    
    
    func addMapTrackingButton(){
        let buttonItem = MKUserTrackingButton(mapView: mapView)
        
        buttonItem.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 35, height: 35))
        buttonItem.center = CGPoint(x: self.view.bounds.width - 30.0, y: 100)
        buttonItem.layer.backgroundColor = UIColor(white: 1, alpha: 0.8).cgColor
        buttonItem.layer.borderColor = UIColor.white.cgColor
        buttonItem.layer.borderWidth = 1
        buttonItem.layer.cornerRadius = 5
        view.addSubview(buttonItem)
        
       
    }
    
    /*func createPolyline() {
       
        let point1 = CLLocationCoordinate2D(latitude: 24.470458, longitude: 39.641289);
        let point2 = CLLocationCoordinate2D(latitude: 24.468865, longitude: 39.620650);
        let point3 = CLLocationCoordinate2D(latitude: 24.464284, longitude: 39.617587);
        let point4 = CLLocationCoordinate2D(latitude: 24.463023, longitude: 39.610075);
        let point5 = CLLocationCoordinate2D(latitude: 24.441181, longitude: 39.626046);
        let point6 = CLLocationCoordinate2D(latitude: 24.432948, longitude: 39.632027); //24.441938  39.638269
        let point7 = CLLocationCoordinate2D(latitude: 24.441938, longitude: 39.638269);
        let point8 = CLLocationCoordinate2D(latitude: 24.447359, longitude: 39.645253);
        let point9 = CLLocationCoordinate2D(latitude: 24.461363, longitude: 39.639611);
        let point10 = CLLocationCoordinate2D(latitude: 24.463289, longitude: 39.643622);
        let point11 = CLLocationCoordinate2D(latitude: 24.470458, longitude: 39.641289);
        

        let points: [CLLocationCoordinate2D]
        points = [point1, point2, point3, point4, point5, point6, point7, point8, point9, point10, point11]

        let geodesic = MKPolyline(coordinates: points, count: 7)
        
        mapView.addOverlay(geodesic)
    }*/
    
    
    func updateMap()
    {
        //self.update()
        self.downloadIfNeeded()
       
        Timer.scheduledTimer(withTimeInterval: Self.updateInterval, repeats: true) { _ in
            self.downloadIfNeeded()
        }
    }
    fileprivate func configureExpandingMenuButton()
    {
        if let viewWithTag = self.view.viewWithTag(555)
        {
            viewWithTag.removeFromSuperview()
        }
    
        if Constants.lang == "ar"
        {
            chatTitle = Constants.chatTitleAr
            langTitle = Constants.langTitle
            aboutTitle = Constants.aboutTitleAr
            updateTitle = Constants.updateTitleAr
            chatTitle = Constants.chatTitleAr
            settingsTitle = Constants.settingsTitleAr
        }
        else
        {
            chatTitle = Constants.chatTitle
            langTitle = Constants.langTitleAr
            aboutTitle = Constants.aboutTitle
            updateTitle = Constants.updateTitle
            chatTitle = Constants.chatTitle
            settingsTitle = Constants.settingsTitle
        }
        
        let menuButtonSize: CGSize = CGSize(width: 64.0, height: 64.0)
        let menuButton = ExpandingMenuButton(frame: CGRect(origin: CGPoint.zero, size: menuButtonSize), image: UIImage(named: "chooser-button-tab")!, rotatedImage: UIImage(named: "chooser-button-tab-highlighted")!)
        menuButton.tag = 555
        menuButton.center = CGPoint(x: self.view.bounds.width - 30.0, y: self.view.bounds.height - 320.0)
            
        self.view.addSubview(menuButton)
           
        let langItem = ExpandingMenuItem(size: menuButtonSize, title: settingsTitle, image: UIImage(named: "menu-settings")!, highlightedImage: UIImage(named: "menu-settings")!, backgroundImage: UIImage(named: "chooser-moment-button"), backgroundHighlightedImage: UIImage(named: "chooser-moment-button-highlighted")) { () -> Void in
               
            if Constants.lang == "ar"
            {
                self.settingsTitle = Constants.settingsTitleAr
                self.okTitle = Constants.okTitle
                self.cancelTitle = Constants.cancelTitle
                
                
                let appearance = SCLAlertView.SCLAppearance(
                        showCloseButton: false // if you dont want the close button use false
                    )
                    let alertView = SCLAlertView(appearance: appearance)
                    let alertViewIcon = UIImage(named: "menu-settings")
                 if UserDefaults.standard.bool(forKey: "showCity") == true
                 {
                    alertView.addButton(Constants.hideCityArTitle)
                    {
                       UserDefaults.standard.set(false, forKey: "showCity")
                       self.updateMap()
                       self.updateRegionScreen(report: (self.view as? ReportAnnotationView)?.report)
                       self.configureExpandingMenuButton()
                     
                    }
                 }
                else
                {
                    alertView.addButton(Constants.showCityArTitle)
                    {
                       UserDefaults.standard.set(true, forKey: "showCity")
                       self.updateMap()
                       self.updateRegionScreen(report: (self.view as? ReportAnnotationView)?.report)
                       self.configureExpandingMenuButton()
                    }
                }
                alertView.addButton(Constants.changeToEnTitle) {
                                       
                       UserDefaults.standard.set("en", forKey: "lang")
                       Constants.lang = "en"
                   
                       self.updateMap()
                       self.updateRegionScreen(report: (self.view as? ReportAnnotationView)?.report)
                       self.configureExpandingMenuButton()
                       self.appTitle.text = Constants.appTitle


                   }
                alertView.addButton(Constants.cancelTitleAr) {
                }
                alertView.showSuccess(self.settingsTitle, subTitle: "الرجاء الضغط على الإختيار المناسب" , circleIconImage: alertViewIcon)
                
            }
            else
            {
                self.settingsTitle = Constants.settingsTitle
                self.okTitle = Constants.okTitleAr
                self.cancelTitle = Constants.cancelTitleAr
                
                let appearance = SCLAlertView.SCLAppearance(
                       showCloseButton: false // if you dont want the close button use false
                   )
                   let alertView = SCLAlertView(appearance: appearance)
                   let alertViewIcon = UIImage(named: "menu-settings")
                   if UserDefaults.standard.bool(forKey: "showCity") == true
                   {
                        alertView.addButton(Constants.hideCityEnTitle)
                        {
                           UserDefaults.standard.set(false, forKey: "showCity")
                           self.updateMap()
                           self.updateRegionScreen(report: (self.view as? ReportAnnotationView)?.report)
                           self.configureExpandingMenuButton()
                         
                        }
                   }
                   else
                   {
                        alertView.addButton(Constants.showCityEnTitle)
                        {
                           UserDefaults.standard.set(true, forKey: "showCity")
                           self.updateMap()
                           self.updateRegionScreen(report: (self.view as? ReportAnnotationView)?.report)
                           self.configureExpandingMenuButton()
                        }
                   }
                   alertView.addButton(Constants.changeToArTitle) {
                       
                      UserDefaults.standard.set("ar", forKey: "lang")
                      Constants.lang = "ar"
                      self.updateMap()
                      self.updateRegionScreen(report: (self.view as? ReportAnnotationView)?.report)
                      self.configureExpandingMenuButton()
                      self.appTitle.text = Constants.appTitleAr


                   }
               alertView.addButton(Constants.cancelTitle){}
               alertView.showSuccess(self.settingsTitle, subTitle: "Please select the needed option", circleIconImage: alertViewIcon)
            }
            
           }
           
           let aboutItem = ExpandingMenuItem(size: menuButtonSize, title: aboutTitle, image: UIImage(named: "menu-info")!, highlightedImage: UIImage(named: "menu-info")!, backgroundImage: UIImage(named: "chooser-moment-button"), backgroundHighlightedImage: UIImage(named: "chooser-moment-button-highlighted")) { () -> Void in
              
            if Constants.lang == "ar"
            {
                self.settingsTitle = Constants.settingsTitleAr
                self.okTitle = Constants.closeTitleAr
                self.cancelTitle = Constants.cancelTitleAr
                SCLAlertView().showInfo(self.aboutTitle, subTitle: "تم بناء التطبيق من قبل المركز الوطني للمعلومات الصحية - المجلس الصحي السعودي",closeButtonTitle: Constants.closeTitleAr)
            }
            else
            {
                self.settingsTitle = Constants.settingsTitle
                self.okTitle = Constants.closeTitle
                self.cancelTitle = Constants.cancelTitle
                SCLAlertView().showInfo(self.aboutTitle, subTitle: "The application was built by the National Health Information Center - Saudi Health Council",closeButtonTitle: Constants.closeTitle)
            }
            
           }
            
           let refreshItem = ExpandingMenuItem(size: menuButtonSize, title: updateTitle, image: UIImage(named: "menu-synchronize")!, highlightedImage: UIImage(named: "menu-synchronize")!, backgroundImage: UIImage(named: "chooser-moment-button"), backgroundHighlightedImage: UIImage(named: "chooser-moment-button-highlighted")) { () -> Void in
           
            self.updateMap()
            self.updateRegionScreen(report: (self.view as? ReportAnnotationView)?.report)
           }
        
            let chatItem = ExpandingMenuItem(size: menuButtonSize, title: chatTitle, image: UIImage(named: "menu-chat")!, highlightedImage: UIImage(named: "menu-chat")!, backgroundImage: UIImage(named: "chooser-moment-button"), backgroundHighlightedImage: UIImage(named: "chooser-moment-button-highlighted")) { () -> Void in
                
                self.performSegue(withIdentifier: "chatSeque", sender: self)
            }
            
            
           
           menuButton.addMenuItems([aboutItem, langItem, refreshItem, chatItem])
           menuButton.willPresentMenuItems = { (menu) -> Void in}
           menuButton.didDismissMenuItems = { (menu) -> Void in}
       }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		panelController.addPanel(toParent: self, animated: true)
		regionContainerController.regionController.tableView.setContentOffset(.zero, animated: false)
	}
    
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		panelController.removePanelFromParent(animated: animated)
	}
    
	private func initializeBottomSheet() {
		panelController = FloatingPanelController()
        panelController.delegate = self
		panelController.surfaceView.cornerRadius = 12
		panelController.surfaceView.shadowHidden = false
		panelController.set(contentViewController: regionContainerController)
		panelController.track(scrollView: regionContainerController.regionController.tableView)
		panelController.surfaceView.backgroundColor = .clear
		panelController.surfaceView.contentView.backgroundColor = .clear
	}

	func updateRegionScreen(report: Report?) {
		regionContainerController.regionController.report = report
		regionContainerController.regionController.update()
	}

	func showRegionScreen() {
		panelController.move(to: .full, animated: true)
	}

	func hideRegionScreen() {
		panelController.move(to: .half, animated: true)
	}

    @IBAction func findMyLocation(_ sender: Any) {
           let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
           let span = MKCoordinateSpan.init(latitudeDelta: 0.003, longitudeDelta: 0.003)
           let region = MKCoordinateRegion(center: center, span: span)
           self.mapView.setRegion(region, animated: true)
           
       }
    
	private func update()
    {
        if UserDefaults.standard.bool(forKey: "showCity") == true
        {
            allAnnotations = DataManager.instance.allReports
                .filter({ $0.stat.existingCount > 0})
                .map({ ReportAnnotation(report: $0) })

            countryAnnotations = DataManager.instance.countryReports
                .filter({ $0.stat.existingCount > 0})
                .map({ ReportAnnotation(report: $0) })
        }
        else
        {
            allAnnotations = DataManager.instance.allReports
                .filter({ $0.stat.existingCount > 0 && $0.region.IsCity == false})
                .map({ ReportAnnotation(report: $0) })

            countryAnnotations = DataManager.instance.countryReports
                .filter({ $0.stat.existingCount > 0 && $0.region.IsCity == false})
                .map({ ReportAnnotation(report: $0) })
        }
		

        currentAnnotations = countryAnnotations
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(currentAnnotations)

		regionContainerController.regionController.report = nil
		regionContainerController.regionController.update()
         HUD.hide()
	}

	func downloadIfNeeded() {
        _ = allAnnotations.isEmpty
		//if showSpinner {
            if Constants.lang == "ar"
            {
                HUD.show(.label(Constants.updatingTitleAr), onView: view)
            }
            else
            {
                HUD.show(.label(Constants.updatingTitle), onView: view)
            }
			
		//}
		regionContainerController.isUpdating = true

		DataManager.instance.download { success in
			DispatchQueue.main.async {
				self.regionContainerController.isUpdating = false

				if success {
					self.update()
                   
				}
				else {
                    if Constants.lang == "ar"
                    {
                      HUD.flash(.label(Constants.noUpdateTitleAr), onView: self.view, delay: 5.0)
                    }
                    else
                    {
                       HUD.flash(.label(Constants.noUpdateTitle), onView: self.view, delay: 5.0)
                    }

				}
			}
		}
	}
}

extension MapController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
       if let userLocation = mapView.view(for: mapView.userLocation) {
            userLocation.isHidden = true
       }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
      
        if overlay.isKind(of: MKPolyline.self){
            
        let circleRenderer = MKPolylineRenderer(overlay: overlay)
            circleRenderer.fillColor = UIColor.blue.withAlphaComponent(1.0)
            circleRenderer.strokeColor = UIColor.red
            circleRenderer.lineWidth = 1
        return circleRenderer
    }
        return MKOverlayRenderer(overlay: overlay)
    }
  
    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        
        if locationManager.location?.coordinate.latitude != nil && locationManager.location?.coordinate.longitude != nil
        {
            let initialLocation = CLLocation(latitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!)
                func centerMapOnLocation(location:CLLocation) {
                let coordianteRegion = MKCoordinateRegion(center: location.coordinate,
                                                              span: MKCoordinateSpan(latitudeDelta: 30, longitudeDelta: 30))
                       mapView.setRegion(coordianteRegion, animated: true)
                }
                centerMapOnLocation(location: initialLocation)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
       
       let locValue:CLLocationCoordinate2D = manager.location!.coordinate
          
       let initialLocation = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
          func centerMapOnLocation(location:CLLocation) {
          let coordianteRegion = MKCoordinateRegion(center: location.coordinate,
                                                        span: MKCoordinateSpan(latitudeDelta: 30, longitudeDelta: 30))
                 mapView.setRegion(coordianteRegion, animated: true)
          }
          centerMapOnLocation(location: initialLocation)
        
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //print("Error \(error)")
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		
        guard !(annotation is MKUserLocation) else
        {
           return nil
		}
      
		var annotationView: ReportAnnotationView
		
        guard let view = mapView.dequeueReusableAnnotationView(
				withIdentifier: ReportAnnotation.reuseIdentifier,
				for: annotation) as? ReportAnnotationView
            else {
               
                return nil
                
        }
        
        annotationView = view
        annotationView.mapZoomLevel = mapView.zoomLevel

		return annotationView
	}

	func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
		for annotation in currentAnnotations {
			if let view = mapView.view(for: annotation) as? ReportAnnotationView {
				view.mapZoomLevel = mapView.zoomLevel
			}
		}
	}

	func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
		if mapView.zoomLevel > Self.cityZoomLevel
        {
			if currentAnnotations.count != allAnnotations.count {
				mapView.removeAnnotations(mapView.annotations)
				currentAnnotations = allAnnotations
				mapView.addAnnotations(currentAnnotations)
			}
		}
		else {
			if currentAnnotations.count != countryAnnotations.count {
				mapView.removeAnnotations(mapView.annotations)
				currentAnnotations = countryAnnotations
				mapView.addAnnotations(currentAnnotations)
			}
		}
	}
    
	func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
    {
       updateRegionScreen(report: (view as? ReportAnnotationView)?.report)
	}

	func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView)
    {
        updateRegionScreen(report: nil)
	}
}

extension MapController: FloatingPanelControllerDelegate {
	func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
		(newCollection.userInterfaceIdiom == .pad ||
			newCollection.verticalSizeClass == .compact) ? LandscapePanelLayout() : PanelLayout()
	}
}

class PanelLayout: FloatingPanelLayout {
	public var initialPosition: FloatingPanelPosition {
		return .half
	}

	public func insetFor(position: FloatingPanelPosition) -> CGFloat? {
		switch position {
		case .full: return 16
		case .half: return 260
		case .tip: return 68
		default: return nil
		}
	}

	func prepareLayout(surfaceView: UIView, in view: UIView) -> [NSLayoutConstraint] {
		
        return [
            surfaceView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0.0),
            surfaceView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0.0),
        ]
		
	}

	func backdropAlphaFor(position: FloatingPanelPosition) -> CGFloat {
		return position == .full ? 0.3 : 0.0
	}
}

class LandscapePanelLayout: PanelLayout {
	override func prepareLayout(surfaceView: UIView, in view: UIView) -> [NSLayoutConstraint] {
		
        return [
            surfaceView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8.0),
            surfaceView.widthAnchor.constraint(equalToConstant: 400),
        ]
		
	}

	override func backdropAlphaFor(position: FloatingPanelPosition) -> CGFloat {
		return 0.0
	}
}
