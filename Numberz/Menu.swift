//
//  Menu.Swift
//  Numberz
//
//
//  Created by Jiang Wenhao on 01/5/17.
//  Copyright © 2017 Jiang Wenhao. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import GameKit
import GoogleMobileAds
import AudioToolbox
import Social



/* GLOBAL VARIABLES */

var timerToGenerateRandomNumbers: Timer?
var timerToIncreaseTimeInterval: Timer?
var increaseCount = 0

var timeInterval: TimeInterval?
var timer60sec: Timer?

var countdown = 60

var gameMode = ""

var buttonsCounter = 0

var pauseIsOn = false

var audioPlayer = AVAudioPlayer()


var boardButtTapsCount = 0
var firstTAG = 0

var defaults = UserDefaults.standard
var scorePoints = 0
var bestScore =  0


// IMPORTANT: replace the red string below with your own Leaderboard ID (the one you've set in iTunes Connect)
let leaderboardID = "com.bestscore.numberz"

// IMPORTANT: REPLACE THE RED STRING BELOW WITH THE UNIT ID YOU'VE GOT BY REGISTERING YOUR APP IN http://www.apps.admob.com
let ADMOB_UNIT_ID = "ca-app-pub-9733347540588953/6145924825"




// Basic color for Board Buttons (you can edit the RGBA values here)
var grayColor = UIColor(red: 47/255, green: 55/255, blue: 65/255, alpha: 0.37)



/* GLOBAL VIEWS */
var button: UIButton!









// MARK: - MENU CONTROLLER
class Menu: UIViewController,
GKGameCenterControllerDelegate
{
    
    /* Views */
    @IBOutlet weak var infoView: UIView!
   
    
    
    /* Variables */
    var gcEnabled = Bool() // Check if the user has Game Center enabled
    var gcDefaultLeaderBoard = String() // Check the default leaderboardID
    
    
    
override var prefersStatusBarHidden : Bool {
        return true
}
    
override func viewDidLoad() {
        super.viewDidLoad()
    
    // infoView Setup
    infoView.frame = CGRect(x: 0, y: self.view.frame.size.height, width: 260, height: 260)
    infoView.center = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height*2)
    infoView.layer.cornerRadius = 10
  //  self.view.bringSubviewToFront(infoView)
    
    
    // Call the GC authentication controller
    authenticateLocalPlayer()
}
  
    
    
// MARK: - AUTHENTICATE LOCAL PLAYER - GAME CENTER
func authenticateLocalPlayer() {
    let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
        
    localPlayer.authenticateHandler = {(ViewController, error) -> Void in
        if((ViewController) != nil) {
            // 1 Show login if player is not logged in
            self.present(ViewController! , animated: true, completion: nil)
        } else if (localPlayer.isAuthenticated) {
            // 2 Player is already euthenticated & logged in, load game center
            self.gcEnabled = true
                
            // Get the default leaderboard ID
            localPlayer.loadDefaultLeaderboardIdentifier(completionHandler: { (leaderboardIdentifer, error) -> Void in
                if error != nil {
                    print(error)
                } else {
                    self.gcDefaultLeaderBoard = leaderboardIdentifer!
                }
            })
        } else {
            // 3 Game center is not enabled on the users device
            self.gcEnabled = false
            print("Local player could not be authenticated!")
            print(error)
            }
            
        }
}
func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
}
    
    
    
 
/* 60-SEC BUTTON ==============================*/
@IBAction func sec60Butt(_ sender: AnyObject) {
    gameMode = "60sec"
    countdown = 60
    let gbVC = self.storyboard?.instantiateViewController(withIdentifier: "GameBoard") as! GameBoard
    self.navigationController?.pushViewController(gbVC, animated: true)
}
    
/* ENDLESS BUTTON ==============================*/
@IBAction func endlessButt(_ sender: AnyObject) {
    gameMode = "endless"
    let gbVC = self.storyboard?.instantiateViewController(withIdentifier: "GameBoard") as! GameBoard
    self.navigationController?.pushViewController(gbVC, animated: true)
}


/* GAME CENTER BUTTON ==============================*/
@IBAction func gameCenterButt(_ sender: AnyObject) {
    let gcVC: GKGameCenterViewController = GKGameCenterViewController()
    gcVC.gameCenterDelegate = self
    gcVC.viewState = GKGameCenterViewControllerState.leaderboards
    gcVC.leaderboardIdentifier = leaderboardID
    self.present(gcVC, animated: true, completion: nil)
}
    
/* INFO BUTTON ==============================*/
@IBAction func infoButt(_ sender: AnyObject) {
    showInfoView()
}
    
@IBAction func dismissInfoView(_ sender: AnyObject) {
  hideInfoView()
}

    
    
/* ANIMATIONS FOR THE INFO VIEW ===================*/
func showInfoView() {
    UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
        self.infoView.frame.origin.y = 110
        }, completion: { (finished: Bool) in
        });
}
func hideInfoView() {
    UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
        self.infoView.frame.origin.y = self.view.frame.size.height
        }, completion: { (finished: Bool) in
        });
}
    
    
    
    
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
}
}


