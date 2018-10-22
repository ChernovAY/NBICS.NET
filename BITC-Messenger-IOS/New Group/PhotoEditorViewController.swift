//
//  PhotoEditorViewController.swift
//  BITC-Messenger-IOS
//
//  Created by Анна Гринер on 19.09.2018.
//  Copyright © 2018 riktus. All rights reserved.
//PhotoEditorViewController

import UIKit

class PhotoEditorViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIScrollViewDelegate,UIGestureRecognizerDelegate
{
    let picker = UIImagePickerController()
    var circlePath = UIBezierPath()
    
    @IBOutlet weak var crop: CropView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scroll: UIScrollView!
        {
        didSet{
            scroll.delegate = self
            scroll.minimumZoomScale = 1
            scroll.maximumZoomScale = 10.0
            scroll.zoomScale = 1
        }
    }
    
    //MARK: -View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pangest));
        //  crop.backgroundColor = UIColor.lightGray
        //   crop.addGestureRecognizer(gestureRecognizer)
        picker.delegate = self
        let size : CGFloat = self.view.frame.size.width//280
        layer(x: (self.view.frame.size.width / 2) - (size/2), y: (self.view.frame.size.height / 2) - (size / 2), width: size,height: size,cornerRadius: self.view.frame.size.width / 2)
        
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    //MARK: -SubLayer
    
    func layer(x: CGFloat,y: CGFloat,width: CGFloat,height: CGFloat,cornerRadius: CGFloat)
    {
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height), cornerRadius: 0)
        circlePath = UIBezierPath(roundedRect: CGRect(x: x,y: y,width: width,height: height), cornerRadius: cornerRadius)
        path.append(circlePath)
        path.usesEvenOddFillRule = true
        let fillLayer = CAShapeLayer()
        fillLayer.path = path.cgPath
        fillLayer.fillRule = CAShapeLayerFillRule.evenOdd
        fillLayer.opacity = 0.7
        fillLayer.fillColor = UIColor.lightGray.cgColor
        view.layer.addSublayer(fillLayer)
    }
    
    //MARK: -UIScrollViewDelegate
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView?
    {
        return imageView
    }
    
    
    //MARK: -UIGestureRecognizerDelegate
    
    //   @IBAction func pangest(_ gestureRecognizer: UIPanGestureRecognizer)
    //   {
    //      if gestureRecognizer.state == .began || gestureRecognizer.state == .changed
    //      {
    //         let translation = gestureRecognizer.translation(in: view)
    //         gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x + translation.x, y: gestureRecognizer.view!.center.y + translation.y)
    //         gestureRecognizer.setTranslation(CGPoint.zero, in: view)
    //     }
    // }
    
    //MARK: -Cropping
    
    @IBAction func cropping(_ sender: UIBarButtonItem)
    {
        let croppedCGImage = imageView.image?.cgImage?.cropping(to: cropArea)
        if ((croppedCGImage) != nil){
            var croppedImage = UIImage(cgImage: croppedCGImage!)
            croppedImage = croppedImage.resizeImage(image: croppedImage, targetSize: CGSize(width: 280 , height: 280))
            VSMAPI.Data.Profile?.Icon = croppedImage
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    var cropArea:CGRect
    {
        get{
            let factor = imageView.image!.size.width/view.frame.width
            let scale = 1/scroll.zoomScale
            let imageFrame = imageView.imageFrame()
            let x = (scroll.contentOffset.x + circlePath.bounds.origin.x - imageFrame.origin.x) * scale * factor
            let y = (scroll.contentOffset.y + circlePath.bounds.origin.y - imageFrame.origin.y) * scale * factor
            let width =  circlePath.bounds.width  * scale * factor
            let height = circlePath.bounds.height  * scale * factor
            return CGRect(x: x, y: y, width: width, height: height)
        }
        
    }
    
    //MARK: -UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        let chosenImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as! UIImage
        imageView.contentMode = .scaleAspectFit
        imageView.image = chosenImage.resizeImage(image: chosenImage, targetSize: CGSize(width: 3024 , height: 4032))
        //imageView.image = chosenImage
        dismiss(animated:true, completion: nil)
    }
    
    //MARK: -PickImage
    
    @IBAction func album(_ sender: UIBarButtonItem)
    {
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    //MARK: -UIImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: -ShootImage
    
    @IBAction func shoot(_ sender: UIBarButtonItem)
    {
        if UIImagePickerController.isSourceTypeAvailable(.camera)
        {  picker.sourceType = UIImagePickerController.SourceType.camera
            picker.cameraCaptureMode =  UIImagePickerController.CameraCaptureMode.photo
            picker.modalPresentationStyle = .custom
            present(picker,animated: true,completion: nil)
        }
        else
        {
            nocamera()
        }
    }
    func nocamera()
    {
        let alertVC = UIAlertController(title: "No Camera",message: "Sorry, this device has no camera",preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK",style:.default,handler: nil)
        alertVC.addAction(okAction)
        present(alertVC,animated: true,completion: nil)
    }
    
    
    
}
extension UIImageView
{
    func imageFrame()->CGRect
    {
        let imageViewSize = self.frame.size
        guard let imageSize = self.image?.size else
        {
            return CGRect.zero
        }
        let imageRatio = imageSize.width / imageSize.height
        let imageViewRatio = imageViewSize.width / imageViewSize.height
        if imageRatio < imageViewRatio
        {
            let scaleFactor = imageViewSize.height / imageSize.height
            let width = imageSize.width * scaleFactor
            let topLeftX = (imageViewSize.width - width) * 0.5
            return CGRect(x: topLeftX, y: 0, width: width, height: imageViewSize.height)
        }
        else
        {
            let scalFactor = imageViewSize.width / imageSize.width
            let height = imageSize.height * scalFactor
            let topLeftY = (imageViewSize.height - height) * 0.5
            return CGRect(x: 0, y: topLeftY, width: imageViewSize.width, height: height)
        }
    }
}
extension UIImage
{
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage
    {
        let size = image.size
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        var newSize: CGSize
        if(widthRatio > heightRatio)
        {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        }
        else
        {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
