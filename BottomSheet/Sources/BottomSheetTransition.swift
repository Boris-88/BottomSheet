//
//  BottomSheetTransition.swift
//  BottomSheet
//
//  Created by Boris Zverik on 18.05.2024.
//

import UIKit

public final class BottomSheetTransition: NSObject {
    public var backgraundEfect: BackgraundEfect = .blure
    public var prefersGrabberVisible: Bool = false
    public var cornerRadius: CGFloat = 24
    public var dismissThreshold: CGFloat = 0.3
    public var animationDuration: TimeInterval = 0.75
    public var maxLifting: CGFloat = 0.85
    
    private(set) var animateTransition = Animator()
}

// MARK: - BottomSheetTransitionDelegate
extension BottomSheetTransition: BottomSheetTransitionDelegate {
    public func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        return PresentationController(
            forPresented: presented,
            presenting: presenting,
            backgraundEfect: backgraundEfect,
            prefersGrabberVisible: prefersGrabberVisible,
            dismissThreshold: dismissThreshold,
            cornerRadius: cornerRadius,
            maxLifting: maxLifting
        )
    }
    
    public func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        animateTransition.isPresenting = true
        animateTransition.wantsInteractiveStart = false
        return animateTransition
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animateTransition.animationDuration = animationDuration
        animateTransition.isPresenting = false
        return animateTransition
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        animateTransition.animationDuration = animationDuration
        animateTransition.isPresenting = false
        return animateTransition
    }
}
