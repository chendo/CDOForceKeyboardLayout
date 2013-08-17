# CDOForceKeyboardLayout

Ever needed to implement a 'Force Keyboard Layout' feature for your OSX application? Look no further!

This small library will handle saving the user's desired keyboard layout, as well as KVC-support so
you can bind the available layouts to a `NSPopUpButton`

Please note that this is my first attempt at a library. Comments and criticisms very much appreciated!

Only tested on 10.8, but should work for 10.7 at the very least.

## Instructions

### Setup

* Add source files, either manually or with CocoaPods (once the Podfile has been added)
* Link Carbon.framework if you're doing it manually

### Preferences view

In the preferences nib or where you want to create the `NSPopUpButton` for users to pick what layout to force:

* Drag in an `NSObject`, set the class to `CDOForceKeyboardLayoutController`
* Drag in an `NSArrayController`, name it `Available Keyboard Layouts Controller` or something similar
* Drag the `NSPopUpButton` to your desired location
* In the `NSArrayController`:
  * In the Bindings panel, Bind the `Content Array` to the `Force Keyboard Layout Controller`, and set the `Model Key Path` to `self.availableKeyboardLayouts`
  * In the Attributes panel, set the `Class Name` in the `Object Controller` section to `CDOKeyboardLayout`
* In the `NSPopUpButton` Bindings panel:
  * Bind the `Content` to `Available Keyboard Layouts Controller`
  * Bind the `Content Values` to `Available Keyboard Layouts Controller`:
    * Set the `Model Key Path` to `label`
    * Check the `Inserts Null Placeholder` box
    * Set the `Null Placeholder` to whatever value you desire
  * Bind the `Selected Object` to `Force Keyboard Layout Controller`:
    * Set the `Model Key Path` to `self.forceKeyboardLayout`

And that should be it! Let me know if you have difficulty with this. Please also refer to the Demo app that's within the project.

## License

MIT. See `LICENSE` for more details.
