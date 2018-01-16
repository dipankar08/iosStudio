//
//  APIClient.swift
//  AudioAnchor
//
//  Created by Joseph Ugowe on 1/5/18.
//  Copyright © 2018 Joseph Ugowe. All rights reserved.
//

import Foundation

class APIClient {
    
    typealias JSONDictionary = [String: Any]
    typealias JSONResponse = ([Album]?, String) -> ()
    
    var albums: [Album] = []
    var errorMessage = ""
    
    let defaultSession = URLSession(configuration: .default)
    let sharedSession = URLSession.shared
    
    var dataTask: URLSessionDataTask?
    let tracksEndpoint = "http://simplestore.dipankar.co.in/api/bengalimusic1"//https://s3-us-west-2.amazonaws.com/anchor-website/challenges/bsb.json"
    
    func fetchAudioTracks(completion: @escaping JSONResponse) {
         dataTask?.cancel()
        
        guard let url = NSURL(string: tracksEndpoint) else {
            print("This isn't working")
            return }
        var request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "GET"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData

        
        dataTask = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            defer { self.dataTask = nil}
            
            if let error = error {
                self.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
            } else if let data = data {
                self.serializeJSON(data)
                
                DispatchQueue.main.async {
                    completion(self.albums, self.errorMessage)
                }
            }
        }
        dataTask?.resume()
    }
    
   func serializeJSON(_ data: Data) {
        var response: JSONDictionary?
        do {
            response = try JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary
        } catch let parseError as NSError {
            errorMessage += "JSONSerialization error: \(parseError.localizedDescription)\n"
            return
        }
        if response!["status"] as? String != "success" {
            errorMessage += "Dictionary does not contain results key\n"
            return;
        }
        guard let albumArray = response!["out"] as? [Any] else {
            errorMessage += "Dictionary does not contain results key\n"
            return
        }

        for album in albumArray {
            var songs:[Song] = []
            let albumDictionary = album as? JSONDictionary
            let trackArray = albumDictionary!["tracks"] as? [Any]
            let title = albumDictionary!["album_name"] as? String
            let imageURLString = albumDictionary!["album_image"] as? String
            let imageURL = URL(string: imageURLString!)
            
            for track in trackArray! {
                var trackDictionary = track as? JSONDictionary
                let title = trackDictionary!["track_name"] as? String
                let author = trackDictionary!["track_artist"] as? String
                let mediaURLString = trackDictionary!["track_audio_url"] as? String
                let mediaURL = URL(string: mediaURLString!)
                let newSong = Song(title: title!, author: author!, mediaURL: mediaURL!)
                songs.append(newSong)
            }
        
            let newAlbum = Album(title: title!, imageURL: imageURL!, songs: songs)
            albums.append(newAlbum)
        }
    }
    /*
    func serializeJSON1(_ data: Data) {
        var response: JSONDictionary?
        
        do {
            response = try JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary
        } catch let parseError as NSError {
            errorMessage += "JSONSerialization error: \(parseError.localizedDescription)\n"
            return
        }
        
        guard let trackArray = response!["tracks"] as? [Any] else {
            errorMessage += "Dictionary does not contain results key\n"
            return
        }
        var index = 0
        for track in trackArray {
            if let trackDictionary = track as? JSONDictionary,
                let title = trackDictionary["title"] as? String,
                let mediaURLString = trackDictionary["mediaUrl"] as? String,
                let mediaURL = URL(string: mediaURLString),
                let imageURLString = trackDictionary["imageUrl"] as? String,
                let imageURL = URL(string: imageURLString) {
                if !mediaURLString.contains("video") {
                    let newTrack = Track(title: title, mediaURL: mediaURL, imageURL: imageURL, index: index)
                    tracks.append(newTrack)
                    index += 1
                }
            } else {
                errorMessage += "Problem parsing trackDictionary\n"
            }
            
        }
    }
 */
}


