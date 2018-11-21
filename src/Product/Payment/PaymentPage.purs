module Product.Payment.PaymentPage where

import Prelude

import Constants as Constants
import Effect.Class (liftEffect)
import Effect.Aff (Milliseconds(..), makeAff, nonCanceler, throwError)
import Control.Monad.Except (runExcept, runExceptT)
import Control.Transformers.Back.Trans (BackT(..), FailBack(..), runBackT)
import Data.Array (concat, filter, fold, foldl, index, length, zipWith)
import Data.Array as Arr
import Data.Either (Either(..), hush)
{-- import Foreign.NullOrUndefined (NullOrUndefined) --}
import Data.Int (toNumber)
import Data.Lens ((.~), (?~), (^.))
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Newtype (class Newtype)
import Data.Number (fromString)
import Data.String (Pattern(..), Replacement(..), contains, replaceAll, toLower, trim)
import Data.String as S
import Data.Traversable (traverse)
import Engineering.Helpers.Commons (checkPermissions, continue, getFromWindow, liftFlow, log, requestPermissions, startAnim, startAnim_, unsafeJsonStringify, unsafeJsonDecode )
import Engineering.Helpers.Types.Accessor (_addNewCardState, _amount, _bank_Name, _banks, _billerCard, _cardBrand, _cardMethod, _cardProvider, _currentOverlay, _customerId, _debitCardCount, _dueIn, _error, _ifsc, _mobile, _orderId, _orderToken, _payTotal, _payUsing, _ppInput, _preferedBanks, _selectedBank, _selectedProvider, _selectedTab, _session_token, _storedCards, _uiState, _upiAccounts, _upiInfo, _upiNBTabState, _upiNLAccounts, _upiState, _upiTabState, _youPay)
import Engineering.Helpers.Utils (exitApp, exitWithSuccess, getCurrentTime, getLoaderConfig, liftFlowBT, sendBillerChanges, setScreen, (>>))
import Engineering.OS.Permission (toAndroidPermission)
import Engineering.Types.App (FlowBT, MicroAppResponse, PaymentPageError)
import Engineering.Types.App as Err
import Externals.Godel.Flow (mkGodelParams, startGodel)
import Externals.UPI.Flow (openUPIApp)
import JBridge (attach, requestKeyboardHide)
import JBridge as UPI
import Presto.Core.Flow (Flow, delay, doAff, oneOf, showScreen)
import Presto.Core.Types.API (ErrorPayload(..), Response(..))
import Presto.Core.Types.Language.Flow (loadS, saveS)
import Presto.Core.Types.Permission (Permission(..))
import Presto.Core.Utils.Encoding (defaultDecodeJSON, defaultEncodeJSON)
import Product.Payment.Utils (mkPaymentPageState,  fetchSIMDetails)
import Product.Types
import Remote.Accessors (_status, _payment)
import Remote.Backend (mkPayment, checkOrderStatus, getPaymentMethods) as Remote
import Remote.Config (encKey, merchantId)
import Remote.Types (InitiateTxnResp(..), PaymentSourceReq(PaymentSourceReq))
import Remote.Utils (mkPayReqCard, mkPayReqNB, mkPayReqSavedCard, mkPayReqUPI)
import Tracker.Tracker (toString) as T
import Tracker.Tracker (trackEventMerchant)
import Type.Data.Boolean (kind Boolean)
import UI.Controller.Component.AddNewCard as A
import UI.Controller.Screen.PaymentsFlow.ErrorMessage as ErrorMessageC
import UI.Controller.Screen.PaymentsFlow.PaymentPage
import UI.Flow as UI
import UI.Utils (logit, os)
import UI.View.Screen.PaymentsFlow.ErrorMessage as ErrorMessage
import UI.View.Screen.PaymentsFlow.Loader as Loader
import UI.View.Screen.PaymentsFlow.Toast as Toast
import UPI.Mapper (AccountList(..))
import UPI.Mapper as UPIMap

