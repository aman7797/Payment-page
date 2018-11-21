module UPI.Mapper where

import Prelude

import Control.Monad.Except (runExcept)
import Data.Array (index, length)
import Data.Either (Either(..))
import Foreign.Class (class Decode)
import Foreign.Generic (decodeJSON)
import Data.Generic.Rep (class Generic)
import Data.Maybe (fromMaybe)
import Data.String (Pattern(..), split)
import Engineering.Helpers.Commons (bankList, log)
import Engineering.Types.App (FlowBT, PaymentPageError, liftFlowBT)
import JBridge (decrypt)
import Presto.Core.Utils.Encoding (defaultDecode)
import Presto.Core.Flow (Flow)
import Remote.Config(encKey)
import UPI.Layer as UPI
import UPI.Remote (UPIRequest(..))

decyptMsg :: forall t35 t36.
  { responseMsgEncrypted :: String
  , responseMsg :: t35
  | t36
  }
  -> { responseMsg :: String
     , responseMsgEncrypted :: String
     | t36
     }
decyptMsg req = req {responseMsg = decrypt req.responseMsgEncrypted encKey}


checkDeviceId ::
    {token :: String, tnxID :: String, session_token :: String, customerId :: String, add1 :: String, client_auth_token :: String}
    -> Flow {deviceStatus :: String, simStatus :: String, smsStatus :: String, vpa :: String, encryptedResp :: String , mobileNo :: String, yblRef ::String , add1 :: String, smsContent :: String , encKey :: String, recpmob :: String}
checkDeviceId {
     token
    ,tnxID
    ,session_token
    ,customerId
    ,add1
    ,client_auth_token
    } = do
    result <- UPI.checkDeviceId token tnxID session_token customerId add1 client_auth_token
    case result of
        Left _ -> pure { deviceStatus : "F"
                        , yblRef : ""
                        , add1 : ""
                        , simStatus : "F"
                        , smsStatus : "F"
                        , encryptedResp : ""
                        , smsContent : ""
                        , encKey : ""
                        , recpmob : ""
                        , vpa : "NA"
                        , mobileNo : "NA"
                        }
        Right (UPIRequest b) -> do
            let a = log "THE DECRYPTED" $ decyptMsg b
            let val = split (Pattern "|") $ a.responseMsg
            pure $  { deviceStatus : fromMaybe "NA" $ index val 2 
                    , yblRef : fromMaybe "" $ index val 0 
                    , add1 : do
                        let up = fromMaybe "D" $ index val 11
                        if up == "" then "D" else up
                    , smsContent : fromMaybe "D" $ index val 9
                    , encKey : fromMaybe "D" $ index val 10
                    , recpmob : fromMaybe "D" $ index val 8
                    , simStatus : fromMaybe "NA" $ index val 4
                    , smsStatus : fromMaybe "NA" $ index val 3 
                    , mobileNo : fromMaybe "NA" $ index val 6
                    , encryptedResp : a.responseMsgEncrypted
                    , vpa : fromMaybe "NA" $ index val 7
                    }

getAccountList :: 
    { token :: String
    , tnxID :: String
    , session_token :: String
    , customerId :: String
    , reqFlag :: String
    , vpa :: String
    , bankCode :: String
    , client_auth_token :: String} 
    -> Flow { accountList :: Array AccountList,regReqId :: String, name :: String, register :: Boolean, status :: Boolean }
getAccountList {
     token
    ,tnxID
    ,session_token
    ,customerId
    ,reqFlag
    ,vpa
    ,bankCode
    ,client_auth_token
    } = do
    result <- UPI.getAccountList token tnxID session_token customerId reqFlag vpa bankCode client_auth_token
    case result of
        Left _ -> pure $ {accountList :[], regReqId : "", name : "", register : true, status: false}
        Right (UPIRequest b) -> do
            let a = log "THE DECRYPTED" $ decyptMsg b
            let val = split (Pattern "|") $ a.responseMsg
            let json = runExcept $ decodeJSON $ fromMaybe "NA" $ index val 4
            let regReqId = log "Reg Reference Number" $ fromMaybe "" $ index val 1
            let status = "F" /= (fromMaybe "" $ index val 2)
            let name = fromMaybe "" $ index val 5
            let accounts = case json of
                                Right (arr :: Array AccountList) -> arr
                                Left _ -> []
            let accountList = if length accounts == 0
                                then do
                                    let json2 = runExcept $ decodeJSON $ fromMaybe "NA" $ index val 4
                                    let accs = case json2 of
                                                Right (arr2:: Array AccountRegistered) -> acRegToAcLst <$> arr2
                                                Left _ -> []
                                    accs
                                else
                                    accounts
            let reg = length accounts /= 0
            pure $ { accountList, regReqId, name, register : reg, status}

