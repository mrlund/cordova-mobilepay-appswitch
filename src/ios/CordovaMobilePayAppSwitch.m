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
    float fAmount = [amountStr floatValue];
    MobilePayPayment *payment = [[MobilePayPayment alloc]initWithOrderId:@"123456" productPrice:fAmount];
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
        NSLog(@"MobilePay purchase succeeded: Your have now paid for order with id '%@' and MobilePay transaction id '%@' and the amount withdrawn from the card is: '%@'", orderId, transactionId,amountWithdrawnFromCard);
        
        NSString *resultString = [NSString stringWithFormat:@"Success. Order id '%@', transaction id '%@' for amount '%@' completed succesfully.", orderId, transactionId, amountWithdrawnFromCard];
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:resultString];
        [self.commandDelegate sendPluginResult:result callbackId:myCallbackId];

    } error:^(NSError * _Nonnull error) {
        NSDictionary *dict = error.userInfo;
        NSString *errorMessage = [dict valueForKey:NSLocalizedFailureReasonErrorKey];
        NSLog(@"MobilePay purchase failed:  Error code '%li' and message '%@'",(long)error.code,errorMessage);

        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"Error: '%@'", errorMessage]];
        [self.commandDelegate sendPluginResult:result callbackId:myCallbackId];

        //TODO: show an appropriate error message to the user. Check MobilePayManager.h for a complete description of the error codes

        //An example of using the MobilePayErrorCode enum
        //if (error.code == MobilePayErrorCodeUpdateApp) {
        //    NSLog(@"You must update your MobilePay app");
        //}
    } cancel:^(MobilePayCancelledPayment * _Nullable mobilePayCancelledPayment) {
        NSLog(@"MobilePay purchase with order id '%@' cancelled by user", mobilePayCancelledPayment.orderId);
        
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Cancelled by user"];
        [self.commandDelegate sendPluginResult:result callbackId:myCallbackId];

    }];
}

@end
