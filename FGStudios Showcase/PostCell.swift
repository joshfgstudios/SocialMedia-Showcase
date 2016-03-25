//
//  PostCell.swift
//  FGStudios Showcase
//
//  Created by Joshua Ide on 24/03/2016.
//  Copyright © 2016 Fox Gallery Studios. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell {
    
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var imgShowcase: UIImageView!
    @IBOutlet weak var txtViewDescription: UITextView!
    @IBOutlet weak var lblLikes: UILabel!

    var post: Post!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func drawRect(rect: CGRect) {
        imgProfile.layer.cornerRadius = imgProfile.frame.size.width / 16
        imgProfile.clipsToBounds = true
        imgShowcase.clipsToBounds = true
    }

    func configureCell(post: Post) {
        self.post = post
        
        self.txtViewDescription.text = post.postDescription
        self.lblLikes.text = "\(post.likes)"
    }

}
