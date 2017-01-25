//
//  ViewController.swift
//  BanglaDictionary
//
//  Created by MacBook Pro on 11/29/16.
//  Copyright © 2016 MacMan. All rights reserved.
//

import UIKit

class HomeViewController: BaseViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchBarLeadingSpace: NSLayoutConstraint!
    @IBOutlet weak var languageSegmented: UISegmentedControl!
    @IBOutlet weak var searchBarTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var suggestionTableView: UITableView!
    @IBOutlet weak var languageSegmentedControl: UISegmentedControl!

    var searchBarDefaultWidth : CGFloat = 0.0
    var searchBarAnimatedWidth : CGFloat = 0.0
    var suggestionList = [String]()
    var suggestionIdList = [Int]()
    var containerViewController : ContainerViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(languageSegmented.selectedSegmentIndex == 0){
            searchBar.placeholder = "Search English Words"
        }
        else if(languageSegmented.selectedSegmentIndex == 1){
            searchBar.placeholder = "Search Bangla Words"
        }
        DBManager.shared.printPath()
        customizeSearchBar()
    }
    override func viewWillAppear(_ animated: Bool) {
        suggestionTableView.tableFooterView = UIView()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //MARK: TableView delegate methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return suggestionList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseId")
        cell!.textLabel!.text = suggestionList[indexPath.row].capitalized
        cell!.textLabel?.numberOfLines = 0
//        cell!.backgroundColor = UIColor.clear//(red: 48.0/255.0, green: 61.0/255.0, blue: 76.0/255.0, alpha: 1.0)
        cell?.textLabel?.textColor = UIColor.white
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var envelope : [Any]!
        envelope = [languageSegmented.selectedSegmentIndex, suggestionIdList[indexPath.row]]
        suggestionTableView.cellForRow(at: indexPath)?.contentView.backgroundColor = UIColor(red: 68.0/255.0, green: 80.0/255.0, blue: 93.0/255.0, alpha: 1.0)
        DispatchQueue.main.async {
            self.containerViewController.performSegue(withIdentifier: "ToMeaningViewController", sender: envelope)
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    //MARK: Actions
    @IBAction func languageChanged(_ sender: Any) {
        searchBar.text = ""
        suggestionList.removeAll()
        suggestionIdList.removeAll()
        suggestionTableView.isHidden = true
        if(languageSegmented.selectedSegmentIndex == 0){
            searchBar.placeholder = "Search English Words"
        }
        else if(languageSegmented.selectedSegmentIndex == 1){
            searchBar.placeholder = "Search Bangla Words"
        }
    }
    @IBAction func leftMenuTapped(_ sender: AnyObject) {
        self.foldMenuController().leftMenuAction()
    }
    //MARK: SearchBar Delegates
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        if(searchBar.text != ""){
            suggestionTableView.isHidden = false
        }
        searchBarLeadingSpace.constant = 0
        UIView.transition(with: searchBar, duration: 0.1, options: UIViewAnimationOptions() , animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        UIView.transition(with: self.languageSegmented, duration: 0.1, options: .transitionFlipFromTop , animations: {
            self.languageSegmented.isHidden = false
        }, completion: nil)
        
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText == ""){
            suggestionTableView.isHidden = true
        }
        else{
            suggestionTableView.isHidden = false
        }
        if(languageSegmented.selectedSegmentIndex == 0){
            let returnedResult = DBManager.shared.fetchSuggestionForPrimaryWord(prefix: searchText)
            suggestionList = returnedResult.suggestionList
            suggestionIdList = returnedResult.suggestionIdList
        }
        else if(languageSegmented.selectedSegmentIndex == 1){
            let returnedResult = DBManager.shared.fetchSuggestionForSecondaryWord(prefix: searchText)
            suggestionList = returnedResult.suggestionList
            suggestionIdList = returnedResult.suggestionIdList
        }
        suggestionTableView.frame.size.height = CGFloat(8 * 50)
        suggestionTableView.reloadData()
    }
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool{
        suggestionTableView.isHidden = true
        searchBarLeadingSpace.constant = 0
        UIView.transition(with: searchBar, duration: 0.4, options: UIViewAnimationOptions() , animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        UIView.transition(with: self.languageSegmented, duration: 0.4, options: .transitionFlipFromBottom , animations: {
            self.languageSegmented.isHidden = true
        }, completion: nil)
        
        return true
    }
    //MARK: Others
    func customizeSearchBar() {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBarDefaultWidth = searchBar.frame.size.width
        searchBarAnimatedWidth = searchBarDefaultWidth + 40
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
        searchBar.backgroundColor = UIColor(red: 48.0/255.0, green: 61.0/255.0, blue: 76.0/255.0, alpha: 1.0)
        searchBar.tintColor = UIColor.white
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.white
        
        let textFieldInsideSearchBarLabel = textFieldInsideSearchBar!.value(forKey: "placeholderLabel") as? UILabel
        textFieldInsideSearchBarLabel?.textColor = UIColor.white
        
        let clearButton = textFieldInsideSearchBar?.value(forKey: "clearButton") as! UIButton
        clearButton.setImage(clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate), for: .normal)
        clearButton.tintColor = UIColor.white
        
        let glassIconView = textFieldInsideSearchBar?.leftView as? UIImageView
        
        glassIconView?.image = glassIconView?.image?.withRenderingMode(.alwaysTemplate)
        glassIconView?.tintColor = UIColor.white
    }
}

