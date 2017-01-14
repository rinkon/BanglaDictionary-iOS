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
    var containerViewController : ContainerViewController!
    
    
    @IBOutlet weak var historyTableView: UITableView!
    
    override func viewDidLoad() {
        
    }
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
        
        var historyArray = UserDefaults.standard.value(forKey: Constants.HISTORY_ARRAY_KEY) as! [String]
        
        historyWordListArray.removeAll()
        historyWordTableList.removeAll()
        historyWordIdList.removeAll()
        
        for index in 0..<historyArray.count {
            var word = ""
            var characterArray = Array(historyArray[index].characters)
            if(characterArray[0] == "p"){
                historyArray[index].remove(at: historyArray[index].startIndex)
                word = DBManager.shared.fetchFavorite(tableName: "primary_word", wordId: Int(historyArray[index])!)
                historyWordTableList.append(0)
                historyWordIdList.append(Int(historyArray[index])!)
            }
            else if(characterArray[0] == "s"){
                historyArray[index].remove(at: historyArray[index].startIndex)
                word = DBManager.shared.fetchFavorite(tableName: "secondary_word", wordId: Int(historyArray[index])!)
                historyWordTableList.append(1)
                historyWordIdList.append(Int(historyArray[index])!)
            }
            historyWordListArray.append(word)
        }
        historyTableView.reloadData()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyWordListArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyReuseId", for: indexPath)
        cell.textLabel?.text = historyWordListArray[indexPath.row].capitalized
        cell.backgroundColor = UIColor(red: 48.0/255.0, green: 61.0/255.0, blue: 76.0/255.0, alpha: 1.0)
        cell.textLabel?.textColor = UIColor.white
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var envelope = [Any]()
        envelope = [historyWordTableList[indexPath.row], historyWordIdList[indexPath.row]]
        DispatchQueue.main.async {
            self.containerViewController.performSegue(withIdentifier: "ToMeaningViewController", sender: envelope)
        }
    }
}
