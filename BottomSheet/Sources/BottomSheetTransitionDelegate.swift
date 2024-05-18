//
//  BottomSheetTransitionDelegate.swift
//  BottomSheet
//
//  Created by Boris Zverik on 18.05.2024.
//

import UIKit

/// Basic protocol for using Bottom sheet
public protocol BottomSheetTransitionDelegate: UIViewControllerTransitioningDelegate {
    /// Enum visual efect backgroundView
    var backgraundEfect: BackgraundEfect { get set }
    /// Parameter visible graber view
    var prefersGrabberVisible: Bool { get set }
    /// Corner radius  presenting view
    var cornerRadius: CGFloat { get set }
    /// Parameter user ineration swape view to trashhold, where 1 == 100%
    var dismissThreshold: CGFloat { get set }
    /// Animation duration TimiInterval to prsent/dismiss
    var animationDuration: TimeInterval { get set }
    /// Default lifting presenting view, where 1 == 100%
    var maxLifting: CGFloat { get set }
}

public enum BackgraundEfect: Int, CaseIterable {
    case blure
    case dimm
}


