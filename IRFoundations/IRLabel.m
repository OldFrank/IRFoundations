//
//  IRLabel.m
//  Milk
//
//  Created by Evadne Wu on 2/14/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRLabel.h"
#import "CoreText+IRAdditions.h"


NSString * const kIRTextLinkAttribute = @"kIRTextLinkAttribute";
NSString * const kIRTextActiveBackgroundColorAttribute = @"kIRTextActiveBackgroundColorAttribute";


@interface IRLabel () <UIGestureRecognizerDelegate>

- (void) irCommonInit;

@property (nonatomic, readwrite, assign) CTFramesetterRef ctFramesetter;
@property (nonatomic, readwrite, assign) CTFrameRef ctFrame;
@property (nonatomic, readwrite, retain) UIBezierPath *lastHighlightedRunOutline;
- (CTRunRef) linkRunAtPoint:(CGPoint)touchPoint;

@end


@implementation IRLabel

@synthesize attributedText, ctFramesetter, ctFrame, lastHighlightedRunOutline;

+ (IRLabel *) labelWithFont:(UIFont *)aFont color:(UIColor *)aColor {

	IRLabel *returnedLabel = [[self alloc] init];
	returnedLabel.font = aFont;
	returnedLabel.textColor = aColor;
	returnedLabel.minimumFontSize = aFont.pointSize;
	returnedLabel.adjustsFontSizeToFitWidth = NO;
	
	return [returnedLabel autorelease];

}

- (id) initWithFrame:(CGRect)frame {

	self = [super initWithFrame:frame];
	if (!self)
		return nil;
	
	[self irCommonInit];
	
	return self;

}

- (void) awakeFromNib {

	[super awakeFromNib];	
	[self irCommonInit];

}

- (void) irCommonInit {

	UITapGestureRecognizer *tapRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)] autorelease];
	tapRecognizer.delegate = self;
	
	UILongPressGestureRecognizer *longPressRecognizer = [[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)] autorelease];
	longPressRecognizer.delegate = self;
	longPressRecognizer.minimumPressDuration = 0.01f;
	
	[self addGestureRecognizer:tapRecognizer];
	[self addGestureRecognizer:longPressRecognizer];
	
}

- (BOOL) isShowingRichText {

	return !!(self.attributedText);

}

- (void) dealloc {

	if (ctFramesetter)
		CFRelease(ctFramesetter);
	
	if (ctFrame)
		CFRelease(ctFrame);
	
	[attributedText release];
	[lastHighlightedRunOutline release];
	
	[super dealloc];

}

- (void) setFrame:(CGRect)frame {

	[super setFrame:frame];

	if (ctFrame) {
		CTFrameRef oldFrame = ctFrame;
		ctFrame = nil;
		CFRelease(oldFrame);
	}
	
	if (ctFramesetter) {
		CTFramesetterRef oldFramesetter = ctFramesetter;
		ctFramesetter = nil;
		CFRelease(oldFramesetter);
	}
	
	if ([self isShowingRichText])
		[self setNeedsDisplay];
	
}

- (void) setBounds:(CGRect)bounds {

	[super setBounds:bounds];
	
	if (ctFrame) {
		CTFrameRef oldFrame = ctFrame;
		ctFrame = nil;
		CFRelease(oldFrame);
	}
	
	if (ctFramesetter) {
		CTFramesetterRef oldFramesetter = ctFramesetter;
		ctFramesetter = nil;
		CFRelease(oldFramesetter);
	}
	
	if ([self isShowingRichText])
		[self setNeedsDisplay];

}

- (void) setAttributedText:(NSAttributedString *)newAttributedText {

	if (attributedText == newAttributedText)
		return;
	
	[self willChangeValueForKey:@"attributedText"];
	
	if (ctFrame) {
		CTFrameRef oldFrame = ctFrame;
		ctFrame = nil;
		CFRelease(oldFrame);
	}
	
	if (ctFramesetter) {
		CTFramesetterRef oldFramesetter = ctFramesetter;
		ctFramesetter = nil;
		CFRelease(oldFramesetter);
	}
	
	[attributedText release];
	attributedText = [newAttributedText copy];
	
	[self didChangeValueForKey:@"attributedText"];
	[self setNeedsDisplay];

}

