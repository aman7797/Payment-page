module Remote.Config where

import Prelude


foreign import getEnv :: Unit -> String

baseUrl :: String
baseUrl = case getEnv unit of
            "sandbox" -> "https://sandbox.juspay.in"
            _         -> "https://api.juspay.in"

eulerLocation :: String
eulerLocation = 
    case getEnv unit of
        "sandbox" -> "http://euler-ec-beta.ap-southeast-1.elasticbeanstalk.com/sdk/v1"
        _         -> "https://api.juspay.in/sdk/v1"

baseUPI :: String
baseUPI = 
    case getEnv unit of
        "sandbox" -> "http://sandbox.juspay.in/sdk/v1/yes/callYesApis"
        _         -> "https://lambda.juspay.in/sdk/v1/yesb/process"


encKey :: String 
encKey = 
 case getEnv unit of
        "sandbox" -> "75b3efbe2d3c554bddca85c443d82971"
        _         -> "c0a5d2095a07438f49809f1fa18742c4"


yesBase :: String 
yesBase = 
    case getEnv unit of
        "sandbox" -> "https://uatsky.yesbank.in:444/app/uat/IntegrationServices/"
        _         -> "https://sky.yesbank.in:444/app/live/IntegrationServices/"

merchantId :: String
merchantId =
    case getEnv unit of
        "sandbox" -> "YES0000000010334"
        _         -> "YES0000000318805"
