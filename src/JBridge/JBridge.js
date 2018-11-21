var CardValidator = require('simple-card-validator');


exports.logAny = function(element) {
  console.log(element);
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

exports.getElemPostion = function (id) {
  try {
    var elem = document.getElementById(id);
    return { x : parseInt(elem.style.left) , y : parseInt(elem.style.top) }
  } catch (error) {
    return { x : 0 , y : 0  }
  }
}

exports.changeCursorTo = function (cursorType) {
        document.body.style.cursor=cursorType;
}

exports.updateViewPort = function (screenSize){
  var viewport ;
  viewport = document.querySelector("meta[name=viewport]");
  if(viewport) {
    // viewport.setAttribute('content', 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0');
    viewport.setAttribute('content', 'width='+(screenSize.width + 50 )+', height='+(screenSize.height + 100 )+', initial-scale=1.0');
    return true;
  } else{
    var metaTag=document.createElement('meta');
    metaTag.name = "viewport"
    metaTag.content = "width="+(screenSize.width + 50)+", height="+(screenSize.height + 100 )+", initial-scale=1.0"
    document.getElementsByTagName('head')[0].appendChild(metaTag);
    return true;
  }
  return false;
}

exports.updateLayoutCursor = function (id) {
  return function (cursorType) {
     var elem = document.getElementById(id);
    if (elem){
      elem.style.cursor=cursorType;
    } else{
      document.body.style.cursor=cursorType;
    }
  }
}

exports.getText = function (id) {
  var elem = document.getElementById(id);
  console.log(elem);
  if (elem){
    return elem.value
  } else{
    return ""
  }
}


exports["getPaymentMethods"] = function(key) {
  var config = window.getConfig()
  if (config && config["payment_order"]){
    return config["payment_order"]
  } else {
    return []
  }
}

exports["getFromConfig"] = function(key) {
  var config = window.getConfig()
  if (config && config[key]){
    return config[key]
  } else {
    return []
  }
}

exports["getWalletConfigs"] = function() {
  var config = window.getConfig()
  if (config && config["otp_config"]){
    return config["otp_config"]
  } else {
    return []
  }
}

exports["getKeyboardHeight"] = function () {
  try {
    if (!window["__keyboard_height_details"]) {
      window["__keyboard_height_details"] = JSON.parse(JBridge.keyboardDetail());
    }
    return window["__keyboard_height_details"].height;
  } catch(err) {
    return 0;
  }
}

exports["getKeyboardDuration"] = function () {
  try {
    if (!window["__keyboard_height_details"]) {
      window["__keyboard_height_details"] = JSON.parse(JBridge.keyboardDetail());
    }
    return window["__keyboard_height_details"].duration;
  } catch(err) {
    return 0;
  }
}

exports["getCardValidation"] = function (number) {
  try {
    var card = new CardValidator(number);
    var validation = card.getCardDetails();
    switch(validation.card_type){
      case 'mastercard' : validation.card_type = "master"; break;
      case 'diners_club_international' : validation.card_type = "diners"; break;
      case 'diners_club_carte_blanche' : validation.card_type = "diners"; break;
    }
    return validation;
  }catch (e){
    return {
      card_type : "undefined",
      valid : true,
      luhn_valid : true ,
      length_valid : true ,
      cvv_length : [3],
      supported_lengths : [15] 
    }
  }
}

// exports["setSessionAttribute'"] = function(key) {
//   return function(value) {
//     JBridge.setSessionAttribute(key, value);
//   }
// }

exports["getSessionAttribute'"] = function(key) {
  var x = JBridge.getSessionAttribute(key);
  if(x == "") {
    x = "__failed";
  }

  return x;
}

exports.getKeyboardHeight = function() {
  if (!JBridge.keyboardDetail) {
    return 0;
  }
  const params = JSON.parse(JBridge.keyboardDetail());
  return params.height;
}

exports.getKeyboardDuration = function () {
  if (!JBridge.keyboardDetail) {
    return 0;
  }
  const params = JSON.parse(JBridge.keyboardDetail());
  return params.duration * 1000;
}

exports["hideKeyboard"] = function() {
  JBridge.requestKeyboardHide();
}

exports["showKeyboard"] = function(id) {
  JBridge.requestKeyboardShow(id);
}


exports.requestKeyboardHide = function() {
  if (window.__OS == "ANDROID") {
    JBridge.requestKeyboardHide();
  }
}

exports.requestKeyboardShow = function(id) {
  return function() {
    if (window.__OS == "ANDROID") {
      JBridge.requestKeyboardShow(id);
    }
  }
}

exports["detach"] = function(id) {
  JBridge.detach([id]);
}

exports["bringToFocus"] = function(pID) {
  return function(cID) {
    try {
      var cmd = "set_childView=ctx->findViewById:i_"+cID+";"
      cmd += "set_btm=get_childView->getBottom;"
      cmd += "set_scrollView=ctx->findViewById:i_"+pID+";"
      cmd += "get_scrollView->scrollTo:i_0,get_btm;"
      setTimeout(function(){
        Android.runInUI(cmd,null);
      },100)
    }catch(e){
      return false;
    }
    return true;
  }
}

exports.requestFocus = function(id) {
  try{
    setTimeout(function(){
      if (window.__OS == "IOS") {
         Android.runInUI({id: id, becomeFirstResponder: true});
      } else {
        Android.runInUI("set_view=ctx->findViewById:i_" + id + ";get_view->requestFocus", null);
      }
    },100)
  }catch(e){
    return false;
  }
  return true;
}

exports["attach'"] = function(eventListener){
  return function(args){
    return function(callbackId){
      return function(){
        return JBridge.attach(eventListener,args,callbackId);
      }
    }
  }
}

exports["getToken"] = function (a){
  return function(b){
    return function(c){
      return function(){
        // if(JBridge.yesbank_getToken)
        // {
          return JBridge.yesbank_getToken(a,b,c);
      //   }
      //   return ""
      }
    }
  }
}

exports["init"] = function (sc){
  return function(a){
    return function(b){
      return function(c){
        return function(){
          var callback = callbackMapper.map(function(payload) {
            var parsedData = payload;
            console.log("INIT",parsedData);
            sc(JSON.parse(payload))();
          });
          JBridge.yesbank_init(a,b,c,callback);
        }
      }
    }
  }
}


exports["sendSMS"] = function (sc){
  return function(a){
    return function(){
      var callback = callbackMapper.map(function(payload) {
        var parsedData = payload;
        console.log("SendSMS",parsedData);
        sc(JSON.parse(payload))();
      });
      JBridge.yesbank_sendSMS(a,callback);
    }
  }
}

exports["setMPIN"] = function (sc){
  return function(a){
    return function() {
      var callback = callbackMapper.map(function(payload) {
        var parsedData = payload;
        console.log("SetMpin",parsedData);
        if (window.__OS == "ANDROID" )
          {
            var pay = {status : (payload.status == "S") + ''
                      ,statusCode : payload.status
                      ,response : {
                      status : payload.status == "MC07" ? "Cancelled" : (payload.status == "S") + ''
                    } 
                   }
            sc(pay)();
          }
        else
          sc(JSON.parse(payload))();
      });
      JBridge.yesbank_setMPIN( a, callback);
    }
  }
}


exports["checkBalance"] = function (sc){
  return function(a){
    return function() {
      var callback = callbackMapper.map(function(payload) {
        var parsedData = payload;
        console.log("CheckBalance",parsedData);
        sc(JSON.parse(payload))();
      });
      JBridge.yesbank_checkBalance( a, callback);
    } 
  }
}


exports["transaction"] = function (sc){
  return function(a) {   
    console.log("12HEREEEEEE");
    return function() {
      console.log("44HEREEEEEE");
      var callback = callbackMapper.map(function(payload) {
        console.log("Tansaction",payload);
        if (window.__OS == "ANDROID"){
          var pay = {status : (payload.statusCode == "S") + ''
                    ,statusCode : payload.statusCode
                    ,response : {
                      status : payload.statusCode == "MC07" ? "Cancelled" : (payload.statusCode == "S") + ''
                    } 
                   }
          console.log("Pay", pay)
          sc(pay)();
        }
        else {
          sc(JSON.parse(payload))();
        }
      });
      console.log("HER33EEEEEE");
      window.__vai = JSON.stringify(a);
      console.log("HER4433EEEEEE");
      JBridge.yesbank_transaction( a, callback);
      console.log("HE3R4433EEEEEE");
    }
  }
}

exports["encrypt"] = function (a){
  return function(b){
      return JBridge.yesbank_encrypt(a,b);
    // return "";
  }
}

exports["decrypt"] = function (a){
  return function(b){
      return JBridge.yesbank_decrypt(a,b);
  }
}


exports["collectApprove"] = function (a){
  return function(){
    // if(JBridge.yesbank_collectApprove)
    // {
      return JBridge.yesbank_collectApprove(a);
      // }
      // return "";
    }
  }

exports["getScrollTop"] = function (id) {
  if(typeof JBridge.scrollVisibleTop == "function") {
      return parseInt(JBridge.scrollVisibleTop(String(id)));  
    }
    return -1;
  }
