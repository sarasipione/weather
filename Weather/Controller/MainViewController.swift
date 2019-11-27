//
//  ViewController.swift
//  Weather
//
//  Created by Sara Sipione on 27/11/2019.
//  Copyright © 2019 Sara Sipione. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SVProgressHUD
import CoreLocation
import RealmSwift

class MainViewController: UIViewController {

    @IBOutlet weak var climaTableView: UITableView!
    @IBOutlet weak var degreeSwitch: UISegmentedControl!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var climaIcon: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var backgroundView: UIImageView!
    
    let WEATHER_URL = K.WEATHER_URL
    let APP_ID = Credential().APP_ID
    
    let locationManager = CLLocationManager()
    let climaDataModel = ClimaDataModel()
    
    var currentDegree = "℃"
    var degreeConvert = 273.15
    let dateFormatter = DateFormatter()
    let mainDateFormatter = DateFormatter()
    
    var recents : [ItemLocation] = []
    var dailyClima : [ItemClima] = []
   
    let realm = try! Realm()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        recents = Array(realm.objects(ItemLocation.self))
        
        dateFormatter.dateFormat = "EEEE"
        mainDateFormatter.dateFormat = "EEEE,  dd MMMM"
        
        climaTableView.dataSource = self
        
        climaTableView.register(UINib(nibName: K.MainVC.cellNibName, bundle: nil), forCellReuseIdentifier: K.MainVC.cellIdentifier)
        climaTableView.register(UINib(nibName: K.MainVC.cellNibName1, bundle: nil), forCellReuseIdentifier: K.MainVC.cellIdentifier1)
        climaTableView.register(UINib(nibName: K.MainVC.cellNibName2, bundle: nil), forCellReuseIdentifier: K.MainVC.cellIdentifier2)
        
        climaTableView.tableFooterView = UIView()
        climaTableView.backgroundColor = UIColor.clear
    }

    @IBAction func degreePressed(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
           currentDegree = "℉"
           updateUIClimaData()
        }
        else {
           currentDegree = "℃"
           updateUIClimaData()
        }
    }
    
    @IBAction func shareButtonPressed(_ sender: UIButton) {
        
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        var imagesToShare = [AnyObject]()
        imagesToShare.append(image!)

        let activityViewController = UIActivityViewController(activityItems: imagesToShare , applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        present(activityViewController, animated: true, completion: nil)
    }
    
    
//MARK: - Networking Main View & TableView

   func getClimaData(url: String, parameters: [String: String]) {

       Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
           response in
           if response.result.isSuccess {
               print("Success! Got the weather data")
               let weatherJSON : JSON = JSON(response.result.value!)
               print(weatherJSON)
               self.updateClimaData(json: weatherJSON)
           }
           else {
               print("Error \(String(describing: response.result.error))")
               self.cityLabel.text = "Connection Issues"
           }
       }
   }
   
//MARK: - JSON Parsing Main View

   func updateClimaData(json : JSON) {
       if json["cod"] != "200" {
           let alert = UIAlertController(title: "City Not Found!", message: "Try again...", preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
           self.present(alert, animated: true)
           } else {
               climaDataModel.temperature = Int(json["list"][0]["main"]["temp"].doubleValue)
               climaDataModel.city = json["city"]["name"].stringValue
               climaDataModel.condition = json["list"][0]["weather"][0]["id"].intValue
               climaDataModel.climaIconName = ClimaDataModel.updateIcon(condition: climaDataModel.condition)
               climaDataModel.background = ClimaDataModel.updateBackground(conditionB: climaDataModel.condition)
               climaDataModel.description = json["list"][0]["weather"][0]["description"].stringValue
               climaDataModel.day = mainDateFormatter.string(from: NSDate(timeIntervalSince1970: TimeInterval(json["list"][0]["dt"].intValue)) as Date)
               climaDataModel.humidity = json["list"][0]["main"]["humidity"].intValue
               climaDataModel.pressure = json["list"][0]["main"]["pressure"].intValue
               climaDataModel.windSpeed = json["list"][0]["wind"]["speed"].doubleValue.rounded()
               climaDataModel.clouds = json["list"][0]["clouds"]["all"].intValue

           var foundCity = false
           for i in recents {
               if i.cityLoc == climaDataModel.city {
                   foundCity = true
                   break
               }
           }
           if foundCity == false {
               try! realm.write {
                 let itemsLoc = ItemLocation()
                 itemsLoc.cityLoc = climaDataModel.city
                 itemsLoc.iconLoc = climaDataModel.climaIconName
                 itemsLoc.tempLoc = climaDataModel.temperature
                 itemsLoc.baseLoc = climaDataModel.background
                 realm.add(itemsLoc)
                 recents.append(itemsLoc)
               }
           }
           dailyClima = []
           var c = 0
           var min = 9999999
           var max = 0
           for i in json["list"].arrayValue {
               c += 1
               if i["main"]["temp_min"].intValue < min {
                   min = i["main"]["temp_min"].intValue
               }
               if i["main"]["temp_max"].intValue > max {
                   max = i["main"]["temp_max"].intValue
               }
               if c != 8 {
                   continue
               }
               let dayClima = ItemClima()
               dayClima.tempMinClima = min
               dayClima.tempMaxClima = max
               dayClima.iconClima = ClimaDataModel.updateIcon(condition: i["weather"][0]["id"].intValue)
               dayClima.dayNameClima = dateFormatter.string(from: NSDate(timeIntervalSince1970: TimeInterval(i["dt"].intValue)) as Date)

               dailyClima.append(dayClima)
               c = 0
               max = 0
               min = 99999
           }
       }
       updateUIClimaData()
   }
  
    
    //MARK: - UI Updates Main View
    
    func updateUIClimaData() {
        cityLabel.text = climaDataModel.city.uppercased()
        let t = ClimaUtils.degreeConverter(degreeK: climaDataModel.temperature, currentDegree: currentDegree)
        temperatureLabel.text = "\(t) \(currentDegree)"
        climaIcon.image = UIImage(named: climaDataModel.climaIconName)
        descriptionLabel.text = climaDataModel.description.uppercased()
        dayLabel.text = climaDataModel.day.uppercased()
        backgroundView.image = UIImage(named: climaDataModel.background)
      
        climaTableView.reloadData()
    }
}


