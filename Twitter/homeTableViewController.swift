//
//  homeTableViewController.swift
//  Twitter
//
//  Created by John Smith V on 3/1/21.
//  Copyright © 2021 Dan. All rights reserved.
//

import UIKit

class homeTableViewController: UITableViewController {
    
    // If you do "let varName", let means the variable is never going to change
    // if you do "var" the variable can change
    // Create a dictionary
    var tweetArray = [NSDictionary]()
    var numberOfTweets: Int! = nil
    
    // When the user pulls down on the top, the UITable will refresh
    let myRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Calling the function so the tweets load
        loadTweets()
        
        myRefreshControl.addTarget(self, action: #selector(loadTweets), for: .valueChanged)
        tableView.refreshControl = myRefreshControl
        // Allow the rows to grow dynamically
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150
    }
    
    // Every time the view did appear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadTweets()
    }
    
    // We are calling the API to access a certain number of tweets
    @objc func loadTweets(){
        numberOfTweets = 20
        let tweetApiUrl = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        let myParams = ["count": numberOfTweets]
        TwitterAPICaller.client?.getDictionariesRequest(url: tweetApiUrl, parameters: myParams, success: { (tweets: [NSDictionary]) in
            // At the success, the information will be stored in the dictionary called tweets
            // We need to then fill this array with the tweets
            // Need self. due to the fact that we're in a closure
            print("Tweets are being refreshed")
            self.tweetArray.removeAll()
            for tweet in tweets {
                self.tweetArray.append(tweet)
            }
            // Make sure when we are calling the api, the rows are going to be updated
            self.tableView.reloadData()
            
            // We need to now stop the refresh animation from refreshing
            self.refreshControl?.endRefreshing()
            
        }, failure: { (Error) in
            print("Error: Could not retrieve Tweets :(")
        })
    }
    
    func refreshTweetRetweetCount(){
        self.tableView.reloadData()
    }
    
    // For infinite scolling!!
    func loadMoreTweets(){
        let tweetApiUrl = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        numberOfTweets += 20
        let myParams = ["count": numberOfTweets]
        TwitterAPICaller.client?.getDictionariesRequest(url: tweetApiUrl, parameters: myParams, success: { (tweets: [NSDictionary]) in
            // At the success, the information will be stored in the dictionary called tweets
            // We need to then fill this array with the tweets
            // Need self. due to the fact that we're in a closure
            print("Adding more Tweets!")
            self.tweetArray.removeAll()
            for tweet in tweets {
                self.tweetArray.append(tweet)
            }
            // Make sure when we are calling the api, the rows are going to be updated
            self.tableView.reloadData()
            
        }, failure: { (Error) in
            print("Error: Could not retrieve Tweets :(")
        })
    }
    
    // When the user is near the end of the # of tweets, then we are going to call the "loadMoreTweets" function which is going to literally load more tweets
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == tweetArray.count {
            loadMoreTweets()
        }
    }
    
    // When the user clicks the logout button
    @IBAction func onLogout(_ sender: Any) {
        // Kills authorization
        TwitterAPICaller.client?.logout()
        UserDefaults.standard.set(false, forKey: "userLoggedIn")
        // Go back to the login screen; is animated which is dope
        self.dismiss(animated: true, completion: nil)
    }

    
    // Make sure when we scroll, the cells are dequeing and being reused
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Casting the cell to of type TweetCellTableViewCell | ! to force it to be that type
        let cell = tableView.dequeueReusableCell(withIdentifier: "tweetCell", for: indexPath) as! TweetCellTableViewCell

        let userObject = tweetArray[indexPath.row]["user"] as! NSDictionary
        
        let retweetCount = tweetArray[indexPath.row]["retweet_count"] as! Int
        let favoriteCount = tweetArray[indexPath.row]["favorite_count"] as! Int
        // Configure the cell...
        cell.userNameLabel.text = userObject["name"] as! String
        cell.tweetsContent.text = tweetArray[indexPath.row]["text"] as! String
        cell.numberOfRetweets.text = String(describing: retweetCount)
        cell.numberOfFavorites.text = String(describing: favoriteCount)
        
        let imageUrl = URL(string: (userObject["profile_image_url_https"]) as! String)
        let data = try? Data(contentsOf: imageUrl!)
        
        if let imageData = data {
            cell.userProfileImage.image = UIImage(data: imageData)
        }
        
        cell.setFavorite(tweetArray[indexPath.row]["favorited"] as! Bool)
        cell.setRetweet(tweetArray[indexPath.row]["retweeted"] as! Bool)
        // Setting the ID of the tweet so we can Favorite and Retweet the tweet
        cell.tweetId = tweetArray[indexPath.row]["id"] as! Int
        
        return cell
    }
    
    // Only one section
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    // We are returning the total number of rows based on the # of tweets that we GOT from the Server
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweetArray.count
    }
    

}
