# KDKit
 
A Swift iOS library for the development of mobile audio applications. Wraps and extends AudioKit and libPD, and provides interface components, all governed by an API designed to be simple and accessible.

```
KDKIt is under HEAVY development, but a more complete,  
usable version is on its way. In the meantime, here are  
some examples of how KDKit works.
```

### A Simple Piano App Example
The following creates a complete (UI and Audio) fullscreen piano/keyboard app.

<img src="https://raw.githubusercontent.com/justKD/KDKit/master/example_images/1_keyboard_app_code.png" alt="drawing" width="600" />

<img src="https://raw.githubusercontent.com/justKD/KDKit/master/example_images/2_keyboard_app_image.png" alt="drawing" width="600" />

### Create a ScrollView
Simply add content and KDScrollView handles the rest.

<img src="https://raw.githubusercontent.com/justKD/KDKit/master/example_images/3_scrollview_code.png" alt="drawing" width="600" />

### Add Gesture Recognition
KDViews own methods for adding and managing their own gesture recognition.

<img src="https://raw.githubusercontent.com/justKD/KDKit/master/example_images/4_addtap_code.png" alt="drawing" width="600" />

Add multiple types and easily test for different gestures.

<img src="https://raw.githubusercontent.com/justKD/KDKit/master/example_images/5_testforgesture_code.png" alt="drawing" width="600" />

### Motion
A few lines of code is all it takes to add and retrieve filtered, normalized motion data.

<img src="https://raw.githubusercontent.com/justKD/KDKit/master/example_images/6_motion_code.png" alt="drawing" width="600" />

### Animation
KDKit also includes an animation scripting syntax and a growing library of pre-built animations.

<img src="https://raw.githubusercontent.com/justKD/KDKit/master/example_images/7_animation_code.png" alt="drawing" width="600" />

### Pure Data and libPD

Adding and using Pure Data patches has never been easier...
<img src="https://raw.githubusercontent.com/justKD/KDKit/master/example_images/8_pd_code.png" alt="drawing" width="600" />

<img src="https://raw.githubusercontent.com/justKD/KDKit/master/example_images/9_pd_code.png" alt="drawing" width="600" />

### AudioKit
... and neither has creating and managing an orchestra of AudioKit instruments.

<img src="https://raw.githubusercontent.com/justKD/KDKit/master/example_images/10_audiokit.png" alt="drawing" width="600" />

### Plist
Quickly and easily manage simple persistent state without the hassle of Core Data. KDPlist exposes a simple API for creating basic persistent data stores.

<img src="https://raw.githubusercontent.com/justKD/KDKit/master/example_images/11_plist_code.png" alt="drawing" width="650" />