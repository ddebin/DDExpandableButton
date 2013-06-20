//
//  DDExpandableButton.h
//  https://github.com/ddebin/DDExpandableButton
//

#ifndef __IPHONE_6_0
#warning "This project uses features only available in iOS SDK 6.0 and later."
#endif

#import <UIKit/UIKit.h>


#define DDView UIView <DDExpandableButtonViewSource>

@protocol DDExpandableButtonViewSource;

@interface DDExpandableButton : UIControl

// Current button status (if expanded or shrunk).
@property (nonatomic,assign,getter=isExpanded)	BOOL		expanded;

// Use animation during button state stransitions.
@property (nonatomic,assign)	BOOL		useAnimation;

// Use button as a toggle (like "HDR On"/"HDR Off" button in camera app).
@property (nonatomic,assign)	BOOL		toggleMode;

// To shrink the button after a timeout. Use `0` if you want to disable timeout.
@property (nonatomic,assign)	CGFloat		timeout;

// Horizontal padding space between items.
@property (nonatomic,assign)	CGFloat 	horizontalPadding;

// Vertical padding space above and below items.
@property (nonatomic,assign)	CGFloat 	verticalPadding;

// Width (thickness) of the button border.
@property (nonatomic,assign)	CGFloat 	borderWidth;

// Width (thickness) of the inner borders between items.
@property (nonatomic,assign)	CGFloat 	innerBorderWidth;

// Selected item number.
@property (nonatomic,assign)	NSUInteger	selectedItem;

// Color of the button and inner borders.
@property (nonatomic,strong)	UIColor		*borderColor;

// Color of text labels.
@property (nonatomic,strong)	UIColor		*textColor;

// Font of text labels.
@property (nonatomic,strong)	UIFont		*labelFont;

// Font of unselected text labels. Nil if not different from labelFont.
@property (nonatomic,strong)	UIFont		*unSelectedLabelFont;

// Access UIView used to draw labels.
@property (nonatomic,strong,readonly)	NSArray 	*labels;

- (instancetype)initWithPoint:(CGPoint)point leftTitle:(id)leftTitle buttons:(NSArray *)buttons;

- (void)setSelectedItem:(NSUInteger)selected animated:(BOOL)animated;
- (void)setExpanded:(BOOL)expanded animated:(BOOL)animated;
- (void)setLeftTitle:(id)leftTitle;
- (void)setButtons:(NSArray *)buttons;

- (void)disableTimeout;
- (void)updateDisplay;

@end

@protocol DDExpandableButtonViewSource <NSObject>

- (CGSize)defaultFrameSize;

@optional
- (void)setHighlighted:(BOOL)highlighted;

@end