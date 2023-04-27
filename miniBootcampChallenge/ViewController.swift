//
//  ViewController.swift
//  miniBootcampChallenge
//

import UIKit

class ViewController: UICollectionViewController {
    
    private struct Constants {
        static let title = "Mini Bootcamp Challenge"
        static let cellID = "imageCell"
        static let cellSpacing: CGFloat = 1
        static let columns: CGFloat = 3
        static var cellSize: CGFloat?
    }
    
    private lazy var urls: [URL] = URLProvider.urls
    private var imageCache = NSCache<NSURL, UIImage>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Constants.title
        // USE ONE FUNCTION AT A TIME
        // Function 1
//        downloadAsync()
        // Function 2
        downloadAfter()
    }


}

extension ViewController {
    
    
    
    // TODO: 1.- Implement a function that allows the app downloading the images without freezing the UI or causing it to work unexpected way
//    func downloadAsync(url: URL, cell: ImageCell) {
    func downloadAsync() {
        let queue = OperationQueue()
        
        for url in self.urls {
            let downloadOperation = BlockOperation {
                if self.imageCache.object(forKey: url as NSURL) == nil {
                    // Download image from URL
                    if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                        // Save image in cache
                        self.imageCache.setObject(image, forKey: url as NSURL)
                    } else {
                        print("Error downloading the image: \(url)")
                        self.imageCache.setObject(UIImage(systemName: "camera.circle")!, forKey: url as NSURL)
                    }
                }
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
            queue.addOperation(downloadOperation)
        }
    }
    // TODO: 2.- Implement a function that allows to fill the collection view only when all photos have been downloaded, adding an animation for waiting the completion of the task.
    func downloadAfter() {
        let queue = OperationQueue()
        var counter = 0
        // Loading Animation
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: 20, y: 20), radius: 10, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        let shapeLayer = CAShapeLayer()
        
        shapeLayer.path = circlePath.cgPath
        shapeLayer.fillColor = UIColor.systemBlue.cgColor
        shapeLayer.position = view.center
        view.layer.addSublayer(shapeLayer)
        
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.fromValue = 0
        animation.toValue = 2 * CGFloat.pi
        animation.duration = 1
        animation.repeatCount = .infinity
        shapeLayer.add(animation, forKey: "rotation")
        
        if self.urls.isEmpty {
            self.title = "No images"
            return
        }
        for url in self.urls {
            let downloadOperation = BlockOperation {
                if self.imageCache.object(forKey: url as NSURL) != nil {
                    counter += 1
                } else {
                    // Download image from URL
                    if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                        // Save image in cache
                        self.imageCache.setObject(image, forKey: url as NSURL)
                        counter += 1
                    } else {
                        counter += 1
                        print("Error downloading the image: \(url)")
                        self.imageCache.setObject(UIImage(systemName: "camera.circle")!, forKey: url as NSURL)
                    }
                }
                // If number of images saved qual to total of urls, finish animation and reload collectionView
                if counter == self.urls.count {
                    DispatchQueue.main.sync {
                        shapeLayer.removeAllAnimations()
                        shapeLayer.removeFromSuperlayer()
                        self.collectionView.reloadData()
                    }
                }
            }
            queue.addOperation(downloadOperation)
        }
    }
}
// MARK: - UICollectionView DataSource, Delegate
extension ViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        urls.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellID, for: indexPath) as? ImageCell else { return UICollectionViewCell() }
        
        let url = urls[indexPath.row]
        let image = imageCache.object(forKey: url as NSURL)
        cell.display(image)
        
        return cell
    }
}


// MARK: - UICollectionView FlowLayout
extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if Constants.cellSize == nil {
          let layout = collectionViewLayout as! UICollectionViewFlowLayout
            let emptySpace = layout.sectionInset.left + layout.sectionInset.right + (Constants.columns * Constants.cellSpacing - 1)
            Constants.cellSize = (view.frame.size.width - emptySpace) / Constants.columns
        }
        return CGSize(width: Constants.cellSize!, height: Constants.cellSize!)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        Constants.cellSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        Constants.cellSpacing
    }
}
