module UPI.Layer where

import Prelude

import Data.Foldable (foldl)
import Presto.Core.Types.Language.Flow (Flow, APIResult)
import UPI.Remote (RequestObject(..), UPIRequest, upiCall, getOSVersion, getPackageName)
import Remote.Config(yesBase)

pgMerchantId :: String
pgMerchantId = "YES0000000318805"
appId :: String
appId = getPackageName unit
gcmID :: String
gcmID = "123"
city :: String
city = "INDIA"
ip :: String
ip = "187.0.0.1"
osVersion :: String
osVersion = getOSVersion unit
capabilities :: String
capabilities = "7446489340284893413847123456709876"
types :: String
types = "MOB"

checkDeviceId :: String -> String -> String -> String -> String -> String -> Flow (APIResult UPIRequest)
checkDeviceId token tnxID sessionToken customerId add1 cat = do
    let dt = [
        tnxID
    ,   gcmID
    ,   appId
    ,   "0.0,0.0"
    ,   city
    ,   ip
    ,   types
    ,   capabilities
    ,   osVersion
    ,   token,   token
    ,   "1",   "1",   "1"
    ,   add1,   "",   "",   "",   "",   "",   "",   ""
    ,   "NA",   "NA"
    ]
    let requestMsg = foldl (\a b -> a <> "|" <> b) pgMerchantId dt
    upiCall $ RequestObject {  requestMsg
                            ,  url : yesBase <> "deviceStatusMEService"
                            ,  token
                            ,  pgMerchantId
                            ,  client_auth_token : cat
                            ,  encryptionRequired : false
                            }


getUPIBankList :: String -> String -> String -> String -> String -> Flow (APIResult UPIRequest)
getUPIBankList token tnxID sessionToken customerId cat = do
    let dt = [
        tnxID
    ,   appId
    ,   "0.0,0.0"
    ,   city
    ,   ip
    ,   types
    ,   capabilities
    ,   osVersion
    ,   token
    ,   token
    ,   "1",   "1",   "1"
    ,   "",   "",   "",   "",   "",   "",   "",   ""
    ,   "NA",   "NA"
    ]
    let requestMsg = foldl (\a b -> a <> "|" <> b) pgMerchantId dt
    upiCall $ RequestObject {  requestMsg
                            ,  url : yesBase <> "getBankListMEService"
                            ,  token
                            ,  pgMerchantId
                            ,  encryptionRequired : false
                            ,  client_auth_token : cat
                            }


getAccountList :: String -> String -> String -> String -> String -> String -> String -> String -> Flow (APIResult UPIRequest)
getAccountList token tnxID sessionToken customerId reqFlag vpa bankCode cat = do
    let dt = [
        tnxID
    ,   vpa
    ,   bankCode
    ,   appId
    ,   "0.0,0.0"
    ,   city
    ,   ip
    ,   types
    ,   capabilities
    ,   osVersion
    ,   token
    ,   token
    ,   "1",   "1",   "1"
    ,   reqFlag
    ,   "",   "",   "",   "",   "",   "",   "",   ""
    ,   "NA",   "NA"
    ]
    let requestMsg = foldl (\a b -> a <> "|" <> b) pgMerchantId dt
    upiCall $ RequestObject {  requestMsg
                            ,  url : yesBase <> "getRegisterAccListMEService"
                            ,  token
                            ,  pgMerchantId
                            ,  client_auth_token : cat
                            ,  encryptionRequired : false
                            }


register :: String -> String -> String -> String -> String -> String -> String -> String -> String -> String -> Flow (APIResult UPIRequest)
register token tnxID regReqId vpa accountID name secretQuestion sessionToken customerId cat = do
    let dt = [
        tnxID
    ,   regReqId
    ,   gcmID
    ,   vpa
    ,   accountID
    ,   name
    ,   secretQuestion
    ,   "JUSPAY"
    ,   appId
    ,   "0.0,0.0"
    ,   city
    ,   ip
    ,   types
    ,   capabilities
    ,   osVersion
    ,   token
    ,   token
    ,   "1",   "1",   "1"
    ,   "",   "",   "",   "",   "",   "",   "",   ""
    ,   "NA",   "NA"
    ]
    let requestMsg = foldl (\a b -> a <> "|" <> b) pgMerchantId dt
    upiCall $ RequestObject {  requestMsg
                            ,  url : yesBase <> "getRegisterService"
                            ,  token
                            ,  pgMerchantId
                            ,  client_auth_token : cat
                            ,  encryptionRequired : false
                            }


updateUser :: String -> String -> String -> String -> String-> String -> String -> String -> Flow (APIResult UPIRequest)
updateUser token tnxID mob uptype simChangeRefd secretQuestion customerId cat = do
    let dt = [
        tnxID
    ,   mob
    ,   uptype
    ,   secretQuestion
    ,   "JUSPAY"
    ,   simChangeRefd
    ,   appId
    ,   "0.0,0.0"
    ,   city
    ,   ip
    ,   types
    ,   capabilities
    ,   osVersion
    ,   token
    ,   token
    ,   "1",   "1",   "1"
    ,   "TWVyY2hhbnQyLjA=",   "",   "",   "",   "",   "",   "",   ""
    ,   "NA",   "NA"
    ]
    let requestMsg = foldl (\a b -> a <> "|" <> b) pgMerchantId dt
    upiCall $ RequestObject {  requestMsg
                            ,  url : yesBase <> "updateDevice"
                            ,  token
                            ,  pgMerchantId
                            ,  encryptionRequired : false
                            ,  client_auth_token : cat
                            }


addMultipleAccounts :: String -> String -> String -> String -> String -> String -> Flow (APIResult UPIRequest)
addMultipleAccounts tnxID regRef vpa accountList token cat=  do
    let dt = [
        tnxID
    ,   regRef
    ,   vpa
    ,   accountList
    ,   appId
    ,   "0.0,0.0"
    ,   city
    ,   ip
    ,   types
    ,   capabilities
    ,   osVersion
    ,   token
    ,   token
    ,   "1",   "1",   "1"
    ,   "NA",   "",   "",   "",   "",   "",   "",   ""
    ,   "NA",   "NA"
    ]
    let requestMsg = foldl (\a b -> a <> "|" <> b) pgMerchantId dt
    upiCall $ RequestObject {  requestMsg
                            ,  url : yesBase <> "submitMultiAccount"
                            ,  token
                            ,  pgMerchantId
                            ,  encryptionRequired : false
                            ,  client_auth_token : cat
                            }


accountSync :: String -> String -> String -> String -> String -> Flow (APIResult UPIRequest)
accountSync tnxID vpa accId token cat=  do
    let dt = [
        tnxID
    ,   vpa
    ,   accId
    ,   appId
    ,   "0.0,0.0"
    ,   city
    ,   ip
    ,   types
    ,   capabilities
    ,   osVersion
    ,   token
    ,   token
    ,   "1",   "1",   "1"
    ,   "",   "",   "",   "",   "",   "",   "",   ""
    ,   "NA",   "NA"
    ]
    let requestMsg = foldl (\a b -> a <> "|" <> b) pgMerchantId dt
    upiCall $ RequestObject {  requestMsg
                            ,  url : yesBase <> "syncAccountDeatils"
                            ,  token
                            ,  pgMerchantId
                            ,  encryptionRequired : false
                            ,  client_auth_token : cat
                            }