-- getUPIBankList :: {token :: String, tnxID :: String, session_token :: String, customerId :: String, client_auth_token :: String} -> FlowBT PaymentPageError {bankList :: Array BankList}
-- getUPIBankList {
--      token
--     ,tnxID
--     ,session_token
--     ,client_auth_token
--     } = do
--     result <- liftFlowBT $ UPI.getUPIBankList token tnxID session_token "" client_auth_token
--     case result of
--         Left _ -> pure {bankList :[]}
--         Right (UPIRequest b) ->do
--             let a = log "THE DECRYPTED" $ decyptMsg b
--             let val = split (Pattern "|") $ a.responseMsg
--             let json = runExcept $ decodeJSON $ (log "BANKLIST") $ fromMaybe "NA" $ index val 2
--             let bankList = case json of 
--                                 Right (a :: Array BankList) -> a
--                                 Left _ -> []
--             pure $ { bankList }

getUPIBankList :: {token :: String, tnxID :: String, session_token :: String, customerId :: String, client_auth_token :: String} -> Flow {bankList :: Array BankList}
getUPIBankList a = pure $
    case (runExcept $ decodeJSON (bankList unit)) of
        Right (BLST blst) ->
            { bankList : blst.banks }
        Left _ ->
            { bankList : [] }

newtype BLST = BLST {banks :: Array BankList }


register :: {token :: String, tnxID :: String, regReqId :: String, vpa :: String, accountID :: String, name :: String, secretQuestion :: String, session_token :: String, customerId :: String, client_auth_token :: String} -> FlowBT PaymentPageError { status :: Boolean, accID :: String }
register {
     token
    ,tnxID
    ,regReqId
    ,vpa
    ,accountID
    ,name
    ,secretQuestion
    ,session_token
    ,customerId
    ,client_auth_token
    } = do
    result <- liftFlowBT $ UPI.register token tnxID regReqId vpa accountID name secretQuestion session_token customerId client_auth_token
    case result of
        Left _ -> pure {status : false, accID : ""}
        Right (UPIRequest b) ->do
            let a = log "THE DECRYPTED" $ decyptMsg b
            let val = split (Pattern "|") $ a.responseMsg
            let json = fromMaybe "F" $ index val 3
            let account = fromMaybe "F" $ index val 1
            let status = json == "S"
            pure $ { status, accID : account }


updateUser
    :: {token :: String, tnxID :: String, simChangeRefd :: String, upType :: String, secretQuestion :: String, customerId :: String, client_auth_token :: String, mob :: String}
    -> Flow { status :: Boolean, mobile :: String }
updateUser {
     token     
    ,tnxID
    ,upType
    ,mob
    ,simChangeRefd
    ,secretQuestion
    ,customerId
    ,client_auth_token
    } = do
    result <- UPI.updateUser token tnxID mob upType simChangeRefd secretQuestion customerId client_auth_token 
    case result of
        Left _ -> pure {status : false, mobile : "NA"}
        Right (UPIRequest b) ->do
            let a = log "THE DECRYPTED" $ decyptMsg b
            let val = split (Pattern "|") $ a.responseMsg
            let json = fromMaybe "F" $ index val 1
            let mobile = fromMaybe "NA" $ index val 3
            let status = json == "S"
            pure $ { status, mobile}

            -- YblRefNo|MeTxnId|VirtualAddress|Status|StatusDesc|RegDate|RegRefId|MobileNo|Add1|Add2|Add3|Add4|Add5|Add6|Add7|Add8|Add9|Add10Parameter 
            -- 34480|vF1bQcU6imN|918291982384@yesb|S|CustomerRegisteredSuccessfully|2017:05:0801:01:50|34480|918291982384|3699|XXXXXX0141|NA|NA|NA|NA|NA|NA|NA|NA


