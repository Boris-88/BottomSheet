//
//  PresentationController.swift
//  BottomSheet
//
//  Created by Boris Zverik on 18.05.2024.
//

import UIKit

final class PresentationController: UIPresentationController {

    private var backgraundEfect: BackgraundEfect
    private var prefersGrabberVisible: Bool
    private var cornerRadius: CGFloat
    private var dismissThreshold: CGFloat
    private let maxLifting: CGFloat
   
    init(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        backgraundEfect: BackgraundEfect,
        prefersGrabberVisible: Bool,
        dismissThreshold: CGFloat,
        cornerRadius: CGFloat,
        maxLifting: CGFloat
    ) {
        self.backgraundEfect = backgraundEfect
        self.prefersGrabberVisible = prefersGrabberVisible
        self.dismissThreshold = dismissThreshold
        self.cornerRadius = cornerRadius
        self.maxLifting = maxLifting
        super.init(presentedViewController: presented, presenting: presenting)
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView, let presentedView = presentedView else {
            return super.frameOfPresentedViewInContainerView
        }
        let maximumHeight = (containerView.frame.height - containerView.safeAreaInsets.top - containerView.safeAreaInsets.bottom) * maxLifting
        let fittingSize = CGSize(width: containerView.bounds.width, height: UIView.layoutFittingCompressedSize.height)
        let presentedViewHeight = presentedView.systemLayoutSizeFitting(
            fittingSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
        
        let targetHeight = presentedViewHeight == .zero ? maximumHeight : presentedViewHeight
        let adjustedHeight = min(targetHeight, maximumHeight) + containerView.safeAreaInsets.bottom
        let targetSize = CGSize(width: containerView.frame.width, height: adjustedHeight)
        let targetOrigin = CGPoint(x: .zero, y: containerView.frame.maxY - targetSize.height)
        
        return CGRect(origin: targetOrigin, size: targetSize)
    }
    
    private var presentedScrollView: UIScrollView? {
        return presentedView?.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView
    }
    
    private var transitioningDelegate: BottomSheetTransition? {
        presentedViewController.transitioningDelegate as? BottomSheetTransition
    }
    
    private lazy var backgroundView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: nil)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedBackgroundView)))
        if backgraundEfect == .dimm {
            view.contentView.backgroundColor = .black.withAlphaComponent(0.75)
        }
        return view
    }()
    
    private lazy var grabberView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.frame.size = CGSize(width: 40, height: 4)
        return view
    }()
    
    private lazy var panGesture = UIPanGestureRecognizer(target: self, action: #selector(pannedPresentedView))
    
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        guard let presentedView, presentedView.frame.height != frameOfPresentedViewInContainerView.height else {
            return
        }
        UIView.animate(withDuration: 0.25, animations: {
                presentedView.frame = self.frameOfPresentedViewInContainerView
            }
        )
    }
   
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        containerView?.addSubview(backgroundView)
        presentedView?.addSubview(grabberView)
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] _ in
            guard let self = self else { return }
            self.presentedView?.layer.cornerRadius = cornerRadius
            if self.backgraundEfect == .blure {
                self.backgroundView.effect = UIBlurEffect(style: .regular)
            }
            if self.backgraundEfect == .dimm {
                self.backgroundView.contentView.alpha = 1
            }
        })
    }
    
    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        guard let presentedView = presentedView else { return }
        layoutAccessoryViews()
        setupPresentedViewInteraction()
        presentedView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        presentedViewController.additionalSafeAreaInsets.top = grabberView.frame.maxY
    }
    
    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] _ in
            guard let self = self else { return }
            self.presentedView?.layer.cornerRadius = .zero
            self.backgroundView.effect = nil
            self.backgroundView.contentView.alpha = 0
        })
    }
    
    private func layoutAccessoryViews() {
        guard let containerView, let presentedView else { return }
        backgroundView.frame = containerView.bounds
        grabberView.frame.origin.y = 8
        grabberView.center.x = presentedView.center.x
        grabberView.layer.cornerRadius = grabberView.frame.height / 2
        grabberView.isHidden = !prefersGrabberVisible
    }
    
    private func setupPresentedViewInteraction() {
        guard let presentedScrollView else {
            presentedView?.addGestureRecognizer(panGesture)
            return
        }
        presentedView?.layoutIfNeeded()
        if presentedScrollView.contentSize.height > presentedScrollView.frame.height {
            presentedScrollView.delegate = self
        } else {
            presentedView?.addGestureRecognizer(panGesture)
        }
    }
    
    private func dismiss(interactively isInteractive: Bool) {
        transitioningDelegate?.animateTransition.wantsInteractiveStart = isInteractive
        presentedViewController.dismiss(animated: true)
    }
    
    private func updateTransitionProgress(for translation: CGPoint) {
        guard let transitioningDelegate, let presentedView else { return }
        let adjustedHeight = presentedView.frame.height - translation.y
        let progress = 1 - (adjustedHeight / presentedView.frame.height)
        transitioningDelegate.animateTransition.update(progress)
    }
    
    private func handleEndedInteraction() {
        guard let transitioningDelegate else { return }
        if transitioningDelegate.animateTransition.dismissFractionComplete > dismissThreshold {
            transitioningDelegate.animateTransition.finish()
        } else {
            transitioningDelegate.animateTransition.cancel()
        }
    }
    
    @objc private func tappedBackgroundView() {
        dismiss(interactively: false)
    }
    
    @objc private func pannedPresentedView(_ recognizer: UIPanGestureRecognizer) {
        guard let presentedView, let containerView else { return }
        switch recognizer.state {
        case .began:
            dismiss(interactively: true)
        case .changed:
            guard presentedView.frame.maxY >= containerView.frame.maxY else { return }
            let translation = recognizer.translation(in: presentedView)
            updateTransitionProgress(for: translation)
        case .ended, .cancelled, .failed:
            handleEndedInteraction()
        case .possible: break
        default: break
        }
    }
}

// MARK: - UIScrollViewDelegate
extension PresentationController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard scrollView.contentOffset.y <= .zero else { return }
        dismiss(interactively: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let presentedView else { return }
        if scrollView.contentOffset.y < .zero {
            let originalOffset = CGPoint(x: scrollView.contentOffset.x, y: -scrollView.safeAreaInsets.top)
            scrollView.setContentOffset(originalOffset, animated: false)
        }
        
        let translation = scrollView.panGestureRecognizer.translation(in: presentedView)
        updateTransitionProgress(for: translation)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        handleEndedInteraction()
    }
}

