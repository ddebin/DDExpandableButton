//
//  DDExpandableButton.m
//  https://github.com/ddebin/DDExpandableButton
//

#import <QuartzCore/CALayer.h>
#import "DDExpandableButton.h"


#pragma mark -
#pragma mark Custom UIImageView Class

@interface DDExpandableButtonCustomUILabel : UILabel <DDExpandableButtonViewSource>

@end

@implementation DDExpandableButtonCustomUILabel

- (CGSize)defaultFrameSize
{
	return [self.text sizeWithFont:self.font];
}

@end


#pragma mark Custom UILabel Class

@interface DDExpandableButtonCustomUIImageView : UIImageView <DDExpandableButtonViewSource>

@end

@implementation DDExpandableButtonCustomUIImageView

- (CGSize)defaultFrameSize
{
	return self.image.size;
}

@end


#pragma mark -
#pragma mark DDExpandableButton Class

@interface DDExpandableButton ()

@property (nonatomic, assign) CGFloat cornerAdditionalPadding;
@property (nonatomic, assign) CGFloat leftWidth;
@property (nonatomic, assign) CGFloat maxHeight;
@property (nonatomic, assign) CGFloat maxWidth;
@property (nonatomic, strong) DDView *leftTitleView;

@end

@implementation DDExpandableButton

static CGFloat const kDefaultTimeout = 4.0f;
static CGFloat const kDefaultAlpha = 0.8f;
static CGFloat const kDefaultDisabledAlpha = 0.5f;

#pragma mark Init Methods

- (instancetype)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame]))
	{
		// Flash Button like parameters	
		self.expanded = NO;
		self.maxHeight = 0.0f;
		self.useAnimation = YES;
		self.borderWidth = 1.0f;
		self.innerBorderWidth = 1.0f;
		self.horizontalPadding = 12.0f;
		self.verticalPadding = 7.0f;
		self.timeout = kDefaultTimeout;
		
		[self addTarget:self action:@selector(chooseLabel:forEvent:) forControlEvents:UIControlEventTouchUpInside];
		
		self.borderColor = [UIColor colorWithWhite:0.0f alpha:1.0f];
		self.textColor = _borderColor;
		self.labelFont = [UIFont boldSystemFontOfSize:14.0f];
		self.unSelectedLabelFont = nil;
		
		self.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.4f];
		self.alpha = kDefaultAlpha;
		self.opaque = YES;
	}
	return self;
}

- (instancetype)initWithPoint:(CGPoint)point leftTitle:(id)leftTitle buttons:(NSArray *)buttons
{
    if ((self = [self initWithFrame:CGRectMake(point.x, point.y, 0, 0)]))
	{
		[self setLeftTitle:leftTitle];
		[self setButtons:buttons];
		[self updateDisplay];
    }
    return self;
}

#pragma mark Parameters Methods

- (void)disableTimeout
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(shrinkButton) object:nil];
	self.timeout = 0.0f;
}

- (void)setLeftTitle:(id)leftTitle
{
	[self.leftTitleView removeFromSuperview];
	self.leftTitleView = nil;
	
	if (leftTitle != nil)
	{
		self.leftTitleView = [self getViewFrom:leftTitle];
		[self addSubview:self.leftTitleView];
	}
}

- (void)setButtons:(NSArray *)buttons
{
    [self.labels makeObjectsPerformSelector:@selector(removeFromSuperview)];
	
	NSMutableArray *updatedLabels = [NSMutableArray arrayWithCapacity:[buttons count]];
	for (NSObject *button in buttons)
	{
		DDView *v = [self getViewFrom:button];
		[self addSubview:v];
		[updatedLabels addObject:v];
	}
	_labels = updatedLabels;
}

