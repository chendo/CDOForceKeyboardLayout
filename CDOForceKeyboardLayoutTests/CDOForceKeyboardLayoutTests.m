/*
 * This file is part of the CDOForceKeyboardLayout package.
 * (c) 2013 Jack Chen (chendo)
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "CDOForceKeyboardLayoutTests.h"

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
    TISInputSourceRef layout = (__bridge TISInputSourceRef)[controller availableKeyboardLayouts][0];
    [controller setForceKeyboardLayout:layout];
    
    TISInputSourceRef loadedLayout = [controller forceKeyboardLayout];
    STAssertTrue(CFEqual(layout, loadedLayout), @"Loaded layout matches saved layout");
}

- (void)testForcingLayoutAndRestoringLayout
{
    TISInputSourceRef originalLayout = TISCopyCurrentKeyboardInputSource();
        TISInputSourceRef layoutToForce = (__bridge TISInputSourceRef)[[controller availableKeyboardLayouts] lastObject];

    [controller setForceKeyboardLayout:layoutToForce];
    [controller activate];
    
    TISInputSourceRef currentLayout = TISCopyCurrentKeyboardInputSource();
    
    STAssertTrue(CFEqual(currentLayout, layoutToForce), @"Active layout set to forced layout");
    
    CFRelease(currentLayout);
    [controller deactivate];
    currentLayout = TISCopyCurrentKeyboardInputSource();
    
    STAssertTrue(CFEqual(originalLayout, currentLayout), @"Restored original layout");
    
    CFRelease(currentLayout);
}

@end
