//
//  ViewController.swift
//  VASILY-Intern2016
//
//  Created by 下村一将 on 2016/06/14.
//  Copyright © 2016年 kazu. All rights reserved.
//

import UIKit
import SwiftyJSON
import Accounts
import Social
import Foundation


class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    var accountStore = ACAccountStore()
    var twAccount: ACAccount?
    let queue:dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)


    //データ格納用配列
    var tweets_text:[String] = []
    var tweets_UserName:[String] = []
    var tweets_UserID:[String] = []
    var tweets_IconUrl:[String] = []
    var tweets_Date:[String] = []
    var lastTweets_ID = ""
    var frag = true
    

    
    let vc = UIApplication.sharedApplication().delegate as! AppDelegate

    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()
        
        self.selectTwitterAccount()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    

    
    // MARK: - UICollectionViewDelegate Protocol
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:CustomCell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! CustomCell
        //セルに取得したデータを格納
        cell.user_Id.text = tweets_UserID[indexPath.row]
        cell.userName.text = tweets_UserName[indexPath.row]
        cell.textView.text = tweets_text[indexPath.row]
        cell.date.text = tweets_Date[indexPath.row]
        
        //UIの設定
        cell.backgroundColor = UIColor.whiteColor()
        cell.layer.borderWidth = 0.3
        cell.layer.borderColor = UIColor.lightGrayColor().CGColor

        let url = NSURL(string:tweets_IconUrl[indexPath.row])
        let req = NSURLRequest(URL:url!)
        //非同期で変換
        NSURLConnection.sendAsynchronousRequest(req, queue:NSOperationQueue.currentQueue()!){(res, data, err) in
            if err == nil {
                let image = UIImage(data:data!)
                cell.icon.image = self.cropThumbnailImage(image!, w: 70, h: 70)
            }else {
                cell.icon.image = nil
            }
        }
        return cell
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.tweets_text.count
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        //一番下までスクロールしたかどうか
        if(self.collectionView.contentOffset.y >= (self.collectionView.contentSize.height - self.collectionView.bounds.size.height))
        {
            
            if frag {
            getTimeline()
            print("更新")
                frag = false
            }
            
        }
    }
    
    func cropThumbnailImage(image :UIImage, w:Int, h:Int) ->UIImage
    {
        // リサイズ処理
        
        let origRef    = image.CGImage;
        let origWidth  = Int(CGImageGetWidth(origRef))
        let origHeight = Int(CGImageGetHeight(origRef))
        var resizeWidth:Int = 0, resizeHeight:Int = 0
        
        if (origWidth < origHeight) {
            resizeWidth = w
            resizeHeight = origHeight * resizeWidth / origWidth
        } else {
            resizeHeight = h
            resizeWidth = origWidth * resizeHeight / origHeight
        }
        
        let resizeSize = CGSizeMake(CGFloat(resizeWidth), CGFloat(resizeHeight))
        UIGraphicsBeginImageContext(resizeSize)
        
        image.drawInRect(CGRectMake(0, 0, CGFloat(resizeWidth), CGFloat(resizeHeight)))
        
        let resizeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // 切り抜き処理
        
        let cropRect  = CGRectMake(
            CGFloat((resizeWidth - w) / 2),
            CGFloat((resizeHeight - h) / 2),
            CGFloat(w), CGFloat(h))
        let cropRef   = CGImageCreateWithImageInRect(resizeImage.CGImage, cropRect)
        let cropImage = UIImage(CGImage: cropRef!)
        
        return cropImage
    }
    
    private func selectTwitterAccount() {
        
        // 認証するアカウントのタイプを選択
        let accountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        accountStore.requestAccessToAccountsWithType(accountType, options: nil) { (granted:Bool, error:NSError?) -> Void in
            if error != nil {
                // エラー処理
                print("error! \(error)")
                return
            }
            
            if !granted {
                print("error! Twitterアカウントの利用が許可されていません")
                return
            }
            
            let accounts = self.accountStore.accountsWithAccountType(accountType) as! [ACAccount]
            if accounts.count == 0 {
                print("error! 設定画面からアカウントを設定してください")
                return
            }
            
            // 取得したアカウントで処理を行う...
            self.showAccountSelectSheet(accounts)
            
        }
    }
    
    // アカウント選択のActionSheetを表示する
    private func showAccountSelectSheet(accounts: [ACAccount]) {
        
        let alert = UIAlertController(title: "Twitter",
                                      message: "アカウントを選択してください",
                                      preferredStyle: .ActionSheet)
        
        // アカウント選択のActionSheetを表示するボタン
        for account in accounts {
            alert.addAction(UIAlertAction(title: account.username,
                style: .Default,
                handler: { (action) -> Void in
                    //
                    print("your select account is \(account)")
                    self.twAccount = account
                    
                    self.getTimeline()
            }))
        }
        
        // キャンセルボタン
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        // 表示する
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // タイムラインを取得する
    private func getTimeline() {
        let URL = NSURL(string: "https://api.twitter.com/1.1/search/tweets.json")
        
        // リクエスト情報を生成
        var request = SLRequest(forServiceType: SLServiceTypeTwitter,
                                requestMethod: .GET,
                                URL: URL,
                                parameters: ["q":"iQON", "count":"100", "lang":"ja"])
        
        if lastTweets_ID != "" {
            request = SLRequest(forServiceType: SLServiceTypeTwitter,
                                requestMethod: .GET,
                                URL: URL,
                                parameters: ["q":"iQON", "count":"100", "lang":"ja", "max_id":self.lastTweets_ID])
        }
        
        // 認証したアカウントをセット
        request.account = twAccount
        
        // APIコールを実行
        request.performRequestWithHandler { (responseData, urlResponse, error) -> Void in
            
            if error != nil {
                //                print("error is \(error)")
            }
            else {
                // 結果の表示
                do {
                    let _ = try NSJSONSerialization.JSONObjectWithData(responseData, options: .MutableContainers)
//                    print(a)
                } catch  {
                }

                let json = JSON(data: responseData)
                for tweet in json["statuses"].array! {
                    if let text = tweet["text"].string {
                        self.tweets_text.append(text)
                    }
                    if let id = tweet["user"]["screen_name"].string {
                        self.tweets_UserID.append("@" + id)
                    }
                    
                    if let name = tweet["user"]["name"].string {
                        self.tweets_UserName.append(name)
                    }
                    
                    if let iconUrl = tweet["user"]["profile_image_url_https"].string {
                        self.tweets_IconUrl.append(iconUrl)
                        
                    }
                    
                    if let lastTweets_ID = tweet["id"].string {
                        self.lastTweets_ID = lastTweets_ID
                    }
                    
                    if let date = tweet["created_at"].string {
                        self.tweets_Date.append(date.componentsSeparatedByString(" +")[0])
                    }
                    
                }
                self.frag = true
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.collectionView.reloadData()
                })

            }
        }
    }
    
   

    
}



class CustomCell: UICollectionViewCell {
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet var userName:UILabel!
    @IBOutlet weak var user_Id: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var date: UILabel!
    
    
    
    override init(frame: CGRect){
        super.init(frame: frame)
        textView.frame.size.height = textView.contentSize.height
    }
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
    
}


