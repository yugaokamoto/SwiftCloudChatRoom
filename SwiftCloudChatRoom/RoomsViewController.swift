//
//  RoomsViewController.swift
//  SwiftCloudChatRoom
//
//  Created by 岡本優河 on 2018/05/23.
//  Copyright © 2018年 岡本優河. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage



class RoomsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    var uid = Auth.auth().currentUser?.uid
    
    var profileImage:NSURL!
    
    var address:String = String()
    
    var posts = [Post]()
    
    @IBOutlet var tableView: UITableView!
    
    var country_Array = [String]()
    var administrativeArea_Array = [String]()
    var subAdministrativeArea_Array = [String]()
    var locality_Array = [String]()
    var subLocality_Array = [String]()
    var thoroughfare_Array = [String]()
    var subThoroughfare_Array = [String]()
    var pathToImage_Array = [String]()
    var roomName_Array = [String]()
    var roomRule_Array = [String]()
    var userID_Array = [String]()
    
    
    var posst = Post()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 160 //セルの高さ
        tableView.rowHeight = UITableViewAutomaticDimension
    }

   
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        fetchPosts()
        
        print("post \(posts)")
    }

    //Postsの取得
    func fetchPosts(){
        
        let ref = Database.database().reference()
        ref.child("Rooms").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snap) in
            let postsSnap = snap.value as! [String : AnyObject]
            
            for (_,post) in postsSnap{
                if let userID = post["userID"] as? String{
                    
                    self.posst = Post()
                    if let pathToImage = post["pathToImage"] as? String,
                        let postID = post["postID"] as? String,
                        let roomName = post["roomName"] as? String,
                        let country = post["country"] as? String,
                        let administrativeArea = post["administrativeArea"] as? String,
                        let subAdministrativeArea = post["subAdministrativeArea"] as? String,
                        let locality = post["locality"] as? String, let subLocality = post["subLocality"] as? String,
                        let thoroughfare = post["thoroughfare"] as? String {
                        
                        self.posst.pathToImage = pathToImage
                        self.posst.postID = postID
                        self.posst.userID = userID
                        self.posst.roomName = roomName
                        self.posst.country = country
                        self.posst.administrativeArea = administrativeArea
                        self.posst.subAdministrativeArea = subAdministrativeArea
                        self.posst.locality = locality
                        self.posst.subLocality = subLocality
                        self.posst.thoroughfare = thoroughfare
                        self.roomName_Array.append(self.posst.roomName)
                        //比較して入れるものを限る
//                        if ((self.posst.country + self.posst.administrativeArea + self.posst.subAdministrativeArea
//                            + self.posst.locality + self.posst.subLocality + self.posst.thoroughfare ) == self.address)
//                        {
                            self.posts.append(self.posst)
                            self.tableView.reloadData()
//                        }
                    }
                    
                }
            }
            
            
        })
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //画面遷移
        performSegue(withIdentifier: "privateChat", sender: indexPath)
        
    }
    
    
    override func prepare(for segue:UIStoryboardSegue,sender:Any?){
        
        if(segue.identifier == "privateChat"){
            
            let privateChatVC = segue.destination as! PrivateChatViewController
            
            //Roomsの中の全てのAddressを足したもの→これとaddressを比べる
            let fromDBAddress = self.posst.country + self.posst.administrativeArea + self.posst.subAdministrativeArea
                + self.posst.locality + self.posst.subLocality
            
            print(address)
            
            //RoomNameを渡したい
            privateChatVC.roomName = self.posst.roomName
            
            //住所を渡したい
            privateChatVC.fromDBAddress = fromDBAddress
            
            //PathToImageを渡したい profile画像用URL
            privateChatVC.pathToImage = profileImage.absoluteString!
            
        }
        
        
        
        
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        //オーナーの名前(現在はUserIDでとっている)
        let ownerNameLabel = cell.viewWithTag(1) as! UILabel
        ownerNameLabel.text = self.posts[indexPath.row].userID
        
        print(self.posts[indexPath.row].userID)
        
        //プロフィール
        let profileImageView = cell.viewWithTag(2) as! UIImageView
        let profileImageUrl = URL(string:self.posts[indexPath.row].pathToImage as String)!
        profileImageView.sd_setImage(with: profileImageUrl, completed: nil)
        
        //部屋の名前
        let roomNameLabel = cell.viewWithTag(3) as! UILabel
        roomNameLabel.text = self.posts[indexPath.row].roomName
        
        
        
        return cell
    }
    
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    @available(iOS 2.0, *)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.posts.count
        
    }

                        
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
