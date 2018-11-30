const axios = require("axios");

const transformTxnResponse = function(successResponse, headers) {
    //Transforming params to string TODO : Why is this required?
    if(headers["x-api"] && headers["x-api"] == "txns" && successResponse.code == 200) {
      try {
        successResponse.response.payment.authentication.params = JSON.stringify(successResponse.response.payment.authentication.params);
      } catch(err) {};
    }
    return successResponse;
};

const makeRequest = function(headersRaw, method, url, payload, success) {
      // window.tokenHash = window.tokenHash || JBridge.getMd5(__payload.sessionToken || "");
      window.currentAPIUrl = url;

      var successResponse = {};
      var headers = {};
      headers["Cache-Control"] = "no-cache";
      // headers["x-jp-merchant-id"] = __payload.merchant_id;
      headers["x-jp-session-id"] = window.hyper_session_id;

      console.log("URL" , url);
      console.log("METHOD" , method);
      console.log("BODY",payload);
      console.log("HEADERS",headersRaw);

      var isSSLPinnedURL = false;

      for(var i=0;i<headersRaw.length;i++){
        headers[headersRaw[i].field] = headersRaw[i].value;
      }
      var callback = callbackMapper.map(function() {
        if (arguments && arguments.length >= 3) {
            successResponse = {
                  status: arguments[0],
                  response: JSON.parse(atob(arguments[1]) || "{}"),
                  code: parseInt(arguments[2])
            };
            successResponse = transformTxnResponse(successResponse, headers);
            console.log("Response: ");
            console.log(successResponse);
            if(successResponse.status === "failure"){
                  console.log("inside failure");
                  successResponse.response = {error : true,
                                                  errorMessage: "",
                                                  userMessage: ""
                                                };
                  console.log("Response: ");
                  console.log(successResponse);
                  success(JSON.stringify(successResponse))();
                }else
                      success(JSON.stringify(successResponse.response))();
          } else {
                success({
                      status: "failed",
                      response: "{}",
                      code: 50
                    })();
              }
        });
        console.log("Enter CAll API")
        JBridge.callAPI(method, url, getEncodedData(payload), getEncodedData(JSON.stringify(headers)), isSSLPinnedURL, callback);
  }

exports["showUI'"] = function(sc,screen) {
	return function() {
		var screenJSON = JSON.parse(screen);
		var screenName = screenJSON.tag;
		screenJSON.screen = screenName;
    if(screenName=="InitScreen") {
      screenJSON.screen = "INIT_UI";
    }
		window.__duiShowScreen(sc, screenJSON);
	};
};

exports["callAPI'"] = function() {
    return function(success) {
        return function(request) {
            return function() {
                makeRequest(request.headers, request.method, request.url, request.payload, success);
            };
        };
    };
}

exports["dpToPx"] = function(dp) {
  if (window.__OS == "ANDROID") {
    if (!window.__android_density) {
      window.__android_density = JBridge.getPixels();
    }
    return window.__android_density ? Math.round(window.__android_density * dp) : JBridge.getPixels() * dp;
  } else {
    return dp;
  }
}



exports["log"] = function (tag) {
    return function (a) {
        console.log(tag + " >>", a);
        return a;
    }
}

exports["startAnim_"] = function (animId) {
  Android.startAnim(animId);
}

exports["startAnim"] = function(animId) {
    return function() {
      console.log("startAnim", animId);
      Android.startAnim(animId)
    }
  }

  var bringToFocus = function(pID) {
    return function(cID) {
      try {
        var cmd = "set_childView=ctx->findViewById:i_"+cID+";"
        cmd += "set_btm=get_childView->getBottom;"
        cmd += "set_scrollView=ctx->findViewById:i_"+pID+";"
        cmd += "get_scrollView->smoothScrollTo:i_0,get_btm;"
        // Give 500ms to scrollview to finish it's animations first and then begin the focus part.
        setTimeout(function(){
          Android.runInUI(cmd,null);
        },300)
      }catch(e){
        return false;
      }
      return true;
    }
  }


var bringToFocusJbridge = function(parentId) {
    return function (childId) {
        JBridge.bringToFocus(parentId, childId);
    }
}

exports["bringToFocus"] = bringToFocusJbridge

