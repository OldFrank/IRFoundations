//
//  IRAction.m
//  Milk
//
//  Created by Evadne Wu on 2/15/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRAction.h"


@implementation IRAction

@synthesize title, enabled, action;

+ (IRAction *) actionWithTitle:(NSString *)title block:(void (^)(void))action {

	IRAction *returnedAction = [[self alloc] init];
	if (!returnedAction)
	return nil;
	
	returnedAction.title = title;
	returnedAction.action = action;
	
	return [returnedAction autorelease];

}

- (id) init {

	self = [super init]; 
	if (!self) return nil;
	
	self.title = nil;
	self.action = nil;
	self.enabled = YES;
	
	return self;

}

- (void) invoke {

	if (self.action)
	self.action();

}

- (void) dealloc {

	[title release];
	[action release];

	[super dealloc];

}

@end
