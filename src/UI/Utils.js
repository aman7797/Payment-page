const state = {
  cardNumber: "",
  cardNumberHandler: null,
  cardNumberCallbackHandler: null,
  expiryNumber: "",
  expiryNumberHandler: null,
  expiryNumberCallbackHandler: null,
  screenHeight: null,
};

const FRAME_DURATION = 16;

exports.logit = function(x){console.log("LOGGING",x)}

exports.logAny = function(a) {
  console.log("@@@", a);

  return a;
}

exports.getOs = function () {
  var userAgent = navigator.userAgent;
  if (!userAgent)
    return console.error(new Error("UserAgent is null"));
  if (userAgent.indexOf("Android") != -1 && userAgent.indexOf("Version") != -1)
    return "ANDROID";
  if (userAgent.indexOf("iPhone") != -1 && userAgent.indexOf("Version") == -1)
    return "IOS";
  return "WEB";
}

exports.screenHeight = function () {
  if (state.screenHeight === null) {
    state.screenHeight = window.__HEIGHT;
    if (window.__OS == "ANDROID") {
      state.screenHeight = (parseInt(window.__HEIGHT)) / JBridge.getPixels() - parseInt( JBridge.getResourceByName("status_bar_height","dimen","android")) ;
    }
  }
  return state.screenHeight;
}

exports.statusBarHeight = function(x){
  if (window.__OS == "ANDROID")
    return parseInt( JBridge.getResourceByName("status_bar_height","dimen","android"));
  else
    return 0;
}

exports.date = function (x){
    var today = new Date();
    var dd = today.getDate();
    var mm = today.getMonth()+1; //January is 0!
    var yyyy = today.getFullYear();
    if(dd<10) {
        dd = '0'+dd
    }
    if(mm<10) {
        mm = '0'+mm
    }
    today = dd + '-' + mm + '-' + yyyy;
    return today;
}

exports["_cardNumberHanlder"] = function (id) {
  return function (str) {
    return function (push) {
      if (state.cardNumberHandler != null) {
        clearTimeout(state.cardNumberHandler);
      }
      state.cardNumberHandler = setTimeout(cardNumber.bind(this, id, str, push), FRAME_DURATION);
    }
  }
}

exports["_expiryHandler"] = function (id) {
  return function (str) {
    return function (push) {
      if (state.expiryNumberHandler != null) {
        clearTimeout(state.expiryNumberHandler);
      }
      state.expiryNumberHandler = setTimeout(expiryNumber.bind(this, id, str, push), FRAME_DURATION);
    }
  }
}

function expiryNumber(id, str, push) {
  state.expiryNumberHandler = null;
  if (str === state.expiryNumber) {
    return;
  }
  var sExpiry = state.expiryNumber;
  var sLen = sExpiry.length;
  var len = str.length;
  var cursorPos = parseInt(JBridge.cursorPosition(parseInt(id)));
  // Trailing forward slash removed by the user
  if ((sLen - len) == 1 && sExpiry[cursorPos] == '/' && str[cursorPos] !== '/') {
    setText(id, sExpiry, cursorPos);
    return;
  }

  var rawDate = "";
  // debugger;
  for (var i = 0; i < str.length; i++) {
    if (str[i] >= '0' && str[i] <= '9') {
      rawDate += str[i];
      if (rawDate.length == 4){
        break;
      }
    }
  }

  var month = rawDate.substring(0, 2);
  var year = rawDate.substring(2,4);
  var formattedDate = "";

  if (month.length == 1 && month > 1) {
    month = "0" + month;
  } else if (month.length == 2 && (month > 12 || month == 0)) {
    month = "12";
  }
  formattedDate = month;

  if (formattedDate.length == 2) {
    if(cursorPos<3){
      cursorPos = 3;
    }
    formattedDate += '/';
  }

  formattedDate += year;

  state.expiryNumber = formattedDate;
  if (state.expiryNumberCallbackHandler != null) {
    clearTimeout(state.expiryNumberCallbackHandler);
  }
  state.expiryNumberCallbackHandler = setTimeout(callbackHelper.bind(this, formattedDate, push), FRAME_DURATION);

  if (str == formattedDate) {
    setText(id, formattedDate, cursorPos);
    return;
  }

  if (formattedDate[cursorPos] == '/') {
    cursorPos++;
  }
  setText(id, formattedDate, cursorPos);
}

