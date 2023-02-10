//
//  ImageSaver.swift
//  InstaFilter
//
//  Created by Floriano Fraccastoro on 10/02/23.
//

import SwiftUI

class ImageSaver: NSObject {
    func writeToPhotoAlbum(image: UIImage){
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }
    
    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer){
        print("Save completed")
    }
}
