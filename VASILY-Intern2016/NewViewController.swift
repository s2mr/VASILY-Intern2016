//
//  NewViewController.swift
//  VASILY-Intern2016
//
//  Created by 下村一将 on 2016/06/15.
//  Copyright © 2016年 kazu. All rights reserved.
//

import UIKit
import TwitterKit

class NewViewController: TWTRTimelineViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Swift
        let client = TWTRAPIClient()
        let dataSource = TWTRSearchTimelineDataSource(searchQuery: "#iQON", APIClient: client)
        
        self.dataSource = dataSource
        self.showTweetActions = true

//
//        let client = TWTRAPIClient(userID: "puaru_tea")
//        self.dataSource = TWTRUserTimelineDataSource(screenName: "fabric", APIClient: client)
//
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
