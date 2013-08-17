/*
 * This file is part of the CDOForceKeyboardLayout package.
 * (c) 2013 Jack Chen (chendo)
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */


#import <Carbon/Carbon.h>

@interface CDOKeyboardLayout : NSObject

- (instancetype)initWithInputSource:(TISInputSourceRef)inputSource;


@property (nonatomic, assign) TISInputSourceRef inputSource;
@property (readonly) NSString *label;
@property (readonly) NSString *inputSourceID;

@end
