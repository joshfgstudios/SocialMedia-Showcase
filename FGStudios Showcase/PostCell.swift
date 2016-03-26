//
//  PostCell.swift
//  FGStudios Showcase
//
//  Created by Joshua Ide on 24/03/2016.
//  Copyright © 2016 Fox Gallery Studios. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class PostCell: UITableViewCell {
    
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var imgShowcase: UIImageView!
    @IBOutlet weak var txtViewDescription: UITextView!
    @IBOutlet weak var lblLikes: UILabel!
    @IBOutlet weak var imgLike: UIImageView!

    var post: Post!
    var request: Request?
    var likeRef: Firebase!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        tapGesture.numberOfTapsRequired = 1
        imgLike.addGestureRecognizer(tapGesture)
        imgLike.userInteractionEnabled = true
    }
    
    override func drawRect(rect: CGRect) {
        imgProfile.layer.cornerRadius = imgProfile.frame.size.width / 16
        imgProfile.clipsToBounds = true
        imgShowcase.clipsToBounds = true
    }

    func configureCell(post: Post, image: UIImage?, completed: DownloadComplete) {
        self.post = post
        
        likeRef = DataService.ds.REF_USER_CURRENT.childByAppendingPath("likes").childByAppendingPath(post.postKey)
        
        self.txtViewDescription.text = post.postDescription
        self.lblLikes.text = "\(post.likes)"
        
        if post.imageURL != nil {
            //Check for cached image
            if image != nil {
                self.imgShowcase.image = image
                self.imgShowcase.hidden = false
            } else {  //no cached image, download one
                self.imgShowcase.hidden = true
                request = Alamofire.request(.GET, post.imageURL!).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
                    if err == nil {
                        let image = UIImage(data: data!)!
                        self.imgShowcase.image = image
                        FeedVC.imageCache.setObject(image, forKey: self.post.imageURL!) //store it in the cache once downloaded
                    }
                })
                completed()
            }
        } else {
            self.imgShowcase.hidden = true
        }

        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if (snapshot.value as? NSNull) != nil {
                //We haven't liked this specific post
                self.imgLike.image = UIImage(named: "heart-empty")
            } else {
                self.imgLike.image =  UIImage(named: "heart-full")
            }
        })
    }
    
    func allowLikes() {
        imgLike.userInteractionEnabled = true
    }
    
    func likeTapped(sender: UITapGestureRecognizer) {
        imgLike.userInteractionEnabled = false
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if (snapshot.value as? NSNull) != nil {
                self.imgLike.image =  UIImage(named: "heart-full")
                self.post.adjustLikes(true)
                self.likeRef.setValue(true)
            } else {
                self.imgLike.image = UIImage(named: "heart-empty")
                self.post.adjustLikes(false)
                self.likeRef.removeValue()
            }
        })
        NSTimer.scheduledTimerWithTimeInterval(0.6, target: self, selector: #selector(allowLikes), userInfo: nil, repeats: false)
    }

}