exports["bankList"] = function(x) {
	return JSON.stringify({
        "banks": [
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "Ae912363a87b4f18b67fc12ebe9b8aa",
                "ifsc": "AIRP",
                "iin": "990288",
                "mobRegFormat": null,
                "name": "Airtel Payments Bank",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A5aad0e0c8e411e6bee4fb43f52875b",
                "ifsc": "ALLA",
                "iin": "607117",
                "mobRegFormat": null,
                "name": "Allahabad Bank",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A4d0da21c2e14daabfc3b5b8632d41a",
                "ifsc": "ALLA0AU1",
                "iin": "607091",
                "mobRegFormat": null,
                "name": "Allahabad UP Gramin Bank",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A5ae2c40c8e411e6bee4fb43f52875b",
                "ifsc": "ANDB",
                "iin": "607170",
                "mobRegFormat": null,
                "name": "Andhra Bank",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A393184cb2e543568fe28001a2d90f4",
                "ifsc": "APGV",
                "iin": "607198",
                "mobRegFormat": null,
                "name": "Andhra Pradesh Grameena Vikas Bank",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "Aa748a7023794406884a86814c9273e",
                "ifsc": "APGB",
                "iin": "607121",
                "mobRegFormat": null,
                "name": "Andhra Pragathi Grameena Bank",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A1072ed21f854994a8b94baddd3d870",
                "ifsc": "ASBL",
                "iin": "607101",
                "mobRegFormat": null,
                "name": "Apna Sahakari Bank Ltd.",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "Ac9ae9eb8c0648a5b76a0aa83610fa1",
                "ifsc": "UTBI0RRBAGB",
                "iin": "607064",
                "mobRegFormat": null,
                "name": "Assam Gramin Vikash Bank",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A5b00100c8e411e6bee4fb43f52875b",
                "ifsc": "UTIB",
                "iin": "607153",
                "mobRegFormat": null,
                "name": "Axis Bank Ltd",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A1fc804043cb4c07a35ffa56d20b9b6",
                "ifsc": "BDBL",
                "iin": "508753",
                "mobRegFormat": null,
                "name": "Bandhan Bank",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A5b1d5c0c8e411e6bee4fb43f52875b",
                "ifsc": "BARB",
                "iin": "606985",
                "mobRegFormat": null,
                "name": "Bank of Baroda",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "Ae78c1f0d28a11e6bd9e0361e545833",
                "ifsc": "BKID",
                "iin": "508505",
                "mobRegFormat": null,
                "name": "Bank of India",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A5b3f8a0c8e411e6bee4fb43f52875b",
                "ifsc": "MAHB",
                "iin": "607387",
                "mobRegFormat": null,
                "name": "Bank of Maharashtra",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled":true,
                "id":"A63a56edf14243dbbe6d3250b91ce4e",
                "ifsc":"BARB0BGGBXX",
                "iin":"606995",
                "mobRegFormat":null,
                "name":"Baroda Gujarat Gramin Bank",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "Acbc4df85a3445eda0d0dd017bd3f45",
                "ifsc": "BARB0BRGBXX",
                "iin": "607280",
                "mobRegFormat": null,
                "name": "Baroda Rajasthan Kshetriya Gramin Bank",
                "upiEnabled": "true"
            },
        {
            "active": "Y",
            "commonAppEnabled": true,
            "id": "A2904bb5bda147d78beb66d255ea596",
            "ifsc": "BARB0BUPGBX",
            "iin": "606993",
            "mobRegFormat": null,
            "name": "Baroda UP Gramin Bank",
            "upiEnabled": "true"
        },
        {
            "active": "Y",
            "commonAppEnabled": true,
            "id": "A8a513ebe94e4349b59b9d377c9f317",
            "ifsc": "BACB",
            "iin": "508512",
            "mobRegFormat": null,
            "name": "Bassein Catholic Co-operative Bank",
            "upiEnabled": "true"
        },
        {
            "active": "Y",
            "commonAppEnabled": true,
            "id": "Ac09eb316fed45ac8ca8ae347186b26",
            "ifsc": "UCBA0RRBBKG",
            "iin": "607377",
            "mobRegFormat": null,
            "name": "Bihar Gramin Bank",
            "upiEnabled": "true"
        },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A5b5a650c8e411e6bee4fb43f52875b",
                "ifsc": "CNRB",
                "iin": "508532",
                "mobRegFormat": null,
                "name": "Canara Bank",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A5b75400c8e411e6bee4fb43f52875b",
                "ifsc": "CSBK",
                "iin": "607442",
                "mobRegFormat": null,
                "name": "Catholic Syrian Bank",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A5b901b0c8e411e6bee4fb43f52875b",
                "ifsc": "CBIN",
                "iin": "607115",
                "mobRegFormat": null,
                "name": "Central Bankof India",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A898840f13be403791f412057bd1b8f",
                "ifsc": "SBIN0RRCHGB",
                "iin": "607214",
                "mobRegFormat": null,
                "name": "CHATISGARH R G BANK",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A487abb6d310488fad9f7406ebea408",
                "ifsc": "CITI",
                "iin": "607485",
                "mobRegFormat": null,
                "name": "Citibank",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "Aa76f08ea54a4b01b650a5bc2714574",
                "ifsc": "CIUB",
                "iin": "607324",
                "mobRegFormat": null,
                "name": "City Union Bank",
                "upiEnabled": "true"
            },
            {
                "active":"Y",
                "commonAppEnabled":true,
                "id":"A05b8a2754244c759bfdc9365831c17",
                "ifsc":"ANDB0CGGBHO",
                "iin":"607080",
                "mobRegFormat":null,
                "name":"Chaitanya Godavari Grameena Bank",
                "upiEnabled":"true"
            },
        {
            "active":"Y",
            "commonAppEnabled":true,
            "id":"Ab76475078ba48c89d83adc06914b37",
            "ifsc":"CORP",
            "iin":"607184",
            "mobRegFormat":null,
            "name":"Corporation Bank",
            "upiEnabled":"true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "Adc23b6a4c5d4b3f9e95de7e9df7c26",
                "ifsc": "COSB",
                "iin": "607090",
                "mobRegFormat": null,
                "name": "Cosmos Bank",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A3a1f2b009c24db8bac68c7ea881145",
                "ifsc": "DBSS",
                "iin": "199641",
                "mobRegFormat": null,
                "name": "DBS BANK LTD",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "Abbb9ecae00b4776beb78ad56dfd77a",
                "ifsc": "DNSB",
                "iin": "607055",
                "mobRegFormat": null,
                "name": "Dombivali Nagri Sahakari Bank",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A5bad670c8e411e6bee4fb43f52875b",
                "ifsc": "DCBL",
                "iin": "607290",
                "mobRegFormat": null,
                "name": "DCB Bank Ltd",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A5bc5d10c8e411e6bee4fb43f52875b",
                "ifsc": "BKDN",
                "iin": "508547",
                "mobRegFormat": null,
                "name": "Dena Bank",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "Ab03ec78fedc49e3becacd9a6072e6c",
                "ifsc": "BKDN0700000",
                "iin": "607099",
                "mobRegFormat": null,
                "name": "Dena Gujarat Gramin Bank",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "Ace9378b3c6448faa440954b1dacd64",
                "ifsc": "ESFB",
                "iin": "508998",
                "mobRegFormat": null,
                "name": "Equitas Bank",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A5be0ac0c8e411e6bee4fb43f52875b",
                "ifsc": "FDRL",
                "iin": "607363",
                "mobRegFormat": null,
                "name": "Federal Bank",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "Ad9553f5aae74bd6aed917fc658413b",
                "ifsc": "FINO",
                "iin": "608001",
                "mobRegFormat": null,
                "name": "Fino Payments Bank",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A3581e842e41405488faaa09423ae0a",
                "ifsc": "PJSB",
                "iin": "607273",
                "mobRegFormat": null,
                "name": "GP PARSIK BANK",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A5bf9160c8e411e6bee4fb43f52875b",
                "ifsc": "HDFC",
                "iin": "607152",
                "mobRegFormat": null,
                "name": "HDFC BANK LTD",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A5c11800c8e411e6bee4fb43f52875b",
                "ifsc": "HSBC",
                "iin": "999999",
                "mobRegFormat": null,
                "name": "HSBC",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A5c29ea0c8e411e6bee4fb43f52875b",
                "ifsc": "ICIC",
                "iin": "508534",
                "mobRegFormat": null,
                "name": "ICICI Bank",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A5c3fe30c8e411e6bee4fb43f52875b",
                "ifsc": "IBKL",
                "iin": "607095",
                "mobRegFormat": null,
                "name": "IDBI Bank Limited",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A5c5fa00c8e411e6bee4fb43f52875b",
                "ifsc": "IDFB",
                "iin": "608117",
                "mobRegFormat": null,
                "name": "IDFC Bank",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A5c780a0c8e411e6bee4fb43f52875b",
                "ifsc": "IDIB",
                "iin": "607105",
                "mobRegFormat": null,
                "name": "Indian Bank",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A2b6a090cb8911e69e0e2b637851660",
                "ifsc": "IOBA",
                "iin": "607126",
                "mobRegFormat": null,
                "name": "Indian Overseas Bank",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A5c90740c8e411e6bee4fb43f52875b",
                "ifsc": "INDB",
                "iin": "607189",
                "mobRegFormat": null,
                "name": "INDUSIND BANK",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "Ae562095b54f4267af24455aecf708d",
                "ifsc": "JAKA",
                "iin": "607440",
                "mobRegFormat": null,
                "name": "Jammu & Kashmir Bank",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled":true,
                "id":"A6a46a50002847a7a866ef5e8509bfc",
                "ifsc":"JJSB",
                "iin":"607158",
                "mobRegFormat":null,
                "name":"Jalgaon Janata Sahkari Bank Ltd Jalgaon",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "Ab68e27d56fd4cfcb828de2fcbc89aa",
                "ifsc": "JSBP",
                "iin": "607276",
                "mobRegFormat": null,
                "name": "Janata Sahakari Bank Ltd.,Pune",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "Ad976b90e74c4f9f92d2198b531c1e5",
                "ifsc": "KAIJ",
                "iin": "607249",
                "mobRegFormat": null,
                "name": "KAIJSB- Ichalkaranji",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "Aa297a53a8d84e27a8b8f27729bc070",
                "ifsc": "KJSB",
                "iin": "607506",
                "mobRegFormat": null,
                "name": "Kalyan Janata Sahakari Bank",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A5ca8de0c8e411e6bee4fb43f52875b",
                "ifsc": "KARB",
                "iin": "607270",
                "mobRegFormat": null,
                "name": "Karnataka Bank",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A55c5701a18e495eb11818b9ea9ee2d",
                "ifsc": "KVGB",
                "iin": "607122",
                "mobRegFormat": null,
                "name": "Karnataka Vikas Grameena Bank",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "Ad24c190cde611e680328f4ac3fe129",
                "ifsc": "KVBL",
                "iin": "607100",
                "mobRegFormat": null,
                "name": "Karur Vysya Bank",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "Aa0fb7d518a541a0ac801225eb52190",
                "ifsc": "SBIN0RRCKGB",
                "iin": "607308",
                "mobRegFormat": null,
                "name": "Kaveri Grameena Bank",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A0c27315be1044959a8bd35799491e2",
                "ifsc": "KLGB",
                "iin": "607476",
                "mobRegFormat": null,
                "name": "Kerala Gramin Bank",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A5cb9f50c8e411e6bee4fb43f52875b",
                "ifsc": "KKBK",
                "iin": "607420",
                "mobRegFormat": null,
                "name": "Kotak Mahindra Bank",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "Aca8772d235c494cb560be28d1825be",
                "ifsc": "LAVB",
                "iin": "607058",
                "mobRegFormat": null,
                "name": "Lakshmi Vilas Bank",
                "upiEnabled": "true"
            },
            {
                "active":"Y",
                "commonAppEnabled":true,
                "id":"A541c841fc92436ba8b6b418b1b1649",
                "ifsc":"SBIN0RRLDGB",
                "iin":"607202",
                "mobRegFormat":null,
                "name":"Langpi Dehangi Rural Bank",
                "upiEnabled":"true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A3d6be13d36843edbf688163a26da70",
                "ifsc": "MAHG",
                "iin": "607000",
                "mobRegFormat": null,
                "name": "Maharashtra Gramin Bank",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A79697b0f98f4c04bba979f9cafb015",
                "ifsc": "SBIN0RRMLGB",
                "iin": "607241",
                "mobRegFormat": null,
                "name": "Malwa Gramin Bank",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "Ae8e86f693ec4b7f800cf2178bbe97a",
                "ifsc": "SBIN0RRMEGB",
                "iin": "607206",
                "mobRegFormat": null,
                "name": "Meghalaya Rural Bank",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A49b32f6d89a4365ac474909cea6554",
                "ifsc": "UTBI0RRBMRB",
                "iin": "607062",
                "mobRegFormat": null,
                "name": "Manipur Rural Bank",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A75d8056d18d40c894d69f2062dd4a0",
                "ifsc": "SBIN0RRMIGB",
                "iin": "607230",
                "mobRegFormat": null,
                "name": "Mizoram Rural Bank",
                "upiEnabled": "true"
            },
        {
            "active": "Y",
            "commonAppEnabled": true,
            "id": "A0b11349cbc344c0966b87ba9c73054",
            "ifsc": "NKGS",
            "iin": "607104",
            "mobRegFormat": null,
            "name": "NKGSB Bank",
            "upiEnabled": "true"
        },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A5ccd7d0c8e411e6bee4fb43f52875b",
                "ifsc": "ORBC",
                "iin": "508585",
                "mobRegFormat": null,
                "name": "Oriental Bank of Commerce",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A38c73adb3ee49d1ba058fce912fa53",
                "ifsc": "PYTM",
                "iin": "608032",
                "mobRegFormat": null,
                "name": "Paytm Payments Bank",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A85a0134fc424aba985803b806ee9bd",
                "ifsc": "PKGB",
                "iin": "607389",
                "mobRegFormat": null,
                "name": "Pragathi Krishna Gramin Bank",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "Ae17106879884f459c27cb7ea4e2c98",
                "ifsc": "PRTH",
                "iin": "607124",
                "mobRegFormat": null,
                "name": "Prathama Bank",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A5ce1050c8e411e6bee4fb43f52875b",
                "ifsc": "PUNB",
                "iin": "508568",
                "mobRegFormat": null,
                "name": "Punjab National Bank",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A8607f5e0f2e45e09e0b2a575d456c4",
                "ifsc": "PMCB",
                "iin": "607057",
                "mobRegFormat": null,
                "name": "Punjab and Maharashtra cooperative Bank",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "Aa01c043176b46f4b7bd24901d78a39",
                "ifsc": "PSIB",
                "iin": "607087",
                "mobRegFormat": null,
                "name": "Punjab & Sind Bank",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "Ab2b9a30fe0c4976b0b61208e22afe2",
                "ifsc": "SBIN0RRPUGB",
                "iin": "607212",
                "mobRegFormat": null,
                "name": "Purvanchal Bank",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A897a9b155ef4901b29a11747f3e647",
                "ifsc": "SBIN0RRMRGB",
                "iin": "607509",
                "mobRegFormat": null,
                "name": "Rajasthan Marudhara Gramin Bank",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A35b38eba2ca4025accf3faea442f03",
                "ifsc": "RNSB",
                "iin": "607354",
                "mobRegFormat": null,
                "name": "Rajkot Nagrik Sahakari Bank Ltd.",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A5cf6fe0c8e411e6bee4fb43f52875b",
                "ifsc": "RATN",
                "iin": "607393",
                "mobRegFormat": null,
                "name": "RBL",
                "upiEnabled": "true"
            },
        {
            "active": "Y",
            "commonAppEnabled": true,
            "id": "A2e1b0d667e34bc1a3870807409a1b1",
            "ifsc": "IBKL0041SCB",
            "iin": "608195",
            "mobRegFormat": null,
            "name": "Samruddhi Co-Operative Bank Ltd Nagpur",
            "upiEnabled": "true"
        },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A990a89d71964318ad86a6da94f420d",
                "ifsc": "SRCB",
                "iin": "652150",
                "mobRegFormat": null,
                "name": "Saraswat Bank",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A7f1172f80114def8b01b4add162d29",
                "ifsc": "SBIN0RRSRGB",
                "iin": "607200",
                "mobRegFormat": null,
                "name": "Saurashtra Gramin Bank",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A5d11d90c8e411e6bee4fb43f52875b",
                "ifsc": "SIBL",
                "iin": "607167",
                "mobRegFormat": null,
                "name": "South Indian BanK",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A5d2cb40c8e411e6bee4fb43f52875b",
                "ifsc": "SCBL",
                "iin": "607394",
                "mobRegFormat": null,
                "name": "Standard Chartered",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A5d403c0c8e411e6bee4fb43f52875b",
                "ifsc": "SBIN",
                "iin": "508548",
                "mobRegFormat": null,
                "name": "State Bank Of India",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "Acdbe63b8c274216b6f1528097ad87b",
                "ifsc": "SVCB",
                "iin": "607258",
                "mobRegFormat": null,
                "name": "SVC Co-Operative Bank Ltd",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A5d51530c8e411e6bee4fb43f52875b",
                "ifsc": "SYNB",
                "iin": "508508",
                "mobRegFormat": null,
                "name": "Syndicate Bank",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A98b5962927c4758b54903db1f31e44",
                "ifsc": "TMBL",
                "iin": "607187",
                "mobRegFormat": null,
                "name": "Tamilnad Mercantile Bank",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "Aee0062a9ebd4ef2ad1f6f553706cc4",
                "ifsc": "SBIN0RRDCGB",
                "iin": "607195",
                "mobRegFormat": null,
                "name": "Telangana Grameena bank",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "Ad7f551e76824da49d179d2b53a5b28",
                "ifsc": "TBSB",
                "iin": "607291",
                "mobRegFormat": null,
                "name": "Thane Bharat Sahakari Bank Ltd",
    
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A40493d9840440258f04ae2ba75e84f",
                "ifsc": "GSCB",
                "iin": "607689",
                "mobRegFormat": null,
                "name": "The Gujarat State Cooperative Bank",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A960a6912a104af996e7c1aa994867d",
                "ifsc": "HCBL",
                "iin": "607621",
                "mobRegFormat": null,
                "name": "The Hasti Co-operative Bank Ltd",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A8bee552ca2743d5a25dd8998c2aae5",
                "ifsc": "MCBL",
                "iin": "607320",
                "mobRegFormat": null,
                "name": "The Mahanagar Co.Op. Bank Ltd.",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A2f74f9028a64ba6a37aa3703bd7f43",
                "ifsc": "MSNU",
                "iin": "508517",
                "mobRegFormat": null,
                "name": "The Mehsana Urban Co-Operative Bank Ltd.",
                "upiEnabled": "true"
            },
        {
            "active": "Y",
            "commonAppEnabled": true,
            "id": "Aa1be07f68ba410cab1f1c373787105",
            "ifsc": "ICIC00TUCBD",
            "iin": "508794",
            "mobRegFormat": null,
            "name": "THE URBAN CO OP BANK LTD DHARANGAON",
            "upiEnabled": "true"
        },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A5d626a0c8e411e6bee4fb43f52875b",
                "ifsc": "TJSB",
                "iin": "607130",
                "mobRegFormat": null,
                "name": "TJSB",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A95cd5490fdd4ade922f943a89dd855",
                "ifsc": "UTBI0RRBTGB",
                "iin": "607065",
                "mobRegFormat": null,
                "name": "Tripura Gramin Bank",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A5d75f20c8e411e6bee4fb43f52875b",
                "ifsc": "UCBA",
                "iin": "607066",
                "mobRegFormat": null,
                "name": "UCO Bank",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "Ab4f27df5b9f44ce9f559514ac7c38e",
                "ifsc": "UJVN",
                "iin": "508991",
                "mobRegFormat": null,
                "name": "Ujjivan Small Finance Bank",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A5d8beb0c8e411e6bee4fb43f52875b",
                "ifsc": "UBIN",
                "iin": "508500",
                "mobRegFormat": null,
                "name": "Union Bank of India",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A5d9f730c8e411e6bee4fb43f52875b",
                "ifsc": "UTBI",
                "iin": "607028",
                "mobRegFormat": null,
                "name": "United Bank of India",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A311b0f9bb284856976cf3c37fbce73",
                "ifsc": "SBIN0RRUTGB",
                "iin": "607197",
                "mobRegFormat": null,
                "name": "Uttarakhand Gramin Bank",
                "isRRB": "true",  
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A16a19fa9c874666994d2152adcf707",
                "ifsc": "SBIN0RRVCGB",
                "iin": "607210",
                "mobRegFormat": null,
                "name": "Vananchal Gramin Bank",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "Aaff0b5ffcfd4b1dbb4ccb2d42b26f8",
                "ifsc": "VVSB",
                "iin": "607544",
                "mobRegFormat": null,
                "name": "Vasai Vikas Sahakari Bank Ltd",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A5db2fb0c8e411e6bee4fb43f52875b",
                "ifsc": "VIJB",
                "iin": "607075",
                "mobRegFormat": null,
                "name": "Vijaya Bank",
                "upiEnabled": "true"
            },
            {
                "active": "Y",
                "commonAppEnabled": true,
                "id": "A5dc6830c8e411e6bee4fb43f52875b",
                "ifsc": "YESB",
                "iin": "607223",
                "mobRegFormat": null,
                "name": "Yes Bank Ltd",
                "upiEnabled": "true"
            }
        ]
    });
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

