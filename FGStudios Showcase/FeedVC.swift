//
//  FeedVC.swift
//  FGStudios Showcase
//
//  Created by Joshua Ide on 24/03/2016.
//  Copyright © 2016 Fox Gallery Studios. All rights reserved.
//

import UIKit
import Firebase

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //Outlets
    @IBOutlet weak var tableView: UITableView!
    
    //Properties
    var posts = [Post]()
    static var imageCache = NSCache()

    //Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 350
        
        DataService.ds.REF_POSTS.observeEventType(.Value, withBlock: { snapshot in
                        
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                //Empty out the array as we're going to replace with current data
                self.posts = []
                //Iterate through each post
                for snap in snapshots {
                    //Append the current post in the loop to the posts array
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = Post(postKey: key, dictionary: postDict)
                        self.posts.append(post)
                    }
                }
            }
            
            self.tableView.reloadData()
        })
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //For each post, create a cell
        let post = posts[indexPath.row]
        
        //If there's a reusable cell, give it to us, otherwise create one
        if let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as? PostCell {
            //if the new cell being reused has an existing request, cancel it
            cell.request?.cancel()
            
            var img: UIImage?
            
            if let url = post.imageURL {
                img = FeedVC.imageCache.objectForKey(url) as? UIImage
            }
            
            cell.configureCell(post, image: img)
            
            return cell
        } else {
            return PostCell()
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let post = posts[indexPath.row]
        
        if post.imageURL == nil {
            return tableView.estimatedRowHeight / 2
        } else {
            return tableView.estimatedRowHeight
        }
    }


}
