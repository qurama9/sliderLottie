//
//  ViewController.swift
//  sliderLottie
//
//  Created by Рамазан Абайдулла on 19.06.2024.
//

import UIKit
import Lottie

class ViewController: UIViewController {

    let sliderData: [SliderItem] = [
    SliderItem(color: .brown, title: "Slide 1", text: "Рандомный текст чтобы заполнить первый слайд", animationName: "a1"),
    SliderItem(color: .gray, title: "Slide 2", text: "Еще один рандомный текст чтобы заполнить второй слайд", animationName: "a2"),
    SliderItem(color: .purple, title: "Slide 3", text: "На дворе трава, на траве дрова", animationName: "a3")
    ]

    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.width, height: view.frame.height)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.delegate = self
        collection.dataSource = self
        collection.register(SliderCell.self, forCellWithReuseIdentifier: "cell")
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.isPagingEnabled = true
        
        return collection
    }()
    
    lazy var skipBtn: UIButton = {
        let button = UIButton()
        button.setTitle("Skip", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        
        return button
    }()
    
    lazy var hStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 0
        stack.alignment = .center
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        return stack
    }()
    
    lazy var vStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.alignment = .leading
        stack.spacing = 5
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        return stack
    }()
    
    lazy var nextBtn: UIView = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(nextSlide))
        
        let buttonImage = UIImageView()
        buttonImage.image = UIImage(systemName: "chevron.right.circle.fill")
        buttonImage.tintColor = .white
        buttonImage.contentMode = .scaleAspectFit
        buttonImage.translatesAutoresizingMaskIntoConstraints = false
        
        buttonImage.widthAnchor.constraint(equalToConstant: 45).isActive = true
        buttonImage.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        let button = UIView()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 50).isActive = true
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.isUserInteractionEnabled = true
        button.addGestureRecognizer(tapGesture)
        button.addSubview(buttonImage)
        
        buttonImage.centerXAnchor.constraint(equalTo: button.centerXAnchor).isActive = true
        buttonImage.centerYAnchor.constraint(equalTo: button.centerYAnchor).isActive = true
        return button
    }()
    
    
    private let shape = CAShapeLayer()
    private var pagers: [UIView] = []
    private var currentSlide = 0
    private var currentPageIndex: CGFloat = 0
    private var fromValue: CGFloat = 0
//    private var pagerConstraints: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setControl()
        setShape()
    }
    
    
    private func setShape() {
        let nextStroke = UIBezierPath(arcCenter: CGPoint(x: 25, y: 25), radius: 23, startAngle: -(.pi/2), endAngle: 5, clockwise: true)
        
        currentPageIndex = CGFloat(1) / CGFloat(sliderData.count)
        
        let trackShape = CAShapeLayer()
        trackShape.path = nextStroke.cgPath
        
        trackShape.fillColor = UIColor.clear.cgColor
        trackShape.strokeColor = UIColor.white.cgColor
        trackShape.lineWidth = 3
        trackShape.opacity = 0.1
        nextBtn.layer.addSublayer(trackShape)
        
        shape.path = nextStroke.cgPath
        
        shape.fillColor = UIColor.clear.cgColor
        shape.strokeColor = UIColor.white.cgColor
        shape.lineWidth = 3
        shape.lineCap = .round
        shape.strokeStart = 0
        shape.strokeEnd = 0
        
        nextBtn.layer.addSublayer(shape)
    }
    
    private func setControl() {
        
        view.addSubview(hStack)
        
        let pagerStack = UIStackView()
        pagerStack.axis = .horizontal
        pagerStack.spacing = 5
        pagerStack.alignment = .center
        pagerStack.distribution = .fill
        pagerStack.translatesAutoresizingMaskIntoConstraints = false
        
        for tag in 1...sliderData.count {
            let pager = UIView()
            pager.tag = tag
            pager.translatesAutoresizingMaskIntoConstraints = false
            pager.backgroundColor = .white
            pager.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(slideToSender(sender:))))
            pager.layer.cornerRadius = 5
            self.pagers.append(pager)
            pagerStack.addArrangedSubview(pager)
        }
        
        hStack.addArrangedSubview(vStack)
        vStack.addArrangedSubview(pagerStack)
        vStack.addArrangedSubview(skipBtn)
        hStack.addArrangedSubview(nextBtn)
        
        NSLayoutConstraint.activate([
            hStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            hStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            hStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
    }
    
    private func setupUI() {
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    
    
    @objc func slideToSender(sender: UIGestureRecognizer) {
        if let index = sender.view?.tag {
            collectionView.scrollToItem(at: IndexPath(item: index - 1, section: 0), at: .centeredHorizontally, animated: true)
            currentSlide = index - 1
        }
    }
    
    @objc func nextSlide() {
        let maxSlide = sliderData.count
        
        if currentSlide < maxSlide - 1 {
            currentSlide += 1
            collectionView.scrollToItem(at: IndexPath(item: currentSlide, section: 0), at: .centeredHorizontally, animated: true)
        }
    }


}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
   
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        sliderData.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? SliderCell {
            cell.contentView.backgroundColor = sliderData[indexPath.item].color
            cell.textLabel.text = sliderData[indexPath.item].text
            cell.titleLabel.text = sliderData[indexPath.item].title
            
            cell.animationSetup(animationName: sliderData[indexPath.item].animationName)
            
                return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        currentSlide = indexPath.item
        
        pagers.forEach { pager in
            let tag = pager.tag
            let viewTag = indexPath.row + 1
            
            pager.constraints.forEach { constraints in
                pager.removeConstraint(constraints)
            }
            
            if viewTag == tag {
                pager.layer.opacity = 1
                pager.widthAnchor.constraint(equalToConstant: 20).isActive = true
            } else {
                pager.layer.opacity = 0.5
                pager.widthAnchor.constraint(equalToConstant: 10).isActive = true
            }
            
            
//            pagerConstraints?.isActive = true
            pager.heightAnchor.constraint(equalToConstant: 10).isActive = true
        }
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        let currentIndex = currentPageIndex * CGFloat(indexPath.item + 1)
        
        animation.fromValue = fromValue
        animation.toValue = currentIndex
        animation.duration = 0.2
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        shape.add(animation, forKey: "animation")
        
        fromValue = currentIndex
    }
}

struct SliderItem {
    var color: UIColor
    var title: String
    var text: String
    var animationName: String
}