const getEncodedData = function(data) {
    if (window.__OS == "IOS")
      return  btoa(unescape(encodeURIComponent(data)));
    else
      return data;
  }

exports["onBackPress'"] = function(cb) {
    return function() {
      window.onBackPressed = function() {
     console.log("Back pressed");
     window.onBackPressed = null;
     cb()();
      }
    }
};

exports["unsafeGet'"] = function(key) {
    return function() {
        return window[key];
    };
};

exports["setOnWindow'"] = function(key) {
    return function(val) {
        return function() {
            window[key] = val;
        };
    };
};

exports["checkPermissions"] = function(list) {
    // console.warn("Permissions");
    return function(){
        // console.warn("Permissions");
        return JBridge.checkPermission(list);
    }
}

const callbackMapper2 = {
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

exports["requestPermissions"] = function(success){
    return function(permissions){
    // console.warn("Permissions");
        return function(){
            var callback = callbackMapper2.map(function(params) {
                console.warn("Permissions", params)
                success(JSON.stringify(params))();
            });
            console.warn("Permissions");
            JBridge.requestPermission(permissions, "2", callback);
        }
    }
}

var ifscIinMap = {
    AIRP: "990288",
    ALLA: "607117",
    ALLA0AU1: "607091",
    ANDB: "607170",
    ANDB0CGGBHO: "607080",
    APGB: "607121",
    APGV: "607198",
    ASBL: "607101",
    BACB: "508512",
    BARB: "606985",
    BARB0BGGBXX: "606995",
    BARB0BRGBXX: "607280",
    BARB0BUPGBX: "606993",
    BDBL: "508753",
    BKDN: "508547",
    BKDN0700000: "607099",
    BKID: "508505",
    CBIN: "607115",
    CITI: "607485",
    CIUB: "607324",
    CNRB: "508532",
    CORP: "607184",
    COSB: "607090",
    CSBK: "607442",
    DBSS: "199641",
    DCBL: "607290",
    DNSB: "607055",
    ESFB: "508998",
    FDRL: "607363",
    FINO: "608001",
    GSCB: "607689",
    HCBL: "607621",
    HDFC: "607152",
    HSBC: "999999",
    IBKL: "607095",
    IBKL0041SCB: "608195",
    ICIC: "508534",
    ICIC00TUCBD: "508794",
    IDFB: "608117",
    IDIB: "607105",
    INDB: "607189",
    IOBA: "607126",
    JAKA: "607440",
    JJSB: "607158",
    JSBP: "607276",
    KAIJ: "607249",
    KARB: "607270",
    KJSB: "607506",
    KKBK: "607420",
    KLGB: "607476",
    KVBL: "607100",
    KVGB: "607122",
    LAVB: "607058",
    MAHB: "607387",
    MAHG: "607000",
    MCBL: "607320",
    MSNU: "508517",
    NKGS: "607104",
    ORBC: "508585",
    PJSB: "607273",
    PKGB: "607389",
    PMCB: "607057",
    PRTH: "607124",
    PSIB: "607087",
    PUNB: "508568",
    PYTM: "608032",
    RATN: "607393",
    RNSB: "607354",
    SBIN: "508548",
    SBIN0RRCHGB: "607214",
    SBIN0RRCKGB: "607308",
    SBIN0RRDCGB: "607195",
    SBIN0RRLDGB: "607202",
    SBIN0RRMEGB: "607206",
    SBIN0RRMIGB: "607230",
    SBIN0RRMLGB: "607241",
    SBIN0RRMRGB: "607509",
    SBIN0RRPUGB: "607212",
    SBIN0RRSRGB: "607200",
    SBIN0RRUTGB: "607197",
    SBIN0RRVCGB: "607210",
    SCBL: "607394",
    SIBL: "607167",
    SRCB: "652150",
    SVCB: "607258",
    SYNB: "508508",
    TBSB: "607291",
    TJSB: "607130",
    TMBL: "607187",
    UBIN: "508500",
    UCBA: "607066",
    UCBA0RRBBKG: "607377",
    UJVN: "508991",
    UTBI: "607028",
    UTBI0RRBAGB: "607064",
    UTBI0RRBMRB: "607062",
    UTBI0RRBTGB: "607065",
    UTIB: "607153",
    VIJB: "607075",
    VVSB: "607544",
    YESB: "607223"
};

var nbIinMap = {
    NB_ALLB: "607117",
    NB_AXIS: "607153",
    NB_BOB: "606985",
    NB_BOBCORP: "606985",
    NB_CSB: "607442",
    NB_DCB: "607290",
    NB_DENA: "508547",
    NB_DEUT: "493541",
    NB_HDFC: "607152",
    NB_ICICI: "508534",
    NB_IDFC: "608117",
    NB_INDUS: "607189",
    NB_IOB: "607126",
    NB_KOTAK: "607420",
    NB_PNB: "508568",
    NB_PNBCORP: "508568",
    NB_SARASB: "652150",
    NB_SBI: "508548",
    NB_SYNB: "508508",
    NB_UCOB: "607066",
    NB_YESB: "607223",
    NB_BOI : "508505",
    NB_BOM : "607387",
    NB_CBI : "607115",
    NB_CORP : "607184",
    NB_FED : "607363",
    NB_IDBI : "607095",
    NB_INDB : "607105",
    NB_JNK : "607440",
    NB_SBBJ : "607214",
    NB_KARN : "607270",
    NB_KVB : "607100",
    NB_SBH : "508548",
    NB_SBM : "508548",
    NB_SBT : "508548",
    NB_SOIB : "607167",
    NB_UBI : "607028",
    NB_UNIB : "508500",
    NB_VJYB : "607075",
    NB_CUB : "607324",
    NB_CANR : "508532",
    NB_SBP : "508548",
    NB_CITI : "607485",
    NB_ANDHRA : "607170",
    NB_TMB : "607187",
    NB_JSB : "607158",
    NB_LVBCORP : "607058",
    NB_LVB : "607058",
    NB_PMCB : "607057",
    NB_PNJSB : "607087",
    NB_COSMOS : "607090",
    NB_DCBB : "607290",
    NB_KVBCORP : "607100",
    NB_UBICORP : "607028",
    NB_RATN : "607393",
    NB_SVCB : "607258",
    NB_BBKM : "455012",
    NB_DLS : "436360",
    NB_AIRTEL : "990288",
    NB_OBC : "515948",
    NB_SCB : "607394",
    NB_NAIB : "607592",
    NB_ING : "607222",
    NB_BHARAT : "607339"
};

var iinNbMap = {
    "607117" : "NB_ALLB" ,
    "607153" : "NB_AXIS" ,
    "606985" : "NB_BOB" ,
    "606985" : "NB_BOBCORP" ,
    "607442" : "NB_CSB" ,
    "607290" : "NB_DCB" ,
    "508547" : "NB_DENA" ,
    "493541" : "NB_DEUT" ,
    "607152" : "NB_HDFC" ,
    "508534" : "NB_ICICI" ,
    "608117" : "NB_IDFC" ,
    "607189" : "NB_INDUS" ,
    "607126" : "NB_IOB" ,
    "607420" : "NB_KOTAK" ,
    "508568" : "NB_PNB" ,
    "508568" : "NB_PNBCORP" ,
    "652150" : "NB_SARASB" ,
    "508548" : "NB_SBI" ,
    "508508" : "NB_SYNB" ,
    "607066" : "NB_UCOB" ,
    "607223" : "NB_YESB" ,
    "508505" : "NB_BOI" ,
    "607387" : "NB_BOM" ,
    "607115" : "NB_CBI" ,
    "607184" : "NB_CORP" ,
    "607363" : "NB_FED" ,
    "607095" : "NB_IDBI" ,
    "607105" : "NB_INDB" ,
    "607440" : "NB_JNK" ,
    "607214" : "NB_SBBJ" ,
    "607270" : "NB_KARN" ,
    "607100" : "NB_KVB" ,
    "508548" : "NB_SBH" ,
    "508548" : "NB_SBM" ,
    "508548" : "NB_SBT" ,
    "607167" : "NB_SOIB" ,
    "607028" : "NB_UBI" ,
    "508500" : "NB_UNIB" ,
    "607075" : "NB_VJYB" ,
    "607324" : "NB_CUB" ,
    "508532" : "NB_CANR" ,
    "508548" : "NB_SBP" ,
    "607485" : "NB_CITI" ,
    "607170" : "NB_ANDHRA" ,
    "607187" : "NB_TMB" ,
    "607158" : "NB_JSB" ,
    "607058" : "NB_LVBCORP" ,
    "607058" : "NB_LVB" ,
    "607057" : "NB_PMCB" ,
    "607087" : "NB_PNJSB" ,
    "607090" : "NB_COSMOS" ,
    "607290" : "NB_DCBB" ,
    "607100" : "NB_KVBCORP" ,
    "607028" : "NB_UBICORP" ,
    "607393" : "NB_RATN" ,
    "607258" : "NB_SVCB" ,
    "455012" : "NB_BBKM" ,
    "436360" : "NB_DLS" ,
    "990288" : "NB_AIRTEL" ,
    "515948" : "NB_OBC" ,
    "607394" : "NB_SCB" ,
    "607592" : "NB_NAIB" ,
    "607222" : "NB_ING" ,
    "607339" : "NB_BHARAT" 
};



exports["getIinNb"] = function (iin) {
    return iinNbMap[iin]
};

exports["getIin"] = function(ifsc) {
    return ifscIinMap[ifsc]
};

exports["getNbIin"] = function (nb) {
    return nbIinMap[nb]
};

exports["ourMaybe"] = function (val) {
    return val
};



exports.unsafeJsonStringify = function(value) {
  return JSON.stringify(value);
}

exports.unsafeJsonDecodeImpl = function(value, just, nothing) {
  try {
    var decoded = JSON.parse(value);
    if (decoded) {
      return just(decoded);
    }
    else {
      return nothing;
    }
  } catch(e) {
    return nothing;
  }
}
