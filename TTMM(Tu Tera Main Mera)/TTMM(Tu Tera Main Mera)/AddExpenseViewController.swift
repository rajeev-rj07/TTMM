//
//  AddExpenseViewController.swift
//  iTEM(Travel Event Manager)
//
//  Created by Rajeev on 7/29/17.
//  Copyright © 2017 Zenarc. All rights reserved.
//

import UIKit
import CoreData

class AddExpenseViewController: UIViewController{
    
    typealias EventPartnersWithStatus = (eventPartner: EventPartner, isSelected: Bool)
    
    @IBOutlet var clcView: UICollectionView!
    @IBOutlet var txtExpenseName: UITextField!
    @IBOutlet var txtExpenseAmount: UITextField!
    
    var event: Event!
    var contibuterName: String!
    var selectedIndexPath: Int? = nil
    var setOfExpense = Set<Expense>()
    var arrEventPartners: [EventPartner]!
    var arrOfSelectedPartnersWithStatus = [EventPartnersWithStatus]()
    var eventPartnerImageData: Data!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtExpenseName.keyboardType = UIKeyboardType.alphabet
        txtExpenseAmount.keyboardType = UIKeyboardType.numberPad
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fethcReq: NSFetchRequest = EventPartner.fetchRequest()
        
        do {
            arrEventPartners = try context.fetch(fethcReq)
            
            for partner in arrEventPartners {
                let eventPartnerWithStatus = EventPartnersWithStatus(partner, false)
                arrOfSelectedPartnersWithStatus.append(eventPartnerWithStatus)
            }
        } catch {
            print(error.localizedDescription)
        }
        self.clcView.reloadData()
    }
}

// MarK:- Collectioon View

extension AddExpenseViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return event.eventPartners!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let itemCell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemCell", for: indexPath) as! AddExpenseViewControllerCollectionViewCell

        itemCell.EventPartnerImg.layer.cornerRadius = 57.0
        itemCell.EventPartnerImg.layer.borderWidth = 2.0
        
        let indexPathOfObjects = event.eventPartners?.allObjects[indexPath.row] as! EventPartner
        
        let imagePath = indexPathOfObjects.eventPartnerPhoto
        let imageUrl = URL(fileURLWithPath: imagePath!)
        
        do {
            eventPartnerImageData = try Data(contentsOf: imageUrl)
        } catch {
            print(error.localizedDescription)
        }
        
        itemCell.lblEventPartnerName.text = indexPathOfObjects.eventPartnerName
        itemCell.EventPartnerImg.image = UIImage(data: eventPartnerImageData)
        
        if(indexPath.row == selectedIndexPath) {
            itemCell.EventPartnerImg.layer.borderColor = UIColor.green.cgColor
        } else {
            itemCell.EventPartnerImg.layer.borderColor = UIColor.black.cgColor
        }
        
        return itemCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        selectedIndexPath = indexPath.row
        let indexPathOfObjects = event.eventPartners?.allObjects[indexPath.row] as! EventPartner
        self.contibuterName = indexPathOfObjects.eventPartnerName
        self.clcView.reloadData()
    }
    
}

// Mark:- IBAction

extension AddExpenseViewController {
    @IBAction func addNewExpense() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newExpenses = Expense(context: context)
        
        newExpenses.expenseName = txtExpenseName.text
        newExpenses.amount = Int64(txtExpenseAmount.text!)!
        newExpenses.contributer = self.contibuterName
        
        setOfExpense.insert(newExpenses)
        for previouslyAddedExpenses in event.expenses! {
            setOfExpense.insert(previouslyAddedExpenses as! Expense)
        }
        event.expenses = setOfExpense as NSSet?
        
        do {
            try context.save()
            let alert = UIAlertController(title: "New Expense Created", message: nil, preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Ok", style: .default, handler: { (_) in
                self.dismiss(animated: true, completion: nil)
            })
            self.present(alert, animated: true, completion: nil)
            alert.addAction(alertAction)
            
            txtExpenseName.text = nil
            txtExpenseAmount.text = nil
            
        } catch {
            print(error.localizedDescription)
        }
    }
}

// Mark:- Collection View ItemCell

class AddExpenseViewControllerCollectionViewCell: UICollectionViewCell {
    @IBOutlet var lblEventPartnerName: UILabel!
    @IBOutlet var EventPartnerImg: UIImageView!
}















