//
//  TrackTableViewController.swift
//  AudioAnchor
//
//  Created by Joseph Ugowe on 1/5/18.
//  Copyright © 2018 Joseph Ugowe. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating  {

    var albumPlaylist: [Album] = []
    let apiClient = APIClient()
    var currentIndex: Int = Int()
    @IBOutlet weak var tableView: UITableView!
    var previousSerachText = ""

    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AudioPlayer.sharedInstance.isPaused = true
    }
    
    override func viewDidLoad() {
    super.viewDidLoad()
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search album"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.searchBar.scopeButtonTitles = ["Album", "Songs", "Artist", "Offlines"]
        searchController.searchBar.delegate = self
        
        apiClient.fetchAudioTracks(text: "?album_name=Nach") { (results, errorMessage) in
            if let results = results{
                self.albumPlaylist = results
                self.tableView.reloadData()
            }
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        if previousSerachText == searchText {
            return
        }
        previousSerachText = searchText
        apiClient.fetchAudioTracks(text: "?album_name="+searchText) { (results, errorMessage) in
            if let results = results{
                self.albumPlaylist = results
                self.tableView.reloadData()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albumPlaylist.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SearchTableViewCell = tableView.dequeueReusableCell(withIdentifier: "searchcell", for: indexPath) as! SearchTableViewCell
     
        let album = albumPlaylist[indexPath.row]
        cell.albumTitle.text = album.title
        
        album.downloadImage(url: album.imageURL) { (songImage) in
            DispatchQueue.main.async {
                if songImage != nil {
                    cell.albumImage.image = songImage
                }
            }
        }
        return cell
    }
    
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentIndex = indexPath.row
        performSegue(withIdentifier: "ShowNext", sender: self)
    }
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let album = albumPlaylist[currentIndex]
        if let destinationViewController = segue.destination as? PlayerController {
            destinationViewController.album = album
        }
    }
    
}

extension SearchViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}