multiAccountAdd :: {tnxID ::String, regRef ::String, vpa ::String, accountList ::String, token ::String, cat ::String } -> FlowBT PaymentPageError { status :: Boolean }
multiAccountAdd {tnxID, regRef, vpa, accountList, token, cat } = do
    result <- liftFlowBT $ UPI.addMultipleAccounts tnxID regRef vpa accountList token cat
    case result of
        Left _ -> pure {status : false}
        Right (UPIRequest b) ->do
            let a = log "THE DECRYPTED" $ decyptMsg b
            let val = split (Pattern "|") $ a.responseMsg
            let json = fromMaybe "F" $ index val 3
            let status = json == "S"
            pure $ { status}


accountSync :: {tnxID ::String, accId ::String, vpa ::String, token ::String, cat ::String } -> FlowBT PaymentPageError { status :: Boolean }
accountSync {tnxID, vpa, accId, token, cat } = do
    result <- liftFlowBT $ UPI.accountSync tnxID vpa accId token cat
    case result of
        Left _ -> pure {status : false}
        Right (UPIRequest b) ->do
            let a = log "THE DECRYPTED" $ decyptMsg b
            let val = split (Pattern "|") $ a.responseMsg
            let json = fromMaybe "F" $ index val 3
            let status = json == "S"
            pure $ { status}


newtype AccountList = AccountList 
    {
        accId :: Int
    ,   accNo :: String
    ,   ifscCode :: String
    ,   mpinStatus :: String
    ,   bankName :: String
    ,   bankCode :: String
    ,   crdLength :: Int
    ,   crdType :: String
    ,   accountType :: String
    }
newtype AccountRegistered = AccountRegistered{
        accountId :: Int,
        accountName :: String,
        accountNumber :: String,
        accountType :: String,
        atmCrdLength  :: Int,
        bankCode ::  String,
        bankName ::  String,
        crdLength :: Int,
        crdType ::  String,
        currStatusCode ::Int,
        customerId :: Int,
        dMobile ::  String,
        defAccFlag ::  String,
        fvaddr ::  String,
        ifscCode ::  String,
        mpinStatus ::  String,
        otpdLength :: Int,
        statusCode :: Int
        }

acRegToAcLst :: AccountRegistered -> AccountList
acRegToAcLst (AccountRegistered acc) = AccountList {
        accId : acc.accountId
    ,   accNo : acc.accountNumber
    ,   ifscCode : acc.ifscCode
    ,   mpinStatus : acc.mpinStatus
    ,   bankName : acc.bankName
    ,   bankCode : acc.bankCode
    ,   crdLength : acc.crdLength
    ,   crdType : acc.crdType
    ,   accountType : acc.accountType}

derive instance accListGenric :: Generic AccountList _
instance accListDecode :: Decode AccountList where decode = defaultDecode

derive instance accRegListGenric :: Generic AccountRegistered _
instance accRegListDecode :: Decode AccountRegistered where decode = defaultDecode

newtype SecretQuestion = SecretQuestion{ quesId :: Int
    , quesName :: String
    }

derive instance secQuesGenric :: Generic SecretQuestion _
instance secQuesDecode :: Decode SecretQuestion where decode = defaultDecode

newtype BankList = BankList { 
     id :: String
    ,name :: String
    ,ifsc ::String
    ,iin ::String
    }

-- -- newtype BankList = BankList { bankId :: Int
--     ,bankName :: String
--     ,ifsc ::String
--     ,bankCode ::String
--     ,statusCode :: Int}

derive instance bankListGenric :: Generic BankList _
instance bankListDecode :: Decode BankList where decode = defaultDecode


derive instance blstGenric :: Generic BLST _
instance blstDecode :: Decode BLST where decode = defaultDecode