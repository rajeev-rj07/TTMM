//
//  EventDetailsViewController.swift
//  iTEM(Travel Event Manager)
//
//  Created by Rajeev on 7/29/17.
//  Copyright © 2017 Zenarc. All rights reserved.
//

import UIKit
import CoreData

class EventDetailsViewController: UIViewController {
    
    @IBOutlet var eventDetailsTblView: UITableView!
    @IBOutlet var addNewExpenseUIButton: UIButton!
    @IBOutlet var partnerClcView: UICollectionView!
    @IBOutlet var lblTotalOfExpenses: UILabel!
    
    var eventPartnerImageData: Data!
    var event: Event!
    var eventPartners: EventPartner!
    var contributerName: String? = nil
    var totalOfExpenses: Int64 = 0
    
    var arrExpences = [Expense]()
    var arrPartners = [EventPartner?]()
    
    var arrOfEventPartnerFromUnwind: [Partner]!
    var setOfEventPartnersFromUnwind = Set<EventPartner>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addNewExpenseUIButton.layer.cornerRadius = 27.0
        
        arrExpences = event.expenses?.allObjects as! [Expense]
        arrPartners = event.eventPartners?.allObjects as! [EventPartner]
        arrPartners.append(nil)
        
        
        totalOfExpenses = 0
        for expenseAmount in arrExpences {
            totalOfExpenses += expenseAmount.amount
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        event.amount = totalOfExpenses
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
        
        lblTotalOfExpenses.text = "Rs/-\(totalOfExpenses)"
        
        eventDetailsTblView.reloadData()
        partnerClcView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addExpenseVC" {
            let addExpenseVC_Obj = segue.destination as! AddExpenseViewController
            addExpenseVC_Obj.event = self.event
        }
    }
    
    @IBAction func unWindToAddPartner(segue: UIStoryboardSegue) {
        let source = segue.source as! AllPartnersViewController
        arrOfEventPartnerFromUnwind = [Partner]()
        
        for eventPartner in source.arrOfPartnersWithStatus {
            if eventPartner.isSelected {
                self.arrOfEventPartnerFromUnwind.append(eventPartner.partner)
            }
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        setOfEventPartnersFromUnwind = event.eventPartners as! Set<EventPartner>
        
        for partner in arrOfEventPartnerFromUnwind {
            let eventPartner = EventPartner(context: context)
            eventPartner.eventPartnerName = partner.partnerName
            eventPartner.eventPartnerPhoto = partner.photo
            setOfEventPartnersFromUnwind.insert(eventPartner)
        }
        
        event.eventPartners = setOfEventPartnersFromUnwind as NSSet?
        
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    func myExpences(myName: String, lableColorIn: EventDetailsViewControllerCollectionViewCell) -> String {

        var myTotalExpences: Double = 0
        let totalParteners = Int64(arrPartners.count-1)
        
        for expence in arrExpences {
            
            let onePart = Double(expence.amount/totalParteners)
            
            if expence.contributer == myName {
                myTotalExpences += onePart * Double(totalParteners-1)
            } else {
                myTotalExpences += (onePart) * -1
            }
        }
        
        if myTotalExpences > 0 {
            lableColorIn.lblOwnOrLoan.textColor = UIColor.green
            return "+₹\(myTotalExpences)/-"
        } else if myTotalExpences == 0 {
            lableColorIn.lblOwnOrLoan.textColor = UIColor.black
            return "₹\(myTotalExpences)/-"
        } else {
            lableColorIn.lblOwnOrLoan.textColor = UIColor.red
            return "₹\(myTotalExpences)/-"
        }
    }
    
}

// Mark:- Table View

extension EventDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrExpences.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventExpenseCell", for: indexPath) as! EventDetailsViewControllerTableViewCell
        
        let expence = arrExpences[indexPath.row]
        
        cell.lblExpenseName.text = "Expense: \(expence.expenseName!)"
        cell.lblContributer.text = "Paid By: \(expence.contributer!)"
        cell.lblContributedAmount.text = "₹\(expence.amount)/-"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        
        if editingStyle == .delete {
        
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let expenceToDelete = arrExpences[indexPath.row] 
            totalOfExpenses -= expenceToDelete.amount
            lblTotalOfExpenses.text = "Rs/-\(totalOfExpenses)"
            
            context.delete(expenceToDelete)
            
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
            
            let context2 = appDelegate.persistentContainer.viewContext
            event.amount = totalOfExpenses
            do {
                try context2.save()
            } catch {
                print(error.localizedDescription)
            }
            
            
            
            arrExpences.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            
            partnerClcView.reloadData()
            tableView.reloadData()
        }
    }
    
}

// Mark:- Collection View Protocols

extension EventDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrPartners.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let partner = arrPartners[indexPath.row]
        
        if partner == nil {
            let addCell = collectionView.dequeueReusableCell(withReuseIdentifier: "addPartnersCell", for: indexPath)
            return addCell
        } else {
            
            let itemCell = collectionView.dequeueReusableCell(withReuseIdentifier: "eventPartnersCell", for: indexPath) as! EventDetailsViewControllerCollectionViewCell
            
            
            itemCell.partnerImg.layer.cornerRadius = 60.0
            itemCell.partnerImg.layer.borderWidth = 1.0
            
            let eventPartner = event.eventPartners?.allObjects[indexPath.row] as! EventPartner
            
            let imagePath = eventPartner.eventPartnerPhoto
            let imageUrl = URL(fileURLWithPath: imagePath!)
            
            do {
                eventPartnerImageData = try Data(contentsOf: imageUrl)
            } catch {
                print(error.localizedDescription)
            }
            
            itemCell.lblPartnerName.text = eventPartner.eventPartnerName
            itemCell.partnerImg.image = UIImage(data: eventPartnerImageData)
            itemCell.lblOwnOrLoan.text = myExpences(myName: eventPartner.eventPartnerName!, lableColorIn: itemCell)
            
            
            return itemCell

        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "allPartnersVC", sender: self)
    }

}

// Mark:- Table View Cell

class EventDetailsViewControllerTableViewCell: UITableViewCell {
    @IBOutlet var lblExpenseName: UILabel!
    @IBOutlet var lblContributer: UILabel!
    @IBOutlet var lblContributedAmount: UILabel!
}

// Mark:- Collection View Cell

class EventDetailsViewControllerCollectionViewCell: UICollectionViewCell {
    @IBOutlet var lblPartnerName: UILabel!
    @IBOutlet var lblOwnOrLoan: UILabel!
    @IBOutlet var partnerImg: UIImageView!
}

