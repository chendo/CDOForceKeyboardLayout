/*
 * This file is part of the CDOForceKeyboardLayout package.
 * (c) 2013 Jack Chen (chendo)
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "CDOForceKeyboardLayoutController.h"
#import "CDOKeyboardLayout.h"

@interface CDOForceKeyboardLayoutController () {
    TISInputSourceRef savedKeyboardLayout;
}

@end

@implementation CDOForceKeyboardLayoutController

static NSString* const kCDOForceKeyboardLayoutDefaultsKey = @"ForceKeyboardLayout";

- (instancetype)init {
    self = [super init];
    if (self) {
        savedKeyboardLayout = NULL;
        [self updateAvailableKeyboardLayouts];
    }
    return self;
}

- (void)setForceKeyboardLayout:(CDOKeyboardLayout *)layout
{
    [self willChangeValueForKey:@"forceKeyboardLayout"];
    NSString *inputSourceID;
    
    if (layout) {
        inputSourceID = (__bridge NSString *)TISGetInputSourceProperty(layout.inputSource, kTISPropertyInputSourceID);
    }
    else {
        inputSourceID = nil;
    }

    [[NSUserDefaults standardUserDefaults] setObject:inputSourceID forKey:kCDOForceKeyboardLayoutDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self didChangeValueForKey:@"forceKeyboardLayout"];

}

- (CDOKeyboardLayout *)forceKeyboardLayout
{
    NSString *inputSourceID = [[NSUserDefaults standardUserDefaults] objectForKey:kCDOForceKeyboardLayoutDefaultsKey];
    
    if (inputSourceID == NULL) {
        return NULL;
    }
    
    CFDictionaryRef properties = CFBridgingRetain(@{
                                                  (NSString *)kTISPropertyInputSourceID: inputSourceID,
                                                  (NSString *)kTISPropertyInputSourceIsEnabled: @(YES),
                                                  (NSString *)kTISPropertyInputSourceIsSelectCapable: @(YES)
                                                  });
    
    NSArray *layouts = CFBridgingRelease(TISCreateInputSourceList(properties, NO));
    CFRelease(properties);
    if (layouts.count == 0) {
        return NULL;
    }
    else if (layouts.count > 1) {
        // Somehow we have multiple matching layouts
        NSLog(@"ForceKeyboardLayout: Managed to find multiple layouts with InputModeID %@, using first found", inputSourceID);
    }
    return [[CDOKeyboardLayout alloc] initWithInputSource:(TISInputSourceRef)layouts[0]];
}

- (void)updateAvailableKeyboardLayouts
{
    CFDictionaryRef properties = CFBridgingRetain(@{
                                                  (NSString *)kTISPropertyInputSourceCategory: (NSString *)kTISCategoryKeyboardInputSource,
                                                  (NSString *)kTISPropertyInputSourceIsSelectCapable: @(YES)
                                                  });
    NSArray *layouts = CFBridgingRelease(TISCreateInputSourceList(properties, NO));
    CFRelease(properties);
    
    NSMutableArray *layoutModels = [NSMutableArray arrayWithCapacity:layouts.count];
    
    [layouts enumerateObjectsUsingBlock:^(id inputSource, NSUInteger idx, BOOL *stop) {
        [layoutModels addObject:[[CDOKeyboardLayout alloc] initWithInputSource:(__bridge TISInputSourceRef)(inputSource)]];
    }];
    
    self.availableKeyboardLayouts = layoutModels;
}

- (BOOL)activate
{
    if (savedKeyboardLayout != NULL) {
        // We don't want to lose a saved layout if activateForceKeyboardLayout is called twice
        return NO;
    }
    savedKeyboardLayout = TISCopyCurrentKeyboardInputSource(); // TODO: Investigate difference between this and TISCopyCurrentKeyboardLayoutInputSource
    
    OSStatus status = TISSelectInputSource([self forceKeyboardLayout].inputSource);
    if (status == noErr) {
        return YES;
    }
    else {
        return NO;
    }
}

- (BOOL)deactivate
{
    if (savedKeyboardLayout == NULL) {
        return NO;
    }
    
    OSStatus status = TISSelectInputSource(savedKeyboardLayout);
    if (status == noErr) {
        CFRelease(savedKeyboardLayout);
        savedKeyboardLayout = NULL;
        return YES;
    }
    else {
        return NO;
    }
}


@end
