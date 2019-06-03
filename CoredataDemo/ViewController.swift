//
//  ViewController.swift
//  CoredataDemo
//
//  Created by Meenal Kewat on 6/3/19.
//  Copyright © 2019 Meenal. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let person = people[indexPath.row]
        cell.textLabel?.text = person.value(forKey: "name") as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            
            deleteData(indexPath: indexPath)
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        updateData(indexPath: indexPath)
    }
    

    @IBOutlet weak var tableView: UITableView!
    
    var people:[NSManagedObject] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        title = "The List"
        fetchData()
    }


    @IBAction func addAction(_ sender: Any) {
        
        let alert = UIAlertController(title: "Add Name", message: "Add New Name Here", preferredStyle: .alert)
        
        let saveAction = UIAlertAction.init(title: "Save", style: .default)
        {
           [unowned self] action in
            guard let textField = alert.textFields?.first,
                let nameToSave = textField.text else {
                    return
            }
            self.save(name: nameToSave)
            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        
        alert.addTextField()
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    //save data
    func save(name : String){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
            return
        }
        //1
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //2
        let entity = NSEntityDescription.entity(forEntityName: "Person", in: managedContext)!
        let person = NSManagedObject(entity: entity, insertInto: managedContext)
        
        //3
        person.setValue(name, forKey: "name")
        
        //4
        do{
            try managedContext.save()
            people.append(person)
        }catch let error as NSError{
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    //Fetch data
    func fetchData(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        //1
        
        let managedContext = appDelegate.persistentContainer.viewContext
        //2
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Person")
        //3
        
        do {
          people =  try managedContext.fetch(fetchRequest)
            
            for records in people{
                print("All Person Records : \(String(describing: records.value(forKey: "name")))")
            }
            
        }catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
    }
    
    
    //Update Records
    func updateData(indexPath: IndexPath){
        let alert = UIAlertController(title: "Update Name", message: "Update Name Here", preferredStyle: .alert)
        
        let saveAction = UIAlertAction.init(title: "Save", style: .default)
        {
            [unowned self] action in
            guard let textField = alert.textFields?.first,
                let nameToSave = textField.text else {
                    return
            }
          self.updateOperation(nameToSave: nameToSave, indexPath: indexPath)
          self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        
        alert.addTextField()
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    func updateOperation(nameToSave:String, indexPath:IndexPath){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let selectedRow = people[indexPath.row]
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Person")
        fetchRequest.predicate = NSPredicate(format: "name = %@", selectedRow)
        selectedRow.setValue(nameToSave, forKey: "name")
        
        
        do{
            try managedContext.save()
        }catch let error as NSError{
            print("Could not update. \(error), \(error.userInfo)")
        }
    }
    
    
    //Delete Records
    func deleteData(indexPath : IndexPath){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        //1
        let managedContext = appDelegate.persistentContainer.viewContext
        //2
        // let deleteRequest = NSFetchRequest<NSManagedObject>(entityName: "Person")
        
        let deleteData = people[indexPath.row]
        
        people.remove(at: indexPath.row)
        
        tableView.deleteRows(at: [indexPath], with: .left)
        
        managedContext.delete(deleteData)
        
        do {
            try managedContext.save()
        }catch let error as NSError{
            print("could not save after deleting data. \(error), \(error.userInfo)")
        }
    }
}

