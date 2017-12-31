//
//  ViewController.swift
//  bengaliMusicPlayer
//
//  Created by Dipankar Dutta on 12/31/17.
//  Copyright © 2017 Dipankar Dutta. All rights reserved.
//

import UIKit
import AVFoundation

struct MyJson:Decodable{
    let out:[Song]
    let status:String
    let msg:String
}
struct Song : Decodable {
    let track_name:String
    let track_album:String
    let track_artist:String
    let image: String?
    var url:String
}


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate {
   // let elements = ["dog","cat","dog","cat","dog","cat","dog","cat","dog","cat","dog","cat"]
    var songs:[Song] = [Song]()
    var onlineSongs:[Song] = [Song]()
    var offlineSongs:[Song] = [Song]()
    
    var curSongIndex = 0;
    var page  = 0;
    
    var autdioPalyer = AVPlayer()

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var playPauseBtn: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var filteredData = [Song]()
    var isSearching = false

    @IBOutlet weak var segmentedView: UISegmentedControl!
    
    @IBAction func segmentedViewChanged(_ sender: Any) {
        if(segmentedView.selectedSegmentIndex==0){
            songs = onlineSongs
            tableView.reloadData()
        }
        else if(segmentedView.selectedSegmentIndex==1){
            offlineSongs = getAllLocal();
            songs = offlineSongs
            tableView.reloadData()
        }
        else{
            
        }

    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        
        clearTable()
        loadMoreData()
        //test
        print(inCache(url:"http://freetone.org/ring/stan/iPhone_5-Alarm.mp3"))
        savelocal(url:"http://freetone.org/ring/stan/iPhone_5-Alarm.mp3")
        print(inCache(url:"http://freetone.org/ring/stan/iPhone_5-Alarm.mp3"))
        getAllLocal()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isSearching{
           return filteredData.count
        }
 
        return songs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell") as! CustomTableViewCell
        
        var song:Song
        if isSearching{
            song = filteredData[indexPath.row]
        } else{
            song = songs[indexPath.row]
        }
        
        cell.songImage.downloadedFrom(link:song.image ?? "")
        //cell.songImage.image = UIImage(named: songs[indexPath.row])
        cell.songLabel.text = song.track_name
        cell.cellView.layer.cornerRadius = cell.cellView.frame.height / 2
        cell.songImage.layer.cornerRadius = cell.songImage.frame.height / 2
        
        let button1:UIButton = cell.btnDownload
        button1.addTarget(self, action: #selector(FisrtButtonClick), for: .touchUpInside)
        
        return cell
        
    }
    @objc func FisrtButtonClick(_ sender: Any)  {
        //Get Button cell position.
        let ButtonPosition = (sender as AnyObject).convert(CGPoint.zero, to: tableView)
        let indexPath = tableView.indexPathForRow(at: ButtonPosition)
        if indexPath != nil {
            print("Download clicked for: \(indexPath?.row)")
            savelocal(url: songs[(indexPath?.row)!].url)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        curSongIndex = indexPath.row
        play()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastitem = songs.count - 1
        print("willDisplay: Name : \(indexPath.row)")
        if(lastitem == indexPath.row){
            loadMoreData()
        }
    }
    
    func loadMoreData(){
        //data fetchinh
        let surl = "http://simplestore.dipankar.co.in/api/bengalimusic?page=\(self.page)"
        
        guard let url = URL(string: surl) else {
            return
        }
        
        URLSession.shared.dataTask(with: url){(data,responce,err) in
            print("some stuff here..")
            guard let data = data else {return }
            do{
                let myJson = try JSONDecoder().decode(MyJson.self, from:data)
                if myJson.out.count == 0 {
                    print(" No more data to be lopade...")
                } else{
                    self.onlineSongs.append(contentsOf: myJson.out)
                    self.songs.append(contentsOf: myJson.out)
                    print("Number of songs exists: \(self.songs.count)")
                    for song in myJson.out{
                        print("Song Entry: Name : \(song.track_name)")
                    }
                    self.page += 1
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
                
            } catch {
                
            }
            }.resume()
        }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == ""{
            isSearching = false
            view.endEditing(true)
            filteredData = songs
            tableView.reloadData()
        } else{
            isSearching = true
            filteredData = songs.filter {
                let text = searchBar.text ?? ""
                return $0.track_name.range(of: text, options: .caseInsensitive) != nil
            }
            tableView.reloadData()
        }
    }
    fileprivate func clearTable() {
        self.songs.removeAll(keepingCapacity: false)
        self.tableView.reloadData()
    }
    
    
    @IBAction func previous(_ sender: Any) {
        curSongIndex = curSongIndex - 1
        if curSongIndex == -1 {
            curSongIndex = songs.count - 1
        }
        play()
    }
    
    @IBAction func playpause(_ sender: Any) {
        if autdioPalyer.isPlaying {
            autdioPalyer.pause()
            playPauseBtn.setTitle("Play", for: UIControlState())
        } else{
            autdioPalyer.play()
            playPauseBtn.setTitle("Pause", for: UIControlState())
        }
    }
    
    @IBAction func next(_ sender: Any) {

        curSongIndex = curSongIndex + 1
        if curSongIndex == songs.count - 1 {
            curSongIndex = 0
        }
        play();
    }
    func play(){
        var song = songs[curSongIndex];
        let url = encode1(a : &song.url);
        Toast(message: "Now playing " + song.track_name + "...")
        print(url)
     
            let playerItem = AVPlayerItem(url: URL(string: url)!)
            autdioPalyer = AVPlayer(playerItem: playerItem)
            autdioPalyer.rate = 1.0;
            autdioPalyer.addObserver(self, forKeyPath: "status", options:NSKeyValueObservingOptions(), context: nil)
            autdioPalyer.play()
            playPauseBtn.setTitle("Pause", for: UIControlState())
    }
    func encode1( a : inout String)->String{
        a = a.replacingOccurrences(of: " ", with: "%20")
        a = a.replacingOccurrences(of: "(", with: "%28")
        a = a.replacingOccurrences(of: ")", with: "%29")
        return a
    }
    
    func Toast( message: String){
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        self.present(alert, animated: true)
        // duration in seconds
        let duration: Double = 5
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
            alert.dismiss(animated: true)
        }
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "status") {
            let status: AVPlayerStatus = self.autdioPalyer.status
            switch (status) {
            case AVPlayerStatus.readyToPlay:
                print("---------- ReadyToPlay ----------")
                break
            case .unknown:
                
                break;
            case .failed:
                Toast(message: "Not able to play the music...")
            }
        }
    }
    
    //cache ---------
    func inCache(url:String) -> Bool{
        if let audioUrl = URL(string: url) {
            // then lets create your document folder url
            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            // lets create your destination file url
            let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
            print(destinationUrl)
            
            // to check if it exists before downloading it
            if FileManager.default.fileExists(atPath: destinationUrl.path) {
                print("The file already exists at path")
                return true;
            }
        }
        return false;
    }
    
    func getAllLocal() -> [Song]{
        var locals = [Song]()
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            for file in fileURLs{
                let s = Song(track_name: file.lastPathComponent, track_album: "", track_artist: "", image: "", url: file.absoluteString)
                print(s)
                locals.append(s)
            }
            
        } catch {
            print("Error while enumerating files \(error.localizedDescription)")
        }
        return locals;
    }
    
    func savelocal(url:String) {
        var url1 = url;
        Toast(message: "Downloding the songs")
        if let audioUrl = URL(string: encode1(a: &url1)) {
            
            // then lets create your document folder url
            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            // lets create your destination file url
            let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
            print(destinationUrl)
            
            // to check if it exists before downloading it
            if FileManager.default.fileExists(atPath: destinationUrl.path) {
                print("The file already exists at path")
                
                // if the file doesn't exist
            } else {
                
                // you can use NSURLSession.sharedSession to download the data asynchronously
                URLSession.shared.downloadTask(with: audioUrl, completionHandler: { (location, response, error) -> Void in
                    guard let location = location, error == nil else { return }
                    do {
                        // after downloading your file you need to move it to your destination url
                        try FileManager.default.moveItem(at: location, to: destinationUrl)
                        print("File moved to documents folder")
                        self.Toast(message: "Downloding complete")
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }).resume()
            }
        }
    }
    //cache end ----
}

extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else {
                    DispatchQueue.main.async() {
                        self.image = UIImage(named: "cat")
                    }
                
                return
            }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}
extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}

/*
>>> for m in a:
...   m['url'] = "http://media-audio.mio.to/various_artists/"+m['album_id'][0]+"/"+m['album_id']+"/"+m['disc_number']+"_"+m['track_number']+" - "+m['track_name']+"-vbr-V5.mp3""

*/
