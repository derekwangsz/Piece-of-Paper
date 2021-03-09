//
//  NotesViewController.swift
//  Piece Of Paper
//
//  Created by Derek Wang on 2020-09-20.
//  Copyright © 2020 Derek Wang. All rights reserved.
//

import UIKit
import CoreData

class NotesViewController: UITableViewController {
    
    var selectedFolder:Folder?{
        didSet{
            loadNotes()
        }
    }

    var notes = [Note]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewWillAppear(_ animated: Bool) {
        loadNotes()
        tableView.rowHeight = 50.0
    }
    

    // MARK: - TableView Datasource Methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let note = notes[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath)
        cell.textLabel?.text = note.title
        cell.detailTextLabel?.text = note.text
        return cell
    }
    
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "noteToContent", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! ContentViewController
        
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationVC.selectedNote = notes[indexPath.row]
        }
    }
    
    
    
    //MARK: - Delete Notes
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        context.delete(notes[indexPath.row])
        notes.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        
        saveNotes()
    }
    
    
    
    //MARK: - Data Manipulation
    
    func loadNotes(with request:NSFetchRequest<Note> = Note.fetchRequest(), predicate:NSPredicate? = nil){
        
        let folderPredicate = NSPredicate(format: "parentFolder.name MATCHES %@", selectedFolder!.name!)
        
        if let additionalPredicate = predicate{
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [folderPredicate,additionalPredicate])
        }else{
            request.predicate = folderPredicate
        }
        
        
        do {
            notes = try context.fetch(request)
        } catch {
            print("Error fetching notes, \(error)")
        }
        
        tableView.reloadData()
    }
    
    
    func saveNotes(){
        
        do {
            try context.save()
        } catch {
            print("Error saving notes / deleting notes, \(error)")
        }
        
        tableView.reloadData()
    }
    
    
    //MARK: - Add New Note
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var nameTextField = UITextField()
        var contentTextField = UITextField()
        
        let alert = UIAlertController(title: "Add New Note", message: "", preferredStyle: .alert)
        
        alert.addTextField { (textfield) in
            nameTextField = textfield
            textfield.placeholder = "Enter title"
        }
        
        alert.addTextField { (textfield) in
            contentTextField = textfield
            textfield.placeholder = "Enter notes (optional)"
        }
        
        let action = UIAlertAction(title: "Done", style: .default) { (action) in
            let newNote = Note(context: self.context)
            newNote.title = nameTextField.text
            newNote.text = contentTextField.text
            newNote.parentFolder = self.selectedFolder
            self.notes.append(newNote)
            
            self.saveNotes()
            
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
}


extension NotesViewController : UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request:NSFetchRequest<Note> = Note.fetchRequest()

        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)

        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]

        loadNotes(with: request, predicate: predicate)
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text?.count == 0{
            loadNotes()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
        else{
            let request:NSFetchRequest<Note> = Note.fetchRequest()
            
            let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
            
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            
            loadNotes(with: request, predicate: predicate)
        }
    }
    
    
}