- (void)updateDisplay
{
	// maxHeight update
	self.maxWidth = 0.0f;
	self.maxHeight = [self calculateMaxHeight];
	for (DDView *v in self.labels)
	{
		self.maxHeight = MAX(self.maxHeight, [v defaultFrameSize].height + self.verticalPadding * 2.0f);
		self.maxWidth = MAX(self.maxWidth, [v defaultFrameSize].width);
	}
	
	// borderWidth update
	for (DDView *v in self.labels)
	{
		v.layer.borderWidth = self.innerBorderWidth;
	}
	
	self.cornerAdditionalPadding = roundf(self.maxHeight / 2.2f) - self.borderWidth - self.horizontalPadding;

	self.leftWidth = self.cornerAdditionalPadding;
	if (self.leftTitleView != nil)
    {
        CGFloat frameWidth = [self.leftTitleView defaultFrameSize].width;
        CGFloat additionalPadding = (self.innerBorderWidth == 0) ? self.horizontalPadding : 0.0f;        
        self.leftWidth += self.horizontalPadding + frameWidth + additionalPadding;
    }
	
	self.layer.borderWidth  = self.borderWidth;
	self.layer.borderColor  = self.borderColor.CGColor;
	self.layer.cornerRadius = roundf(self.maxHeight / 2.0f);
	
	[self setSelectedItemIndex:0 animated:NO];
}


#pragma mark Frame Rect Methods

- (CGRect)shrunkFrameRect
{
    CGPoint originPoint = self.frame.origin;
    CGFloat x = 0.0f;
    CGFloat y = self.maxHeight;
	if (self.toggleMode)
	{        
        x = (self.cornerAdditionalPadding + self.horizontalPadding) * 2 + self.maxWidth;
        return (CGRect){ originPoint, { x, y } };
	}
	else
	{
		DDView *currentLabel = self.labels[self.selectedItemIndex];
        x = currentLabel.frame.origin.x + currentLabel.frame.size.width + self.cornerAdditionalPadding;
        return (CGRect){ originPoint, { x, y } };
	}
}

- (CGRect)expandedFrameRect
{
	if (self.toggleMode == YES)
	{
		return [self shrunkFrameRect];
	}
	else
	{
		DDView *lastLabel = [self.labels lastObject];
		return CGRectMake(self.frame.origin.x, self.frame.origin.y, lastLabel.frame.origin.x + lastLabel.frame.size.width + self.cornerAdditionalPadding, self.maxHeight);
	}
}

- (CGRect)currentFrameRect
{
	if (self.isExpanded == YES)
	{
		return [self expandedFrameRect];
	}
	else
	{
		return [self shrunkFrameRect];
	}
}


#pragma mark Animation Methods

- (void)setEnabled:(BOOL)enabled
{
	[super setEnabled:enabled];
	self.alpha = enabled ? 1.0f : kDefaultDisabledAlpha;
}

- (void)shrinkButton
{
	[self setExpanded:NO animated:self.useAnimation];
}

- (void)setExpanded:(BOOL)isExpanded
{
	[self setExpanded:isExpanded animated:NO];
}

- (void)setExpanded:(BOOL)isExpanded animated:(BOOL)animated
{
	_expanded = isExpanded;
	
	if (animated)
	{
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.2f];
	}
	
	// set labels appearance
	
	if (_expanded)
	{
        NSUInteger i = 0;
		CGFloat x = self.leftWidth;
        for (DDView *v in self.labels)
		{
            if (i != self.selectedItemIndex)
			{
				if ([v isKindOfClass:[DDExpandableButtonCustomUILabel class]])
				{
					[(DDExpandableButtonCustomUILabel *)v setFont:(self.unSelectedLabelFont != nil)?self.unSelectedLabelFont:self.labelFont];
				}
				if ([v respondsToSelector:@selector(setHighlighted:)])
				{
					[v setHighlighted:NO];
				}
            }
			else if ([v respondsToSelector:@selector(setHighlighted:)])
			{
				[v setHighlighted:YES];
			}
			
			CGRect labelRect = CGRectMake(x, 0, [v defaultFrameSize].width + self.horizontalPadding * 2, self.maxHeight);
			x += labelRect.size.width - v.layer.borderWidth;
			v.frame = labelRect;
			
			if ((i > 0) && (i < ([self.labels count] - 1)) && (v.layer.borderWidth > 0))
			{
				v.layer.borderColor = self.borderColor.CGColor;
			}
			
            i++;
        }
		
		if (self.timeout > 0)
		{
			[self performSelector:@selector(shrinkButton) withObject:nil afterDelay:self.timeout];
		}
	}
	else
	{
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(shrinkButton) object:nil]; 
		
        NSUInteger i = 0;
		CGFloat selectedWidth = 0;
		for (DDView *v in self.labels)
		{
			if ([v isKindOfClass:[DDExpandableButtonCustomUILabel class]])
			{
				[(DDExpandableButtonCustomUILabel *)v setFont:self.labelFont];
				[(DDExpandableButtonCustomUILabel *)v setTextColor:self.textColor];
			}
			if ([v respondsToSelector:@selector(setHighlighted:)])
			{
				[v setHighlighted:(i == self.selectedItemIndex)];
			}
			
			CGRect r = CGRectZero;
			r.size.height = self.maxHeight;
			if (i < self.selectedItemIndex)
			{
				r.origin.x = self.leftWidth;
			}
			else if (i == self.selectedItemIndex)
			{
				r.size.width = [v defaultFrameSize].width + self.horizontalPadding * 2;
				r.origin.x = self.leftWidth;
				selectedWidth = r.size.width;
			}
			else if (i > self.selectedItemIndex)
			{
				r.origin.x = self.leftWidth + selectedWidth;
			}
			v.layer.borderColor = [UIColor colorWithWhite:0.0f alpha:0.0f].CGColor;
			v.frame = r;
			
			i++;
		}
	}
	
	// set title frames
	self.leftTitleView.frame = CGRectMake(self.cornerAdditionalPadding + self.horizontalPadding, 0, [self.leftTitleView defaultFrameSize].width, self.maxHeight);
	
	// set whole frame
	[self setFrame:[self currentFrameRect]];
	
	if (animated)
	{
		[UIView commitAnimations];
	}
}

