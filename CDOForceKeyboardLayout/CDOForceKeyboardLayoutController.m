/*
 * This file is part of the CDOForceKeyboardLayout package.
 * (c) 2013 Jack Chen (chendo)
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "CDOForceKeyboardLayoutController.h"

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
    }
    return self;
}

- (void)setForceKeyboardLayout:(TISInputSourceRef)layout
{
    NSString *inputSourceID = (__bridge NSString *)TISGetInputSourceProperty(layout, kTISPropertyInputSourceID);

    [[NSUserDefaults standardUserDefaults] setObject:inputSourceID forKey:kCDOForceKeyboardLayoutDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (TISInputSourceRef)forceKeyboardLayout
{
    NSString *inputSourceID = [[NSUserDefaults standardUserDefaults] objectForKey:kCDOForceKeyboardLayoutDefaultsKey];
    
    CFDictionaryRef properties = CFBridgingRetain(@{
                                                  (NSString *)kTISPropertyInputSourceID: inputSourceID,
                                                  (NSString *)kTISPropertyInputSourceIsEnabled: @(YES),
                                                  (NSString *)kTISPropertyInputSourceIsSelectCapable: @(YES)
                                                  });
    
    NSArray *layouts = CFBridgingRelease(TISCreateInputSourceList(properties, NO));
    if (layouts.count == 0) {
        return NULL;
    }
    else if (layouts.count == 1) {
        return (TISInputSourceRef)CFBridgingRetain(layouts[0]);
    }
    else {
        // Somehow we have multiple matching layouts
        NSLog(@"ForceKeyboardLayout: Managed to find multiple layouts with InputModeID %@, using first found", inputSourceID);
        return (TISInputSourceRef)CFBridgingRetain(layouts[0]);
    }
}

- (NSArray *)availableKeyboardLayouts
{
    CFDictionaryRef properties = CFBridgingRetain(@{
                                (NSString *)kTISPropertyInputSourceCategory: (NSString *)kTISCategoryKeyboardInputSource,
                                (NSString *)kTISPropertyInputSourceIsSelectCapable: @(YES)
                                                  }

                                                  );
    CFArrayRef layouts = TISCreateInputSourceList(properties, NO);
    CFRelease(properties);
    return CFBridgingRelease(layouts);
}

- (BOOL)activate
{
    if (savedKeyboardLayout != NULL) {
        // We don't want to lose a saved layout if activateForceKeyboardLayout is called twice
        return NO;
    }
    savedKeyboardLayout = TISCopyCurrentKeyboardInputSource(); // TODO: Investigate difference between this and TISCopyCurrentKeyboardLayoutInputSource
    
    OSStatus status = TISSelectInputSource([self forceKeyboardLayout]);
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
