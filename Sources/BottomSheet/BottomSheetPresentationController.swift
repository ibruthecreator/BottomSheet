#if canImport(UIKit)
import UIKit

public final class BottomSheetPresentationController: UIPresentationController {
    
    private lazy var dimmingView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .systemUltraThinMaterial)
        let view = UIVisualEffectView(effect: effect)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        view.addGestureRecognizer(gesture)
        return view
    }()
        
    private lazy var panGesture: UIPanGestureRecognizer = {
        UIPanGestureRecognizer(target: self, action: #selector(drag(_:)))
    }()
    
    private var presentedViewCenter: CGPoint = .zero
    
    public override var frameOfPresentedViewInContainerView: CGRect {
        switch sheetSizingStyle {
            case .adaptive: return adaptiveFrame
            case .toSafeAreaTop: return toSafeAreaTopFrame
            case .fixed(let height): return fixedFrame(height)
        }
    }
    
    private var adaptiveFrame: CGRect {
        guard let containerView = containerView, let presentedView = presentedView else { return .zero }
        
        let safeAreaFrame = containerView.bounds.inset(by: containerView.safeAreaInsets)
        
        let targetWidth = safeAreaFrame.width
        // Fitting size for auto layout
        let fittingSize = CGSize(width: targetWidth, height: UIView.layoutFittingCompressedSize.height)
        var targetHeight = presentedView.systemLayoutSizeFitting(fittingSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .defaultLow).height
        
        // Get content size of scrollable content
        targetHeight += getContentSize(of: presentedView).height
        
        // Add the bottom safe area inset
        targetHeight += containerView.safeAreaInsets.bottom
        
        var frame = safeAreaFrame
        frame.origin.y += frame.size.height - targetHeight
        frame.size.width = targetWidth
        frame.size.height = targetHeight
        
        if frame.height > toSafeAreaTopFrame.height {
            return toSafeAreaTopFrame
        }
        
        presentedView.scrollView?.isScrollEnabled = false
        return frame
    }
    
    private var toSafeAreaTopFrame: CGRect {
        guard let containerView = containerView else { return .zero }
        
        let safeAreaFrame = containerView.bounds.inset(by: containerView.safeAreaInsets)
        let targetWidth = safeAreaFrame.width
        
        var frame = safeAreaFrame
        frame.origin.y += containerView.safeAreaInsets.bottom
        frame.size.width = targetWidth
        return frame
    }
    
    private func fixedFrame(_ height: CGFloat) -> CGRect {
        guard let containerView = containerView else { return .zero }
        
        let safeAreaFrame = containerView.bounds.inset(by: containerView.safeAreaInsets)
        let targetWidth = safeAreaFrame.width
        
        var frame = safeAreaFrame
        frame.origin.y += containerView.safeAreaInsets.bottom
        frame.size.width = targetWidth
        frame.size.height = height
        
        if frame.height > toSafeAreaTopFrame.height {
            return toSafeAreaTopFrame
        }
        return frame
    }
    
    /// The style of the bottom sheet
    var sheetSizingStyle: BottomSheetView.SheetSizingStyle {
        guard let presentedController = presentedViewController as? BottomSheetViewController else { return .toSafeAreaTop }
        return presentedController.sheetSizingStyle
    }
    
    public init(presentedViewController: BottomSheetViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }
    
    public override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        
        guard let presentedView = presentedView else { return }
        
        presentedView.isUserInteractionEnabled = true
        
        if !(presentedView.gestureRecognizers?.contains(panGesture) ?? false) {
            presentedView.addGestureRecognizer(panGesture)
        }
    }
    
    public override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        
        guard let presenterView = containerView else { return }
        guard let presentedView = presentedView else { return }
        
        let newFrame = frameOfPresentedViewInContainerView
        presentedView.frame = newFrame
                
        let gap = presenterView.bounds.height - newFrame.height
        presentedView.center = CGPoint(x: presenterView.center.x, y: presenterView.center.y + gap / 2)
        presentedViewCenter = presentedView.center
        
        dimmingView.frame = presenterView.bounds
    }
    
    public override func presentationTransitionWillBegin() {
        dimmingView.alpha = 0
        
        guard let presenterView = containerView else { return }
        presenterView.addSubview(dimmingView)
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] context in
            self?.dimmingView.alpha = 1
        }, completion: nil)
    }
        
    public override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] context in
            self?.dimmingView.alpha = 0
        }, completion: { [weak self] context in
            self?.dimmingView.removeFromSuperview()
        })
    }
    
    private func getContentSize(of view: UIView) -> CGSize {
        view.tableView?.contentSize ?? view.scrollView?.contentSize ?? .zero
    }
            
    @objc private func dismiss() {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
    
    @objc private func drag(_ gesture: UIPanGestureRecognizer) {
        guard let presentedView = presentedView, let presenterView = containerView else { return }
        
        switch gesture.state {
            case .changed:
                presentingViewController.view.bringSubviewToFront(presentedView)
                let translation = gesture.translation(in: presentingViewController.view)
                let y = presentedView.center.y + translation.y
                
                let gap = presenterView.bounds.height - presentedView.frame.height
                let shouldBounce = y - gap / 2 > presentingViewController.view.center.y
                
                if shouldBounce {
                    presentedView.center = CGPoint(x: presentedView.center.x, y: y)
                }
                
                gesture.setTranslation(.zero, in: presentingViewController.view)
            case .ended:
                let height = presentingViewController.view.frame.height
                let position = presentedView.convert(presentingViewController.view.frame, to: nil).origin.y
                
                let velocity = gesture.velocity(in: presentedView)
                let targetVelocityHeight = presentedView.frame.height * 2
                let targetDragHeight = presentedView.frame.height * 3 / 4
                
                if velocity.y > targetVelocityHeight || height - position < targetDragHeight {
                    dismiss()
                } else {
                    restorePosition()
                    restoreDimming()
                }
                
                gesture.setTranslation(.zero, in: presentingViewController.view)
            default:
                break
        }
    }
    
    private func restorePosition() {
        guard let presentedView = presentedView else { return }
        
        UIView.animate(withDuration: 0.25) { [weak self] in
            guard let self = self else { return }
            presentedView.center = self.presentedViewCenter
        }
    }
    
    private func restoreDimming() {
        UIView.animate(withDuration: 0.25) { [weak self] in
            guard let self = self else { return }
            self.dimmingView.alpha = 1.0
        }
    }
    
    private func normalize<T: FloatingPoint>(value: T, min: T, max: T) -> T {
        (value - min) / (max - min)
    }
    
}

private extension UIView {
    
    var tableView: UITableView? {
        self as? UITableView ?? subviews.first(where: { $0 is UITableView }) as? UITableView
    }
    
    var scrollView: UIScrollView? {
        self as? UIScrollView ?? subviews.first(where: { $0 is UIScrollView }) as? UIScrollView
    }
    
}
#endif
