//
//  AppDelegate.h
//  CDOForceKeyboardLayoutDemo
//
//  Created by Jack Chen on 16/08/13.
//  Copyright (c) 2013 chendo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CDOForceKeyboardLayoutController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet CDOForceKeyboardLayoutController* forceKeyboardLayoutController;


@end
