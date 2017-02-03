//
//  ContainerViewController.swift
//  BanglaDictionary
//
//  Created by MacBook Pro on 12/5/16.
//  Copyright © 2016 MacMan. All rights reserved.
//

import UIKit
import TabPageViewController
import GoogleMobileAds
import AudioToolbox


class ContainerViewController: UIViewController, GADBannerViewDelegate, UITableViewDataSource, UITableViewDelegate {
    let tabPageViewController = TabPageViewController.create()
    var adMobBannerView = GADBannerView()
    var interstitial: GADInterstitial!

    
    @IBOutlet weak var tabPageContainerView: UIView!
    @IBOutlet weak var menuTableView: UITableView!
    @IBOutlet weak var closeMenuButton: UIButton!
    @IBOutlet weak var menuBackgroundImageView: UIImageView!
    @IBOutlet weak var menuTableBackGroundView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addBarButton()
        menuTableView.tableHeaderView = getHeaderView()
        
        closeMenuButton.layer.zPosition = 100
        self.foldMenuController().rightMenuEnabled = false
        self.foldMenuController().foldEffeectEnabled = false
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc1 = storyBoard.instantiateViewController(withIdentifier: "Home") as! HomeViewController
        let vc2 = storyBoard.instantiateViewController(withIdentifier: "Favorite") as! FavoriteViewController
        let vc3 = storyBoard.instantiateViewController(withIdentifier: "History") as! HistoryViewController
        let vc4 = storyBoard.instantiateViewController(withIdentifier: "Settings") as! GamesViewController
        vc1.containerViewController = self
        vc2.containerViewController = self
        vc3.containerViewController = self
        vc4.containerViewController = self
        tabPageViewController.tabItems = [(vc1, "Home"), (vc2, "Saved Words"), (vc3, "History"), (vc4, "Games")]
        tabPageViewController.view.frame = self.tabPageContainerView.frame
        tabPageViewController.option.tabBackgroundColor = UIColor(red: 48.0/255.0, green: 61.0/255.0, blue: 76.0/255.0, alpha: 1.0)
        tabPageViewController.option.currentColor = UIColor.white
        tabPageViewController.option.defaultColor = UIColor.white
        tabPageViewController.option.tabHeight = 32
        self.tabPageContainerView.addSubview(tabPageViewController.view)
        let emptyImage = UIImage()
        self.navigationController?.navigationBar.shadowImage = emptyImage
        self.navigationController?.navigationBar.setBackgroundImage(emptyImage, for: .default)
        initAdMobBanner()
        showBanner(adMobBannerView)
        createAndLoadInterstitial()
    }
    override func viewWillAppear(_ animated: Bool) {
        menuTableView.tableFooterView = UIView()
        print("viewwillappear of containerviewcontroller")
        if(Constants.countForInterstitial%5 == 0 && Constants.countForInterstitial != 0){
            if interstitial.isReady {
                interstitial.present(fromRootViewController: self)
                Constants.countForInterstitial = 0
            } else {
                print("Ad wasn't ready")
            }
            createAndLoadInterstitial()
        }
    }
    
    func addBarButton(){
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "menu_image.png"), for: UIControlState())
        button.addTarget(self, action: #selector(self.leftMenuTapped(_:)), for: UIControlEvents.touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.leftBarButtonItem = barButton
    }
    func leftMenuTapped(_ sender: AnyObject) {
        self.foldMenuController().leftMenuAction()
    }
    func rightMenuTapped(_ sender: AnyObject) {
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "ToMeaningViewController"){
            let vc = segue.destination as! MeaningViewController
            let envelope = sender as! [Any]
            vc.wordTable = envelope[0] as! Int
            vc.wordId = envelope[1] as! Int
            vc.showDismissButton = false
        }
    }
    //MARK: BannerAdRelated
    func initAdMobBanner() {
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            // iPhone
            adMobBannerView.adSize =  GADAdSizeFromCGSize(CGSize(width: 320, height: 50))
            adMobBannerView.frame = CGRect(x: 0, y: view.frame.size.height, width: 320, height: 50)
        } else  {
            // iPad
            adMobBannerView.adSize =  GADAdSizeFromCGSize(CGSize(width: 468, height: 60))
            adMobBannerView.frame = CGRect(x: 0, y: view.frame.size.height, width: 468, height: 60)
        }
        adMobBannerView.adSize = kGADAdSizeSmartBannerPortrait
        
        
        adMobBannerView.adUnitID = Constants.ADMOB_BANNER_UNIT_ID
        adMobBannerView.rootViewController = self
        adMobBannerView.delegate = self
        view.addSubview(adMobBannerView)
        
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        adMobBannerView.load(request)
    }
    
    
    // Hide the banner
    func hideBanner(_ banner: UIView) {
        UIView.beginAnimations("hideBanner", context: nil)
        banner.frame = CGRect(x: view.frame.size.width/2 - banner.frame.size.width/2, y: view.frame.size.height - banner.frame.size.height, width: banner.frame.size.width, height: banner.frame.size.height)
        UIView.commitAnimations()
        banner.isHidden = true
    }
    
    // Show the banner
    func showBanner(_ banner: UIView) {
        UIView.beginAnimations("showBanner", context: nil)
        banner.frame = CGRect(x: view.frame.size.width/2 - banner.frame.size.width/2, y: view.frame.size.height - banner.frame.size.height, width: banner.frame.size.width, height: banner.frame.size.height)
        UIView.commitAnimations()
        banner.isHidden = false
    }
    
    // AdMob banner available
    func adViewDidReceiveAd(_ view: GADBannerView!) {
        showBanner(adMobBannerView)
    }
    
    // NO AdMob banner available
    func adView(_ view: GADBannerView!, didFailToReceiveAdWithError error: GADRequestError!) {
        hideBanner(adMobBannerView)
    }
    //MARK: Interstitial
    fileprivate func createAndLoadInterstitial() {
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-8831588022499731/1042848201")
        let request = GADRequest()
        // Request test ads on devices you specify. Your test device ID is printed to the console when
        // an ad request is made.
        request.testDevices = [ kGADSimulatorID]
        interstitial.load(request)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuReuseCell")
        if(indexPath.row == 0){
            cell?.textLabel?.text = "Clear History"
        }
        
        cell?.backgroundColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.2)
        
        cell?.textLabel?.textColor = UIColor.white
        
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        if(indexPath.row == 0){
            
            let alertController = UIAlertController(title: "Are you sure?", message: "Pressing 'Delete all' will remove all words from History", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let deleteAction = UIAlertAction(title: "Delete all", style: .default, handler: { action in
                var historyArray = UserDefaults.standard.value(forKey: Constants.HISTORY_ARRAY_KEY) as! [String]
                historyArray.removeAll()
                UserDefaults.standard.set(historyArray, forKey: Constants.HISTORY_ARRAY_KEY)
            })
            alertController.addAction(cancelAction)
            alertController.addAction(deleteAction)
            
//            let firstSubview = alertController.view.subviews.first
//            let alertContentView = firstSubview?.subviews.first
//            for subview in (alertContentView?.subviews)! {
//                subview.backgroundColor = UIColor(red: 48.0/255.0, green: 61.0/255.0, blue: 76.0/255.0, alpha: 1.0)
//                subview.layer.cornerRadius = 10
//                subview.alpha = 1
//                subview.layer.borderWidth = 1
//                subview.layer.borderColor = UIColor.white.cgColor
//                
//            }
            self.present(alertController, animated: true, completion: {() -> Void in
            
            })
        }
//        closeMenu(closeMenuButton)
    }
    
    
    @IBAction func closeMenu(_ sender: Any) {
        showOrHideMenu(UIBarButtonItem())
    }
    @IBAction func showOrHideMenu(_ sender: Any) {
        if(menuTableBackGroundView.isHidden){
            UIView.transition(with: menuTableBackGroundView, duration: 0.2, options: .transitionCrossDissolve, animations: {
                self.menuTableBackGroundView.isHidden = false
                self.navigationController?.setNavigationBarHidden(true, animated: true)
                self.adMobBannerView.frame.origin.y = self.view.frame.size.height - self.adMobBannerView.frame.size.height
            }, completion:nil)
            
            UIView.transition(with: menuBackgroundImageView, duration: 0.4, options: .transitionCrossDissolve, animations: {
                self.menuBackgroundImageView.isHidden = false
            }, completion:nil)
        }
        else{
            
            UIView.transition(with: menuTableBackGroundView, duration: 0.2, options: .transitionCrossDissolve, animations: {
                self.menuTableBackGroundView.isHidden = true
                self.menuBackgroundImageView.isHidden = true
                self.adMobBannerView.frame.origin.y = self.view.frame.size.height - self.adMobBannerView.frame.size.height - (self.navigationController?.navigationBar.frame.height)!
                self.navigationController?.setNavigationBarHidden(false, animated: true)
            }, completion: nil)
            
            
            
        }
    }
    func getHeaderView() -> UIView {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 60))
        let headerLabel = UILabel(frame: CGRect(x: 10, y: 0, width: view.frame.width - 10, height: 60))
        headerLabel.text = "Bangla Dictionary"
        headerLabel.font = UIFont.systemFont(ofSize: 30)
        headerLabel.textColor = UIColor.white
        headerView.addSubview(headerLabel)
        return headerView
    }
}
