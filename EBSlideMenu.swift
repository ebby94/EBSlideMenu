//MIT License
//
//Copyright (c) 2016 ebby94
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.

import UIKit

class EBSlideMenu: UIView{
    
    private var initialTouchLocation : CGPoint!
    private var pointBuffer : Points!
    private var preferredSlideDirection = SlideDirection.left
    private var presentedView : UIView!
    private var slidePercentage : CGFloat = 0
    private let mainScreenHeight = UIScreen.main.bounds.height
    private let mainScreenWidth = UIScreen.main.bounds.width
    private var setPercentCompletion: CGFloat!{
        willSet{
            slidePercentage = newValue
            if newValue >= 100{
                backgroundColor = UIColor.init(white: 0, alpha: 0.3)
            }
            else{
                backgroundColor = UIColor.clear
            }
        }
    }
    var requiredSlideDirection : SlideDirection!{
        get{
            return preferredSlideDirection
        }
        set{
            preferredSlideDirection = newValue
            switch preferredSlideDirection{
            case .top:
                frame.origin.y = mainScreenHeight
                frame.origin.x = 0
                presentedView.frame.size.width = mainScreenWidth
                presentedView.frame.size.height = mainScreenHeight-mainScreenHeight/10
                presentedView.frame.origin.x = 0
                presentedView.frame.origin.y = mainScreenHeight/10
                break
            case .bottom:
                frame.origin.y = -mainScreenHeight
                frame.origin.x = 0
                presentedView.frame.size.width = mainScreenWidth
                presentedView.frame.size.height = mainScreenHeight-mainScreenHeight/10
                presentedView.frame.origin.x = 0
                presentedView.frame.origin.y = 0
                break
            case .left:
                frame.origin.x = mainScreenWidth
                frame.origin.y = 0
                presentedView.frame.size.width = mainScreenWidth-mainScreenWidth/6
                presentedView.frame.size.height = mainScreenHeight
                presentedView.frame.origin.x = mainScreenWidth/6
                presentedView.frame.origin.y = 0
                break
            case .right:
                frame.origin.x = -mainScreenWidth
                frame.origin.y = 0
                presentedView.frame.size.width = mainScreenWidth-mainScreenWidth/6
                presentedView.frame.size.height = mainScreenHeight
                presentedView.frame.origin.x = 0
                presentedView.frame.origin.y = 0
                break
            }
        }
    }
    
    init(view:UIView?) {
        let frame = CGRect(x: mainScreenWidth, y: 0, width: mainScreenWidth, height: mainScreenHeight)
        super.init(frame: frame)
        if view != nil{
            presentedView = view!
            presentedView.frame = CGRect(x: mainScreenWidth/6, y: 0, width: (mainScreenWidth-mainScreenWidth/6), height: mainScreenHeight)
            addSubview(presentedView)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit{
        presentedView.removeFromSuperview()
        presentedView = nil
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        resetSlider()
    }
    
    func userBeganSwipe(gesture:UIPanGestureRecognizer){
        if gesture.state == .began{
            initialTouchLocation = gesture.location(in: window)
            pointBuffer = Points.init(point: initialTouchLocation)
        }
        else{
            pointBuffer.addPoint(point: gesture.location(in: window))
        }
        if !shouldDisplaySlider() && !didPerformReverseSlide(){
            return
        }
        if gesture.state == .ended{
            if didPerformReverseSlide(){
                resetSlider()
                return
            }
            if slidePercentage >= 20{
                slideViewToMaximum()
            }
            else{
                resetSlider()
            }
            return
        }
        if isDirectionEnabled(gesture: gesture){
            let velocity = gesture.velocity(in: window)
            if preferredSlideDirection == .top || preferredSlideDirection == .bottom{
                if fabs(velocity.y) > 2000{
                    slideViewToMaximum()
                }
                else{
                    let location = gesture.location(in: window)
                    slideViewWithOffset(offset: location.y)
                }
            }
            else{
                if fabs(velocity.x) > 2000{
                    slideViewToMaximum()
                }
                else{
                    let location = gesture.location(in: window)
                    slideViewWithOffset(offset: location.x)
                }
            }
        }
        else{
            if slidePercentage > 0{
                if preferredSlideDirection == .top || preferredSlideDirection == .bottom{
                    let location = gesture.location(in: window)
                    slideViewWithOffset(offset: location.y)
                }
                else{
                    let location = gesture.location(in: window)
                    slideViewWithOffset(offset: location.x)
                }
            }
        }
    }
    
    func slideViewToMaximum(){
        initialTouchLocation = nil
        slideViewWithOffset(offset: 0)
    }
    
    func resetSlider(){
        initialTouchLocation = nil
        switch preferredSlideDirection {
        case .top:
            slideViewWithOffset(offset: mainScreenHeight)
        case .bottom:
            slideViewWithOffset(offset: -mainScreenHeight)
        case .left:
            slideViewWithOffset(offset: mainScreenWidth)
        case .right:
            slideViewWithOffset(offset: -mainScreenWidth)
        }
        backgroundColor = UIColor.clear
    }
    
    private func slideViewWithOffset(offset: CGFloat){
        var didSliderDismiss : Bool!
        if initialTouchLocation == nil{
            UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut], animations: { [unowned self] in
                if self.preferredSlideDirection == .top || self.preferredSlideDirection == .bottom{
                    self.frame.origin.y = offset
                    if self.preferredSlideDirection == .top{
                        didSliderDismiss = offset != 0 ? true : false
                    }
                    else{
                        didSliderDismiss = offset == -self.mainScreenHeight ? true : false
                    }
                }
                else{
                    self.frame.origin.x = offset
                    if self.preferredSlideDirection == .left{
                        didSliderDismiss = offset != 0 ? true : false
                    }
                    else{
                        didSliderDismiss = offset == -self.mainScreenWidth ? true : false
                    }
                }
                }, completion: { [unowned self] (finished) in
                    if finished{
                        if didSliderDismiss != nil && didSliderDismiss!{
                            self.setPercentCompletion = 0
                        }
                        else{
                            self.setPercentCompletion = 100
                        }
                    }
            })
            return
        }
        if self.preferredSlideDirection == .top || self.preferredSlideDirection == .bottom{
            if self.preferredSlideDirection == .top{
                self.frame.origin.y = offset
            }
            else{
                if offset != 0 && offset != -self.mainScreenHeight{
                    let newOffset = -self.mainScreenHeight + offset
                    self.frame.origin.y = newOffset
                }
                else{
                    self.frame.origin.y = offset
                }
            }
            let point = pointBuffer.lastPoint.y
            if preferredSlideDirection == .top{
                let difference = mainScreenHeight-point
                setPercentCompletion = difference/mainScreenHeight*100
            }
            else{
                let discardHeight = mainScreenHeight-point
                let difference = mainScreenHeight-discardHeight
                setPercentCompletion = difference/mainScreenHeight*100
            }
        }
        else{
            if self.preferredSlideDirection == .left{
                self.frame.origin.x = offset
            }
            else{
                if offset != 0 && offset != -self.mainScreenWidth{
                    let newOffset = -self.mainScreenWidth + offset
                    self.frame.origin.x = newOffset
                }
                else{
                    self.frame.origin.x = offset
                }
            }
            let point = pointBuffer.lastPoint.x
            if preferredSlideDirection == .left{
                let difference = mainScreenWidth-point
                setPercentCompletion = difference/mainScreenWidth*100
            }
            else{
                let discardWidth = mainScreenWidth-point
                let difference = mainScreenWidth-discardWidth
                setPercentCompletion = difference/mainScreenWidth*100
            }
        }
    }
    
