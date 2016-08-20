
var exec = require('cordova/exec');

var PLUGIN_NAME = 'CordovaMobilePayAppSwitch';

var CordovaMobilePayAppSwitch = {
  startPayment: function(amount, orderId, success, fail) {
    exec(success, fail, PLUGIN_NAME, 'startPayment', [amount, orderId]);
  }
};

module.exports = CordovaMobilePayAppSwitch;
