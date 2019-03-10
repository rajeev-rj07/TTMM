//
//  ViewController.swift
//  iTEM(Travel Event Manager)
//
//  Created by Rajeev on 7/27/17.
//  Copyright © 2017 Zenarc. All rights reserved.
//

import UIKit
import CoreData

class EventsViewController: UIViewController {
    
    @IBOutlet var eventTableView: UITableView!
    @IBOutlet var addEventUIButton: UIButton!
    var arrayOfEvents: [Event]!
    var selectedIndexPath: NSIndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addEventUIButton.layer.cornerRadius = 27.0
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fethReq: NSFetchRequest = Event.fetchRequest()
        
        do {
            arrayOfEvents = try context.fetch(fethReq)
            self.eventTableView.reloadData()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "eventDetailsVC" {
            let eventDetailVC_Obj = segue.destination as! EventDetailsViewController
            eventDetailVC_Obj.event = self.arrayOfEvents[selectedIndexPath.row]
        }
    }
}

// Mark:- Table View

extension EventsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! EventsViewControllerCell
        let event = arrayOfEvents[indexPath.row]
        
        cell.lblEventName.text = "Event: \(event.name!)"
        cell.lblEventDate.text = "Date: \(event.date!)"
        cell.lblAmount.text = "₹\(event.amount)/-"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath as NSIndexPath?
        performSegue(withIdentifier: "eventDetailsVC", sender: self)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fethReq: NSFetchRequest = Event.fetchRequest()
            let predicate = NSPredicate(format: "name==%@", arrayOfEvents[indexPath.row].name!)
            fethReq.predicate = predicate
            
            do {
                let events = try context.fetch(fethReq)
                
                for event in events {
                    context.delete(event)
                    try context.save()
                }
                
                arrayOfEvents.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                
                
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
}

// Mark:- Table View Cell

class EventsViewControllerCell: UITableViewCell {
    @IBOutlet var lblEventName: UILabel!
    @IBOutlet var lblEventDate: UILabel!
    @IBOutlet var lblAmount: UILabel!
}