- (NSAttributedString *) attributedStringForString:(NSString *)aString {

	return [self attributedStringForString:aString font:self.font color:self.textColor];

}

- (NSAttributedString *) attributedStringForString:(NSString *)aString font:(UIFont *)aFont color:(UIColor *)aColor {

	if (!aString)
		return nil;
	
	float_t lineHeight = aFont.leading;
	
	id fontAttr = [NSMakeCollectable(CTFontCreateWithName((CFStringRef)aFont.fontName, aFont.pointSize, NULL)) autorelease];
	id foregroundColorAttr = (id)(aColor ? aColor.CGColor : [UIColor blackColor].CGColor);
	id paragraphStyleAttr = ((^ {
		
		CTParagraphStyleSetting paragraphStyles[] = (CTParagraphStyleSetting[]){
			(CTParagraphStyleSetting){ kCTParagraphStyleSpecifierLineHeightMultiple, sizeof(float_t), (float_t[]){ 0.01f } },
			(CTParagraphStyleSetting){ kCTParagraphStyleSpecifierMinimumLineHeight, sizeof(float_t), (float_t[]){ lineHeight } },
			(CTParagraphStyleSetting){ kCTParagraphStyleSpecifierMaximumLineHeight, sizeof(float_t), (float_t[]){ lineHeight } },
			(CTParagraphStyleSetting){ kCTParagraphStyleSpecifierLineSpacing, sizeof(float_t), (float_t[]){ 0.0f } },
			(CTParagraphStyleSetting){ kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(float_t), (float_t[]){ 0.0f } },
			(CTParagraphStyleSetting){ kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(float_t), (float_t[]){ 0.0f } }
		};
	
		CTParagraphStyleRef paragraphStyleRef = CTParagraphStyleCreate(paragraphStyles, sizeof(paragraphStyles) / sizeof(CTParagraphStyleSetting));
		return [NSMakeCollectable(paragraphStyleRef) autorelease];
		
	})());
	
	NSAttributedString *returnedString = [[[NSAttributedString alloc] initWithString:aString attributes:[NSDictionary dictionaryWithObjectsAndKeys:
		fontAttr, kCTFontAttributeName,
		foregroundColorAttr, kCTForegroundColorAttributeName,
		paragraphStyleAttr, kCTParagraphStyleAttributeName,
	nil]] autorelease];
	
	return returnedString;

}

- (CTFramesetterRef) ctFramesetter {

	NSParameterAssert([NSThread isMainThread]);

	if (ctFramesetter)
		return ctFramesetter;
	
	@synchronized (self) {
		if (attributedText)
			ctFramesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedText);
	}
	
	return ctFramesetter;

}

- (CTFrameRef) ctFrame {

	NSParameterAssert([NSThread isMainThread]);

	if (ctFrame)
		return ctFrame;
	
	CGRect frameRect = (CGRect){
		CGPointZero,
		self.bounds.size
		//	(CGSize){
		//		self.bounds.size.width,
		//		MAXFLOAT
		//	}
	};
	
	CTFramesetterRef currentFramesetter = self.ctFramesetter;
	
	CFRange actualRange = (CFRange){ 0, 0 };
	//	CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(currentFramesetter, (CFRange){ 0, 0 }, nil, frameRect.size, &actualRange);

	ctFrame = CTFramesetterCreateFrame(currentFramesetter, actualRange, [UIBezierPath bezierPathWithRect:frameRect].CGPath, nil);
	return ctFrame;

}

