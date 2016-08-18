
var exec = require('cordova/exec');

var PLUGIN_NAME = 'CordovaMobilePayAppSwitch';

var CordovaMobilePayAppSwitch = {
  startPayment: function(amount, cb, fail) {
    exec(cb, fail, PLUGIN_NAME, 'startPayment', [amount]);
  }
};

module.exports = CordovaMobilePayAppSwitch;
