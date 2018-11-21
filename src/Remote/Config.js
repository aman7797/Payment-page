exports["getEnv"] = function (unit) {
    if (window.__payload &&  window.__payload.environment)
    {
        return (window.__payload.environment)
    }
    else
        return "prod";
};