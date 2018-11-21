"use strict;"


exports["jsonStringify"] = function(rec) {
 return JSON.stringify(rec);
};

exports["backPressHandler'"] = function(scc){
    return function (){
      console.log("we are handling back press in api")
      window.__dui_screen =  "api";
      if(window.onBackPressedEvent==null){
        window.onBackPressedEvent = {}
      }
      window.onBackPressedEvent[window.__dui_screen] = function(){
        var errResp = {
          code : -2,
          status : "",
          response :  { error : true
                      , errorMessage : "user_aborted"
                      , userMessage : "user aborted"
                      }
        }
        scc(JSON.stringify(errResp))();
      }
    }
  }
  