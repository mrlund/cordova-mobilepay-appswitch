#import <Cordova/CDVPlugin.h>

@interface CordovaMobilePayAppSwitch : CDVPlugin {
}

// The hooks for our plugin commands
- (void)startPayment:(CDVInvokedUrlCommand *)command;

@end
