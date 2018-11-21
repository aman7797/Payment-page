exports["checkAmazonSdk'"] = function(sc) {
  return function(){
    var cb = window.callbackMapper.map(function(payload) {
      sc(payload)();
    });
    JBridge.checkAmazonSdk(cb);
  }
}

exports["getAmazonBalance'"] = function(merchantId,isSandbox,sc) {
  return function(){
    var cb = window.callbackMapper.map(function(payload) {
      sc(payload)();
    });
    JBridge.getAmazonBalance(merchantId,isSandbox,cb);
  }
}

exports["linkAmazonPay'"] = function(color,sc) {
  return function(){
    var cb = window.callbackMapper.map(function(payload) {
       sc(payload)();
    });
    JBridge.linkAmazonPay(color,cb);
  }
}

exports["amazonChargeStatus'"] = function(maxPollPeriod,interval,isSandbox,payload,just,nothing,sc,tracker) {
  return function(){
    var cb = window.callbackMapper.map(function(result) {
      try {
        output = JSON.parse(result);
        tracker(output.transactionStatus)();
        sc(just(output))();
      } catch(e) {
        sc(nothing)();
      }
    });
    JBridge.amazonChargeStatus(maxPollPeriod,interval,isSandbox,cb,payload);
  }
}
