//
//  ViewController.swift
//  Technical task iOS
//
//  Created by Ruslan Pitula on 5/15/19.
//  Copyright © 2019 Ruslan Pitula. All rights reserved.
//

import UIKit
import RxSwift
import AlamofireImage

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imagePreview: UIImageView!
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var searchCollectionView: UICollectionView!
    
    
    var disposeBag = DisposeBag()
    var pictures = [Picture]()
    var searchPictures = [Picture]()
    var isPreviewShown = false
    var isSearch = false
    var searchPrompt = ""
    
    
    var page = 1
    var searchPage = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        loadPicture(page: self.page)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.addTarget(self, action: #selector(searchBarIsActive), for: .editingDidBegin)
        textFieldInsideSearchBar?.addTarget(self, action: #selector(searchBarTextChanged), for: .editingChanged)
    }
    
    // MARK: - General Functions
    
    func setupView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        searchCollectionView.delegate = self
        searchCollectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        searchCollectionView.showsVerticalScrollIndicator = false
        collectionView.register(UINib(nibName: "PictureCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PictureCollectionViewCell")
        searchCollectionView.register(UINib(nibName: "PictureCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PictureCollectionViewCell")
        let tap = UITapGestureRecognizer(target: self, action: #selector(previewTapped))
        blurView.addGestureRecognizer(tap)
    }

    
    func loadPicture(page: Int) {
        DataManager.shared.pictureController.loadPicturePerPage(page: page).subscribeOn(MainScheduler()).subscribe { (event) in
            switch event {
            case .error(let error):
                print(error)
            case .success(let pictures):
                self.pictures += pictures
                self.page += 1
                self.collectionView.reloadData()
            }
        }.disposed(by: disposeBag)
    }
    
    func loadPictureBySearch(prompt: String, page: Int) {
        DataManager.shared.pictureController.getPicturesBySearch(page: searchPage, search: prompt).subscribeOn(MainScheduler()).subscribe { (event) in
            switch event {
            case .error(let error):
                print(error)
            case .success(let pictures):
                self.searchPictures += pictures
                self.searchCollectionView.reloadData()
            }
            }.disposed(by: disposeBag)
    }
    
    // MARK: - Actions
    
    @IBAction func searchBarIsActive(_ sender: UITextField) {
        UIView.animate(withDuration: 0.5, animations: {
            self.collectionView.alpha = 0.5
            self.searchCollectionView.isHidden = false
        }, completion: { (finished: Bool) in
            self.searchBar.becomeFirstResponder()
        })
    }
    
    @IBAction func searchBarTextChanged(_ sender: UITextField) {
        if let text = sender.text {
            self.collectionView.alpha = 0
            searchPrompt = text
            if searchPrompt.count > 3 {
                loadPictureBySearch(prompt: searchPrompt, page: searchPage)
            } else if searchPrompt.count == 0 {
                self.collectionView.alpha = 1
                self.searchCollectionView.isHidden = true
                self.searchBar.resignFirstResponder()
            } else {
                searchPictures = [Picture]()
                searchCollectionView.reloadData()
            }
            
        }
    }
    
    @IBAction func previewTapped(_ sender: UITapGestureRecognizer) {
        if isPreviewShown {
            isPreviewShown = false
            UIView.animate(withDuration: 0.3) {
                self.imagePreview.alpha = 0
                self.blurView.isHidden = true
                self.blurView.alpha = 0
            }
        }
    }
    
    // MARK: - Collection View
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView {
            return pictures.count
        } else {
            return searchPictures.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.collectionView {
            return CGSize(width: view.frame.width/4, height: view.frame.height/4)
        } else {
            return CGSize(width: view.frame.width/2, height: view.frame.height/4)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PictureCollectionViewCell", for: indexPath) as! PictureCollectionViewCell
        var picture: Picture?
        if collectionView == self.collectionView {
            picture = pictures[indexPath.item]
        } else {
            picture = searchPictures[indexPath.item]
        }
        
        if let small = picture?.urls.small {
            if let url = URL(string: small) {
                cell.pictureImageView.af_setImage(withURL: url, imageTransition: .crossDissolve(0.1))                
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !isPreviewShown {
            isPreviewShown = true
            var picture: Picture?
            if collectionView == self.collectionView {
                picture = pictures[indexPath.item]
            } else {
                picture = searchPictures[indexPath.item]
            }
            UIView.animate(withDuration: 0.3) {
                self.imagePreview.alpha = 1
                self.blurView.isHidden = false
                self.blurView.alpha = 0.4
            }
            if let regular = picture?.urls.regular {
                if let url = URL(string: regular) {
                    imagePreview.image = UIImage()
                    imagePreview.af_setImage(withURL: url, imageTransition: .crossDissolve(0.1))
                }
            }
        }
        
    }
    
    // MARK: - Pagination
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath){
        if pictures.count-1 == indexPath.item && pictures.count%11 == 0{
            loadPicture(page: page)
        }
    }
    

}