- (void) drawTextInRect:(CGRect)rect {

	if (![self isShowingRichText]) {
		[super drawTextInRect:rect];
		return;
	}

	CTFramesetterRef usedFramesetter = self.ctFramesetter;	
	CTFrameRef usedFrame = self.ctFrame;
	if (!usedFrame || !usedFramesetter)
		return;
	
	CFRetain(usedFrame);
	CFRetain(usedFramesetter);
	CGContextRef context = UIGraphicsGetCurrentContext();	
	CGContextConcatCTM(context, CGAffineTransformMake(
		1, 0, 0, -1, 0, CGRectGetHeight(self.bounds)
	));
	
#if 1
	
	__block CGFloat usableHeight = CGRectGetHeight(self.bounds);
	__block CFArrayRef usedLines = CTFrameGetLines(usedFrame);
	NSUInteger stringLength = [attributedText length];
	BOOL needsTailTruncation = NO;
	
	CFRange drawnRange = CTFrameGetStringRange(usedFrame);
	NSUInteger drawnLength = drawnRange.location + drawnRange.length;
	if (drawnLength < stringLength)
		needsTailTruncation = YES;
	
	CGContextSetTextMatrix(context, CGAffineTransformIdentity);
	irCTFrameEnumerateLines(usedFrame, ^(CTLineRef aLine, CGPoint lineOrigin, BOOL *stop) {
		
		CTFontRef lineFont = (CTFontRef)[self.attributedText attribute:(id)kCTFontAttributeName atIndex:(CTLineGetStringRange(aLine)).location effectiveRange:NULL];
		UIFont *usedFont = lineFont ? [UIFont fontWithName:(NSString *)[NSMakeCollectable(CTFontCopyPostScriptName(lineFont)) autorelease] size:CTFontGetSize(lineFont)] : self.font;

		//	Fix: needs simple alignment stuff
		usableHeight -= usedFont.leading;
		CGContextSetTextPosition(context, lineOrigin.x, usableHeight - usedFont.descender);
		
		CFRange lineRange = CTLineGetStringRange(aLine);
		if (needsTailTruncation && (drawnLength == (lineRange.location + lineRange.length))) {
		
			CGFloat ownWidth = CGRectGetWidth(self.bounds);
			CTLineRef realLastLine, truncationToken, truncatedLine;
			realLastLine = CTTypesetterCreateLine(CTFramesetterGetTypesetter(usedFramesetter), (CFRange){ lineRange.location, 0 });
			truncationToken = CTLineCreateWithAttributedString((CFAttributedStringRef)[[[NSAttributedString alloc] initWithString:[NSString stringWithCharacters:(UniChar[]){ 0x2026 } length:1] attributes:(NSDictionary *)CTRunGetAttributes((CTRunRef)[(NSArray *)CTLineGetGlyphRuns(aLine) lastObject])] autorelease]);
			truncatedLine = CTLineCreateTruncatedLine(realLastLine, ownWidth, kCTLineTruncationEnd, truncationToken);
			
			if (truncatedLine) {
				CTLineDraw(truncatedLine, context);
				CFRelease(truncatedLine);
			} else {
				CTLineDraw(realLastLine, context);
			}
			
			CFRelease(realLastLine);
			CFRelease(truncationToken);
				
		} else {
		
			CTLineDraw(aLine, context);
		
		}
		
	});

#else
	
	CTFrameDraw(usedFrame, context);

#endif
	
	CFRelease(usedFrame);

}

