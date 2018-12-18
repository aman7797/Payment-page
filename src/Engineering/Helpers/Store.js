"use strict";



exports.setToStore = function(key, value) {
  window.___STORE = window.___STORE || {};

  window.___STORE[key] = window.___STORE[key] || {};
  window.___STORE[key]["value"] = value;


  if(window.___STORE[key]["cb"]) {
    window.___STORE[key]["cbStatus"] = true;
    window.___STORE[key]["cb"](value)();
  }

}

exports.setErrorToStore = function(key, err) {
  console.warn("STORE -> Received Error callback for KEY=", key);
  console.warn("STORE -> err: ", err);
}

exports.getFromStore = function(key, nothing, just) {
  if (window.___STORE && window.___STORE[key] && window.___STORE[key]["value"]) {
    return just(window.___STORE[key]["value"]);
  } else {
    return nothing;
  }
}



exports.registerCallback = function(key, cb) {
  window.___STORE = window.___STORE || {};

  window.___STORE[key] = window.___STORE[key] || {};
  window.___STORE[key]["cb"] = cb;

  if(window.___STORE[key]["value"]  && !window.___STORE[key]["cbStatus"]) {
    window.___STORE[key]["cbStatus"] = true;
    cb(window.___STORE[key]["value"])();
  } else {
		window.___STORE[key]["cbStatus"] = false;
	}

}











exports.checkStatus = function(key) {
   // 0 -> NoKey
   // 1 -> Status Initiated NoReq
   // 2 -> Status Initiated Registered
   // 3 -> Status Populated NoReq
   // 4 -> Status Populated Responsed
  if(!window.___STORE) {
    return 0;
  }

  if(window.___STORE[key]) {
    // 1,2,3,4  initiated
    if(window.___STORE[key]["value"]) {
      // 3,4 populated
      if(window.___STORE[key]["cb"] &&  window.___STORE[key]["cbStatus"]) {
        return 4;
      } else {
        // Assuming if cb is registered and value populated, then cb is called.
        return 3;
      }
    } else {
      // 1,2 notpopulated
      if(window.___STORE[key]["cb"]) {
        return 2;
      } else {
        return 1;
      }
    }
  } else {
    return 0;
  }

}
