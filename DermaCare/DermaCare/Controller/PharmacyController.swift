//
//  PharmacyController.swift
//  DermaCare
//
//  Created by Pooj on 4/26/18.
//  Copyright © 2018 Pooja. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

class PharmacyController: UIViewController, UITableViewDataSource, UITableViewDelegate,CLLocationManagerDelegate {
    
    @IBOutlet weak var tablesView: UITableView!
    
    var selectedDoctor : String?
    var indexOfSelectedDoctor = 0
    var businesses: [PharmacyModel]!
    var locationManager: CLLocationManager!
    var long : Double = 0.0, lat : Double = 0.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager  = CLLocationManager()
        
        // Ask for Authorisation from the User.
        //self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters //kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        } else{
            print("Location service disabled");
        }
        
        //self.lat = (locationManager.location?.coordinate.latitude)!
        //self.long = (locationManager.location?.coordinate.longitude)!
        
        tablesView.delegate = self
        tablesView.dataSource = self
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
            self.lat = (self.locationManager.location?.coordinate.latitude)!
            self.long = (self.locationManager.location?.coordinate.longitude)!
            if(self.lat != 0.0 || self.long != 0.0) {
                let locationVal = String(self.lat) + "," + String(self.long)
                print("from business \(locationVal)")
                
                PharmacyModel.searchWithTerm(term: "Pharmacy", locationVal: locationVal, completion: { (businesses: [PharmacyModel]?, error: Error?) -> Void in
                    
                    self.businesses = businesses
                    self.tablesView.reloadData()
                    
                    if let businesses = businesses {
                        print("Total Found \(businesses.count)");
                    }
                    
                })
            } else{
                print("ERROR! Location value found nil")
                
            }
            
        })
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        long = locValue.longitude;
        lat = locValue.latitude;
        
        //print("locations = \(locValue.latitude) \(locValue.longitude)")
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if businesses != nil{
            return businesses.count
        } else {
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tablesView.dequeueReusableCell(withIdentifier: "PharmacyViewCell", for: indexPath) as! PharmacyViewCell
        
        cell.business = businesses[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //TODO
        
        indexOfSelectedDoctor = indexPath.row
        self.openMapForPlace(searchResult: businesses[indexOfSelectedDoctor])
    }
    
    func openMapForPlace(searchResult : PharmacyModel) {
        print("\(lat) \(long)")
        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(lat, long)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = searchResult.name
        mapItem.openInMaps(launchOptions: options)
    }

}