    private func didPerformReverseSlide()->Bool{
        let firstPoint = pointBuffer.firstPoint
        let lastPoint = pointBuffer.lastPoint
        switch preferredSlideDirection{
        case .left:
            return lastPoint!.x > firstPoint!.x
        case .right:
            return lastPoint!.x < firstPoint!.x
        case .top:
            return lastPoint!.y > firstPoint!.y
        case .bottom:
            return lastPoint!.y < firstPoint!.y
        }
    }
    
    private func isDirectionEnabled(gesture:UIPanGestureRecognizer) -> Bool{
        let velocity = gesture.velocity(in: window)
        switch preferredSlideDirection{
        case .top:
            return fabs(velocity.y) > fabs(velocity.x) && velocity.y < 0
        case .bottom:
            return fabs(velocity.y) > fabs(velocity.x) && velocity.y > 0
        case .left:
            return fabs(velocity.y) < fabs(velocity.x) && velocity.x < 0
        case .right:
            return fabs(velocity.y) < fabs(velocity.x) && velocity.x > 0
        }
    }
    
    private func shouldDisplaySlider()->Bool{
        // Returns true if slider should not be displayed
        // If it's stupid but works, then it's not stupid :]
        if initialTouchLocation == nil{
            return true
        }
        let lastPoint = pointBuffer.lastPoint
        var constant = mainScreenWidth/7
        if preferredSlideDirection == .top || preferredSlideDirection == .bottom{
            constant = mainScreenHeight/13
        }
        switch preferredSlideDirection{
        case .left:
            return lastPoint!.x < initialTouchLocation!.x-constant
        case .right:
            return lastPoint!.x > initialTouchLocation!.x+constant
        case .top:
            return lastPoint!.y < initialTouchLocation!.y-constant
        case .bottom:
            return lastPoint!.y > initialTouchLocation!.y+constant
        }
    }
    
    private func getVelocity(velocity:CGPoint) -> CGFloat{
        if preferredSlideDirection == .top || preferredSlideDirection == .bottom{
            return fabs(velocity.y)
        }
        return fabs(velocity.x)
    }
}

extension EBSlideMenu{
    
    enum SlideDirection{
        case left
        case right
        case top
        case bottom
    }
    
    struct Points{
        var points:[CGPoint]!
        // Setting value less than 2 will result in weird behaviour
        let MAX_LIMIT = 3
        var firstPoint : CGPoint!{
            get{
                return points.first!
            }
            set{}
        }
        var lastPoint : CGPoint!{
            get{
                return points.last!
            }
            set{}
        }
        
        init(point:CGPoint) {
            points = [point]
        }
        
        mutating func addPoint(point:CGPoint){
            if points.count == MAX_LIMIT{
                points.removeFirst()
                points.append(point)
            }
            else{
                points.append(point)
            }
        }
    }
}
