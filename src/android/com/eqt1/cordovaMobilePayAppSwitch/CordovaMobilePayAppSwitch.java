package com.eqt1.cordovaMobilePayAppSwitch;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.PluginResult;
import org.apache.cordova.PluginResult.Status;
import org.json.JSONObject;
import org.json.JSONArray;
import org.json.JSONException;

import android.app.Activity;
import android.content.Intent;
import android.util.Log;

import java.math.BigDecimal;

import dk.danskebank.mobilepay.sdk.CaptureType;
import dk.danskebank.mobilepay.sdk.Country;
import dk.danskebank.mobilepay.sdk.MobilePay;
import dk.danskebank.mobilepay.sdk.ResultCallback;
import dk.danskebank.mobilepay.sdk.model.FailureResult;
import dk.danskebank.mobilepay.sdk.model.Payment;
import dk.danskebank.mobilepay.sdk.model.SuccessResult;

public class CordovaMobilePayAppSwitch extends CordovaPlugin {
  private static final String TAG = "CordovaMobilePayAppSwitch";
  public CordovaInterface cordova = null;
  public CallbackContext callbackContext = null;
  public int MOBILEPAY_PAYMENT_REQUEST_CODE = 1337;

  public void initialize(CordovaInterface cordova, CordovaWebView webView) {
    super.initialize(cordova, webView);
    this.cordova = cordova;

    int merchantResId = cordova.getActivity().getResources().getIdentifier("merchantId", "string", cordova.getActivity().getPackageName());
    String merchantId = cordova.getActivity().getString(merchantResId);
    
    MobilePay.getInstance().init(merchantId, Country.DENMARK);

    Log.d(TAG, "Initializing CordovaMobilePayAppSwitch");
  }

  public boolean execute(String action, JSONArray args, final CallbackContext callbackContext) throws JSONException {
    if(action.equals("startPayment")) {
      String amount = args.getString(0);
      this.callbackContext = callbackContext;

        // Check if the MobilePay app is installed on the device.
        boolean isMobilePayInstalled = MobilePay.getInstance().isMobilePayInstalled(cordova.getActivity().getApplicationContext());

        if (isMobilePayInstalled) {
          // MobilePay is present on the system. Create a Payment object.
          Payment payment = new Payment();
          payment.setProductPrice(new BigDecimal(amount));
          payment.setOrderId("86715c57-8840-4a6f-af5f-07ee89107ece");

          // Create a payment Intent using the Payment object from above.
          Intent paymentIntent = MobilePay.getInstance().createPaymentIntent(payment);

          // We now jump to MobilePay to complete the transaction. Start MobilePay and wait for the result using an unique result code of your choice.
          cordova.setActivityResultCallback(this);
          cordova.getActivity().startActivityForResult(paymentIntent, MOBILEPAY_PAYMENT_REQUEST_CODE);
          } else {
              // MobilePay is not installed. Use the SDK to create an Intent to take the user to Google Play and download MobilePay.
              Intent intent = MobilePay.getInstance().createDownloadMobilePayIntent(cordova.getActivity().getApplicationContext());
              cordova.getActivity().startActivity(intent);
          }
          //Send a plugin result with NO_RESULT and set KeepCallback as true
          PluginResult r = new PluginResult(PluginResult.Status.NO_RESULT);
          r.setKeepCallback(true);
          callbackContext.sendPluginResult(r);

      } else if(action.equals("getDate")) {
        // An example of returning data back to the web layer
        final PluginResult result = new PluginResult(PluginResult.Status.OK, ("Not Implemented"));
        callbackContext.sendPluginResult(result);
      }
    return true;
  }
  @Override
  public void onActivityResult(int requestCode, int resultCode, Intent data) {
    final CordovaMobilePayAppSwitch that = this; 
    super.onActivityResult(requestCode, resultCode, data);
    if (requestCode == MOBILEPAY_PAYMENT_REQUEST_CODE) {
      // The request code matches our MobilePay Intent
      MobilePay.getInstance().handleResult(resultCode, data, new ResultCallback() {
        @Override
        public void onSuccess(SuccessResult result) {
          // The payment succeeded - you can deliver the product.
          Log.d(TAG, result.getTransactionId());
          final PluginResult successResult = new PluginResult(PluginResult.Status.OK, result.getTransactionId());
          that.callbackContext.sendPluginResult(successResult);          
        }
        @Override
        public void onFailure(FailureResult result) {
          Log.d(TAG, result.getErrorMessage());
          final PluginResult failResult = new PluginResult(PluginResult.Status.ERROR, result.getErrorMessage());
          that.callbackContext.sendPluginResult(failResult);          
          // The payment failed - show an appropriate error message to the user. Consult the MobilePay class documentation for possible error codes.
        }
        @Override
        public void onCancel() {
          Log.d(TAG, "Cancelled");
          // The payment was cancelled.
        }
      });
    }
  }  

}
