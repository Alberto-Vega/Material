/*
 * Copyright (C) 2015 - 2016, Daniel Dahan and CosmicMind, Inc. <http://cosmicmind.io>.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *	*	Redistributions of source code must retain the above copyright notice, this
 *		list of conditions and the following disclaimer.
 *
 *	*	Redistributions in binary form must reproduce the above copyright notice,
 *		this list of conditions and the following disclaimer in the documentation
 *		and/or other materials provided with the distribution.
 *
 *	*	Neither the name of Material nor the names of its
 *		contributors may be used to endorse or promote products derived from
 *		this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import UIKit

@IBDesignable
@objc(MaterialCollectionReusableView)
open class MaterialCollectionReusableView : UICollectionReusableView, CAAnimationDelegate {
    /**
     A CAShapeLayer used to manage elements that would be affected by
     the clipToBounds property of the backing layer. For example, this
     allows the dropshadow effect on the backing layer, while clipping
     the image to a desired shape within the visualLayer.
     */
    open fileprivate(set) lazy var visualLayer: CAShapeLayer = CAShapeLayer()
    
    /**
     A base delegate reference used when subclassing MaterialView.
     */
    open weak var delegate: MaterialDelegate?
    
    /// An Array of pulse layers.
    open fileprivate(set) lazy var pulseLayers: Array<CAShapeLayer> = Array<CAShapeLayer>()
    
    /// The opcaity value for the pulse animation.
    @IBInspectable open var pulseOpacity: CGFloat = 0.25
    
    /// The color of the pulse effect.
    @IBInspectable open var pulseColor: UIColor = MaterialColor.grey.base
    
    /// The type of PulseAnimation.
    open var pulseAnimation: PulseAnimation = .atPointWithBacking {
        didSet {
            visualLayer.masksToBounds = .centerRadialBeyondBounds != pulseAnimation
        }
    }
    
    /**
     A property that manages an image for the visualLayer's contents
     property. Images should not be set to the backing layer's contents
     property to avoid conflicts when using clipsToBounds.
     */
    @IBInspectable open var image: UIImage? {
        didSet {
            visualLayer.contents = image?.cgImage
        }
    }
    
    /**
     Allows a relative subrectangle within the range of 0 to 1 to be
     specified for the visualLayer's contents property. This allows
     much greater flexibility than the contentsGravity property in
     terms of how the image is cropped and stretched.
     */
    @IBInspectable open var contentsRect: CGRect {
        get {
            return visualLayer.contentsRect
        }
        set(value) {
            visualLayer.contentsRect = value
        }
    }
    
    /**
     A CGRect that defines a stretchable region inside the visualLayer
     with a fixed border around the edge.
     */
    @IBInspectable open var contentsCenter: CGRect {
        get {
            return visualLayer.contentsCenter
        }
        set(value) {
            visualLayer.contentsCenter = value
        }
    }
    
    /**
     A floating point value that defines a ratio between the pixel
     dimensions of the visualLayer's contents property and the size
     of the view. By default, this value is set to the MaterialDevice.scale.
     */
    @IBInspectable open var contentsScale: CGFloat {
        get {
            return visualLayer.contentsScale
        }
        set(value) {
            visualLayer.contentsScale = value
        }
    }
    
    /// A Preset for the contentsGravity property.
    open var contentsGravityPreset: MaterialGravity {
        didSet {
            contentsGravity = MaterialGravityToValue(contentsGravityPreset)
        }
    }
    
    /// Determines how content should be aligned within the visualLayer's bounds.
    @IBInspectable open var contentsGravity: String {
        get {
            return visualLayer.contentsGravity
        }
        set(value) {
            visualLayer.contentsGravity = value
        }
    }
    
    /// A preset wrapper around contentInset.
    open var contentInsetPreset: MaterialEdgeInset {
        get {
            return grid.contentInsetPreset
        }
        set(value) {
            grid.contentInsetPreset = value
        }
    }
    
    /// A wrapper around grid.contentInset.
    @IBInspectable open var contentInset: UIEdgeInsets {
        get {
            return grid.contentInset
        }
        set(value) {
            grid.contentInset = value
        }
    }
    
    /// A preset wrapper around spacing.
    open var spacingPreset: MaterialSpacing = .none {
        didSet {
            spacing = MaterialSpacingToValue(spacingPreset)
        }
    }
    
    /// A wrapper around grid.spacing.
    @IBInspectable open var spacing: CGFloat {
        get {
            return grid.spacing
        }
        set(value) {
            grid.spacing = value
        }
    }
    
    /**
     This property is the same as clipsToBounds. It crops any of the view's
     contents from bleeding past the view's frame. If an image is set using
     the image property, then this value does not need to be set, since the
     visualLayer's maskToBounds is set to true by default.
     */
    @IBInspectable open var masksToBounds: Bool {
        get {
            return layer.masksToBounds
        }
        set(value) {
            layer.masksToBounds = value
        }
    }
    
    /// A property that accesses the backing layer's backgroundColor.
    @IBInspectable open override var backgroundColor: UIColor? {
        didSet {
            layer.backgroundColor = backgroundColor?.cgColor
        }
    }
    
    /// A property that accesses the layer.frame.origin.x property.
    @IBInspectable open var x: CGFloat {
        get {
            return layer.frame.origin.x
        }
        set(value) {
            layer.frame.origin.x = value
        }
    }
    
    /// A property that accesses the layer.frame.origin.y property.
    @IBInspectable open var y: CGFloat {
        get {
            return layer.frame.origin.y
        }
        set(value) {
            layer.frame.origin.y = value
        }
    }
    
    /**
     A property that accesses the layer.frame.size.width property.
     When setting this property in conjunction with the shape property having a
     value that is not .None, the height will be adjusted to maintain the correct
     shape.
     */
    @IBInspectable open var width: CGFloat {
        get {
            return layer.frame.size.width
        }
        set(value) {
            layer.frame.size.width = value
            if .none != shape {
                layer.frame.size.height = value
            }
        }
    }
    
    /**
     A property that accesses the layer.frame.size.height property.
     When setting this property in conjunction with the shape property having a
     value that is not .None, the width will be adjusted to maintain the correct
     shape.
     */
    @IBInspectable open var height: CGFloat {
        get {
            return layer.frame.size.height
        }
        set(value) {
            layer.frame.size.height = value
            if .none != shape {
                layer.frame.size.width = value
            }
        }
    }
    
    /// A property that accesses the backing layer's shadowColor.
    @IBInspectable open var shadowColor: UIColor? {
        didSet {
            layer.shadowColor = shadowColor?.cgColor
        }
    }
    
    /// A property that accesses the backing layer's shadowOffset.
    @IBInspectable open var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set(value) {
            layer.shadowOffset = value
        }
    }
    
    /// A property that accesses the backing layer's shadowOpacity.
    @IBInspectable open var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set(value) {
            layer.shadowOpacity = value
        }
    }
    
    /// A property that accesses the backing layer's shadowRadius.
    @IBInspectable open var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set(value) {
            layer.shadowRadius = value
        }
    }
    
    /// A property that accesses the backing layer's shadowPath.
    @IBInspectable open var shadowPath: CGPath? {
        get {
            return layer.shadowPath
        }
        set(value) {
            layer.shadowPath = value
        }
    }
    
    /// Enables automatic shadowPath sizing.
    @IBInspectable open var shadowPathAutoSizeEnabled: Bool = true {
        didSet {
            if shadowPathAutoSizeEnabled {
                layoutShadowPath()
            }
        }
    }
    
    /**
     A property that sets the shadowOffset, shadowOpacity, and shadowRadius
     for the backing layer. This is the preferred method of setting depth
     in order to maintain consitency across UI objects.
     */
    open var depth: MaterialDepth {
        didSet {
            let value: MaterialDepthType = MaterialDepthToValue(depth)
            shadowOffset = value.offset
            shadowOpacity = value.opacity
            shadowRadius = value.radius
            layoutShadowPath()
        }
    }
    
    /**
     A property that sets the cornerRadius of the backing layer. If the shape
     property has a value of .Circle when the cornerRadius is set, it will
     become .None, as it no longer maintains its circle shape.
     */
    open var cornerRadiusPreset: MaterialRadius {
        didSet {
            let v: MaterialRadius = cornerRadiusPreset
            cornerRadius = MaterialRadiusToValue(v)
        }
    }
    
    /// A property that accesses the layer.cornerRadius.
    @IBInspectable open var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set(value) {
            layer.cornerRadius = value
            layoutShadowPath()
            if .circle == shape {
                shape = .none
            }
        }
    }
    
    /**
     A property that manages the overall shape for the object. If either the
     width or height property is set, the other will be automatically adjusted
     to maintain the shape of the object.
     */
    open var shape: MaterialShape {
        didSet {
            if .none != shape {
                if width < height {
                    frame.size.width = height
                } else {
                    frame.size.height = width
                }
                layoutShadowPath()
            }
        }
    }
    
    /// A preset property to set the borderWidth.
    open var borderWidthPreset: MaterialBorder = .none {
        didSet {
            borderWidth = MaterialBorderToValue(borderWidthPreset)
        }
    }
    
    /// A property that accesses the layer.borderWith.
    @IBInspectable open var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set(value) {
            layer.borderWidth = value
        }
    }
    
    /// A property that accesses the layer.borderColor property.
    @IBInspectable open var borderColor: UIColor? {
        get {
            return nil == layer.borderColor ? nil : UIColor(cgColor: layer.borderColor!)
        }
        set(value) {
            layer.borderColor = value?.cgColor
        }
    }
    
    /// A property that accesses the layer.position property.
    @IBInspectable open var position: CGPoint {
        get {
            return layer.position
        }
        set(value) {
            layer.position = value
        }
    }
    
    /// A property that accesses the layer.zPosition property.
    @IBInspectable open var zPosition: CGFloat {
        get {
            return layer.zPosition
        }
        set(value) {
            layer.zPosition = value
        }
    }
    
    /**
     An initializer that initializes the object with a NSCoder object.
     - Parameter aDecoder: A NSCoder instance.
     */
    public required init?(coder aDecoder: NSCoder) {
        depth = .none
        cornerRadiusPreset = .none
        shape = .none
        contentsGravityPreset = .resizeAspectFill
        super.init(coder: aDecoder)
        prepareView()
    }
    
    /**
     An initializer that initializes the object with a CGRect object.
     If AutoLayout is used, it is better to initilize the instance
     using the init() initializer.
     - Parameter frame: A CGRect instance.
     */
    public override init(frame: CGRect) {
        depth = .none
        cornerRadiusPreset = .none
        shape = .none
        contentsGravityPreset = .resizeAspectFill
        super.init(frame: frame)
        prepareView()
    }
    
    /// A convenience initializer.
    public convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    open override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        if self.layer == layer {
            layoutShape()
            layoutVisualLayer()
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        layoutShadowPath()
    }
    
    /**
     A method that accepts CAAnimation objects and executes them on the
     view's backing layer.
     - Parameter animation: A CAAnimation instance.
     */
    open func animate(_ animation: CAAnimation) {
        animation.delegate = self
        if let a: CABasicAnimation = animation as? CABasicAnimation {
            a.fromValue = (layer.presentation() ?? layer).value(forKeyPath: a.keyPath!)
        }
        if let a: CAPropertyAnimation = animation as? CAPropertyAnimation {
            layer.add(a, forKey: a.keyPath!)
        } else if let a: CAAnimationGroup = animation as? CAAnimationGroup {
            layer.add(a, forKey: nil)
        } else if let a: CATransition = animation as? CATransition {
            layer.add(a, forKey: kCATransition)
        }
    }
    
    /**
     A delegation method that is executed when the backing layer starts
     running an animation.
     - Parameter anim: The currently running CAAnimation instance.
     */
    open func animationDidStart(_ anim: CAAnimation) {
        (delegate as? MaterialAnimationDelegate)?.materialAnimationDidStart?(anim)
    }
    
    /**
     A delegation method that is executed when the backing layer stops
     running an animation.
     - Parameter anim: The CAAnimation instance that stopped running.
     - Parameter flag: A boolean that indicates if the animation stopped
     because it was completed or interrupted. True if completed, false
     if interrupted.
     */
    open func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let a: CAPropertyAnimation = anim as? CAPropertyAnimation {
            if let b: CABasicAnimation = a as? CABasicAnimation {
                if let v: AnyObject = b.toValue as AnyObject? {
                    if let k: String = b.keyPath {
                        layer.setValue(v, forKeyPath: k)
                        layer.removeAnimation(forKey: k)
                    }
                }
            }
            (delegate as? MaterialAnimationDelegate)?.materialAnimationDidStop?(anim, finished: flag)
        } else if let a: CAAnimationGroup = anim as? CAAnimationGroup {
            for x in a.animations! {
                animationDidStop(x, finished: true)
            }
        }
    }
    
    /**
     Triggers the pulse animation.
     - Parameter point: A Optional point to pulse from, otherwise pulses
     from the center.
     */
    open func pulse(_ point: CGPoint? = nil) {
        let p: CGPoint = nil == point ? CGPoint(x: CGFloat(width / 2), y: CGFloat(height / 2)) : point!
        MaterialAnimation.pulseExpandAnimation(layer, visualLayer: visualLayer, pulseColor: pulseColor, pulseOpacity: pulseOpacity, point: p, width: width, height: height, pulseLayers: &pulseLayers, pulseAnimation: pulseAnimation)
        _ = MaterialAnimation.delay(0.35) { [weak self] in
            if let s: MaterialCollectionReusableView = self {
                MaterialAnimation.pulseContractAnimation(s.layer, visualLayer: s.visualLayer, pulseColor: s.pulseColor, pulseLayers: &s.pulseLayers, pulseAnimation: s.pulseAnimation)
            }
        }
    }
    
    /**
     A delegation method that is executed when the view has began a
     touch event.
     - Parameter touches: A set of UITouch objects.
     - Parameter event: A UIEvent object.
     */
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        MaterialAnimation.pulseExpandAnimation(layer, visualLayer: visualLayer, pulseColor: pulseColor, pulseOpacity: pulseOpacity, point: layer.convert(touches.first!.location(in: self), from: layer), width: width, height: height, pulseLayers: &pulseLayers, pulseAnimation: pulseAnimation)
    }
    
    /**
     A delegation method that is executed when the view touch event has
     ended.
     - Parameter touches: A set of UITouch objects.
     - Parameter event: A UIEvent object.
     */
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        MaterialAnimation.pulseContractAnimation(layer, visualLayer: visualLayer, pulseColor: pulseColor, pulseLayers: &pulseLayers, pulseAnimation: pulseAnimation)
    }
    
    /**
     A delegation method that is executed when the view touch event has
     been cancelled.
     - Parameter touches: A set of UITouch objects.
     - Parameter event: A UIEvent object.
     */
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        MaterialAnimation.pulseContractAnimation(layer, visualLayer: visualLayer, pulseColor: pulseColor, pulseLayers: &pulseLayers, pulseAnimation: pulseAnimation)
    }
    
    /**
     Prepares the view instance when intialized. When subclassing,
     it is recommended to override the prepareView method
     to initialize property values and other setup operations.
     The super.prepareView method should always be called immediately
     when subclassing.
     */
    open func prepareView() {
        contentScaleFactor = MaterialDevice.scale
        pulseAnimation = .none
        prepareVisualLayer()
    }
    
    /// Prepares the visualLayer property.
    internal func prepareVisualLayer() {
        visualLayer.zPosition = 0
        visualLayer.masksToBounds = true
        layer.addSublayer(visualLayer)
    }
    
    /// Manages the layout for the visualLayer property.
    internal func layoutVisualLayer() {
        visualLayer.frame = bounds
        visualLayer.cornerRadius = cornerRadius
    }
    
    /// Manages the layout for the shape of the view instance.
    internal func layoutShape() {
        if .circle == shape {
            let w: CGFloat = (width / 2)
            if w != cornerRadius {
                cornerRadius = w
            }
        }
    }
    
    /// Sets the shadow path.
    internal func layoutShadowPath() {
        if shadowPathAutoSizeEnabled {
            if .none == depth {
                shadowPath = nil
            } else if nil == shadowPath {
                shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
            } else {
                animate(MaterialAnimation.shadowPath(UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath, duration: 0))
            }
        }
    }
}
