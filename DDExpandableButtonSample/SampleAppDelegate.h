//
//  SampleAppDelegate.h
//  DDExpandableButtonSample
//

#import <UIKit/UIKit.h>

@class SampleViewController;

@interface SampleAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, strong) IBOutlet UIWindow *window;

@property (nonatomic, strong) IBOutlet SampleViewController *viewController;

@end
