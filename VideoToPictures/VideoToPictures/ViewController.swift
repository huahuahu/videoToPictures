//
//  ViewController.swift
//  VideoToPictures
//
//  Created by huahuahu on 2017/10/8.
//  Copyright © 2017年 huahuahu. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation


class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    var videoURL:NSURL?
    var fps:Int?
    var duration:CMTime?
    var picures:[Float64:UIImage]?
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let imagePicker = UIImagePickerController.init()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        
        let availableMediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)
        if let _ =  availableMediaTypes?.contains(String.init(kUTTypeVideo))  {
            imagePicker.mediaTypes = [ kUTTypeMovie as String]
        }
        
        
        self.present(imagePicker, animated: true, completion: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        picker.dismiss(animated: true, completion:  nil)
        videoURL = info[UIImagePickerControllerMediaURL] as? NSURL
        self.processVideo()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func processVideo() -> Void {
        guard let _ = videoURL else {
            return
        }
        
        picures = [Float64:UIImage]()
        
        let videoAsset = AVAsset.init(url: videoURL! as URL)
        fps = Int((videoAsset.tracks(withMediaType: .video).last?.nominalFrameRate)!)
        duration = videoAsset.duration
        let durationSeconds = CMTimeGetSeconds(duration!)
        let picCounts = Int( durationSeconds * Double(fps!))
        
        var times = [CMTime]()
        for count in 0..<picCounts {
            if count % 10 == 0 {
                times.append(CMTime.init(value: CMTimeValue(count), timescale: CMTimeScale(fps!)))
            }
        }
        
        
        
        
        
        //产生图片
        let imageGenerator = AVAssetImageGenerator.init(asset: videoAsset)
        imageGenerator.requestedTimeToleranceAfter = kCMTimeZero
        imageGenerator.requestedTimeToleranceBefore = kCMTimeZero
        
        var currentGeneratedImages:Int = 0
        
        imageGenerator.generateCGImagesAsynchronously(forTimes: times as [NSValue]) { (requestedTime, image, actualTime, result, error) in
            DispatchQueue.main.sync {
                currentGeneratedImages = currentGeneratedImages + 1
                switch result{
                case .cancelled:
                    print("cancelled")
                case .succeeded:
                    print("succeed")
                    self.picures![CMTimeGetSeconds(actualTime)]  = UIImage.init(cgImage: image!)
                case .failed:
                    print("failed")
                }
                print("current iamges is \(currentGeneratedImages)")
                if currentGeneratedImages >= times.count {
                    self.showPictures()
                }
            }
        }
    }
    
    func showPictures() ->  Void{
        let sortedPictures =  picures?.sorted(by: { (item1, item2) -> Bool in
            if item1.key < item2.key
            {
                return true
            }
            else
            {
                return false
            }
        })
        
        let scrollView = UIScrollView.init(frame: view.bounds)
        
        let pictureHeight = 100
        
        scrollView.contentSize = CGSize.init(width: view.frame.width, height: CGFloat(pictureHeight * (sortedPictures?.count)!))
        view.addSubview(scrollView)
        
        var currentY  = 0
        
        for item in sortedPictures! {
            let imageView = UIImageView.init(frame: CGRect.init(x: 0, y: currentY, width: Int(view.frame.width), height: pictureHeight - 10))
            imageView.image = item.value
            imageView.contentMode = .scaleAspectFit
            scrollView.addSubview(imageView)
            currentY = currentY + pictureHeight
        }
        
    }

}

