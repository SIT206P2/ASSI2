//
//  GameOverVC.Swift
//  Numberz
//
//
//  Created by Jiang Wenhao on 01/5/17.
//  Copyright © 2017 Jiang Wenhao. All rights reserved.
//
import UIKit
import Social


class GameOverVC: UIViewController {
    
    /* Views */
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var bestScoreLabel: UILabel!
    // App icon that will be shared on FB & TW together with the message
    @IBOutlet weak var shareImg: UIImageView!
    
    
    
   
override var prefersStatusBarHidden : Bool {
    return true
}
override func viewDidLoad() {
    super.viewDidLoad()
        
    // Show your last Score and saved Best Score
    bestScoreLabel.text = "Best Score: \(bestScore)"
    scoreLabel.text = "Score: \(scorePoints)"
}
    
    
    
// MARK: - EXIT BUTTON
@IBAction func exitButt(_ sender: AnyObject) {
    let menuVC = self.storyboard?.instantiateViewController(withIdentifier: "Menu") as! Menu
    navigationController?.pushViewController(menuVC, animated: true)
}
    
    
    
    
// MARK: - FACEBOOK BUTTON
@IBAction func facebookButt(_ sender: AnyObject) {
    if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook) {
        let fbSheet = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
        fbSheet?.setInitialText("My Best Score on Numberz is \(bestScore)!")
        fbSheet?.add(shareImg.image)
        present(fbSheet!, animated: true, completion: nil)
    } else {
        let alert: UIAlertView = UIAlertView(title: "Facebook",
            message: "Please login to your Facebook account in Settings", delegate: self, cancelButtonTitle: "OK")
        alert.show()
    }
}
    
// MARK: -  TWITTER BUTTON
@IBAction func twitterButt(_ sender: AnyObject) {
    if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
        let twSheet = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        twSheet?.setInitialText("My Best Score on Numberz is \(bestScore)!")
        twSheet?.add(shareImg.image)
        present(twSheet!, animated: true, completion: nil)
    } else {
        let alert: UIAlertView = UIAlertView(title: "Twitter",
            message: "Please login to your Twitter account in Settings", delegate: self, cancelButtonTitle: "OK")
        alert.show()
    }
}
    

// MARK: - PLAY AGAIN BUTTON
@IBAction func playAgainButt(_ sender: AnyObject) {
    let gbVC = self.storyboard?.instantiateViewController(withIdentifier: "GameBoard") as! GameBoard
    navigationController?.pushViewController(gbVC, animated: true)
}
    
    
    
    
    
    
    
    
override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    }
}
