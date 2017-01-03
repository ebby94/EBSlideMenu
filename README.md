# EBSlideMenu
EBSlideMenu is a simple UIView subclass which let's you create a side menu or a slider. EBSliderMenu supports all 4 direction swipe. 
## Installation
Just drag and drop the EBSlider class into your project and you're good to go!
## Usage
- Create an instance of EBSlideMenu with the view that will be loaded as a side menu
```swift
  //let yourView = UIView()
  let slider = EBSlideMenu(view: yourView)
 ```
- You can set the direction of the slider. The default is `.left`
```swift
slider.requiredSlideDirection
``` 
- Available directions are,
```swift
    enum SlideDirection{
        case left
        case right
        case top
        case bottom
    }
```
- Add a Pan gesture recognized to your view and pass the gesture to the slider when pan gesture selector is triggered

```swift
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.panBegan(_:)))
        view.addGestureRecognizer(panGesture)
    }
    
    func panBegan(_ gesture:UIPanGestureRecognizer){
        slider.userBeganSwipe(gesture: gesture)
    }
```
- Don't forget to add the slider as a subview to either the window or the main view!
- You can also display/dismiss the slider without pan gesture
```swift
        slider.slideViewToMaximum()
        slider.resetSlider()
```

## Author
Ebinson, ebinson.dhas@gmail.com
## License
EBSlider is available under the MIT license. See the LICENSE file for more info.