extension MainViewController: ChangeLocationDelegate {
    
    func enteredLocation(city: String, background: String) {
        recents = Array(realm.objects(ItemLocation.self))
        let params : [String : String] = ["q" : city, "appid" : APP_ID]
        getClimaData(url: WEATHER_URL, parameters: params)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.MainVC.segueIdentifier {
            let destinationVC = segue.destination as! LocationViewController
            destinationVC.recentLocations = recents
            destinationVC.currentDegree = currentDegree
            destinationVC.delegate = self
        }
    }
}

extension MainViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
         let location = locations[locations.count - 1]
         if location.horizontalAccuracy > 0 {

             self.locationManager.stopUpdatingLocation()
             print("longitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)")
             locationManager.delegate = nil

             let latitude = String(location.coordinate.latitude)
             let longitude = String(location.coordinate.longitude)
             let params : [String : String] = ["lat" : latitude, "lon" : longitude, "appid" : APP_ID]

             getClimaData(url: WEATHER_URL, parameters: params)
         }
     }
    
     func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
         print(error)
         cityLabel.text = "Location Unavailable"
     }
}


extension MainViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       if dailyClima.count > 0 {
           return dailyClima.count + 2
       }
       return 0
    }

   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           climaTableView.backgroundColor = UIColor.clear

       if indexPath.row < 5 {
           climaTableView.rowHeight = 50.0
           let maxTemp = ClimaUtils.degreeConverter(degreeK: dailyClima[indexPath.row].tempMaxClima, currentDegree: currentDegree)
           let minTemp = ClimaUtils.degreeConverter(degreeK: dailyClima[indexPath.row].tempMinClima, currentDegree: currentDegree)

        let cell = tableView.dequeueReusableCell(withIdentifier: K.MainVC.cellIdentifier) as! CustomClimaCell
           cell.dayClimaCell.text = dailyClima[indexPath.row].dayNameClima
           cell.iconClimaCell.image = UIImage(named: dailyClima[indexPath.row].iconClima)
           cell.tempMaxClimaCell.text = "\(maxTemp) \(currentDegree)"
           cell.tempMinClimaCell.text = "\(minTemp) \(currentDegree)"
           return cell
       } else if indexPath.row == 5 {
           climaTableView.rowHeight = 100.0
        let cell = tableView.dequeueReusableCell(withIdentifier: K.MainVC.cellIdentifier1) as! CustomClimaCell1
           cell.humidityClimaCell.text = "\(climaDataModel.humidity)%"
           cell.pressureClimaCell.text = "\(climaDataModel.pressure) hPa"
           return cell
       } else {
           climaTableView.rowHeight = 100.0
        let cell = tableView.dequeueReusableCell(withIdentifier: K.MainVC.cellIdentifier2) as! CustomClimaCell2
           cell.windSpeedClimaCell.text = "\(climaDataModel.windSpeed) mps"
           cell.cloudsClimaCell.text = "\(climaDataModel.clouds) %"
           return cell
       }
   }
}



