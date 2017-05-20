//
//  GameBoard.Swift
//  Numberz
//
//
//  Created by Jiang Wenhao on 01/5/17.
//  Copyright © 2017 Jiang Wenhao. All rights reserved.
//

import UIKit
import GameKit
import GoogleMobileAds
import AudioToolbox
import AVFoundation


class GameBoard: UIViewController,
GKGameCenterControllerDelegate,
GADBannerViewDelegate
{
    
    /* Views */
    @IBOutlet var numberButtons: [UIButton]!
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var pauseView: UIView!
    @IBOutlet weak var bestScoreLabel: UILabel!
    
    
    //Ad banners properties
    var adMobBannerView = GADBannerView()
    
    
    
    
override var prefersStatusBarHidden : Bool {
    return true
}
    
override func viewWillAppear(_ animated: Bool) {
        
        /* STARTUP SETTINGS ==============================*/
        increaseCount = 0
        buttonsCounter = 0
        scorePoints = 0
        scoreLabel.text = "\(scorePoints)"
        countdown = 60
        pauseIsOn = false
        boardButtTapsCount = 0
        firstTAG = 0
        
        // Load last Best Score
        bestScore = defaults.integer(forKey: "bestScore")
        bestScoreLabel.text = "Best Score: \(bestScore)"
        print("BEST SCORE: \(bestScore)")
        
        // Move the pauseView out of the screen
        pauseView.frame = CGRect(x: 0, y: self.view.frame.size.height,
            width: self.view.frame.size.width, height: self.view.frame.size.height)
        /*===================================================*/
        
        
        
        /* NUMBER BUTTONS SETTINGS =====================================*/
        var tagForButtons = -1
        for  button in numberButtons {
            tagForButtons += 1
            
            // You can edit borders color and width here
            button.layer.cornerRadius = 6
            button.layer.borderWidth = 0.6
            button.layer.borderColor = grayColor.cgColor
            //============================================
            
            button.tag = tagForButtons
            button.setTitle(" ", for: .normal)
            button.addTarget(self, action: #selector(boardButtonTapped(_:)), for: UIControlEvents.touchUpInside)
        }
        /*===============================================================*/
        
        
        
        // GAME MODE - SETUP ==========================
        if gameMode == "60sec" {
            fire60secTimer()
            timerLabel.isHidden = false
            timerLabel.text = "60"
        } else if gameMode == "endless" {
            timerLabel.isHidden = true
        }
        /*===============================================================*/
        
        
        
        /* FIRE TIMERS =========================================*/
        timeInterval = 1.0
        fireTimerToGenerateNumbers()
        fireTimerToIncreaseTimeInterval()
        /*===============================================================*/
        
}
    
    
    
    
override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize Banners
        initAdMobBanner()
}

    
    
    
// MARK: - TIMER TO GENERATE NEW NUMBER TILES
func fireTimerToGenerateNumbers() {
    // Fire a timer to generate random Numbers on the Game Board
    timerToGenerateRandomNumbers = Timer.scheduledTimer(timeInterval: timeInterval!, target: self, selector: #selector(generateRandomNumber), userInfo: nil, repeats: true)
}

    
    
    
// MARK: - TIMER TO INCREASE TIME INTERVAL
func fireTimerToIncreaseTimeInterval() {
    // Every 5 seconds the Time Interval that generates Numbers gets lower (it fires numbers more frequently)
    timerToIncreaseTimeInterval = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(increaseTimeInterval), userInfo: nil, repeats: true)
}
func increaseTimeInterval() {
    increaseCount += 1
    print("INCREASE: \(increaseCount)")
    
    timerToGenerateRandomNumbers?.invalidate()
    fireTimerToGenerateNumbers()
        
    switch increaseCount {
    
    /*** YOU CAN CHANGE THE DIFFERENT TIME INTERVALS TO INCREASE GAME'S DIFFICULTY ***/
    case 1: timeInterval = 0.8; break
    case 2: timeInterval = 0.6; break
    case 3: timeInterval = 0.5; break
    case 4: timeInterval = 0.4; break
            
    default: break }
}

    
    
    
    
// MARK: - 60-SECOND GAME TIMER
func fire60secTimer() {
    timer60sec = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(makeCountdown), userInfo: nil, repeats: true)
}
   
func makeCountdown() {
    // COUNTDOWN...
    if countdown > 0 {
        countdown -= 1
        timerLabel.text = "\(countdown)"
            
    // GAME OVER!!
    } else {
        GameOver()
    }
}
    
    
    
    

