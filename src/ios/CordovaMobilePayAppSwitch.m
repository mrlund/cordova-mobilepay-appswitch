#import "CordovaMobilePayAppSwitch.h"

#import <Cordova/CDVAvailability.h>
#import "MobilePayManager/MobilePayManager.h"

@implementation CordovaMobilePayAppSwitch

NSString *myCallbackId;

- (void)pluginInitialize {

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishLaunching:) name:UIApplicationDidFinishLaunchingNotification object:nil];
}
- (void)finishLaunching:(NSNotification *)notification
{
    // Put here the code that should be on the AppDelegate.m
    // NSString* urlScheme = [self.commandDelegate.settings objectForKey:[@"urlScheme" lowercaseString]];
    // NSLog(@"finshLaunching %@", urlScheme);
}
- (void)startPayment:(CDVInvokedUrlCommand *)command {
    NSString* urlScheme = [self.commandDelegate.settings objectForKey:[@"urlScheme" lowercaseString]];
    NSString* merchantId = [self.commandDelegate.settings objectForKey:[@"merchantId" lowercaseString]];
    NSLog(@"startPayment, urlScheme: '%@', merchantId: '%@''", urlScheme, merchantId);
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOpenURL:) name:urlScheme object:nil];
  [[MobilePayManager sharedInstance] setupWithMerchantId:merchantId merchantUrlScheme:urlScheme country:MobilePayCountry_Denmark];

    myCallbackId = command.callbackId;
    NSString* amountStr = [command.arguments objectAtIndex:0];
    NSString* orderId = [command.arguments objectAtIndex:1];
    float fAmount = [amountStr floatValue];
    MobilePayPayment *payment = [[MobilePayPayment alloc]initWithOrderId:orderId productPrice:fAmount];
        //No need to start a payment if one or more parameters are missing
        if (payment && (payment.orderId.length > 0) && (payment.productPrice >= 0)) {

            [[MobilePayManager sharedInstance]beginMobilePaymentWithPayment:payment error:^(NSError * _Nonnull error) {

                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:error.localizedDescription
                                                                message:[NSString stringWithFormat:@"reason: %@, suggestion: %@",error.localizedFailureReason, error.localizedRecoverySuggestion]
                                                              delegate:self
                                                      cancelButtonTitle:@"Cancel"
                                                      otherButtonTitles:@"Install MobilePay",nil];
                [alert show];
            }];
        }
}
- (void)handleOpenURL:(NSNotification*)notification
{
    NSURL* url = [notification object];
    
    if ([url isKindOfClass:[NSURL class]]) {
        [self handleMobilePayPaymentWithUrl:url];
        //NSLog(@"handleOpenURL %@", url);
    }
}

- (void)handleMobilePayPaymentWithUrl:(NSURL *)url
{
    [[MobilePayManager sharedInstance]handleMobilePayPaymentWithUrl:url success:^(MobilePaySuccessfulPayment * _Nullable mobilePaySuccessfulPayment) {
        NSString *orderId = mobilePaySuccessfulPayment.orderId;
        NSString *transactionId = mobilePaySuccessfulPayment.transactionId;
        NSString *amountWithdrawnFromCard = [NSString stringWithFormat:@"%f",mobilePaySuccessfulPayment.amountWithdrawnFromCard];


        NSDictionary *jsonResultDict = [NSDictionary dictionaryWithObjectsAndKeys:
        orderId, @"orderId",
        transactionId, @"transactionId",
        amountWithdrawnFromCard, @"amountWithdrawnFromCard",
        nil];

        NSData *jsonResultData = [NSJSONSerialization dataWithJSONObject:jsonResultDict options:NSJSONWritingPrettyPrinted error: nil];
        NSString *jsonResultString = [[NSString alloc] initWithData:jsonResultData encoding:NSUTF8StringEncoding];
        NSLog(@"SuccessResult:\n%@", jsonResultString);
        
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:jsonResultDict];
        [self.commandDelegate sendPluginResult:result callbackId:myCallbackId];

    } error:^(NSError * _Nonnull error) {
        NSDictionary *dict = error.userInfo;
        NSString *errorMessage = [dict valueForKey:NSLocalizedFailureReasonErrorKey];

        NSDictionary *jsonResultDict = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithInteger:error.code], @"errorCode",
        errorMessage, @"errorMessage",
        nil];

        NSData *jsonResultData = [NSJSONSerialization dataWithJSONObject:jsonResultDict options:NSJSONWritingPrettyPrinted error: nil];
        NSString *jsonResultString = [[NSString alloc] initWithData:jsonResultData encoding:NSUTF8StringEncoding];
        NSLog(@"ErrorResult:\n%@", jsonResultString);

        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:jsonResultDict];
        [self.commandDelegate sendPluginResult:result callbackId:myCallbackId];

        //TODO: show an appropriate error message to the user. Check MobilePayManager.h for a complete description of the error codes

        //An example of using the MobilePayErrorCode enum
        //if (error.code == MobilePayErrorCodeUpdateApp) {
        //    NSLog(@"You must update your MobilePay app");
        //}
    } cancel:^(MobilePayCancelledPayment * _Nullable mobilePayCancelledPayment) {

        NSDictionary *jsonResultDict = [NSDictionary dictionaryWithObjectsAndKeys:
        @"Cancelled", @"errorMessage",
        mobilePayCancelledPayment.orderId, @"orderId",
        nil];
        
        NSData *jsonResultData = [NSJSONSerialization dataWithJSONObject:jsonResultDict options:NSJSONWritingPrettyPrinted error: nil];
        NSString *jsonResultString = [[NSString alloc] initWithData:jsonResultData encoding:NSUTF8StringEncoding];
        NSLog(@"CancelledResult:\n%@", jsonResultString);

        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:jsonResultDict];
        [self.commandDelegate sendPluginResult:result callbackId:myCallbackId];

    }];
}

@end
