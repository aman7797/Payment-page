exports["startUPI'"] = function(payload){
    return function(sc){
      return function(tracker){
        return function(){
            var cb = function(code) {
                return function(status) {
                  return function() {
                    console.log("Returning from EC UPI:", code, status);
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
  
            if(JOS) {
                JOS.startApp("in.juspay.ec.upi")(payload)(cb)();
            }
        }
      }
    }
  }