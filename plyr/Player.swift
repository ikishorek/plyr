//
//  Player.swift
//  plyr
//
//  Created by Luka Kerr on 1/3/18.
//  Copyright © 2018 Luka Kerr. All rights reserved.
//

import Foundation
import AVFoundation

class Player: NSObject, AVAudioPlayerDelegate, NSUserNotificationCenterDelegate {
  
  // Main audio player
  var audioPlayer: AVAudioPlayer!
  
  // Currently playing song
  var currentSong: URL!
  
  // Currently playing song index
  var currentSongIndex: Int = 0
  
  // All songs
  var allSongs: [URL]!
  
  override init() {
    super.init()
    allSongs = getAllSongs()
    NSUserNotificationCenter.default.delegate = self
  }
  
  func getAllSongs() -> [URL] {
    let path = "\(FileManager.default.homeDirectoryForCurrentUser.path)/Music"
    let songs = FileManager.default.filteredMusicFileURLs(inDirectory: path)
    return songs
  }
  
  func playAll() {
    if allSongs.count > currentSongIndex {
      currentSong = allSongs[currentSongIndex]
      playSong(path: currentSong)
    } else {
      let notification = NSUserNotification()
      notification.title = "No music found"
      notification.informativeText = "No music could be found. Exiting"
      notification.soundName = NSUserNotificationDefaultSoundName
      NSUserNotificationCenter.default.deliver(notification)
      exit(0)
    }
  }
  
  func pause() {
    audioPlayer.pause()
  }
  
  func resume() {
    audioPlayer.prepareToPlay()
    audioPlayer.play()
  }
  
  func skip() {
    audioPlayer.currentTime += 10.0
  }
  
  func rewind() {
    audioPlayer.currentTime -= 10.0
  }
  
  func next() {
    currentSongIndex = (currentSongIndex + 1) % allSongs.count
    playAll()
  }
  
  func previous() {
    let newIndex = currentSongIndex - 1
    currentSongIndex = newIndex < 0 ? 0 : newIndex
    playAll()
  }
  
  func playSong(path: URL) {
    audioPlayer = try? AVAudioPlayer(contentsOf: path)
    audioPlayer.numberOfLoops = 0
    audioPlayer.delegate = self
    audioPlayer.prepareToPlay()
    
    audioPlayer.play()
    
    NotificationCenter.default.post(
      name: NSNotification.Name(rawValue: "setSongDetails"),
      object: currentSong
    )
  }
  
  func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    currentSongIndex = (currentSongIndex + 1) % allSongs.count
    playAll()
  }
}
