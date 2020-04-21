/*
* Copyright (c) 2016-2018 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

/*rules:
title:
should changed depending on the count of the photos
- count == 0 ? "Combinestagram" :  "(count) Photo(s)"
saveImageButton:
should be disabled if count == 0 && not even counts
clearImageButton:
should be disabled if count == 0
addButton:
should be disabled if count > 6
*/


import UIKit
import RealmSwift

final class MainViewController: UIViewController {
	
	//MARK: - Stored
	
	var images = [UIImage](){
		didSet {
			updateMyUI(count: images.count)
		}
	}
	var imageNames: [String] = []
	
	//MARK: - IBOutlet
	
	@IBOutlet weak var imagePreview: UIImageView!
	@IBOutlet weak var buttonClear: UIButton!
	@IBOutlet weak var buttonSave: UIButton!
	@IBOutlet weak var itemAdd: UIBarButtonItem!
	
	
	//MARK: - Life Cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
	}
	
	
	//MARK: - Instance
	
	@IBAction func actionClear() {
		removeImages()
	}
	
	@IBAction func actionSave() {
		saveToDB()
	}
	
	@IBAction func actionAdd() {
		showPhotosGallery()
	}
	
	
	func showMessage(_ title: String, description: String? = nil) {
		let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Close", style: .default, handler: { [weak self] _ in self?.dismiss(animated: true, completion: nil)}))
		present(alert, animated: true, completion: nil)
	}
	
	
	private func updateMyUI(count: Int){
		itemAdd.isEnabled = count < 6
		buttonClear.isEnabled = count > 0
		buttonSave.isEnabled = count > 0 && count % 2 == 0
		self.title = count == 0 ? "Combinestagram" : "\(count)"
		guard count != 0 else {
			imagePreview.image = nil
			return
		}
	}
	
	
	private func showPhotosGallery() {
		let vc = storyboard?.instantiateViewController(withIdentifier: "PhotosViewController") as! PhotosViewController
		vc.addImageDelegate = self
		navigationController?.pushViewController(vc, animated: true)
	}
	
	
	private func saveToDB() {
		let image = Images()
		image.imageArray.append(objectsIn: imageNames)
		
		do {
			let realm = try Realm()
			try realm.write {
				realm.add(image)
			}
		} catch {
			showMessage("Error", description: "\(error)")
			return
		}
		let savedImages = imageNames.joined(separator: "\n")
		showMessage("Success", description: "Images\n\(savedImages)\nare saved.")
	}
	
	
	private func removeImages() {
		do {
			let realm = try Realm()
			try realm.write {
				realm.delete(realm.objects(Images.self))
			}
		} catch {
			showMessage("Error", description: "\(error)")
			return
		}
		images.removeAll()
		imageNames.removeAll()
		showMessage("Success")
	}
	
	
}


//MARK: - AddImageDelegate

extension MainViewController: AddImageDelegate {
	
	func addImage(image: UIImage, imageName: String){
		images.append(image)
		imageNames.append(imageName)
		imagePreview.image = UIImage.collage(
			images: images,
			size: CGSize(
				width: imagePreview.frame.width,
				height: imagePreview.frame.height
		))
	}
}
