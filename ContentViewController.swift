//
//  ContentViewController.swift
//  Piece Of Paper
//
//  Created by Derek Wang on 2020-09-21.
//  Copyright © 2020 Derek Wang. All rights reserved.
//

import UIKit

class ContentViewController: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var selectedNote : Note?{
        didSet{
            //Here we call the DispatchQueue.main.async method because we want to modify the UI in a closure.
            DispatchQueue.main.async {
                self.loadNote()
            }
        }
    }
    
    @IBOutlet weak var titleTextView: UITextView!
    
    @IBOutlet weak var contentsTextView: UITextView!
    
    
    override func viewWillDisappear(_ animated: Bool) {
        saveNote()
    }
    
    
    func loadNote(){
        
        if UITraitCollection.current.userInterfaceStyle == .dark {
                print("Dark mode")
                if let title = selectedNote!.title{
                    titleTextView?.text? = title
                    titleTextView.textColor = .white
                }
                if let text = selectedNote!.text{
                    contentsTextView?.text? = text
                    contentsTextView.textColor = .white
                }
            }
        
            else {
                print("Light mode")
                if let title = selectedNote!.title{
                    titleTextView?.text? = title
                    titleTextView.textColor = .black
                }
                if let text = selectedNote!.text{
                    contentsTextView?.text? = text
                    contentsTextView.textColor = .black
                }
            }
        
    }
    
    
    
    func saveNote(){
        selectedNote?.setValue(titleTextView.text, forKey: "title")
        selectedNote?.setValue(contentsTextView.text, forKey: "text")
        do {
            try context.save()
        } catch {
            print("Error saving note, \(error)")
        }
    }
    
}
