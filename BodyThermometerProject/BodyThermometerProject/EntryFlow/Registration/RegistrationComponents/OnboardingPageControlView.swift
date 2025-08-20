//
//  OnboardingPageControl.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 13.08.25.
//

import UIKit
import SnapKit

final class OnboardingPageControlView: UIView {
    
    private enum Constants {
        static let pageControlHeight: CGFloat = 40.0
        static let numOfPages: Int = 5
    }
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = Constants.numOfPages
        pageControl.backgroundColor = .clear
        pageControl.pageIndicatorTintColor = .appBlack
        pageControl.currentPageIndicatorTintColor = .appBlack
        return pageControl
    }()
    
    var currentPage: Int {
        get { pageControl.currentPage }
        set {
            pageControl.currentPage = newValue
            setupPageContorlIndicator()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        setupPageContorlIndicator()
        setupSnapKitConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//MARK: - Private
private extension OnboardingPageControlView {
    
    func commonInit(){
        self.addSubview(pageControl)
    }
    
    func setupSnapKitConstraints() {
        self.snp.makeConstraints { make in
            make.height.equalTo(Constants.pageControlHeight)
        }
        pageControl.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    func setupPageContorlIndicator() {
        let normal = UIImage.onbPageControlIdicator
        
        let current = UIImage.onbPageControlCurrentIndicator
            .resizableImage(withCapInsets: .zero)
        
        for page in 0..<pageControl.numberOfPages {
            pageControl.setIndicatorImage(normal, forPage: page)
        }
        
        pageControl.setIndicatorImage(current, forPage: pageControl.currentPage)
    }
    
}