startPaymentFlow :: SDKParams -> Maybe PaymentPageState -> Flow Unit
startPaymentFlow sdkParams optPPState = do
  _ <- doAff do liftEffect $ setScreen "LoadingScreen"
  {-- _ <- showScreen (Loader.screen getLoaderConfig) --}
  {-- _ <- if os /= "IOS" then getRequiredPermissions else (pure true) --}
  result <- runExceptT <<< runBackT $ paymentPageFlow sdkParams optPPState 
  ppState <- getFromWindow Constants.ppStateKey
  case result of
    -- ExitApp
    Right (BackPoint (ExitApp { status, code })) -> exitApp (-1) $ log "The final Message" status
    Right (NoBack    (ExitApp { status, code })) -> exitApp (-1) $ log "The final Message" status

    -- RetryPayment
    Right (BackPoint (RetryPayment opts))        -> startPaymentFlow sdkParams ppState
    Right (NoBack    (RetryPayment opts))        -> startPaymentFlow sdkParams ppState

    -- UPI
    Right (BackPoint Proceed) -> exitApp 0 $ log "The final Message" $ makeErrorMessage "failure" (sdkParams ^. _orderId ) "Unable to process"
    Right (NoBack    Proceed) -> exitApp 0 $ log "The final Message" $ makeErrorMessage "failure" (sdkParams ^. _orderId ) "Unable to process"

    Right GoBack                                 -> exitApp 0 $ log "The final Message" $ makeErrorMessage "failure" (sdkParams ^. _orderId ) "Unable to process" 

    -- Error Scenarios
    Left (Err.ExitApp reason)                     -> exitApp 0 $ log "The final Message" $ makeErrorMessage "failure" (sdkParams ^. _orderId ) "Payment Failed"
    Left Err.UserAborted                          -> exitApp 0 $ log "The final Message" $ makeErrorMessage "cancel" (sdkParams ^. _orderId ) "User aborted"
    {-- Left Err.ChargeStatusFailure                  -> startPaymentFlow sdkParams (ppState <#> (_uiState <<< _error) ?~ (Snackbar "Some problem" )) --}
    Left (Err.ApiFailure (Response {response}) )  -> exitApp 0 $ log "The final Message" $ makeErrorMessage "failure" (sdkParams ^. _orderId ) "Unable to process" 
    Left (Err.MicroAppError reason)               -> exitApp 0 $ log "The final Message" $ makeErrorMessage "failure" (sdkParams ^. _orderId ) "Payment failed"
    Left Err.SessionExpired                       -> exitApp 0 $ log "The final Message" $ makeErrorMessage "failure" (sdkParams ^. _orderId ) "Token Expired"
    _                                             -> exitApp 0 $ log "The final Message" $ makeErrorMessage "failure" (sdkParams ^. _orderId ) "Unable to process" 


-- parrallelUPIBankList :: Flow Either 
-- parrallelUPIBankList  = unit


getErrorMessage :: ErrorPayload -> String
getErrorMessage (ErrorPayload err) = err.errorMessage

makeErrorMessage :: String -> String -> String -> String
makeErrorMessage status orderId message = "{\"status\":\"" <> status <> "\",\"order_id\":\"" <> orderId <> "\",\"message\":\"" <> message <> "\"}"

getUserMessage :: ErrorPayload -> String
getUserMessage (ErrorPayload err) = err.userMessage

generateVpa :: String -> String
generateVpa mobile = (S.drop 2 mobile) <> "d5d37924312@yesbank"

type UPIFLOWSTATE =  {upiTab :: UPIState, sims :: Array SIM, token :: String, token' :: String, vpa :: String, banks :: Array Bank, mobile :: String, recpMob :: String, smsKey :: String, smsContent :: String} 


paymentPageFlow :: SDKParams -> Maybe PaymentPageState -> FlowBT PaymentPageError PaymentPageExitAction
paymentPageFlow sdkParams optPPState = do
    ppState <-  pure $ fromMaybe (mkPaymentPageState sdkParams) optPPState

    {-- ppState <- case optPPState of --} 
        {-- Nothing -> do --}
          {-- paymentMethods <- Remote.getPaymentMethods $ PaymentSourceReq { client_auth_token: sdkParams ^. _orderToken, offers: "", refresh : "" } --}
          {-- pure $ fromMaybe (mkPaymentPageState sdkParams paymentMethods) optPPState --}
        {-- Just state -> pure state --}
    res <- UI.showPaymentPage ppState
    paymentPageFlow sdkParams $ Just ppState
    -- Logging

makeValueNB :: PaymentPageState -> Bank -> FlowBT PaymentPageError Unit
makeValueNB ppState bank = do
  trackEventMerchant "UserFlow" "State" "U.NetBanking.Pay" (T.toString (netBankingPay # (_bank_Name .~ "") ))

type TransactionType = {
         enckey :: String  -- hard Code
        ,merchantId :: String -- hard Code
        ,merchantTxnId :: String -- fetch
        ,accId :: String         -- getFrom getAccountList Call
        ,txnNote :: String        -- hard Code
        ,txnType :: String -- ?
        ,transactionDesc :: String -- hard Code
        ,currency :: String -- hard Code
        ,paymentType :: String -- confirm
        ,transactionType :: String -- confirm
        -- Clarify Payer Details mostly fetch from account list and checkDevice
        ,payeraccntNo :: String
        ,payerPaymentAddress :: String  -- ??
        ,payerMobileNo :: String    -- get From SOME API, Possibly Check Device
        ,expiryTime :: String
        ,whitelistedAccnts :: String   -- ??
        ,refurl :: String       -- ??
        ,appName :: String      -- FIX THE APP NAME FETCH DETAILS
        ,subMerchantID :: String  -- Is this us??
        -- CLARIFY ALL PAYEE DETAILS
        ,merchantCatCode :: String  
        ,amount :: String   
        ,geoCode :: String
        ,location :: String
        ,payeePayAddress :: String
        ,payeeAccntNo :: String
        ,payeeAadharNo :: String
        ,payerAadharNo :: String
        ,payeeIFSC :: String
        ,payerIFSC :: String
        ,payeeMMID :: String
        ,payerMMID :: String
        ,payeeMobileNo :: String 
        ,payeeName :: String
        -- GIVE EMPTY
        ,add1 :: String
        ,add2 :: String
        ,add3 :: String
        ,add4 :: String
        ,add5 :: String
        ,add6 :: String
        ,add7 :: String
        ,add8 :: String
        ,add9 :: String
        ,add10 :: String
       }



makettt :: String -> Account -> String -> String -> String ->TransactionType 
makettt orderId (Account account) vpa amount mob = {
    enckey : encKey  -- hard Code
    ,merchantTxnId : orderId -- fetch
    ,txnNote : "PAY"        -- hard Code
    ,amount         -- From UI
    ,currency : "INR" -- hard Code
    ,paymentType : "P2M" -- confirm
    ,txnType : "PAY"
    ,transactionType : "PAY" -- confirm
    ,payeePayAddress : "cred@yesbank"  --MERCHANT VA
    ,payeeAccntNo : ""
    ,payeeIFSC : ""
    ,payeeAadharNo : ""
    ,payeeMobileNo : "" 
    ,merchantCatCode : "7322"  
    ,expiryTime : ""
    ,payeraccntNo : ""        --
    ,payerIFSC : ""
    ,payerAadharNo : ""
    ,payerMobileNo : mob    -- get From SOME API, Possibly Check Device
    ,payerPaymentAddress : vpa  -- PayerVPA
    ,subMerchantID : ""  -- Optional
    ,whitelistedAccnts : ""   -- ??
    ,payeeMMID : ""
    ,payerMMID : ""
    ,payeeName : "Juspay"
    ,accId : account.referenceId        -- getFrom getAccountList Call  -- ADD NOW 
    ,refurl : "https://sky.yesbank.in"       -- 
    ,geoCode : "0.0,0.0"
    ,location : "INDIA"
    ,merchantId -- hard Code
    ,transactionDesc : "" -- hard Code
    -- Clarify Payer Details mostly fetch from account list and checkDevice
    ,appName : "CRED"      -- FIX THE APP NAME FETCH DETAILS
    -- CLARIFY ALL PAYEE DETAILS
    -- GIVE EMPTY
    ,add1 : ""
    ,add2 : ""
    ,add3 : ""
    ,add4 : ""
    ,add5 : ""
    ,add6 : ""
    ,add7 : ""
    ,add8 : ""
    ,add9 : "NA"
    ,add10 : "NA"
  }

type SetMpinType =  
    {    enckey :: String -- hard code
        ,"PCI" :: String     -- ALways Y
        ,merchantId :: String -- hard code
        ,merchantTxnId :: String -- 
        ,virtualAddress :: String -- get from some API (read Doc)
        ,accountId :: String -- 
        ,lastSixDigitNo :: String -- get From UI
        ,expDate :: String -- get From UI
        ,geoCode :: String
        ,location :: String
        -- EMPTY VALUES TO BE PASSED CLARIFY
        ,add1 :: String
        ,add2 :: String
        ,add3 :: String
        ,add4 :: String
        ,add5 :: String
        ,add6 :: String
        ,add7 :: String
        ,add8 :: String
        ,add9 :: String
        ,add10 :: String
    }

makeSMP :: SDKParams -> String -> String -> String -> String -> SetMpinType
makeSMP sdk vpa exp ls6 accID= {    
        enckey : encKey -- hard code
        ,"PCI" : "Y"     -- ALways Y
        ,merchantId -- hard code
        ,merchantTxnId : sdk ^. _orderId -- 
        ,virtualAddress : vpa -- get from some API (read Doc)
        ,accountId : accID -- 
        ,lastSixDigitNo : ls6 -- get From UI
        ,expDate : exp -- get From UI
        ,geoCode : "0.0,0.0"
        ,location : "India"
        -- EMPTY VALUES TO BE PASSED CLARIFY
        ,add1 : ""
        ,add2 : ""
        ,add3 : ""
        ,add4 : ""
        ,add5 : ""
        ,add6 : ""
        ,add7 : ""
        ,add8 : ""
        ,add9 : "NA"
        ,add10 : "NA"
    }

setMpinFlow :: SDKParams -> String -> String -> String -> Account -> FlowBT PaymentPageError {status :: String, response :: {status :: String}}
setMpinFlow sdk vpa lst6 exp (Account account) = liftFlowBT $ doAff (makeAff (\cb -> (UPI.setMPIN (cb <<< Right) (T.toString $ makeSMP sdk vpa exp lst6 account.referenceId) )*> pure nonCanceler ))

registerDeviceCall :: SDKParams -> String -> String -> Account -> FlowBT PaymentPageError { status :: Boolean
    , accID :: String
    }
registerDeviceCall sdk token vpa (Account acc) = UPIMap.register {token : token, tnxID : (sdk ^. _orderId), regReqId : acc.regRefId, vpa, accountID : acc.referenceId , name: acc.accountHolderName, secretQuestion : "104", session_token : (sdk ^. _session_token), customerId : (sdk ^. _customerId), client_auth_token : (sdk ^. _orderToken)}

getRequiredPermissions :: Flow Boolean
getRequiredPermissions = storageGranted >>= (\condition ->
  if condition
    then
      askForStorage 
    else
      pure true )
  where
    storageGranted :: Flow Boolean
    storageGranted = do
      val <- liftFlow (checkPermissions permissionArray)
      pure $ contains (Pattern "false") val

    permissionArray :: Array String
    permissionArray = (toAndroidPermission <$> [PermissionReadPhoneState,PermissionSendSms])

    askForStorage :: Flow Boolean
    askForStorage = do
      value <- doAff (makeAff (\cb -> ( requestPermissions (cb <<< Right) permissionArray )*> pure nonCanceler ))
      pure true
    -- pure <<< allPermissionGranted =<< takePermissions [PermissionReadPhoneState,PermissionSendSms]

-- upiPay :: SDKParams -> FlowBT PaymentPageError PaymentPageExitAction
-- upiPay sdk = do
  
--   BackT $ throwError $ Err.UserAborted

makeValueDebitCardPay :: PaymentPageState -> CardDetails -> FlowBT PaymentPageError Unit
makeValueDebitCardPay ppState card = do
  --let bankName = "BN"
  let cardProvider = fromMaybe "" (Just "CP")
  trackEventMerchant "UserFlow" "State" "U.DebitCard.New.Pay" (T.toString (debitCardNewPay # (_cardProvider .~ cardProvider) )) -- # (_bank_Name .~ bankName) 

{-- makeValueSDebitCardPay :: PaymentPageState -> SavedCardDetails -> FlowBT PaymentPageError Unit --}
{-- makeValueSDebitCardPay ppState card = do --}
{--   let youPay = 0.0 -- fromMaybe 0.0 $ fromString (ppState ^. _uiState ^. _amount) --}
{--   let sc = (ppState ^. _uiState ^. _addNewCardState ^. _cardMethod) --}
{--   let brand = case sc of --}
{--                 A.SavedCard scd -> (scd ^. _cardBrand) --}
{--                 _               -> "" --}
{--   let dueIn = 1.0 --}
{--   let bn = map (\a -> a.card_issuer ) (ppState ^. _uiState ^. _billerCard)--"bankname" --}
{--   let bankName = "BANKNAME" --}
{--   let payTotal = 3.0 --}   
{--   let cardProvider = "" --}
{--   let payUsing = "DEBITCARD" --}
{--   let selectedBank = "" --}
{--   let debitCardCount = toNumber (length (ppState ^. _uiState ^. _storedCards)) --}
{--   trackEventMerchant "UserFlow" "State" "U.DebitCard.Pay" (T.toString (debitCardPay # (_youPay .~ youPay) --} 
{--                                                                           # (_dueIn .~ dueIn) --}
{--                                                                           # (_bank_Name .~ bankName) --} 
{--                                                                           # (_payTotal .~ payTotal ) --}
{--                                                                           # (_cardProvider .~ cardProvider) --}
{--                                                                           # (_payUsing .~ payUsing) --}
{--                                                                           # (_selectedBank .~ selectedBank) --}
{--                                                                           # (_selectedProvider .~ brand) --}
{--                                                                           # (_debitCardCount .~ debitCardCount) )) --}
addlAuth :: InitiateTxnResp -> FlowBT PaymentPageError MicroAppResponse
addlAuth resp = (startGodel =<< mkGodelParams (resp ^. _payment)) <* (liftFlowBT $ attach Constants.networkStatus "{}" "")

getStatus :: forall response b. Newtype response { status :: String | b } => response -> String
getStatus response = response ^. _status

handlePayResp :: PaymentOption -> String -> String -> FlowBT PaymentPageError PaymentPageExitAction
handlePayResp paymentOption order_id status = do
  case status of
    -- Successful
    "CHARGED"       -> pure $ exitWithSuccess order_id
    "COD_INITIATED" -> pure $ exitWithSuccess order_id

    -- Pending -- Failure
    value           -> BackT $ throwError $ Err.MicroAppError "Payment Failed"
                  -- RetryPayment { showError : true, errorMessage : Config.paymentsPendingErrMsg, prevPaymentMethod : paymentOption }
    -- activity recreated has to handled - need to discuss about where to handle
    

---------------------------------------   MOVE TO ENGINEEERING UTILS -------------------------------------------------------

updateOrderAmount :: CallBack -> Flow String
updateOrderAmount billerChanges = doAff (makeAff (\cb -> (sendBillerChanges billerChanges (cb <<< Right)) {--(cb <<< Left)--}*> pure nonCanceler ))


updateCallbackPayload :: Array PayLaterResp -> Array PayLaterResp
updateCallbackPayload aplr = filter (\(PayLaterResp a) -> not a.card_removed) aplr

makeNewCallBackPayload :: Array PayLaterResp -> Array {card_reference:: String , amount:: String}
makeNewCallBackPayload = map (\(PayLaterResp val) -> {card_reference : val.card_reference ,amount: fromMaybe "0" val.amount })


makeCallbackPayload :: Int -> Array PayLaterResp -> String -> CallBack
makeCallbackPayload slno billerChanges session_id = CallBack {
              serial_no : show (slno + 1)
            , session_id
            , "type": "order_update"    -- order_update is an event of a change in the amount of biller cards or removal of the card from order altogether
            , value: makeNewCallBackPayload billerChanges
          }

defaultBank :: Array Bank
defaultBank = [ Bank {code : "plus", name : "Link", ifsc: ""} ]

upiToBankMap :: {iin :: String, name :: String, ifsc:: String} ->  Bank
upiToBankMap {iin, name, ifsc} = Bank {code : iin, name, ifsc}

----------------------------------------------------------MOVE TO UPI ---------------------------------------------------------

getFlag :: String
getFlag = if os == "ANDROID" then "1" else "001"

upiPaymentFlow :: String -> Account -> String -> String -> InitiateTxnResp -> FlowBT PaymentPageError {status :: String, statusCode :: String, response :: { status :: String }}
upiPaymentFlow vpa account amount mob (InitiateTxnResp init) =
    liftFlowBT $
        doAff $ makeAff
                (\cb -> (UPI.transaction (cb <<< Right) (T.toString $ makettt init.txn_uuid account vpa amount mob) )
                    *> pure nonCanceler
                )

fetchAccounts :: SDKParams -> String -> String -> Bank -> UPIState -> FlowBT PaymentPageError UPIState
fetchAccounts sdk token vpa (Bank bank) upi = do
  acc <- liftFlowBT $ UPIMap.getAccountList {token, tnxID : (sdk ^. _orderId), session_token : (sdk ^. _session_token), customerId : (sdk ^. _customerId), reqFlag : "R", vpa, bankCode : bank.ifsc, client_auth_token : (sdk ^. _orderToken)}
  if acc.status 
    then do
      let accounts = toAccount acc
      pure $ PreLink accounts
    else
      pure $ upi

postBoundFlow :: SDKParams -> String -> String -> Array Bank->  FlowBT PaymentPageError {upiTab :: UPIState}
postBoundFlow sdk token vpa banks =  do
  bankList <- traverse (\bankCode -> do
                          acc <- liftFlowBT $ UPIMap.getAccountList {token, tnxID : (sdk ^. _orderId), session_token : (sdk ^. _session_token), customerId : (sdk ^. _customerId), reqFlag : "R", vpa, bankCode, client_auth_token : (sdk ^. _orderToken)}
                          pure acc) $ log "BANKLIST " (sdk ^. _preferedBanks)
  let accounts = concat $ (toAccount <$> bankList)
  if length accounts == 0
    then 
      pure $ { upiTab :Bound banks }
    else
      pure $ {upiTab :PreLink accounts }

-- reccFetchAccounts :: SDKParams -> FlowBT PaymentPageError UPIState
-- reccFetchAccounts sdk = 
--   pure Linked []
---------------------------------------------------------------MOVE TO TYPES ------------------------------------------------------------------------



data SelectAccountScreenOutput = SelectedAccount Account String
----------------------------------------------- MOVE TO UTILS ----------------------------------------------

stringToBoolean :: String -> Boolean
stringToBoolean = eq "true" <<< toLower <<< trim

ccToPlr :: CreditCard -> PayLaterResp
ccToPlr (CreditCard cc) = PayLaterResp {card_reference : cc.card_reference, amount : Just cc.amount_payable, card_removed: false }

eqArrayMapping :: forall a. Eq a => Array a -> Array a -> Boolean
eqArrayMapping a b = foldl (&&) true $ zipWith (\c d -> a == b) a b

toAccount :: {accountList :: Array UPIMap.AccountList, regReqId :: String, name :: String, register :: Boolean, status :: Boolean} -> Array Account
toAccount account = accMap <$> account.accountList
  where 
    accMap :: AccountList -> Account
    accMap (AccountList acc) = Account {
        bankCode : acc.bankCode
      , bankName : acc.bankName
      , maskedAccountNumber : acc.accNo
      , mpinSet : acc.mpinStatus  == "Y"
      , referenceId : show acc.accId
      , regRefId : account.regReqId
      , accountHolderName : account.name
      , register : account.register
      , ifsc : acc.ifscCode
      } 

startLoader :: FlowBT PaymentPageError {}
startLoader = do
          _ <- liftFlowBT $ doAff do liftEffect $ setScreen "LoadingScreen"
          liftFlowBT $ oneOf [(showScreen (Loader.screen getLoaderConfig)), pure {}]

errorMessage :: String -> FlowBT PaymentPageError ErrorMessageC.Action
errorMessage a  = do
          _ <- liftFlowBT $ doAff do liftEffect $ setScreen "ErrorMessage"
          _ <- liftFlowBT $ doAff do liftEffect $ startAnim "errorFadeIn"
          _ <- liftFlowBT $ doAff do liftEffect $ startAnim "errorSlide"
          _ <- liftFlowBT $ doAff do liftEffect $ startAnim "errorMsgFade"
          liftFlowBT (showScreen (ErrorMessage.screen (ErrorMessageC.ErrorMessage a)))

toast :: String -> FlowBT PaymentPageError ErrorMessageC.Action
toast a  = do
          _ <- liftFlowBT $ doAff do liftEffect $ setScreen "Toast"
          _ <- liftFlowBT $ doAff do liftEffect $ startAnim "toastFadeIn"
          _ <- liftFlowBT $ doAff do liftEffect $ startAnim "toastSlide"
          liftFlowBT (oneOf [(showScreen (Toast.screen (ErrorMessageC.ToastMessage a)))
                            , animateAfterDelay
                            ]
                     )

animateAfterDelay :: Flow ErrorMessageC.Action
animateAfterDelay = do
          _ <- delay (Milliseconds 1800.0)
          _ <- doAff do liftEffect $ setScreen "Toast"
          _ <- doAff do liftEffect $ startAnim "toastFadeOut"
          _ <- doAff do liftEffect $ startAnim "toastSlideOut"
          _ <- delay (Milliseconds 400.0)
          pure ErrorMessageC.UserAbort

toBank :: UPIMap.BankList -> Bank
toBank (UPIMap.BankList bank) = Bank {code: bank.iin, name : bank.name, ifsc : bank.ifsc}
