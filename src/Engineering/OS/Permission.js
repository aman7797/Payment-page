var callbackMapper = {
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

exports["getPermissionStatus'"] = function(permission) {
	return function() {
		JBridge.checkPermission(permission);
	};
};

exports["requestPermission'"] = function(err, success, permissions) {
	return function() {
		var callback = callbackMapper.map(function(params) {
			console.warn("Permissions", params)
			success(JSON.stringify(params))();
		});
		console.log(permissions,typeof permissions)
		JBridge.requestPermission(permissions, "2", callback);
	};
};
