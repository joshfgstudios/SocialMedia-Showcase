//
//  PostCell.swift
//  FGStudios Showcase
//
//  Created by Joshua Ide on 24/03/2016.
//  Copyright © 2016 Fox Gallery Studios. All rights reserved.
//

import UIKit
import Alamofire

class PostCell: UITableViewCell {
    
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var imgShowcase: UIImageView!
    @IBOutlet weak var txtViewDescription: UITextView!
    @IBOutlet weak var lblLikes: UILabel!

    var post: Post!
    var request: Request?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func drawRect(rect: CGRect) {
        imgProfile.layer.cornerRadius = imgProfile.frame.size.width / 16
        imgProfile.clipsToBounds = true
        imgShowcase.clipsToBounds = true
    }

    func configureCell(post: Post, image: UIImage?) {
        self.post = post
        
        self.txtViewDescription.text = post.postDescription
        self.lblLikes.text = "\(post.likes)"
        
        if post.imageURL != nil {
            //Check for cached image
            if image != nil {
                self.imgShowcase.image = image
            } else {  //no cached image, download one
                request = Alamofire.request(.GET, post.imageURL!).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
                    if err == nil {
                        let image = UIImage(data: data!)!
                        self.imgShowcase.image = image
                        FeedVC.imageCache.setObject(image, forKey: self.post.imageURL!) //store it in the cache once downloaded
                    }
                })
            }
            self.imgShowcase.hidden = false
        } else {
            self.imgShowcase.hidden = true
        }
    }

}
