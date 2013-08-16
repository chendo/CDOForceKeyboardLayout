/*
 * This file is part of the CDOForceKeyboardLayout package.
 * (c) 2013 Jack Chen (chendo)
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>

@class CDOKeyboardLayout;

@interface CDOForceKeyboardLayoutController : NSObject

- (void)setForceKeyboardLayout:(CDOKeyboardLayout *)layout;
- (CDOKeyboardLayout *)forceKeyboardLayout;
- (NSArray *)availableKeyboardLayouts;

- (BOOL)activate;
- (BOOL)deactivate;


@end