function cardNumber(id, str, push) {
  state.cardNumberHandler = null;

  if (str === state.cardNumber) {
    return;
  }

  var sCardNumber = state.cardNumber;
  var sLen = sCardNumber.length;
  var len = str.length;
  var cursorPos = parseInt(JBridge.cursorPosition(parseInt(id)));

  // Trailing space removed by the user
  if ((sLen - len) == 1 && sCardNumber[cursorPos] == ' ' && str[cursorPos] !== ' ') {
    setText(id, sCardNumber, cursorPos);
    return;
  }

  var rawNumber = "";
  var formattedNumber = "";
  for (var i = 0; i < len; i++) {
    if (str[i] >= '0' && str[i] <= '9') {
      rawNumber += str[i];
      formattedNumber += str[i];
      if (rawNumber.length % 4 == 0 && i != 0)
        formattedNumber += " ";
    }
  }
  state.cardNumber = formattedNumber;

  if (state.cardNumberCallbackHandler != null) {
    clearTimeout(state.cardNumberCallbackHandler);
  }
  state.cardNumberCallbackHandler = setTimeout(callbackHelper.bind(this, rawNumber, push), FRAME_DURATION);

  if (str === formattedNumber) {
    return;
  }

  if (formattedNumber[cursorPos] == ' ') {
    cursorPos++;
  }

  setText(id, formattedNumber, cursorPos);
}

function callbackHelper(str, fn) {
  state.cardNumberCallbackHandler = null;
  fn(str)();
}

function setText(id, text, pos) {
  console.log("Recived Id is",id);
  if (__OS === "ANDROID") {
    var cmd = "set_view=ctx->findViewById:i_" + id + ";";
    cmd += "get_view->setText:cs_" + text + ";";
    cmd += "get_view->setSelection:i_" + pos + ";";
    Android.runInUI(cmd, null);
  } else {
    Android.runInUI({id: id, text: text});
    Android.runInUI({id: id, cursorPosition: pos});
  }
}

// exports.os = function(x){return window.__OS}


exports["getMaxHeight"] = function (x)
{
  var heigh = parseInt( JSON.parse(Android.getScreenDimensions()).height);
  var y = x;
  if (window.__OS == "ANDROID")
  {
    y = Android.dpToPx(x);
  }
  if ((667 > heigh && window.__OS == "IOS") || (y > heigh && window.__OS != "IOS"))  // 667
  {
    return ((heigh * x) / y) - 30;
  }
  else
    return x;
}
// exports["screenHeight"] = JSON.parse(Android.getScreenDimensions()).height

exports["screenWidth"] =
  function (x)
  {
    if(window.__OS == "ANDROID")
    {
      if(window.__android_screenWidth) {
        return window.__android_screenWidth
      } else {
        return window.__android_screenWidth = JSON.parse(Android.getScreenDimensions()).width / JBridge.getPixels();
      }
    }
    else
    {
      if (window.__ios_screenWidth) {
        return window.__ios_screenWidth;
      } else {
        return window.__ios_screenWidth = JSON.parse(Android.getScreenDimensions()).width;
      }
    }
  }

exports.safeMarginTop = function () {
  if (__DEVICE_DETAILS && __DEVICE_DETAILS.safe_area_frame) {
    return __DEVICE_DETAILS.safe_area_frame.y;
  }
  return 0;
}

exports.safeMarginBottom = function () {
  var d = __DEVICE_DETAILS;
  if (!d || !d.safe_area_frame) {
    return 0;
  }
  console.log("SAFE MARGIN BOTTOM -----> ",d.screen_height - d.safe_area_frame.height - d.safe_area_frame.y);
  return (d.screen_height - d.safe_area_frame.height - d.safe_area_frame.y);
}

exports.asyncDelay = function (push) {
  return function (action)
  {
    return function (action1)
    {
      return function (duration)
      {
        setTimeout(push(action),duration);
        return action1
      }
    }
  }
}

exports["resetTextFields"]= function(arr) {
  //"987654321" ID Used for edittexts
  return function(){
    arr.map(function(a) {
      setText(a, "", 0);
    });
  }
}

exports["resetBillerFields"]= function(x) {
  return function(){
      setText("789457612","",0);
  }
}

exports.loaderAfterRender = function(id) {
  if(window.__payload && window.__payload.checkout_loader && window.__OS=="ANDROID") {
    var cmd = "set_VIEW=ctx->findViewById:i_" + id + ";set_inflator=android.view.LayoutInflater->from:ctx_ctx;set_inflatedLayout=get_inflator->inflate:i_" + window.__payload.checkout_loader + ",null_null,b_false;get_VIEW->addView:get_inflatedLayout;"
    Android.runInUI(cmd, null);
    setTimeout(function() {
      if(typeof JBridge.runInJuspayBrowser == "function") {
        JBridge.runInJuspayBrowser("onStartWaitingDialogCreated", "" + id, "");
      }
    }, 200);
  }
}