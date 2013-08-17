/*
 * This file is part of the CDOForceKeyboardLayout package.
 * (c) 2013 Jack Chen (chendo)
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */


#import "CDOKeyboardLayout.h"

@implementation CDOKeyboardLayout

- (instancetype)initWithInputSource:(TISInputSourceRef)inputSource
{
    self = [super init];
    if (self) {
        CFRetain(inputSource);
        self.inputSource = inputSource;
    }
    return self;
}

- (NSString *)label
{
    return (__bridge NSString *)TISGetInputSourceProperty(self.inputSource, kTISPropertyLocalizedName);
}

- (NSString *)inputSourceID
{
    return (__bridge NSString *)TISGetInputSourceProperty(self.inputSource, kTISPropertyInputSourceID);
}

- (void)dealloc
{
    CFRelease(self.inputSource);
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[CDOKeyboardLayout class]]) {
        CDOKeyboardLayout *otherObj = (CDOKeyboardLayout *)object;
        return CFEqual(self.inputSource, otherObj.inputSource);
    }
    return NO;
}

@end
