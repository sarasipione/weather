//
//  LocationViewController.swift
//  Weather
//
//  Created by Sara Sipione on 27/11/2019.
//  Copyright © 2019 Sara Sipione. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON
import Alamofire
import MapKit


protocol ChangeLocationDelegate {
    func enteredLocation(city: String, background: String)
}

class LocationViewController: UIViewController, MKLocalSearchCompleterDelegate {

    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = Credential().APP_ID
    
    var delegate : ChangeLocationDelegate?
   
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var locationTableView: UITableView!
    @IBOutlet weak var searchTableView: UITableView!
    
    let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    var recentLocations = [ItemLocation]()
    var currentDegree = "℃"
    
    var searchCompleter = MKLocalSearchCompleter()
    var completionResults = [MKLocalSearchCompletion]()
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
           super.viewDidLoad()
        
        locationTableView.delegate = self
        locationTableView.dataSource = self
        locationTableView.register(UINib(nibName: K.LocationVC.cellNibName, bundle: nil), forCellReuseIdentifier: K.LocationVC.cellIdentifier)
        locationTableView.rowHeight = 80.0
        locationTableView.tableFooterView = UIView()
        locationTableView.backgroundView = UIImageView(image: UIImage(named: "baseSnow"))
        
        searchBar.delegate = self
        searchBar.searchTextField.textColor = .white
        searchBar.barTintColor = .darkGray
        searchBar.searchTextField.backgroundColor = .lightGray
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        
        searchTableView.delegate = self
        searchTableView.dataSource = self
        searchTableView.isHidden = true
        searchTableView.separatorStyle = .none
        searchTableView.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        blurView.frame = self.view.frame
        
        searchCompleter.delegate = self
        searchCompleter.pointOfInterestFilter = MKPointOfInterestFilter.excludingAll
    }
}

extension LocationViewController: UITableViewDataSource {
    
    //MARK: - TableViews Datasource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == locationTableView {
            return locationTV(tableView, numberOfRowsInSection: section)
        } else {
            return searchTV(tableView, numberOfRowsInSection: section)
        }
    }
       
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == locationTableView {
           return locationTV(_: tableView, cellForRowAt: indexPath)
       } else {
           return searchTV(_: tableView, cellForRowAt: indexPath)
       }
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return locationTV(_: tableView, trailingSwipeActionsConfigurationForRowAt: indexPath)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
           return searchTVNumberOfSection(in: tableView)
    }
    
    //MARK: - LocationTableview Datasource Methods
    
    func locationTV(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentLocations.count
    }
    
    func locationTV(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.LocationVC.cellIdentifier, for: indexPath) as! CustomLocationCell

        let params : [String : String] = ["q" : recentLocations[indexPath.row].cityLoc, "appid" : APP_ID]
        recentLocations[indexPath.row].updateLocationData(url: WEATHER_URL, parameters: params)
        
        let tempLoc = ClimaUtils.degreeConverter(degreeK: recentLocations[indexPath.row].tempLoc, currentDegree: currentDegree)

        cell.cityLocationCell.text = recentLocations[indexPath.row].cityLoc
        cell.iconLocationCell.image = UIImage(named: recentLocations[indexPath.row].iconLoc)
        cell.tempLocationCell.text = "\(tempLoc) \(currentDegree)"
        //cell.baseLocationCell.image = UIImage(named: recentLocations[indexPath.row].baseLoc)
        
        cell.contentView.backgroundColor = UIColor.clear
        locationTableView.backgroundColor = UIColor.clear
        cell.layer.backgroundColor = UIColor.clear.cgColor

        return cell
    }
    
    func locationTV(_ tableView: UITableView,
                      trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        _ = tableView.dequeueReusableCell(withIdentifier: K.LocationVC.cellIdentifier, for: indexPath) as! CustomLocationCell
           let TrashAction = UIContextualAction(style: .normal, title:  "Trash", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
               
               try! self.realm.write {
                   self.realm.delete(self.recentLocations[indexPath.row])
               }
               self.recentLocations.remove(at: indexPath.row)
               self.locationTableView.reloadData()
               success(true)
           })
           TrashAction.backgroundColor = .red
           return UISwipeActionsConfiguration(actions: [TrashAction])
       }
    
    //MARK: - SearchTableView DataSource Methods
        
    func searchTVNumberOfSection(in tableView: UITableView) -> Int {
           return 1
    }
    
    func searchTV(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return completionResults.count
    }
    
    func searchTV(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let searchResult = completionResults[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.attributedText = createHighlightedString(text: searchResult.title, rangeValues: searchResult.titleHighlightRanges)
        cell.backgroundColor = UIColor.clear
        
        return cell
    }
}

extension LocationViewController: UITableViewDelegate {
    
    //MARK: - TableViews Delegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == locationTableView {
            locationTV(_: tableView, didSelectRowAt: indexPath)
        } else {
            searchTV(_: tableView, didSelectRowAt: indexPath)
        }
    }
    
    //MARK: - LocationTableView Delegate Methods
    
    func locationTV(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cityName = recentLocations[indexPath.row].cityLoc
        //let base = recentLocations[indexPath.row].baseLoc
        delegate?.enteredLocation(city: cityName, background: "")
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - SearchTableView Delegate Methods
    
    func searchTV(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
        tableView.deselectRow(at: indexPath, animated: true)
        let completion = completionResults[indexPath.row]
        print(completion.title)
        let completionSplit = completion.title.split(separator: ",")
        self.delegate?.enteredLocation(city: String(completionSplit[0]), background: "")
        self.dismiss(animated: true, completion: nil)
    }
}

extension LocationViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let cityName = searchBar.text!
        let base = ""
        delegate?.enteredLocation(city: cityName, background: base)
        self.dismiss(animated: true, completion: nil)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCompleter.queryFragment = searchText
        searchTableView.isHidden = false
        locationTableView.addSubview(blurView)
        locationTableView.bringSubviewToFront(blurView)
    }

    private func createHighlightedString(text: String, rangeValues: [NSValue]) -> NSAttributedString {
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        let highlightedString = NSMutableAttributedString(string: text)

        let ranges = rangeValues.map { $0.rangeValue }
        ranges.forEach { (range) in
            highlightedString.addAttributes(attributes, range: range)
        }
        return highlightedString
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        completionResults = completer.results.filter({ (completionCandidate) -> Bool in
                     // search for only units larger than a city
                     completionCandidate.subtitle == ""
                 })
        searchTableView.reloadData()
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchTableView.isHidden = true
        blurView.removeFromSuperview()
        dismiss(animated: true, completion: nil)
    }
}

