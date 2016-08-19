|Android|iOS|
|:-:|:-:|

# Cordova Plugin for Danske Bank MobilePay AppSwitch
======

This is an unofficial Cordova plugin wrapping the Danske Bank AppSwitcher libraries for iOS and Android to enable Cordova apps to incorporate the MobilePay AppSwitch payment flow.

> This plugin is not developed, published or otherwise affiliated with Danske Bank or MobilePay, but is a private project released "as-is" to the public by the author.  


## <a id="reference"></a>Reference
## Installation

This requires cordova 5.0+ ( current stable 1.0.0 )

    cordova plugin add cordova-mobilepay-appswitch --variable URL_IDENTIFIER="com.example.myapp" --variable URL_SCHEME="myAppUrlScheme" --variable MERCHANT_ID="APPDK0000000000"

It is also possible to install via repo url directly ( unstable )

    cordova plugin add https://github.com/mrlund/cordova-mobilepay-appswitch.git -variable URL_IDENTIFIER="com.example.myapp" --variable URL_SCHEME="myAppUrlScheme" --variable MERCHANT_ID="APPDK0000000000"

## Supported Platforms

- Android
- iOS

## Methods

- window.CordovaMobilePayAppSwitch.startPayment

## Objects (Read-Only)

- Amount
- OrderId
- Result
- Success
- Failed
- Error

## window.CordovaMobilePayAppSwitch.startPayment

Starts the payment through MobilePay and returns the `success`
callback with a `Result` object as the parameter.  If there is an
error, the `failed` callback is passed a
`Error` object.

    window.CordovaMobilePayAppSwitch.startPayment(amount,
                                             [orderId],
                                             [success],
                                             [failed]);

### Parameters

- __amount__: The amount to be charged.

- __orderId__: _(Optional)_ The order id to identify the order.

- __success__: _(Optional)_ The callback that executes on success.

- __failed__: _(Optional)_ The callback that executes on failure.


### Example

```javascript

    // amount
    //
    var amount = '150'

    //orderId
    //
    var orderId = '1234'

    // onSuccess Callback
    // This method accepts a Result object, which contains the
    // transactionId
    //
    var onSuccess = function(result) {
        alert('OrderId: '          + result.orderId          + '\n' +
              'TransactionId: '         + result.transactionId         + '\n' +
              'AmountWithdrawnFromCard: '          + result.amountWithdrawnFromCard          + '\n' +
    };

    // onError Callback receives an errorr string
    //
    function onError(error) {
        alert('message: ' + error + '\n');
    }

    window.CordovaMobilePayAppSwitch.startPayment(amount, orderId, onSuccess, onError);

```

