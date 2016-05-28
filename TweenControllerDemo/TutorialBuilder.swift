//
//  TutorialBuilder.swift
//  TweenController
//
//  Created by Dalton Claybrook on 5/26/16.
//  Copyright © 2016 Claybrook Software. All rights reserved.
//

import UIKit
import TweenController

protocol TutorialViewController: class {
    var containerView: UIView! { get }
    var buttonsContainerView: UIView! { get }
    var pageControl: UIPageControl! { get }
}

struct TutorialBuilder {
    
    private static let starsSize = CGSize(width: 326, height: 462)
    private static let baselineScreenWidth: CGFloat = 414
    
    //MARK: Public
    
    static func buildWithContainerViewController(viewController: TutorialViewController) -> (TweenController, UIScrollView) {
        let tweenController = TweenController()
        let scrollView = layoutViewsWithVC(viewController)
        describeBottomControlsWithVC(viewController, tweenController: tweenController, scrollView: scrollView)
        observeEndOfScrollView(viewController, tweenController: tweenController, scrollView: scrollView)
        describeBackgroundWithVC(viewController, tweenController: tweenController, scrollView: scrollView)
        describeTextWithVC(viewController, tweenController: tweenController, scrollView: scrollView)
        
        return (tweenController, scrollView)
    }
    
    //MARK: Private
    //MARK: Initial Layout
    
    private static func layoutViewsWithVC(vc: TutorialViewController) -> UIScrollView {
        let scrollView = UIScrollView(frame: vc.containerView.bounds)
        guard let superview = vc.containerView.superview else { return scrollView }
        
        layoutButtonsAndPageControlWithVC(vc, scrollView: scrollView)
        
        superview.addSubview(scrollView)
        return scrollView
    }
    
    private static func layoutButtonsAndPageControlWithVC(vc: TutorialViewController, scrollView: UIScrollView) {
        let snapshot = vc.containerView.snapshotViewAfterScreenUpdates(true)
        
        scrollView.pagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        
        let viewSize = vc.containerView.bounds.size
        scrollView.contentSize = CGSizeMake(viewSize.width * 6.0, viewSize.height)
        vc.pageControl.numberOfPages = 5
        
        vc.containerView.translatesAutoresizingMaskIntoConstraints = true
        scrollView.addSubview(vc.containerView)
        
        let xOffset = scrollView.contentSize.width - viewSize.width
        snapshot.frame = vc.containerView.frame.offsetBy(dx: xOffset, dy: 0.0)
        scrollView.addSubview(snapshot)
        
        let buttonsFrame = vc.buttonsContainerView.convertRect(vc.buttonsContainerView.bounds, toView: scrollView)
        let pageControlFrame = vc.pageControl.convertRect(vc.pageControl.bounds, toView: scrollView)
        
        vc.buttonsContainerView.translatesAutoresizingMaskIntoConstraints = true
        vc.pageControl.translatesAutoresizingMaskIntoConstraints = true
        scrollView.addSubview(vc.buttonsContainerView)
        scrollView.addSubview(vc.pageControl)
        vc.buttonsContainerView.frame = buttonsFrame
        vc.pageControl.frame = pageControlFrame
    }
    
    //MARK: Tutorial Actions
    
    private static func describeBottomControlsWithVC(vc: TutorialViewController, tweenController: TweenController, scrollView: UIScrollView) {
        let viewportSize = vc.containerView.frame.size
        let startingButtonFrame = vc.buttonsContainerView.frame
        let startingPageControlFrame = vc.pageControl.frame
        tweenController.tweenFrom(startingButtonFrame, at: -viewportSize.width)
            .to(startingButtonFrame, at: 0.0)
            .thenTo(CGRect(x: startingButtonFrame.minX, y: viewportSize.height, width: startingButtonFrame.width, height: startingButtonFrame.height), at: viewportSize.width)
            .thenHoldUntil(viewportSize.width * 4.0)
            .thenTo(startingButtonFrame, at: viewportSize.width * 5.0)
            .withAction(vc.buttonsContainerView.twc_slidingFrameActionWithScrollView(scrollView))
        
        let nextPageControlFrame = CGRect(x: startingPageControlFrame.minX, y: startingPageControlFrame.minY + startingButtonFrame.height, width: startingPageControlFrame.width, height: startingPageControlFrame.height)
        tweenController.tweenFrom(startingPageControlFrame, at: 0.0)
            .to(nextPageControlFrame, at: viewportSize.width)
            .thenHoldUntil(viewportSize.width * 4.0)
            .thenTo(startingPageControlFrame, at: viewportSize.width * 5.0)
            .withAction(vc.pageControl.twc_slidingFrameActionWithScrollView(scrollView))
    }
    
