//
//  TwitterAPI.swift
//  VASILY-Intern2016
//
//  Created by 下村一将 on 2016/06/15.
//  Copyright © 2016年 kazu. All rights reserved.
//

import Foundation
import TwitterKit
import Twitter

class TwitterAPI {
    let baseURL = "https://api.twitter.com"
    let version = "/1.1"

    
    init() {
        
    }
    
    class func getHomeTimeline(user: String?, tweets: [TWTRTweet]->(), error: (NSError) -> ()) {
        let api = TwitterAPI()
//        let user = "puaru_tea"
        let client = TWTRAPIClient(userID: user)
        var clientError: NSError?
        let path = "/statuses/home_timeline.json"
        let endPoint = api.baseURL + api.version + path
//        let endPoint = "https://api.twitter.com/1.1/statuses/user_timeline.json"
        let request = client.URLRequestWithMethod("GET", URL: endPoint, parameters: nil, error: &clientError)
        
        //インスタンスを生成しているわけではない。中はnilの恐れあり
//        let vca: ViewController!
        
        let vcb = ViewController()
        
        client.sendTwitterRequest(request, completion: {
            response, data, err in
            if err == nil {
                do {
                    // var jsonError: NSError?
                    let json: AnyObject? =  try! NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers)
                    if let jsonArray = json as? NSArray {
                        
                        tweets(TWTRTweet.tweetsWithJSONArray(jsonArray as [AnyObject]) as! [TWTRTweet])
                        print("正常")
                        print(jsonArray)
                        
                        print(vcb.tweets)
                        print(TWTRTweet.tweetsWithJSONArray(jsonArray as [AnyObject]))
                    }
                }
            } else {
                error(err!)
                print("エラーです")
            }
        })
    }
    
}