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
    TISInputSourceRef _savedKeyboardLayout;
    NSString *_keyPath;
}

@end

@implementation CDOForceKeyboardLayoutController

- (instancetype)init {
    self = [super init];
    if (self) {
        _savedKeyboardLayout = NULL;
        [self updateAvailableKeyboardLayouts];
        
        _keyPath = kCDOForceKeyboardLayoutDefaultsKey;
        [[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:_keyPath options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:_keyPath];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (![_keyPath isEqualToString:keyPath]) {
        return;
    }

    NSString *value = change[NSKeyValueChangeNewKey];

    [self willChangeValueForKey:@"forceKeyboardLayout"];
    if (value) {
        CDOKeyboardLayout *layout = [self keyboardLayoutForInputSourceID:value];
        _forceKeyboardLayout = layout;
    }
    else {
        _forceKeyboardLayout = nil;
    }
    [self didChangeValueForKey:@"forceKeyboardLayout"];    
}

- (CDOKeyboardLayout *)keyboardLayoutForInputSourceID:(NSString *)inputSourceID
{
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

- (void)setForceKeyboardLayout:(CDOKeyboardLayout *)layout
{
    NSString *inputSourceID;
    
    if (layout) {
        inputSourceID = layout.inputSourceID;
    }
    else {
        inputSourceID = nil;
    }

    [[NSUserDefaults standardUserDefaults] setObject:inputSourceID forKey:kCDOForceKeyboardLayoutDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
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
    if (_savedKeyboardLayout != NULL) {
        // We don't want to lose a saved layout if activateForceKeyboardLayout is called twice
        return NO;
    }
    _savedKeyboardLayout = TISCopyCurrentKeyboardInputSource(); // TODO: Investigate difference between this and TISCopyCurrentKeyboardLayoutInputSource
    
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
    if (_savedKeyboardLayout == NULL) {
        return NO;
    }
    
    OSStatus status = TISSelectInputSource(_savedKeyboardLayout);
    if (status == noErr) {
        CFRelease(_savedKeyboardLayout);
        _savedKeyboardLayout = NULL;
        return YES;
    }
    else {
        return NO;
    }
}


@end
