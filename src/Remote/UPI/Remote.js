exports["getOSVersion"] = function (x){
    if (__DEVICE_DETAILS.os_version)
        return __OS + " " + __DEVICE_DETAILS.os_version
    return __OS
};

exports["getPackageName"] = function (x){
    if(JSON.parse(JBridge.getSessionInfo()).package_name){
        return JSON.parse(JBridge.getSessionInfo()).package_name;
    }
    return  "com.";
}
