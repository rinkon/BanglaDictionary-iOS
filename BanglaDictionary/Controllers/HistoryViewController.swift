//
//  HistoryViewController.swift
//  BanglaDictionary
//
//  Created by MacBook Pro on 12/5/16.
//  Copyright © 2016 MacMan. All rights reserved.
//

import UIKit

class HistoryViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    var historyWordListArray = [String]()
    var historyWordTableList = [Int]()
    var historyWordIdList = [Int]()
    var historyArray = [String]()
    var containerViewController : ContainerViewController!
    
    
    @IBOutlet weak var historyTableView: UITableView!
    @IBOutlet weak var heightOfTabBar: NSLayoutConstraint!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var okButtonConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        okButtonConstraint.constant -= view.bounds.height/2
        doneButton.layer.cornerRadius = 3
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        heightOfTabBar.constant = CGFloat(Constants.tabBarHeight)
        historyTableView.tableFooterView = UIView()
        loadHistoryWords()
        if(bannerShown){
            tableBottomConstraint.constant = bannerAdHeight
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyWordListArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyReuseId", for: indexPath)
        cell.textLabel?.text = historyWordListArray[indexPath.row].capitalized
        cell.backgroundColor = UIColor(red: 48.0/255.0, green: 61.0/255.0, blue: 76.0/255.0, alpha: 1.0)
        cell.textLabel?.textColor = UIColor.white
        cell.addGestureRecognizer(generateGestureRecognizer())
        
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor(red: 85.0/255.0, green: 146.0/255.0, blue: 154.0/255.0, alpha: 1.0)
        cell.selectedBackgroundView = selectedBackgroundView
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var envelope = [Any]()
        envelope = [historyWordTableList[indexPath.row], historyWordIdList[indexPath.row]]
        self.containerViewController.performSegue(withIdentifier: "ToMeaningViewController", sender: envelope)
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let alertController = UIAlertController(title: "Delete word?", message: "This word will be permanently deleted", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let deleteAction = UIAlertAction(title: "Delete", style: .default, handler: { action in
                self.removeFromHistory(index: indexPath.row)
                
            })
            alertController.addAction(cancelAction)
            alertController.addAction(deleteAction)
            self.present(alertController, animated: true, completion: nil)
            
        }
    }

    func longPressAction(gesture: UILongPressGestureRecognizer){
        historyTableView.setEditing(true, animated: true)
        
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
        historyTableView.setEditing(false, animated: true)
        UIView.animate(withDuration: 0.5, delay: 0.3, options: .curveEaseOut, animations: {
            self.okButtonConstraint.constant -= self.view.bounds.height/2
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    func removeFromHistory(index : Int) {
        historyArray.remove(at: index)
        UserDefaults.standard.set(historyArray, forKey: Constants.HISTORY_ARRAY_KEY)
        self.loadHistoryWords()
    }
    func loadHistoryWords()  {
        historyArray.removeAll()
        var historyArrayTemp = UserDefaults.standard.value(forKey: Constants.HISTORY_ARRAY_KEY) as! [String]
        historyArray = historyArrayTemp
        historyWordListArray.removeAll()
        historyWordTableList.removeAll()
        historyWordIdList.removeAll()
        
        for index in 0..<historyArrayTemp.count {
            var word = ""
            var characterArray = Array(historyArrayTemp[index].characters)
            if(characterArray[0] == "p"){
                historyArrayTemp[index].remove(at: historyArrayTemp[index].startIndex)
                word = DBManager.shared.fetchFavorite(tableName: "primary_word", wordId: Int(historyArrayTemp[index])!)
                historyWordTableList.append(0)
                historyWordIdList.append(Int(historyArrayTemp[index])!)
            }
            else if(characterArray[0] == "s"){
                historyArrayTemp[index].remove(at: historyArrayTemp[index].startIndex)
                word = DBManager.shared.fetchFavorite(tableName: "secondary_word", wordId: Int(historyArrayTemp[index])!)
                historyWordTableList.append(1)
                historyWordIdList.append(Int(historyArrayTemp[index])!)
            }
            historyWordListArray.append(word)
        }
        historyTableView.reloadData()
    }
    
}
