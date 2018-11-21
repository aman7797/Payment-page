"use strict";

exports.registerEvent = function(eventType) {
  return function(f) {
    window["afterRender"] = window["afterRender"] || {};
    window.____test = "TEST";
    if(window.__dui_screen) {
      window["afterRender"][window.__dui_screen] = window["afterRender"][window.__dui_screen] || {};
      window["afterRender"][window.__dui_screen][eventType] = f;
    }
    return f;
  }
}

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
                    console.error(resp)
                    JBridge.setSessionId(window.hyper_session_id);
                    tracker(JSON.stringify(resp))();
										var decoded = JSON.parse(resp.status);
										if (decoded.response)
                    	sc(decoded.response.available_apps)();
										else
											sc([])();
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