- (void) drawRect:(CGRect)rect {
	
	if (self.lastHighlightedRunOutline) {
		CGContextRef context = UIGraphicsGetCurrentContext();	
		CGContextSaveGState(context);
		CGContextConcatCTM(context, CGAffineTransformMake(
			1, 0, 0, -1, 0, CGRectGetHeight(self.bounds)
		));
		
		CGContextAddPath(context, self.lastHighlightedRunOutline.CGPath);
		CGContextSetFillColorWithColor(context, [[UIColor blackColor] colorWithAlphaComponent:0.15f].CGColor);
		CGContextFillPath(context);
		CGContextRestoreGState(context);	
	}

	[super drawRect:rect];
	
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {

	return ![otherGestureRecognizer isKindOfClass:[UITapGestureRecognizer class]];

}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {

	CTRunRef hitRun = [self linkRunAtPoint:[touch locationInView:self]];
	return (BOOL)(!!hitRun);

}

- (CTRunRef) linkRunAtPoint:(CGPoint)touchPoint {

	if (!self.attributedText)
		return nil;

	touchPoint.y = CGRectGetHeight(self.bounds) - touchPoint.y;
	
	CTRunRef hitRun = irCTFrameFindRunAtPoint(self.ctFrame, touchPoint, 2.0, nil, [NSDictionary dictionaryWithObjectsAndKeys:
		[[^ (id key, id value) {
			return !!value;
		} copy] autorelease], kIRTextLinkAttribute,
	nil]);
	
	return hitRun;

}

- (void) handleTap:(UITapGestureRecognizer *)aTapRecognizer {

	CTRunRef hitRun = [self linkRunAtPoint:[aTapRecognizer locationInView:self]];
	
	NSURL *link = [(NSDictionary *)CTRunGetAttributes(hitRun) objectForKey:kIRTextLinkAttribute];
	
	if ([link isKindOfClass:[NSURL class]])
		[[UIApplication sharedApplication] openURL:link];

}

- (void) handleLongPress:(UILongPressGestureRecognizer *)aLongPressRecognizer {

	CTRunRef hitRun = [self linkRunAtPoint:[aLongPressRecognizer locationInView:self]];
		
	switch (aLongPressRecognizer.state) {
		case UIGestureRecognizerStatePossible: {
			break;
		}
    case UIGestureRecognizerStateBegan:
    case UIGestureRecognizerStateChanged: {
			
			if (hitRun) {
				
				self.lastHighlightedRunOutline = irCTFrameGetRunOutline(self.ctFrame, irCTFrameFindNeighborRuns(self.ctFrame, hitRun, [NSDictionary dictionaryWithObjectsAndKeys:
					[[^ (id key, id value) { return !!value; } copy] autorelease], kIRTextLinkAttribute,
				nil]), UIEdgeInsetsZero, 4.0f, NO, YES, NO);
				
				[self setNeedsDisplay];
				
			} else {
			
				self.lastHighlightedRunOutline = nil;
				
				[self setNeedsDisplay];
			
			}
			
			break;
		}
    case UIGestureRecognizerStateEnded:
    case UIGestureRecognizerStateCancelled:
		case UIGestureRecognizerStateFailed: {
		
			self.lastHighlightedRunOutline = nil;
			
			[self setNeedsDisplay];
		
			break;
			
		}
	};

}

- (CGSize) sizeThatFits:(CGSize)size {
	
	if (![self isShowingRichText])
		return [super sizeThatFits:size];
		
	if (![self.attributedText length])
		return CGSizeZero;
	
	CTFramesetterRef currentFramesetter = self.ctFramesetter;
	if (!currentFramesetter)
		return CGSizeZero;
	
	CFRetain(currentFramesetter);
	
	CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(currentFramesetter, (CFRange){ 0, 0 }, nil, (CGSize){
		size.width, //CGRectGetWidth(self.bounds),
		MAX(size.height, 1024)
	}, NULL);
	
	CFRelease(currentFramesetter);
	
	return suggestedSize;
	
}

@end


@implementation UILabel (IRAdditions)

- (void) irPlaceBehindLabel:(UILabel *)anotherLabel {

	[self irPlaceBehindLabel:anotherLabel withEdgeInsets:UIEdgeInsetsZero];

}

- (void) irPlaceBehindLabel:(UILabel *)anotherLabel withEdgeInsets:(UIEdgeInsets)edgeInsets {

	NSParameterAssert(anotherLabel.superview == self.superview);
	
	//	Not really useful:
	//	CGRect initialFrame = [anotherLabel convertRect:[anotherLabel textRectForBounds:anotherLabel.bounds limitedToNumberOfLines:anotherLabel.numberOfLines] toView:anotherLabel.superview];
	
	CGRect initialFrame = anotherLabel.frame;
	
	if (!UIEdgeInsetsEqualToEdgeInsets(UIEdgeInsetsZero, edgeInsets))
		initialFrame = UIEdgeInsetsInsetRect(initialFrame, edgeInsets);
	
	self.frame = (CGRect){
		(CGPoint){
			CGRectGetMaxX(initialFrame),
			roundf(CGRectGetMaxY(initialFrame) - CGRectGetHeight(self.frame) + anotherLabel.font.descender - self.font.descender)
		},
		self.frame.size
	};

}

@end
