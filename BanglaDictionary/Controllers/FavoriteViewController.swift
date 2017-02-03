//
//  FavoriteViewController.swift
//  BanglaDictionary
//
//  Created by MacBook Pro on 12/5/16.
//  Copyright © 2016 MacMan. All rights reserved.
//

import UIKit

class FavoriteViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    var favoriteWordListArray = [String]()
    var favoriteWordTableList = [Int]()
    var favoriteWordIdList = [Int]()
    var favoriteArrayClass = [String]()
    var containerViewController : ContainerViewController!
    var longGesture : UILongPressGestureRecognizer!
    @IBOutlet weak var favoriteTableView: UITableView!
    
    override func viewDidLoad() {
    }
    override func viewWillAppear(_ animated: Bool) {
//        print("viewWillAppear")
        favoriteTableView.tableFooterView = UIView()
        loadFavoriteWords()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteWordListArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoriteCellReuseId", for: indexPath)
        cell.textLabel?.text = favoriteWordListArray[indexPath.row].capitalized
        cell.backgroundColor = UIColor(red: 48.0/255.0, green: 61.0/255.0, blue: 76.0/255.0, alpha: 1.0)
        cell.textLabel?.textColor = UIColor.white
        
        let accessoryBtn = UIButton()
        accessoryBtn.setBackgroundImage(UIImage(named: "delete1.jpg") , for: .normal)
        accessoryBtn.frame = CGRect(x: cell.frame.size.width - 30, y: (cell.frame.size.height - 20)/2, width: 20, height: 20)
        accessoryBtn.addTarget(self, action: #selector(self.accessoryButtonClicked(sender:)), for: .touchUpInside)
        accessoryBtn.tag = indexPath.row
        cell.addSubview(accessoryBtn)
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var envelope = [Any]()
        envelope = [favoriteWordTableList[indexPath.row], favoriteWordIdList[indexPath.row]]
        self.containerViewController.performSegue(withIdentifier: "ToMeaningViewController", sender: envelope)
    }
    func accessoryButtonClicked(sender : UIButton) {
        let alertController = UIAlertController(title: "Delete word?", message: "someMessage", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete", style: .default, handler: { action in
            self.removeFromFavorite(index: sender.tag)
        })
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        self.present(alertController, animated: true, completion: nil)
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
        favoriteTableView.reloadData()
    }
    
}
