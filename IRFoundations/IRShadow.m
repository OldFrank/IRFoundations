//
//  IRShadow.m
//  Milk
//
//  Created by Evadne Wu on 1/29/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRShadow.h"


@implementation IRShadow

@synthesize color;
@synthesize offset;
@synthesize spread;
@synthesize edgeInsets;

- (id) init {

	self = [super init];
	if (!self) return nil;
	
	self.color = nil;
	self.offset = CGSizeZero;
	self.spread = 0;
	self.edgeInsets = UIEdgeInsetsZero;
	
	return self;

}

- (void) dealloc {

	self.color = nil;
	
	[super dealloc];

}

- (id) initWithCoder:(NSKeyedUnarchiver *)aDecoder {

	self = [self init];
	if (!self) return nil;
	
	self.color = [aDecoder decodeObjectForKey:@"color"];
	self.offset = [aDecoder decodeCGSizeForKey:@"offset"];
	self.spread = [aDecoder decodeFloatForKey:@"spread"];
	self.edgeInsets = [aDecoder decodeUIEdgeInsetsForKey:@"edgeInsets"];
	
	return self;

}

- (void) encodeWithCoder:(NSKeyedArchiver *)aCoder {

	[aCoder encodeObject:self.color forKey:@"color"];
	[aCoder encodeCGSize:self.offset forKey:@"offset"];
	[aCoder encodeFloat:self.spread forKey:@"spread"];
	[aCoder encodeUIEdgeInsets:self.edgeInsets forKey:@"edgeInsets"];

}





+ (IRShadow *) shadowWithColor:(UIColor *)color offset:(CGSize)offset spread:(CGFloat)spread {

	return [self shadowWithColor:color offset:offset spread:spread edgeInsets:UIEdgeInsetsZero];

}

+ (IRShadow *) shadowWithColor:(UIColor *)color offset:(CGSize)offset spread:(CGFloat)spread edgeInsets:(UIEdgeInsets)edgeInsets {

	IRShadow *returnedShadow = [[self alloc] init];
	if (!returnedShadow)
	return nil;
	
	returnedShadow.color = color;
	returnedShadow.offset = offset;
	returnedShadow.spread = spread;
	returnedShadow.edgeInsets = edgeInsets;
	
	return [returnedShadow autorelease];

}

@end
