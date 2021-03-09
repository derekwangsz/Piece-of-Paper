//
//  ViewController.swift
//  Piece Of Paper
//
//  Created by Derek Wang on 2020-09-19.
//  Copyright © 2020 Derek Wang. All rights reserved.
//

import UIKit
import CoreData


class FolderViewController: UITableViewController {
    
    var folders = [Folder]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        loadFolders()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        tableView.rowHeight = 70.0
    }
    
    
    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(folders.count)
        return folders.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let folder = folders[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "FolderCell", for: indexPath)
        cell.textLabel!.text = folder.name
        cell.detailTextLabel?.text = folder.details
        
        return cell
    }
    
    
    //MARK: - TableVIew Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "folderToNotes", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! NotesViewController
        
        if let indexpath = tableView.indexPathForSelectedRow{
            destinationVC.selectedFolder = folders[indexpath.row]
        }
    }
    


    //MARK: - Delete Folders
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        context.delete(folders[indexPath.row])
        folders.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        
        saveFolders()
    }
    
    
    
    //MARK: - Data Manipulation Methods
    
    
    func saveFolders(){
        
        do{
            try context.save()
        }catch{
            print("Error saving groups, \(error)")
        }
        
        tableView.reloadData()
    }
    

    func loadFolders(){
        
        let fetchRequest:NSFetchRequest<Folder> = Folder.fetchRequest()
        
        do{
            folders = try context.fetch(fetchRequest)
        }catch{
            print("Error fetching groups,\(error)")
        }
        
        tableView.reloadData()
    }
    
    
    
    //MARK: - Add New Folder

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var nameTextField = UITextField()
        var descriptTextField = UITextField()
        
        let alert = UIAlertController(title: "Add New Folder", message: "Enter name and description below", preferredStyle: .alert)
        
        
        alert.addTextField { (otextField) in
            nameTextField = otextField
            otextField.placeholder = "Enter name"
        }
        
        alert.addTextField { (otextfield) in
            descriptTextField = otextfield
            otextfield.placeholder = "Enter description (Optional)"
        }
        
        
        let alertAction = UIAlertAction(title: "Done", style: .default) { (action) in
            
            if nameTextField.text! != ""{
                
                let newFolder = Folder(context: self.context)
                newFolder.name = nameTextField.text!
                newFolder.details = descriptTextField.text!
                
                self.folders.append(newFolder)
                self.saveFolders()
            }
            
        }
        
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
    }
    


}

