//
//  LoginViewController.swift
//  VASILY-Intern2016
//
//  Created by 下村一将 on 2016/06/15.
//  Copyright © 2016年 kazu. All rights reserved.
//

import UIKit
import TwitterKit

class LoginViewController: UIViewController {
    
    var tweets: [TWTRTweet] = []
    var userID:String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let loginButton = TWTRLogInButton(logInCompletion: {
            session, error in
            if session != nil {
                print(session!.userName)
                self.userID = (session?.userID)!
                // ログイン成功したらクソ遷移する
                let timelineVC = LoginViewController()
                UIApplication.sharedApplication().keyWindow?.rootViewController = timelineVC
                
                self.loadTweets()
                
//                print(self.tweets)
                
//                let classA = TWTRTimelineViewController()
//                
//                let client = TWTRAPIClient()
//                classA.dataSource = TWTRUserTimelineDataSource(screenName: "puaru_tea", APIClient: client)
//            
                
            } else {
                print(error!.localizedDescription)
            }
        })
        loginButton.center = self.view.center
        self.view.addSubview(loginButton)
        

    }

        // Do any additional setup after loading the view

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func loadTweets() {
        TwitterAPI.getHomeTimeline(userID, tweets: {
            twttrs in
            for tweet in twttrs {
                self.tweets.append(tweet)
            }
            }, error: {
                error in
                print(error.localizedDescription)
        })
        
        print("表示開始")
        print(tweets.count)
        print("表示完了")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
