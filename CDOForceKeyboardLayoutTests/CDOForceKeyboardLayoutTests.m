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
    TISInputSourceRef preTestLayout;
}
@end

@implementation CDOForceKeyboardLayoutTests

- (void)setUp
{
    [super setUp];
    
    preTestLayout = TISCopyCurrentKeyboardInputSource();
    controller = [[CDOForceKeyboardLayoutController alloc] init];
}

- (void)tearDown
{
    [super tearDown];
    
    TISSelectInputSource(preTestLayout);
}

- (void)testListLayouts
{
    NSArray *layouts = [controller availableKeyboardLayouts];
    STAssertTrue(layouts != nil, @"Layouts should not be nil");
}

- (void)testSavingLayout
{
    CDOKeyboardLayout *layout = [controller availableKeyboardLayouts][0];
    controller.forceKeyboardLayout = layout;

    NSString *inputSourceID = [[NSUserDefaults standardUserDefaults] objectForKey:kCDOForceKeyboardLayoutDefaultsKey];
    
    STAssertEqualObjects(inputSourceID, layout.inputSourceID, @"Saves inputSourceID to UserDefaults");
}

- (void)testLoadingLayout
{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kCDOForceKeyboardLayoutDefaultsKey];
    
    STAssertNil(controller.forceKeyboardLayout, @"Layout should be nil");
    
    CDOKeyboardLayout *layout = [controller availableKeyboardLayouts][0];

    [[NSUserDefaults standardUserDefaults] setObject:layout.inputSourceID forKey:kCDOForceKeyboardLayoutDefaultsKey];
    
    STAssertNotNil(controller.forceKeyboardLayout, @"Layout should not be nil");
    STAssertEqualObjects(layout.inputSourceID, controller.forceKeyboardLayout.inputSourceID, @"Layout is loaded from defaults");

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

- (void)testMultipleInstances
{
    CDOForceKeyboardLayoutController *secondController = [[CDOForceKeyboardLayoutController alloc] init];
    
    STAssertEqualObjects(controller.forceKeyboardLayout, secondController.forceKeyboardLayout, @"Same layout across multiple controllers");
    
    NSUInteger randomIndex = arc4random_uniform(controller.availableKeyboardLayouts.count);
    controller.forceKeyboardLayout = controller.availableKeyboardLayouts[randomIndex];

    STAssertEqualObjects(controller.forceKeyboardLayout, secondController.forceKeyboardLayout, @"Same layout across multiple controllers");
}

@end
