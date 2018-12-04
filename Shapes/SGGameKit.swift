//
//  SGGameKit.swift
//  Sky Up
//
//  Created by Binh Huynh on 9/28/16.
//  Copyright © 2016 Binh Huynh. All rights reserved.
//


import GameKit
import Foundation

let PresentAuthenticationViewController = "PresentAuthenticationViewController"
let singleton = SGGameKit()

class SGGameKit: NSObject {
    
    var authenticationViewController: UIViewController?
    
    var lastError: NSError?
    var gameCenterEnabled: Bool
    
    class var sharedInstance: SGGameKit {
        return singleton
    }
    
    override init() {
        gameCenterEnabled = true
        super.init()
    }
    
    func authenticateLocalPlayer() {
        
        let localPlayer = GKLocalPlayer.localPlayer()
        
        localPlayer.authenticateHandler = {(viewController, error) in
            self.lastError = error as NSError?
            if viewController != nil {
                self.authenticationViewController = viewController
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: PresentAuthenticationViewController),
                                                object: self)
            } else if localPlayer.isAuthenticated {
                self.gameCenterEnabled = true
            } else {
                self.gameCenterEnabled = false
            }
        }
        
    }
    
    func showGKGameCenterViewController(viewController: UIViewController!, state: Int) {
        
        if !gameCenterEnabled {
            print("Local player is not authenticated")
            return
        }
        
        let gameCenterViewController = GKGameCenterViewController()
        gameCenterViewController.gameCenterDelegate = self
        
        switch state {
        case 1:
            gameCenterViewController.viewState = .achievements
            break
        case 2:
            gameCenterViewController.viewState = .leaderboards
            break
        default:
            break
        }
        viewController.present(gameCenterViewController,
                               animated: true, completion: nil)
    }
    
    func reportAchievements(achievements: [GKAchievement]) {
        if !gameCenterEnabled {
            print("Local player is not authenticated")
            return
        }
        GKAchievement.report(achievements) { (error: Error?) in
            self.lastError = error as NSError?
        }
    }
    
    func reportScore(score: Int64, forLeaderBoardId leaderBoardId: String) {
        
        if !gameCenterEnabled {
            print("Local player is not authenticated")
            return
        }
        
        let scoreReporter = GKScore(leaderboardIdentifier: leaderBoardId)
        scoreReporter.value = score
        scoreReporter.context = 0
        
        let scores = [scoreReporter]
        
        GKScore.report(scores) { (error: Error?) in
            self.lastError = error as NSError?
        }
    }
    
    
}

extension SGGameKit: GKGameCenterControllerDelegate {
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        
        gameCenterViewController.dismiss(animated: true, completion: nil)
        
    }
    
}


