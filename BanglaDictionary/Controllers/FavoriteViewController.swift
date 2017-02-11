//
//  FavoriteViewController.swift
//  BanglaDictionary
//
//  Created by MacBook Pro on 12/5/16.
//  Copyright © 2016 MacMan. All rights reserved.
//

import UIKit

class FavoriteViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    var favoriteWordListArray = [String]()
    var favoriteWordTableList = [Int]()
    var favoriteWordIdList = [Int]()
    var favoriteArrayClass = [String]()
    var containerViewController : ContainerViewController!
    
    @IBOutlet weak var favoriteTableView: UITableView!
    @IBOutlet weak var heightOfTabBar: NSLayoutConstraint!
    @IBOutlet weak var okButtonConstraint: NSLayoutConstraint!
    @IBOutlet weak var doneButton: UIButton!
    
    override func viewDidLoad() {
        okButtonConstraint.constant -= view.bounds.height/2
        doneButton.layer.cornerRadius = 3
    }
    override func viewWillAppear(_ animated: Bool) {
        heightOfTabBar.constant = CGFloat(Constants.tabBarHeight)
        favoriteTableView.tableFooterView = UIView()
        loadFavoriteWords()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteWordListArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoriteCellReuseId", for: indexPath)
        cell.textLabel?.text = favoriteWordListArray[indexPath.row].capitalized
        cell.textLabel?.textColor = UIColor.white
        
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor.black
        cell.selectedBackgroundView = selectedBackgroundView
        
        cell.addGestureRecognizer(generateGestureRecognizer())
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var envelope = [Any]()
        envelope = [favoriteWordTableList[indexPath.row], favoriteWordIdList[indexPath.row]]
        self.containerViewController.performSegue(withIdentifier: "ToMeaningViewController", sender: envelope)
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let alertController = UIAlertController(title: "Delete word?", message: "someMessage", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let deleteAction = UIAlertAction(title: "Delete", style: .default, handler: { action in
                self.removeFromFavorite(index: indexPath.row)
                
            })
            alertController.addAction(cancelAction)
            alertController.addAction(deleteAction)
            self.present(alertController, animated: true, completion: nil)
            
        }
    }
    
    func accessoryButtonClicked(sender : UIButton) {
        
    }
    func removeFromFavorite(index : Int) {
        favoriteArrayClass.remove(at: index)
        UserDefaults.standard.set(favoriteArrayClass, forKey: Constants.FAVORITE_ARRAY_KEY)
        self.loadFavoriteWords()
    }
    
    func loadFavoriteWords() {
        favoriteArrayClass.removeAll()
        var favoriteArray = UserDefaults.standard.value(forKey: Constants.FAVORITE_ARRAY_KEY) as! [String]
        favoriteArrayClass = favoriteArray
        favoriteWordListArray.removeAll()
        favoriteWordTableList.removeAll()
        favoriteWordIdList.removeAll()
        
        for index in 0..<favoriteArray.count {
            var word = ""
            var characterArray = Array(favoriteArray[index].characters)
            if(characterArray[0] == "p"){
                favoriteArray[index].remove(at: favoriteArray[index].startIndex)
                word = DBManager.shared.fetchFavorite(tableName: "primary_word", wordId: (favoriteArray[index] as NSString).integerValue)
                favoriteWordTableList.append(0)
                favoriteWordIdList.append((favoriteArray[index] as NSString).integerValue)
            }
            else if(characterArray[0] == "s"){
                favoriteArray[index].remove(at: favoriteArray[index].startIndex)
                word = DBManager.shared.fetchFavorite(tableName: "secondary_word", wordId: Int(favoriteArray[index])!)
                favoriteWordTableList.append(1)
                favoriteWordIdList.append(Int(favoriteArray[index])!)
            }
            favoriteWordListArray.append(word)
        }
//        print(favoriteArrayClass)
        print(CGFloat(favoriteWordListArray.count))
        favoriteTableView.reloadData()
    }
    func deleteButtonPressed(_ sender : UIButton) {
        if(favoriteTableView.isEditing){
            sender.setTitle("Delete", for: .normal)
            favoriteTableView.setEditing(false, animated: true)
        }
        else{
            sender.setTitle("Ok", for: .normal)
            favoriteTableView.setEditing(true, animated: true)
        }
    }
    func longPressAction(gesture: UILongPressGestureRecognizer){
        favoriteTableView.setEditing(true, animated: true)
        if(gesture.state == UIGestureRecognizerState.began){
            UIView.animate(withDuration: 0.5, delay: 0.3, options: .curveEaseOut, animations: {
                self.okButtonConstraint.constant += self.view.bounds.height/2
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    func generateGestureRecognizer() -> UILongPressGestureRecognizer {
        let longGesture = UILongPressGestureRecognizer(target: self, action: (#selector(self.longPressAction)))
        longGesture.minimumPressDuration = 1.0
        return longGesture
    }
    @IBAction func doneButtonPressed(_ sender: Any) {
        favoriteTableView.setEditing(false, animated: true)
        UIView.animate(withDuration: 0.5, delay: 0.3, options: .curveEaseOut, animations: {
            self.okButtonConstraint.constant -= self.view.bounds.height/2
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
}
