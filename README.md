# BottomSheet 📱

**Customizable iOS Bottom Sheet Controller with Smooth Animations**

[![Swift 5.0+](https://img.shields.io/badge/Swift-5.0+-orange.svg)](https://swift.org)
[![iOS 13.0+](https://img.shields.io/badge/iOS-13.0+-blue.svg)](https://developer.apple.com/ios/)
[![MIT License](https://img.shields.io/badge/License-MIT-lightgrey.svg)](LICENSE)

## Features ✨

- 🎭 Smooth spring animations  
- 👆 Interactive dismissal gestures  
- 🖱 Scroll view integration  
- 🎨 Customizable appearance  
- 📳 Haptic feedback  
- 🟣 Background effects (blur/dim)  
- 🎚 Configurable corner radius  
- 🖐 Grabber handle with touch area  

## Installation 📦

### Swift Package Manager

Add to your `Package.swift`:
```swift
dependencies: [
    .package(url: "https://github.com/Boris-88/BottomSheet.git", from: "1.0.0")
]
```
# Bottom Sheet Implementation
A customizable bottom sheet component for iOS with smooth animations and interactive dismissal gestures.  
Key Components

## BottomSheetAnimateTransition  
Handles the presentation and dismissal animations for the bottom sheet.


- `animateTransition(using:)`  
*Initiates the transition animation using the interruptible animator.*

- `interruptibleAnimator(using:)`  
*Creates and returns a UIViewPropertyAnimator for interruptible transitions. Handles both presentation and dismissal animations.*

- `setupPresentationAnimations(animator:context:)`  
*Configures animations for presenting the bottom sheet (slides up from bottom).*

- `setupDismissalAnimations(animator:context:)`  
*Configures animations for dismissing the bottom sheet (slides down to bottom).*

- `update(_:)` &` cancel()`  
*Handle interactive transition updates and cancellation.*


## BottomSheetPresentationController  
Manages the presentation style and interactive behaviors.

- `frameOfPresentedViewInContainerView`:  
*Calculates the final frame for the presented view based on content size and maximum lifting height.*

- `animateBackground(show:duration:)`:  
*Animates the background dimming/blur effect during presentation/dismissal.*

- `updateBackgroundForInteractiveDismiss(progress:)`:  
*Updates background appearance during interactive dismissal.*

- `updateAppearanceForProgress(_:)`  
*Updates corner radius and grabber appearance during interaction.*


**Gesture Handlers:**
- `handlePanGesture(_:)`  
*Handles drag gestures for interactive dismissal.*

- `handleScrollViewPan(_:)`  
*Special handling for scroll views within the bottom sheet.*

- `handleGrabberPan(_:)`  
*Handles drag gestures on the grabber handle.*

## BottomSheetTransitionDelegate
The public interface for configuring the bottom sheet behavior.

**Protocol Methods:**
- `presentationController(forPresented:presenting:source:)`:  
*Creates and returns the custom presentation controller.*

- `animationController(forPresented:presenting:source:)`:  
*Returns the animator for presentation.*

- `animationController(forDismissed:)`:  
*Returns the animator for dismissal.*

# Configuration Options

| Parameter          | Type             | Default | Description                     |
|--------------------|------------------|---------|---------------------------------|
| `cornerRadius`     | `CGFloat`        | 24      | Top corner radius               |
| `backgraundEfect`  | `BackgraundEfect`| .blure  | Background visual effect        |
| `dismissThreshold` | `CGFloat`        | 0.3     | Dismiss completion threshold    |
| `maxLifting`       | `CGFloat`        | 0.85    | Maximum height percentage       |


