//
//  Animator.swift
//  BottomSheet
//
//  Created by Boris Zverik on 18.05.2024.
//

import UIKit

final class Animator: UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning {
    
    var isPresenting = true
    var animationDuration: TimeInterval = 0.75
    private var dismissAnimator: UIViewPropertyAnimator?
    private var presentationAnimator: UIViewPropertyAnimator?
 
    var dismissFractionComplete: CGFloat {
        dismissAnimator?.fractionComplete ?? .zero
    }

    func transitionDuration(using context: UIViewControllerContextTransitioning?) -> TimeInterval {
        animationDuration
    }

    func animateTransition(using context: UIViewControllerContextTransitioning) {
        interruptibleAnimator(using: context).startAnimation()
    }

    func interruptibleAnimator(using context: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        return isPresenting
            ? presentationAnimator ?? presentationInterruptibleAnimator(using: context)
            : dismissAnimator ?? dismissInterruptibleAnimator(using: context)
    }
    
    private func presentationInterruptibleAnimator(using context: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        guard let toViewController = context.viewController(forKey: .to), let toView = context.view(forKey: .to) else {
            return UIViewPropertyAnimator()
        }
        
        let animator = UIViewPropertyAnimator(duration: transitionDuration(using: context), dampingRatio: 0.9)
        presentationAnimator = animator
        toView.frame = context.finalFrame(for: toViewController)
        toView.frame.origin.y = context.containerView.frame.maxY
        context.containerView.addSubview(toView)
        
        animator.addAnimations {
            toView.frame = context.finalFrame(for: toViewController)
        }
        animator.addCompletion { position in
            if case .end = position {
                context.completeTransition(!context.transitionWasCancelled)
                return
            }
            context.completeTransition(false)
        }
        animator.addCompletion { [weak self] _ in
            self?.presentationAnimator = nil
        }
        return animator
    }
    
    private func dismissInterruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        guard let fromView = transitionContext.view(forKey: .from) else { return UIViewPropertyAnimator() }
        let animator = UIViewPropertyAnimator(duration: transitionDuration(using: transitionContext), dampingRatio: 0.9)
        
        dismissAnimator = animator
        
        animator.addAnimations {
            fromView.frame.origin.y = fromView.frame.maxY
        }
        animator.addCompletion { position in
            if case .end = position {
                fromView.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                return
            }
            transitionContext.completeTransition(false)
        }
        
        animator.addCompletion { [weak self] _ in
            self?.dismissAnimator = nil
            self?.isPresenting = true
            self?.wantsInteractiveStart = false
        }
        return animator
    }
}

