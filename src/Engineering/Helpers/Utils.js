exports["getValueFromObject'"] = function(object){
  return function(key){
    return object[key];
  }
}

exports["getArrayFromObject'"] = function(object){
  return function(key){
    var value = object[key];
    if (typeof value == "string") {
      return JSON.parse(value);
    } else {
      return value
    }
  }
}


exports.convertJSONToParams = function(json){
  var data = "";
  try {
    for(var i in json) {
      data += "" + i + "=" + json[i] + "&"
    }
    data = (data[data.length-1] == "&") ? (data.slice(0,data.length-1)) : data
  } catch(err) {}
  return data;
}

exports["eval'"] = function(string) {
  return function(){
    try {
      eval(string);
    } catch (err) {
      try{
        eval('('+string+')');
      } catch (error) {
        console.error(error);
      }
    }
    return;
  }
}

exports["readFile'"] = function(filePath) {
  return function() {
    // return JBridge.loadFileInDUI(filePath)
    return;
  }
}

exports.getSessionInfo = function() {
  return JSON.parse(DUIGatekeeper.getSessionInfo());
}

exports.window = window

exports["setScreen'"] = function(screen) {
  return function() {
    setTimeout(function() {
      if(window.idToBeRemoved) {
          Android.runInUI("set_VIEW=ctx->findViewById:i_" + window.idToBeRemoved + ";get_VIEW->removeAllViews;", null);
          Android.runInUI("set_VIEW=ctx->findViewById:i_" + window.idToBeRemoved + ";set_PARENT=get_VIEW->getParent;get_PARENT->removeView:get_VIEW;", null);
          window.idToBeRemoved = null;
      }
    }, 1200);
    window.__dui_screen = screen
  }
}
exports["getValueFromPayload'"] = function(key) {
  var payload = window.__payload;
  if(typeof payload != "undefined") {
    if(typeof payload[key] != "undefined") {
      return "" + payload[key];
    } else {
      console.log("Value not found for key "+key+" in payload: ");
    }
  } else {
    console.log("Payload not found");
  }
  return "";
}


exports.getCurrentYear = function (a) {
  var date = new Date();
  return date.getFullYear();
}

exports.getCurrentMonth = function (b) {
  var date = new Date();
  return (date.getMonth() + 1);
}


exports["exitApp'"] = function(code) {
  return function(status) {
    if (window.__OS=="ANDROID"){
      Android.runInUI("set_VIEW=ctx->findViewById:i_" + "14314314" + ";get_VIEW->removeAllViews;", null);
      Android.runInUI("set_VIEW=ctx->findViewById:i_" + "14314314" + ";set_PARENT=get_VIEW->getParent;get_PARENT->removeView:get_VIEW;", null);
      console.log("Loader View Removed")
    }    
    if(JOS) {
      JOS.finish(code)(status)();
    }
  }
}

// exports["setDelay"] = function(action)
// {
//   return function (time)
//   {
//     setTimeout(action,time);
//   }
// }

exports["setDelay"] = function(action)
{
  return function(ms) {
    return function ()
    {
      var start = Date.now(),
        now = start;
      while (now - start < ms) {
          now = Date.now();
      }
      return action;
    }
  }
}

exports["isOnline'"] = function(){
  return JBridge.isOnline();
}


exports["sendBillerChanges"] = function(billerChanges){
  return function(sc) {   
      console.log("SendBiller Changes ", billerChanges, sc);
      return function() {
        console.log("Biller Changes CallBack Called");
        var callback = callbackMapper.map(function(payload) {
            var parsedData = JSON.parse(payload);
            console.log("Biller Changes",parsedData);
            sc(JSON.stringify(parsedData))();
        });
        console.log(callback);
        // JBridge.runInJuspayBrowser("onEvent",JSON.stringify(billerChanges), callback);
        var json = { event   : "onPayloadChange"
                   , payload : billerChanges
                   } 
        JBridge.runInJuspayBrowser("onEvent", JSON.stringify(billerChanges), callback);
      }
    }
}

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

exports["getSimOperators'"] = function(x) {
  return function(){
      if(JBridge.getSIMOperators === undefined){
        if (__OS == "IOS")
          return ([{slotId:0,carrierName:"DEFAULT_CARD", simId:"76123576"}])
        return JSON.stringify([{slotId:0,carrierName:"NO_SIM_CARD"}]);
      } else {
        if(JBridge.getSIMOperators() === undefined){
          return JSON.stringify([{slotId:0,carrierName:"NO_SIM_CARD"}]);
        }
        else
          return JBridge.getSIMOperators();
      }
  }
};

exports["getCurrentTime"] = function () {
  console.log("---------------------getCurrentTime-------------------", (new Date()).getTime());
  return ((new Date()).getTime());
}

exports["getLoaderConfig"] = {
  customLoader: false,
  parentId: "14314314"
}

exports.eligibleForUPI = (parseInt(JBridge.getResourceByName("godel_build_version")) >= 16);