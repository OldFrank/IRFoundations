//
//  IRActionSheet.m
//  Milk
//
//  Created by Evadne Wu on 2/27/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRActionSheet.h"


@implementation IRActionSheet

@synthesize lastShownInRect, lastShownInView, canUseCustomReshowing;

- (void) showFromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated {

	self.lastShownInRect = rect;
	self.lastShownInView = view;
	self.canUseCustomReshowing = YES;
	
	[super showFromRect:rect inView:view animated:animated];

}

- (void) dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated {

	self.lastShownInRect = CGRectNull;
	self.lastShownInView = nil;

	[super dismissWithClickedButtonIndex:buttonIndex animated:animated];

}

- (void) prepareForReshowingIfAppropriate {

	if (!self.canUseCustomReshowing)
	return;

	if (CGRectEqualToRect(self.lastShownInRect, CGRectNull))
	return;

	NSObject<UIActionSheetDelegate> *originalDelegate = self.delegate;
	CGRect lastRect = self.lastShownInRect;
	UIView *lastView = self.lastShownInView;

	self.delegate = nil;	
	[self dismissWithClickedButtonIndex:-1 animated:NO];
	
	self.delegate = originalDelegate;
	
	self.lastShownInRect = lastRect;
	self.lastShownInView = lastView;

}

- (void) reshowIfAppropriate {

	if (!self.canUseCustomReshowing)
	return;

	if (CGRectEqualToRect(self.lastShownInRect, CGRectNull))
	return;

	NSObject<UIActionSheetDelegate> *originalDelegate = self.delegate;
	UIView *lastView = self.lastShownInView;
	CGRect lastRect = self.lastShownInRect;
	
	self.delegate = nil;
	
	if (lastView)
	[self showFromRect:lastRect inView:lastView animated:NO];
		
	self.delegate = originalDelegate;

}

@end
