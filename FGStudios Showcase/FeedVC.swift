//
//  FeedVC.swift
//  FGStudios Showcase
//
//  Created by Joshua Ide on 24/03/2016.
//  Copyright © 2016 Fox Gallery Studios. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    
    //Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var txtPost: UITextView!
    @IBOutlet weak var imgCamera: UIImageView!
    
    
    //Properties
    var posts = [Post]()
    var imagePicker: UIImagePickerController!
    
    static var imageCache = NSCache()

    //Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtPost.delegate = self
        addDoneButtonToKeyboard()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 350
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
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
            return tableView.estimatedRowHeight / 1.8
        } else {
            return tableView.estimatedRowHeight
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        imgCamera.image = image
    }
    
    func postToFirebase(imgURL: String?) {
        var post: Dictionary<String, AnyObject> = [
            "description": txtPost.text!,
            "likes": 0
        ]
        
        if imgURL != nil {
            post["imageURL"] = imgURL!
        }
        
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        
        txtPost.text = ""
        imgCamera.image = UIImage(named: "camera")
        tableView.reloadData()
    }
    
    func addDoneButtonToKeyboard() {
        let doneToolbar = UIToolbar(frame: CGRectMake(0, 0, 400, 35))
        doneToolbar.barStyle = UIBarStyle.Default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: #selector(dismissKeyboard))
        
        var items = [AnyObject]()
        items.append(flexSpace)
        items.append(done)
        doneToolbar.items = items as? [UIBarButtonItem]
        
        self.txtPost.inputAccessoryView = doneToolbar
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }

    //Actions
    @IBAction func selectImage(sender: UITapGestureRecognizer) {
        presentViewController(imagePicker, animated: true, completion: nil)
    }

    @IBAction func makePost(sender: AnyObject) {
        if let txt = txtPost.text where txt != "" {
            if let img = imgCamera.image where img != UIImage(named: "camera") {
                let urlStr = "https://post.imageshack.us/upload_api.php"
                let url = NSURL(string: urlStr)!
                let imgData = UIImageJPEGRepresentation(img, 0.2)!
                let keyData = "12DJKPSU5fc3afbd01b1630cc718cae3043220f3".dataUsingEncoding(NSUTF8StringEncoding)!
                let keyJSON = "json".dataUsingEncoding(NSUTF8StringEncoding)!
                
                Alamofire.upload(.POST, url, multipartFormData: { multipartFormData in
                    multipartFormData.appendBodyPart(data: imgData, name: "fileupload", fileName: "image", mimeType: "image/jpg")
                    multipartFormData.appendBodyPart(data: keyData, name: "key")
                    multipartFormData.appendBodyPart(data: keyJSON, name: "format")
                }) { encodingResult in
                    switch encodingResult {
                    case .Success(let upload, _, _):
                        upload.responseJSON(completionHandler: { response in
                            if let info = response.result.value as? Dictionary<String, AnyObject> {
                                if let links = info["links"] as? Dictionary<String, AnyObject> {
                                    if let imgLink = links["image_link"] as? String {
                                        self.postToFirebase(imgLink)
                                        self.dismissKeyboard()
                                    }
                                }
                            }
                        })
                    case .Failure(let error): print(error)
                    }
                }
            } else {
                self.postToFirebase(nil)
                dismissKeyboard()
            }
        }
    }
}
