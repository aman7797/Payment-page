const callbackMapper = {
  map : function(fn) {
    if(typeof window.__FN_INDEX !== 'undefined' && window.__FN_INDEX !== null) {
      var proxyFnName = 'F' + window.__FN_INDEX;
      window.__PROXY_FN[proxyFnName] = fn;
        window.__FN_INDEX++;
      return proxyFnName;
    } else {
      throw new Error("Please initialise window.__FN_INDEX = 0 in index.js of your project.");
    }
  }
}

exports["startGodel'"] = function(payload) {
  return function(sc){
    return function(tracker){
      return function(){          
          if(JOS) {
            if (window.__OS.toUpperCase() == 'IOS') {
              var callback = callbackMapper.map(function(payload) {
                // debugger;
                var parsedData = JSON.parse(payload);
                console.log("startGodel",parsedData);
                JBridge.setSessionId(window.hyper_session_id);
                tracker(JSON.stringify(parsedData))();
                sc(parsedData)();
              });
              JBridge.startGodel(payload, callback);
            } else {
              var cb = function(code) {
                return function(status) {
                  return function() {
                    console.log("Returning from Godel:", code, status);
                    var resp = {
                      code: code,
                      status: status
                    }
                    JBridge.setSessionId(window.hyper_session_id);
                    tracker(JSON.stringify(resp))();
                    sc(resp)();
                  }
                }
              }
              JOS.startApp("in.juspay.godel")(JSON.parse(payload))(cb)();
            }
          }
      }
    }
  }
}
