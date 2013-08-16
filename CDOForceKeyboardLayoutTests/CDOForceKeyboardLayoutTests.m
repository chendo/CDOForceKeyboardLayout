/*
 * This file is part of the CDOForceKeyboardLayout package.
 * (c) 2013 Jack Chen (chendo)
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "CDOForceKeyboardLayoutTests.h"
#import "CDOForceKeyboardLayoutController.h"
#import "CDOKeyboardLayout.h"

@interface CDOForceKeyboardLayoutTests () {
    CDOForceKeyboardLayoutController *controller;
}
@end

@implementation CDOForceKeyboardLayoutTests

- (void)setUp
{
    [super setUp];
    
    controller = [[CDOForceKeyboardLayoutController alloc] init];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testListLayouts
{
    NSArray *layouts = [controller availableKeyboardLayouts];
    STAssertTrue(layouts != nil, @"Layouts should not be nil");
}

- (void)testSavingAndLoadingLayouts
{
    CDOKeyboardLayout *layout = [controller availableKeyboardLayouts][0];
    [controller setForceKeyboardLayout:layout];
    
    CDOKeyboardLayout *loadedLayout = [controller forceKeyboardLayout];
    STAssertTrue([layout isEqual:loadedLayout], @"Loaded layout matches saved layout");
}

- (void)testForcingLayoutAndRestoringLayout
{
    TISInputSourceRef originalLayout = TISCopyCurrentKeyboardInputSource();
    CDOKeyboardLayout *layoutToForce = [[controller availableKeyboardLayouts] lastObject];

    [controller setForceKeyboardLayout:layoutToForce];
    [controller activate];
    
    TISInputSourceRef currentLayout = TISCopyCurrentKeyboardInputSource();
    
    STAssertTrue(CFEqual(currentLayout, layoutToForce.inputSource), @"Active layout set to forced layout");
    
    CFRelease(currentLayout);
    [controller deactivate];
    currentLayout = TISCopyCurrentKeyboardInputSource();
    
    STAssertTrue(CFEqual(originalLayout, currentLayout), @"Restored original layout");
    
    CFRelease(currentLayout);
}

@end