    private static func describeBackgroundWithVC(vc: TutorialViewController, tweenController: TweenController, scrollView: UIScrollView) {
        describeStarGradientWithVC(vc, tweenController: tweenController, scrollView: scrollView)
        describeStarsWithVC(vc, tweenController: tweenController, scrollView: scrollView)
        describeEiffelTowerWithVC(vc, tweenController: tweenController, scrollView: scrollView)
    }
    
    private static func describeStarGradientWithVC(vc: TutorialViewController, tweenController: TweenController, scrollView: UIScrollView) {
        let viewportFrame = CGRect(origin: CGPointZero, size: vc.containerView.frame.size)
        let topColor = UIColor(red: 155.0/255.0, green: 39.0/255.0, blue: 153.0/255.0, alpha: 1.0)
        let bottomColor = UIColor(red: 38.0/255.0, green: 198.0/255.0, blue: 218.0/255.0, alpha: 1.0)
        let gradientLayer = CAGradientLayer()
        let gradientView = UIView(frame: viewportFrame.offsetBy(dx: viewportFrame.width, dy: 0.0))
        
        gradientLayer.colors = [bottomColor.CGColor, topColor.CGColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.frame = viewportFrame
        gradientView.backgroundColor = UIColor.clearColor()
        gradientView.layer.addSublayer(gradientLayer)
        gradientView.alpha = 0.0
        scrollView.insertSubview(gradientView, belowSubview: vc.pageControl)
        
        tweenController.tweenFrom(viewportFrame, at: viewportFrame.width)
            .thenHoldUntil(viewportFrame.width * 3.0)
            .withAction(gradientView.twc_slidingFrameActionWithScrollView(scrollView))
        
        tweenController.tweenFrom(gradientView.alpha, at: viewportFrame.width)
            .to(1.0, at: viewportFrame.width * 2.0)
            .thenTo(0.0, at: viewportFrame.width * 3.0)
            .withAction(gradientView.twc_applyAlpha)
    }
    
    private static func describeStarsWithVC(vc: TutorialViewController, tweenController: TweenController, scrollView: UIScrollView) {
        let viewportSize = vc.containerView.frame.size
        let xOffset = (viewportSize.width-starsSize.width)/2.0
        let starsFrame = CGRect(x: xOffset, y: 0.0, width: starsSize.width, height: starsSize.height)
        let starsImageView = UIImageView(image: UIImage(named: "stars"))
        
        starsImageView.frame = starsFrame.offsetBy(dx: viewportSize.width, dy: 0.0)
        starsImageView.alpha = 0.0
        starsImageView.contentMode = .ScaleToFill
        scrollView.insertSubview(starsImageView, belowSubview: vc.pageControl)
        
        tweenController.tweenFrom(starsFrame, at: viewportSize.width)
            .thenHoldUntil(viewportSize.width * 3.0)
            .withAction(starsImageView.twc_slidingFrameActionWithScrollView(scrollView))
        
        tweenController.tweenFrom(starsImageView.alpha, at: viewportSize.width)
            .to(1.0, at: viewportSize.width * 2.0)
            .thenTo(0.0, at: viewportSize.width * 3.0)
            .withAction(starsImageView.twc_applyAlpha)
    }
    
    private static func describeEiffelTowerWithVC(vc: TutorialViewController, tweenController: TweenController, scrollView: UIScrollView) {
        let viewportFrame = CGRect(origin: CGPointZero, size: vc.containerView.frame.size)
        let imageView = UIImageView(image: UIImage(named: "eiffel_tower"))
        imageView.frame = viewportFrame.offsetBy(dx: viewportFrame.width * 2.0, dy: 0.0)
        imageView.alpha = 0.0
        scrollView.addSubview(imageView)
        
        tweenController.tweenFrom(viewportFrame, at: viewportFrame.width * 2.0)
            .thenHoldUntil(viewportFrame.width * 4.0)
            .withAction(imageView.twc_slidingFrameActionWithScrollView(scrollView))
        
        tweenController.tweenFrom(imageView.alpha, at: viewportFrame.width * 2.0)
            .to(1.0, at: viewportFrame.width * 3.0)
            .thenHoldUntil(viewportFrame.width * 4.0)
            .thenTo(0.0, at: viewportFrame.width * 5.0)
            .withAction(imageView.twc_applyAlpha)
    }
    
    private static func describeTextWithVC(vc: TutorialViewController, tweenController: TweenController, scrollView: UIScrollView) {
        let viewportFrame = CGRect(origin: CGPointZero, size: vc.containerView.frame.size)
        let multiplier = viewportFrame.width / baselineScreenWidth
        let topYOffset = 50 * multiplier
        let bottomYOffset = 80 * multiplier
        
        let topView1 = UIImageView(image: UIImage(named: "top_copy_s2"))
        let topView2 = UIImageView(image: UIImage(named: "top_copy_s3"))
        let topView3 = UIImageView(image: UIImage(named: "top_copy_s4"))
        let topView4 = UIImageView(image: UIImage(named: "top_copy_s5"))
        
        let bottomView1 = UIImageView(image: UIImage(named: "bottom_copy_s2"))
        let bottomView2 = UIImageView(image: UIImage(named: "bottom_copy_s3"))
        let bottomView3 = UIImageView(image: UIImage(named: "bottom_copy_s4"))
        let bottomView4 = UIImageView(image: UIImage(named: "bottom_copy_s5"))
        
        let bottomViews = [bottomView1, bottomView2, bottomView3, bottomView4]
        for i in 0..<bottomViews.count {
            let view = bottomViews[i]
            let size = CGSize(width: view.image!.size.width * multiplier, height: view.image!.size.height * multiplier)
            let xOffset = (viewportFrame.width - size.width) / 2.0
            view.frame = CGRect(x: CGFloat(i + 1) * viewportFrame.width + xOffset, y: bottomYOffset, width: size.width, height: size.height)
            scrollView.addSubview(view)
        }
        
        let topViews = [topView1, topView2, topView3, topView4]
        for i in 0..<topViews.count {
            let view = topViews[i]
            let size = CGSize(width: view.image!.size.width * multiplier, height: view.image!.size.height * multiplier)
            let xOffset = (viewportFrame.width - size.width) / 2.0 + viewportFrame.width
            view.frame = CGRect(x: xOffset, y: topYOffset, width: size.width, height: size.height)
            scrollView.addSubview(view)
            
            if i != 0 {
                view.alpha = 0.0
                let progress = CGFloat(i) * viewportFrame.width
                tweenController.tweenFrom(view.alpha, at: progress)
                    .to(1.0, at: progress + viewportFrame.width)
                    .thenTo(0.0, at: progress + viewportFrame.width * 2.0)
                    .withAction(view.twc_applyAlpha)
            } else {
                tweenController.tweenFrom(view.alpha, at: viewportFrame.width)
                    .to(0.0, at: viewportFrame.width * 2.0)
                    .withAction(view.twc_applyAlpha)
            }
            
            tweenController.tweenFrom(view.frame, at: 0.0)
                .to(view.frame.offsetBy(dx: -viewportFrame.width, dy: 0.0), at: viewportFrame.width)
                .thenHoldUntil(viewportFrame.width * 4.0)
                .withAction(view.twc_slidingFrameActionWithScrollView(scrollView))
        }
        
        // reset at the end
        tweenController.observeForwardBoundary(scrollView.contentSize.width - viewportFrame.width) { [weak topView1] in
            topView1?.alpha = 1.0
        }
    }
    
    //MARK: Observers
    
    private static func observeEndOfScrollView(vc: TutorialViewController, tweenController: TweenController, scrollView: UIScrollView) {
        let viewSize = vc.containerView.bounds.size
        tweenController.observeForwardBoundary(scrollView.contentSize.width - viewSize.width) { [weak scrollView, weak vc, weak tweenController] in
            scrollView?.contentOffset = CGPointZero
            scrollView?.scrollEnabled = false
            scrollView?.scrollEnabled = true
            tweenController?.resetProgress()
            vc?.pageControl.currentPage = 0
        }
    }
}