// MARK: - GENERATE RANDOM NUMBERS
func generateRandomNumber() {
        let randomTAG = Int(arc4random() % UInt32(numberButtons.count) )
        let randomNumber = Int(arc4random() % 10)
        
        // Check if a button Title = ""  and if less than 25 buttons have a number
        if numberButtons[randomTAG].titleLabel?.text == " "   &&   buttonsCounter < 25 {
            numberButtons[randomTAG].setTitle("\(randomNumber)", for: .normal)
            numberButtons[randomTAG].backgroundColor = UIColor.white
            buttonsCounter += 1
            // println("ButtCounter: \(buttonsCounter)")
            
            
            // Generate a random number again ================
        } else if numberButtons[randomTAG].titleLabel?.text != nil   &&   buttonsCounter < 25 {
            generateRandomNumber()
            
            
            // GAMER OVER! ====================
        } else if buttonsCounter >= 25 {
            GameOver()
        }
        
        // CONSOLE LOGS =========
        // println("INTERVAL: \(timeInterval)")
}
    
    
    
    
    
    
// MARK: - GAME OVER METHOD
func GameOver() {
    // Stop All Timers
    timerToGenerateRandomNumbers?.invalidate()
    timer60sec?.invalidate()
    timerToIncreaseTimeInterval?.invalidate()
        
    pauseIsOn = false
        
    // Submit BestScore to Game Center Leaderboard
    submitBestScore()
        
    // Open Game Over Controller
    let goVC = self.storyboard?.instantiateViewController(withIdentifier: "GameOverVC") as! GameOverVC
    navigationController?.pushViewController(goVC, animated: true)
    print("GAME OVER!")
}
    
    
    
    

// MARK: - BOARD BUTTON TAPPED
func boardButtonTapped(_ sender: UIButton) {
        let boardButt = sender as UIButton
        
        if boardButt.titleLabel?.text != " " {
            
            boardButtTapsCount += 1
            playTap()
            
            switch boardButtTapsCount {
            case 1: // 1st button tapped
                firstTAG = boardButt.tag
                
                // Grab the main View's background color (you can change it with anothe color of your choice)
                boardButt.backgroundColor = self.view.backgroundColor
                break
                
            case 2: // 2nd button tapped: check if there's a match or not
                
                // You tapped the same button
                if boardButt.tag == firstTAG {
                    boardButtTapsCount -= 1
                    
                    
                // Numbers MATCHED!
                } else if boardButt.tag != firstTAG
                    &&  boardButt.titleLabel?.text == numberButtons[firstTAG].titleLabel?.text {
                        
                        numberButtons[boardButt.tag].backgroundColor = grayColor
                        numberButtons[boardButt.tag].setTitle(" ", for: .normal)
                        
                        numberButtons[firstTAG].backgroundColor = grayColor
                        numberButtons[firstTAG].setTitle(" ", for: .normal)
                        
                        buttonsCounter = buttonsCounter-2
                        boardButtTapsCount = 0
                        scorePoints = scorePoints+50
                        scoreLabel.text = "\(scorePoints)"
                        
                        
                        // Update the Best Score
                        if bestScore < scorePoints {
                            bestScore = scorePoints
                            bestScoreLabel.text = "Best Score: \(bestScore)"
                            
                            // Save the BestScore
                            defaults.set(bestScore, forKey: "bestScore")
                        }
                        
                        
                    
                // Numbers NOT MATCHED!
                } else if boardButt.titleLabel?.text  !=  numberButtons[firstTAG].titleLabel?.text {
                    numberButtons[boardButt.tag].backgroundColor = UIColor.white
                    numberButtons[firstTAG].backgroundColor = UIColor.white
                    
                    //println("NO MATCH!")
                    boardButtTapsCount = 0
                    GameOver()
                }
                break
                
            default: break }
        }
        
        
        // CONSOLE LOGS ====================================
        //  println("firstTAG: \(firstTAG)")
        //  println("1st NUM: \(numberButtons[firstTAG].titleLabel!.text!)")
        //  println("2nd NUM: \(numberButtons[boardButt.tag].titleLabel!.text!)")
        //  println("TAPS: \(boardButtTapsCount)")
        
    }
    
    
    
    
