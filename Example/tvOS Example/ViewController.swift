//
// Copyright (c) 2016 deltaDNA Ltd. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import UIKit
import DeltaDNA

class ViewController: UIViewController, DDNAImageMessageDelegate {
    
    @IBOutlet weak var sdkVersion: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sdkVersion.text = DDNA_SDK_VERSION;
        
        DDNASDK.setLogLevel(.debug)
        DDNASDK.sharedInstance().clientVersion = "tvOS Example v1.0"
        DDNASDK.sharedInstance().hashSecret = "KmMBBcNwStLJaq6KsEBxXc6HY3A4bhGw"
        DDNASDK.sharedInstance().start(
            withEnvironmentKey: "55822530117170763508653519413932",
            collectURL: "http://collect2010stst.deltadna.net/collect/api",
            engageURL: "http://engage2010stst.deltadna.net"
        )
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onSimpleEvent(_ sender: AnyObject) {
        DDNASDK.sharedInstance().recordEvent(withName: "achievement", eventParams: [
            "achievementName" : "Sunday Showdown Tournament Win",
            "achievementID" : "SS-2014-03-02-01",
            "reward" : [
                "rewardName" : "Medal",
                "rewardProducts" : [
                    "items" : [
                        [
                            "item" : [
                                "itemAmount" : 1,
                                "itemName" : "Sunday Showdown Medal",
                                "itemType" : "Victory Badge"
                            ]
                        ]
                    ],
                    "virtualCurrencies" : [
                        [
                            "virtualCurrency" : [
                                "virtualCurrencyAmount" : 20,
                                "virtualCurrencyName" : "VIP Points",
                                "virtualCurrencyType" : "GRIND"
                            ]
                        ]
                    ],
                    "realCurrency" : [
                        "realCurrencyAmount" : 5000,
                        "realCurrencyType" : "USD"
                    ]
                ]
            ]
        ])
    }

    @IBAction func onEngage(_ sender: AnyObject) {
        let engagement = DDNAEngagement(decisionPoint: "gameLoaded")!
        engagement.setParam(4 as NSNumber, forKey: "userLevel")
        engagement.setParam(1000 as NSNumber, forKey: "experience")
        engagement.setParam("Disco Volante" as NSString, forKey: "missionName")
        
        DDNASDK.sharedInstance().request(engagement, engagementHandler:{ (response)->() in
            if response?.json != nil {
                print("Engagement returned: \(String(describing: response?.json["parameters"]))")
            } else {
                print("Engagement failed: \(String(describing: response?.error))")
            }
        })
    }
    
    @IBAction func onImageMessage(_ sender: AnyObject) {
        let engagement = DDNAEngagement(decisionPoint: "imageMessage");
        
        DDNASDK.sharedInstance().request(engagement, engagementHandler:{ (response)->() in
            if let imageMessage = DDNAImageMessage(engagement: response, delegate: self) {
                imageMessage.fetchResources()
            }
        })
    }
    
    @IBAction func onUploadEvents(_ sender: AnyObject) {
        DDNASDK.sharedInstance().upload();
    }
    
    func onDismiss(_ imageMessage: DDNAImageMessage!, name: String!) {
        print("Image message dismissed by \(name)")
    }
    
    func onActionImageMessage(_ imageMessage: DDNAImageMessage!, name: String!, type: String!, value: String!) {
        print("Image message actioned by \(name) with \(type) and \(value)")
    }
    
    func didReceiveResources(for imageMessage: DDNAImageMessage!) {
        print("Image message received resources")
        imageMessage.show(fromRootViewController: self)
    }
    
    func didFailToReceiveResources(for imageMessage: DDNAImageMessage!, withReason reason: String!) {
        print("Image message failed to receive resources: \(reason)")
    }
}

