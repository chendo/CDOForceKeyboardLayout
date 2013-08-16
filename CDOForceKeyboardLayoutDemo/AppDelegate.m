//
//  AppDelegate.m
//  CDOForceKeyboardLayoutDemo
//
//  Created by Jack Chen on 16/08/13.
//  Copyright (c) 2013 chendo. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (IBAction)activate:(id)sender
{
    [self.forceKeyboardLayoutController activate];
}

- (IBAction)deactivate:(id)sender
{
    [self.forceKeyboardLayoutController deactivate];
}

@end
