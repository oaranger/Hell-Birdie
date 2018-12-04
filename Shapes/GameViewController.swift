//
//  GameViewController.swift
//  Shapes
//
//  Created by Binh Huynh on 9/11/16.
//  Copyright (c) 2016 Binh Huynh. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import UIKit
import Social
import GameKit
import StoreKit
import AVFoundation
import GoogleMobileAds

let KeyShare        = "CuBI.com.share"
let KeyLoadInterAds = "CuBI.com.loadInterAd"
let KeyShowInterAds = "CuBI.com.showInterAd"
let KeyLoadFB       = "CuBI.com.loadFB"
let KeyRate         = "CuBI.com.rateUs"
let KeyBannerAds    = "CuBI.com.bannerAds"

var musicPlaying    = true
var bannerDidLoad   = false
var gameOverCount   = 0
var speakerOn       = true

class GameViewController: UIViewController, GKGameCenterControllerDelegate, UIAlertViewDelegate, GADInterstitialDelegate {
    
    var imageView = UIImageView()
    var interstitial: GADInterstitial!
    var rewardedInter: GADRewardBasedVideoAd!
    var banner: GADBannerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            
            let scene = GameScene(size:CGSize(width: 1536, height: 2048))
            scene.scaleMode = .aspectFill
            view.presentScene(scene)
            view.ignoresSiblingOrder = true
            view.showsFPS = false
            view.showsNodeCount = false
            view.showsPhysics = false
            if scene.productPurchased == false {
                loadBanner()
                self.view.addSubview(banner)
                bannerDidLoad = true
            }
        }
        
//        playBackgroundMusic(filename: "next_to_you.mp3")    
        
        //Authenticate Game Center
        NotificationCenter.default.addObserver(self, selector:#selector(GameViewController.showAuthenticationViewController),name:NSNotification.Name(rawValue: PresentAuthenticationViewController), object: nil)
        SGGameKit.sharedInstance.authenticateLocalPlayer()
        
        // Share
        NotificationCenter.default.addObserver(self, selector: (#selector(GameViewController.displayShareSheet)), name:NSNotification.Name(rawValue: KeyShare), object: nil)
        
        // Interstitial iAD: Show
        NotificationCenter.default.addObserver(self, selector: (#selector(GameViewController.showInterstitial)), name:NSNotification.Name(rawValue: KeyShowInterAds), object: nil)
        
        // Interstitial iAD: Load
        NotificationCenter.default.addObserver(self, selector: (#selector(GameViewController.loadInterstitial)), name:NSNotification.Name(rawValue: KeyLoadInterAds), object: nil)
        
        // Load Facebook Page
        NotificationCenter.default.addObserver(self, selector: (#selector(GameViewController.loadFBPage)), name:NSNotification.Name(rawValue: KeyLoadFB), object: nil)
        
        // Pop Up Rate Us
        NotificationCenter.default.addObserver(self, selector: (#selector(GameViewController.popRateUs)), name:NSNotification.Name(rawValue: KeyRate), object: nil)
        
        // Show Ads Banner
        NotificationCenter.default.addObserver(self, selector: (#selector(GameViewController.hideBanner)), name:NSNotification.Name(rawValue: KeyBannerAds), object: nil)

    }
    
    func hideBanner() {
        if bannerDidLoad {
            print("Hidding Ads Banner")
            banner.removeFromSuperview()
        }
    }
    
    func loadBanner() {
        banner = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        banner.adUnitID = "your_banner_id"
        banner.rootViewController = self
        let req: GADRequest = GADRequest()
        banner.load(req)
        banner.frame = CGRect(x: (view.bounds.width - banner.frame.width)/2, y: view.bounds.height - banner.frame.size.height, width: banner.frame.width, height: banner.frame.height)
    }
    
    func loadInterstitial() {
        interstitial = GADInterstitial(adUnitID: "your_interstitial_id")
        interstitial.delegate = self
        let request = GADRequest()
        interstitial.load(request)
    }
    
    func showInterstitial() {
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        }
    }
    
    func displayShareSheet() {
        let initialText = "OMG! Look at what I've got in Hyper Brick !\n" + "https://itunes.apple.com/us/app/id1136172170)"
        if let myImage =  self.view?.pb_takeSnapshot() {
            UIImageWriteToSavedPhotosAlbum(myImage, nil, nil, nil)
            let activityViewController = UIActivityViewController(activityItems: [initialText,myImage as UIImage], applicationActivities: [])
            activityViewController.excludedActivityTypes = [UIActivityType.openInIBooks]
            
            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
                self.present(activityViewController, animated: true, completion: {})
            } else {
//                let popup: UIPopoverController = UIPopoverController(contentViewController:activityViewController)
//                popup.present(from: CGRect(self.view.frame.size.width / 2, self.view.frame.size.height / 4, 0, 0), in: self.view, permittedArrowDirections: UIPopoverArrowDirection.any, animated: true)
            }
        }
    }
    
    func loadFBPage() {
        let url = "https://www.facebook.com/AppBoo-257026071346825/"
        UIApplication.shared.openURL(NSURL(string: url)! as URL)
    }
    
    func popRateUs(){
        let alert = UIAlertController(title: "Enjoying HYPER BRICK ?", message: "Write a review to let us know your thoughts", preferredStyle: UIAlertControllerStyle.alert)
        self.present(alert, animated: true, completion: nil)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("closed", terminator: "")
            case .cancel:
                print("cancel")
            case .destructive:
                print("destructive")
            }
        }))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
            case .default:
                let appId = "1170838321"
                if let url = NSURL(string: "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=\(appId)") {
                    UIApplication.shared.openURL(url as URL)
                }
                print("closed", terminator: "")
            case .cancel:
                print("cancel")
            case .destructive:
                print("destructive")
            }
        }))
    }
    
    func showAuthenticationViewController() {
        let gameKitHelper = SGGameKit.sharedInstance
        if let authenticationViewController = gameKitHelper.authenticationViewController {
            self.present(authenticationViewController, animated: true,
                         completion: nil)
        }
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController){
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override var shouldAutorotate : Bool {
        return true
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
}
