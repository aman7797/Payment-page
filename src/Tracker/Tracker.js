window.bundle = JSON.parse(JBridge.getSessionAttribute("bundleParams","{}"));
window.logList = [];
window.sn = 0;
window.canPostLogs = true;
window.merchantLogsPostingEnabled = !bundle.logsPostingEnabled || !(bundle.logsPostingEnabled.toString() == "false")
window.pageId = 0;
window.logsUrl = bundle.logsPostingUrl || JBridge.getResourceByName("juspay_analytics_endpoint");
JBridge.setAnalyticsEndPoint(logsUrl)

const EVENT_CATEGORY_HYPERPAY = "hyper_pay";
const EVENT_ACTION_INFO = "info";
const EVENT_CATEGORY_CONFIG = "config";
const EVENT_ACTION_CHECK = "check";
const LOG_LEVEL_MINIMAL = "1";

const stampLogs = function(log) {
    log["at"] = Date.now();
    log["sn"] = ++window.sn;
    log["session_id"] = window.hyper_session_id;
    return log;
}

const buildApiLogs = function(apiData) {
    var dataMap = {};
    dataMap.type = "API";
    dataMap["url"] = apiData.url;
    dataMap["api_load_start"] = apiData.apiStartTime;
    dataMap["api_load_end"] = apiData.apiEndTime;
    var apiStartTime = parseInt(apiData.apiStartTime);
    var apiEndTime = parseInt(apiData.apiEndTime);
    var latency = apiEndTime-apiStartTime;
    dataMap["latency"] = latency == NaN ? "Error while parsing latency" : latency ; // If latency is NaN then there is parsing value to int is error
    dataMap["status_code"] = apiData.statusCode;
    dataMap["log_level"] = LOG_LEVEL_MINIMAL;
    return stampLogs(dataMap);
}

const preProcessEvent = function(category, action, label, value) {
    var dataMap = {};
    dataMap["type"] = "event";
    dataMap["category"] = category;
    dataMap["action"] = action;
    dataMap["label"] = label;
    dataMap["value"] = value;
    dataMap["pageId"] = window.pageId;
    return stampLogs(dataMap);
}

exports.preProcessEvent = function(category) {
    return function(action) {
        return function(label) {
            return function(value) {
                return function(){
                    return preProcessEvent(category, action, label, value);
                }
            }
        }
    }
}

exports.preProcessHyperPayEvent = function(key) {
    return function(value) {
        return function(){
            return preProcessEvent(EVENT_CATEGORY_HYPERPAY, EVENT_ACTION_INFO, key, value);
        }
    }
}

exports.preProcessTrackInfo = function(label) {
    return preProcessEvent(EVENT_CATEGORY_HYPERPAY, EVENT_ACTION_INFO, label, "");
}

exports.preProcessTrackExceptionEvent = function(description) {
    return function(message) {
        return function(stackTrace) {
            return function(){
                var dataMap = {};
                dataMap["type"] = "Exception";
                dataMap["message"] = message;
                dataMap["stackTrace"] = stackTrace;
                dataMap["pageId"] = window.pageId;
                dataMap["description"] = description;
                dataMap["log_level"] = LOG_LEVEL_MINIMAL;
                return stampLogs(dataMap);
            }
        }
    }
}

exports.preProcessTrackPage = function(url) {
    return function(fragmentName) {
        return function(){
            var screenView = {}
            screenView["type"] = "screen";
            screenView.title = fragmentName
            screenView.url = url;
            screenView.pageId = window.pageId;
            return stampLogs(screenView);
        }
    }
}

exports.preProcessSessionInfo = function(session) {
    return function(){
        return stampLogs(session);
    }
}

exports.preProcessPaymentDetails = function() {
    var keyToFilter =   [ "customerPhoneNumber"
                        , "offerMethodType"
                        , "customerId"
                        , "orderId"
                        , "order_id"
                        , "offerMsg"
                        , "sessionToken"
                        , "udf_type"
                        , "udf_operator"
                        , "merchantId"
                        , "merchant_id"
                        , "offerApplied"
                        , "offerMethod"
                        , "clientId"
                        , "client_id"
                        , "clearCookies"
                        , "udf_circle"
                        , "offerCode"
                        , "customerEmail"
                        , "udf_itemCount"
                        , "amount"
                        ]
    var paymentDetails = new Object();
    keyToFilter.forEach(function(key) {
        if(window.__payload.hasOwnProperty(key))
            paymentDetails[key] = window.__payload[key];
    });
    paymentDetails["type"] = "payment_details";
    return stampLogs(paymentDetails);
}

exports["addToLogList'"] = function(shouldShareWithMerchant){
    return function(logs) {
        return function(){
            if(shouldShareWithMerchant){
                if (JBridge.shareWithMerchant){
                    JBridge.shareWithMerchant(JSON.stringify(logs));
                }
                console.log("inside",logs);
            }
            JBridge.addToLogList(JSON.stringify(logs));
        }
    }
}

exports.canPostLogs = function() {
    return window.canPostLogs;
}

exports.updateLogList = function(logs) {
    return function() {
        JBridge.updateLogList(JSON.stringify(logs));
    }
}

exports.postLogsToAnalytics = function(logs) {
    return function() {
        if(logs.length > 0) {
            console.log(logs);
            console.log(logsUrl);

            var logData = {
            data: logs
            }
            if(merchantLogsPostingEnabled)
                JBridge.postLogs(logsUrl, JSON.stringify(logData));
        }
    }
}

exports.getLogList = function() {
    return JSON.parse(JBridge.getLogList());
}

exports.submitAllLogs = function() {
    JBridge.submitAllLogs();
    return null;
}

const trackAPICalls = function(url,apiStartTime,apiEndTime,statusCode){
    try{
        var apiData = new Object();
        apiData["url"] = url;
        apiData["apiStartTime"] = apiStartTime 
        apiData["apiEndTime"] = apiEndTime 
        apiData["statusCode"] =  statusCode;
        var constructedData = buildApiLogs(apiData);
        JBridge.addToLogList(JSON.stringify(constructedData));
        return;
    } catch (err){
        console.error(" Error While trackApiCalls : " , err.toString());
    }
}

exports["trackAPICalls'"] = function(url){
    return function(apiStartTime){
        return function(apiEndTime){
            return function(statusCode){
                return function(){
                    if(typeof trackAPICalls == "function"){
                        trackAPICalls(url,apiStartTime,apiEndTime,statusCode);
                    } else {
                        console.error("trackApiCalls is not a function");
                    }
                }
            }
        }
    }
}

exports.setInterval = function (ms) {
    return function (fn) {
      return function () {
        return setInterval(fn, ms);
      };
    };
  };

exports.toString = function (attr) {
    return JSON.stringify(attr);
};