- (void)setSelectedItemIndex:(NSUInteger)selected
{
	[self setSelectedItemIndex:selected animated:NO];
}

- (void)setSelectedItemIndex:(NSUInteger)selected animated:(BOOL)animated
{	
	BOOL notify = (_selectedItemIndex != selected);
	
	_selectedItemIndex = selected;
	
	[self setExpanded:NO animated:animated];
	
	if (notify)
	{
		[self sendActionsForControlEvents:UIControlEventValueChanged];
	}        
}


#pragma mark UIButton UIControlEventTouchUpInside target

- (void)chooseLabel:(id)sender forEvent:(UIEvent *)event
{
	if (self.toggleMode)
	{
		[self setSelectedItemIndex:((self.selectedItemIndex + 1) % [self.labels count])];
	}
    else if (self.isExpanded == NO)
	{
		[self setExpanded:YES animated:self.useAnimation];
    }
	else
	{
        BOOL inside = NO;
		
		NSUInteger i = 0;
        for (DDView *v in self.labels)
		{
            if ([v pointInside:[[[event allTouches] anyObject] locationInView:v] withEvent:event])
			{
                inside = YES;
                break;
            }
			i++;
        }
        
        if (inside)
		{
            [self setSelectedItemIndex:i animated:self.useAnimation];
        }
		else
		{
            [self setSelectedItemIndex:self.selectedItemIndex animated:self.useAnimation];
		}
    }
}


#pragma mark Utilities

- (DDView *)getViewFrom:(id)obj
{
	if ([obj isKindOfClass:[NSString class]])
	{
		DDExpandableButtonCustomUILabel *v = [[DDExpandableButtonCustomUILabel alloc] init];
		v.font = self.labelFont;
        v.textColor = self.textColor;
        v.backgroundColor = [UIColor clearColor];
		v.textAlignment = UITextAlignmentCenter;
		v.opaque = YES;
		v.text = obj;
		return v;
	}
	else if ([obj isKindOfClass:[UIImage class]])
	{
		DDExpandableButtonCustomUIImageView *v = [[DDExpandableButtonCustomUIImageView alloc] initWithImage:obj];
		v.backgroundColor = [UIColor clearColor];
		v.opaque = YES;
		v.contentMode = UIViewContentModeCenter;
		v.clipsToBounds = YES;
		return v;
	}
	else if (obj == nil)
	{
		return nil;
	}
	else
	{
		NSAssert([obj isKindOfClass:[UIView class]], @"obj must be an UIView class !");
		NSAssert([obj respondsToSelector:@selector(defaultFrameWidth)], @"obj must implement - (CGFloat)defaultFrameWidth !");
		return obj;
	}
}

- (CGFloat)calculateMaxHeight
{
    CGFloat maxHeight = 0.0f;
    if (self.leftTitleView != nil)
    {
        maxHeight = [self.leftTitleView defaultFrameSize].height + self.verticalPadding * 2.0f;
    }
    else
    {
        maxHeight = 0.0f;
    }
    return maxHeight;
}


@end
