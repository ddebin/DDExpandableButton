//
//  SampleAppDelegate.m
//  DDExpandableButtonSample
//

#import "SampleAppDelegate.h"
#import "SampleViewController.h"


@implementation SampleAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[self.window addSubview:self.viewController.view];
	[self.window makeKeyAndVisible];
    return YES;
}

@end
