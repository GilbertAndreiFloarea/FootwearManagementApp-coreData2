//
//  ViewController.swift
//  FootwearManagementApp
//
//  Created by Gilbert Andrei Floarea on 13/04/2019.
//  Copyright © 2019 Gilbert Andrei Floarea. All rights reserved.
//

import CoreData
import UIKit

class ViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var favoriteLabel: UILabel!
    @IBOutlet weak var lastWornLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var timesWornLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    // MARK: - Properties
    var managedContext: NSManagedObjectContext!
    
    var currentFootwear: Footwear!
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        insertSampleData()
        
        let request: NSFetchRequest<Footwear> = Footwear.fetchRequest()
        let firstTitle = segmentedControl.titleForSegment(at: 0)!
        request.predicate = NSPredicate(format: "%K = %@", argumentArray: [#keyPath(Footwear.searchKey), firstTitle])
        
        do {
            let results = try managedContext.fetch(request)
            currentFootwear = results.first
            populate(Footwear: results.first!)
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    // MARK: - IBActions
    @IBAction func segmentedControl(_ sender: Any) {
        
        guard let control =  sender as? UISegmentedControl,
            let selectedValue = control.titleForSegment(at: control.selectedSegmentIndex) else {
                return
        }
        
        let request: NSFetchRequest<Footwear> = Footwear.fetchRequest()
        request.predicate = NSPredicate(format: "%K = %@", argumentArray: [#keyPath(Footwear.searchKey), selectedValue])
        
        do {
            let results =  try managedContext.fetch(request)
            currentFootwear =  results.first
            populate(Footwear: currentFootwear)
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    @IBAction func wear(_ sender: Any) {
        let times = currentFootwear.timesWorn
        currentFootwear.timesWorn = times + 1
        currentFootwear.lastWorn = NSDate()
        
        do {
            try managedContext.save()
            populate(Footwear: currentFootwear)
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    @IBAction func rate(_ sender: Any) {
        
        let alert = UIAlertController(title: "New Rating", message: "Rate this bow tie", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.keyboardType = .decimalPad
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] action in
            
            if let textField = alert.textFields?.first {
                self.update(rating: textField.text)
            }
        }
        
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        
        present(alert, animated: true)
    }
    
    func insertSampleData() {
        
        let fetch: NSFetchRequest<Footwear> = Footwear.fetchRequest()
        fetch.predicate = NSPredicate(format: "searchKey != nil")
        
        let count = try! managedContext.count(for: fetch)
        
        if count > 0 {
            // SampleData.plist data already in Core Data
            return
        }
        let path = Bundle.main.path(forResource: "SampleFootwear",
                                    ofType: "plist")
        let dataArray = NSArray(contentsOfFile: path!)!
        
        for dict in dataArray {
            let entity = NSEntityDescription.entity(forEntityName: "Footwear", in: managedContext)!
            let footwear = Footwear(entity: entity, insertInto: managedContext)
            let btDict = dict as! [String: Any]
            
            footwear.id = UUID(uuidString: btDict["id"] as! String)
            footwear.name = btDict["name"] as? String
            footwear.searchKey = btDict["searchKey"] as? String
            footwear.rating = btDict["rating"] as! Double
            let colorDict = btDict["tintColor"] as! [String: Any]
            footwear.tintColor = UIColor.color(dict: colorDict)
            
            let imageName = btDict["imageName"] as? String
            let image = UIImage(named: imageName!)
            let photoData = image!.pngData()!
            footwear.photoData = NSData(data: photoData)
            footwear.lastWorn = btDict["lastWorn"] as? NSDate
            
            let timesNumber = btDict["timesWorn"] as! NSNumber
            footwear.timesWorn = timesNumber.int32Value
            footwear.isFavorite = btDict["isFavorite"] as! Bool
            footwear.url = URL(string: btDict["url"] as! String)
        }
        try! managedContext.save()
    }
    
    func populate(Footwear: Footwear) {
        
        guard let imageData = Footwear.photoData as Data?,
            let lastWorn = Footwear.lastWorn as Date?,
            let tintColor = Footwear.tintColor as? UIColor else {
                return
        }
        
        imageView.image = UIImage(data: imageData)
        nameLabel.text = Footwear.name
        ratingLabel.text = "Rating: \(Footwear.rating)/5"
        timesWornLabel.text = "# times worn: \(Footwear.timesWorn)"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        
        lastWornLabel.text = "Last worn: " + dateFormatter.string(from: lastWorn)
        
        favoriteLabel.isHidden = !Footwear.isFavorite
        view.tintColor = tintColor
    }
    
    func update(rating: String?) {
        
        guard let ratingString = rating,
            let rating = Double(ratingString) else {
                return
        }
        
        do {
            
            currentFootwear.rating = rating
            try managedContext.save()
            populate(Footwear: currentFootwear)
            
        } catch let error as NSError {
            
            if error.domain == NSCocoaErrorDomain &&
                (error.code == NSValidationNumberTooLargeError ||
                    error.code == NSValidationNumberTooSmallError) {
                rate(currentFootwear)
            } else {
                print("Could not save \(error), \(error.userInfo)")
            }
        }
    }
}

private extension UIColor {
    
    static func color(dict: [String : Any]) -> UIColor? {
        guard let red = dict["red"] as? NSNumber,
            let green = dict["green"] as? NSNumber,
            let blue = dict["blue"] as? NSNumber else {
                return nil
        }
        
        return UIColor(red: CGFloat(truncating: red) / 255.0,
                       green: CGFloat(truncating: green) / 255.0,
                       blue: CGFloat(truncating: blue) / 255.0,
                       alpha: 1)
    }
}


