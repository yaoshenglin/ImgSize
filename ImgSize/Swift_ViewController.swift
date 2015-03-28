//
//  Swift_ViewController.swift
//  ImgSize
//
//  Created by Yin on 14-11-4.
//  Copyright (c) 2014年 caidan. All rights reserved.
//

import UIKit

class Swift_ViewController: UIViewController,UITableViewDelegate,UIAlertViewDelegate
{
    var btnBack:UIButton?;
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 0.89, green: 0.89, blue: 0.89, alpha: 1.0);
        
        var btn:UIButton = UIButton.buttonWithType(UIButtonType.Custom) as UIButton;
        btn.frame = CGRectMake(110.0, 120.0, 100.0, 50.0)
        btn.clipsToBounds = true;
        btn.layer.cornerRadius = 5;
        btn.setTitle("返回按钮", forState: UIControlState.Normal)
        btn.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        btn.backgroundColor = UIColor.whiteColor();
        //btn.setBackgroundImage(UIImage(named: ""), forState: UIControlState.Normal);
        btn.setBackgroundImage(UIImage(named: "选中背景图"), forState: UIControlState.Highlighted);
        btn.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view .addSubview(btn);
        
        var str:String = "Hello, playground"
        str = str.stringByAppendingString("woeifowefa");
        
        NSLog(str);

        // Do any additional setup after loading the view.
    }
    
    func buttonAction(sender: UIButton)
    {
        // Swfit -> ObjC
        btnBack = sender;
        //btnBack.setTitle("返回按钮", forState: UIControlState.Normal);
        //self.navigationController?.popViewControllerAnimated(true)
        
        var alert:UIAlertView = UIAlertView(title: "你确定要退出吗", message: nil, delegate: self, cancelButtonTitle: "取消");
        //var alert:UIAlertView = UIAlertView(title: "你确定要退出吗", message: nil, delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "确定", nil)
        alert.addButtonWithTitle("确定")
        alert.tag = 1;
        alert.show();
        
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        var btnTitle:NSString = alertView.buttonTitleAtIndex(buttonIndex);
        if btnTitle.isEqualToString("确定") {
            exit(0);
        }
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int
    {
        return 3
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell!
    {
        var identifier = NSString.stringByAppendingFormat("abc");
        identifier = String.stringByAppendingFormat("")
        let cell:UITableViewCell = UITableViewCell.alloc();
        return nil
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
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