// Submit Best Score to Game Center's LEADERBOARD
func submitBestScore() {
    let bestScoreInt = GKScore(leaderboardIdentifier: leaderboardID)
    bestScoreInt.value = Int64(bestScore)
    GKScore.report([bestScoreInt], withCompletionHandler: { (error) in
        if error != nil { print(error!.localizedDescription)
        } else { print("Best Score submitted to your Leaderboard!") }
    })
}
func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
    gameCenterViewController.dismiss(animated: true, completion: nil)
}
    
    
    
    
    
    
// MARK: - BACK BUTTON
@IBAction func backButt(_ sender: AnyObject) {
    // Stop all Timers
    timerToGenerateRandomNumbers?.invalidate()
    timer60sec?.invalidate()
    timerToIncreaseTimeInterval?.invalidate()
        
    let menuVC = self.storyboard?.instantiateViewController(withIdentifier: "Menu")as! Menu
    self.navigationController?.pushViewController(menuVC, animated: true)
}
    

    
// MARK: - PAUSE GAME
@IBAction func pauseButt(_ sender: AnyObject) {
        pauseIsOn = true
        
        // Pause all Timers
        timerToGenerateRandomNumbers?.invalidate()
        timer60sec?.invalidate()
        timerToIncreaseTimeInterval?.invalidate()
        
        // Move the pauseView out of the screen
        pauseView.frame = CGRect(x: 0, y: 0,
            width: self.view.frame.size.width, height: self.view.frame.size.height)
        print("GAME PAUSED!")
}
    
    

// MARK: - RESUME GAME
@IBAction func resumeGameButt(_ sender: AnyObject) {
        pauseIsOn = false
        
        // Restart all Timers
        fireTimerToGenerateNumbers()
        fire60secTimer()
        fireTimerToIncreaseTimeInterval()
        
        // Move the pauseView out of the screen
        pauseView.frame = CGRect(x: 0, y: self.view.frame.size.height,
            width: self.view.frame.size.width, height: self.view.frame.size.height)
        print("GAME RESUMED!")
}
    
    
    
    
    
// MARK: - SOUNDS
func playTap() {
    let alertSound: URL = URL(fileURLWithPath: Bundle.main.path(forResource: "tap", ofType: "mp3")!)
    do { audioPlayer = try AVAudioPlayer(contentsOf: alertSound)
    } catch { audioPlayer = AVAudioPlayer() }
        
    audioPlayer.prepareToPlay()
    audioPlayer.play()
}
    
    
    
    
    
    
    
    
// MARK: -  AdMob BANNER METHODS
func initAdMobBanner() {
        adMobBannerView.adSize =  GADAdSizeFromCGSize(CGSize(width: 320, height: 50))
        adMobBannerView.frame = CGRect(x: 0, y: self.view.frame.size.height, width: 320, height: 50)
        adMobBannerView.adUnitID = ADMOB_UNIT_ID
        adMobBannerView.rootViewController = self
        adMobBannerView.delegate = self
        view.addSubview(adMobBannerView)
        
        let request = GADRequest()
        adMobBannerView.load(request)
    }
    
    
    // Hide the banner
    func hideBanner(_ banner: UIView) {
            UIView.beginAnimations("hideBanner", context: nil)
            banner.frame = CGRect(x: 0, y: view.frame.size.height, width: banner.frame.size.width, height: banner.frame.size.height)
            UIView.commitAnimations()
            banner.isHidden = true
    }
    
    // Show the banner
    func showBanner(_ banner: UIView) {
            UIView.beginAnimations("showBanner", context: nil)
            banner.frame = CGRect(x: view.frame.size.width/2 - banner.frame.size.width/2,
                                      y: view.frame.size.height - banner.frame.size.height,
                                      width: banner.frame.size.width, height: banner.frame.size.height);
            UIView.commitAnimations()
            banner.isHidden = false
    }

    // AdMob banner available
    func adViewDidReceiveAd(_ view: GADBannerView!) {
        print("AdMob loaded!")
        showBanner(adMobBannerView)
    }
    // NO AdMob banner available
    func adView(_ view: GADBannerView!, didFailToReceiveAdWithError error: GADRequestError!) {
        print("AdMob Can't load ads right now, they'll be available later \n\(error)")
        hideBanner(adMobBannerView)
    }
    
    // Pause the game when user taps on an ad banner
    func adViewWillLeaveApplication(_ adView: GADBannerView!) {
        pauseButt(self)
        print("leave application - AdMob")
    }
    func adViewWillPresentScreen(_ adView: GADBannerView!) {
        pauseButt(self)
        print("will present full screen - AdMob")
    }
    
    
   
    
    
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


