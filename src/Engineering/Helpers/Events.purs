module Engineering.Helpers.Events where

import Prelude (Unit, bind, pure, show, unit, ($), (*>), (/=), (<$>), (<<<), (<>), (=<<), (==), (>>=), (||))
import Product.Types (Account(..), Bank(..), SDKParams, SIM, UPIState(..))

import Web.Event.Event (EventType(..), Event) as DOM
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Halogen.VDom.DOM.Prop (Prop(..))
import Unsafe.Coerce as U

{-- ======= --}
{-- import Prelude --}
import Effect.Aff (launchAff_, makeAff, nonCanceler)
import Effect.Aff.AVar (new) as AVar
import Effect.Class (liftEffect)
import Effect.Timer (setTimeout)
{-- import Control.Monad.Eff.Unsafe (unsafeCoerceEff) --}
import Control.Monad.State.Trans (evalStateT) as S
{-- import DOM.Event.Types (EventType(..), Event) as DOM --}
import Data.Array (length)
import Data.Either (Either(Right, Left))
import Data.Function.Uncurried (runFn2)
import Data.Lens ((^.))
import Foreign.Object (empty)
import Data.String (drop) as S
import Engineering.Helpers.Commons (callAPI', liftFlow, mkNativeRequest, showUI',  unsafeJsonStringify)
import Engineering.Helpers.Types.Accessor (_customerId, _orderId, _orderToken, _session_token)
import Engineering.Helpers.Utils (eligibleForUPI, upiMethodPayload)
import Engineering.OS.Permission (checkIfPermissionsGranted, requestPermissions) as P
import Externals.UPI.Flow (getInstalledUPIAppsPayload)
import Externals.UPI.Types (UPIIntentPayload)
import JBridge as UPI
import Presto.Core.Flow (Flow, doAff)
import Presto.Core.Language.Runtime.API (APIRunner)
import Presto.Core.Language.Runtime.Interpreter (PermissionCheckRunner, PermissionRunner(..), PermissionTakeRunner, Runtime(..), UIRunner, run)
import Presto.Core.Types.Language.Flow (saveS)
import Remote.Config (encKey, merchantId)
import Tracker.Tracker (trackHyperPayEvent')
import UI.Utils
import UPI.Mapper (AccountList(..))
import UPI.Mapper as UPIMap

foreign import registerEvent :: String -> (DOM.Event → Effect Unit) -> (DOM.Event -> Effect Unit)

foreign import startUPI' :: forall a. UPIIntentPayload -> (a -> Effect Unit ) -> (forall val . val -> Effect Unit) -> Effect Unit


makeEvent :: forall a. (a -> Effect Unit) -> (DOM.Event → Effect Unit)
makeEvent push = \ev -> do
    _ <- push (U.unsafeCoerce ev)
    pure unit

makeLazyLoadEvent :: forall a. (a -> Effect Unit ) -> (DOM.Event → Effect Unit)
makeLazyLoadEvent push = \ev -> do
    _ <-  setTimeout 300 (push (U.unsafeCoerce ev))
    pure unit

makeGetUpiAppsEvent :: forall a. String -> (a -> Effect Unit ) -> (DOM.Event → Effect Unit)
makeGetUpiAppsEvent orderId push = \ev -> do
        _ <- startUPI' (getInstalledUPIAppsPayload (upiMethodPayload orderId)) push (trackHyperPayEvent' "response_from_upi")
        pure unit

makeGetUpiEvent :: forall a. SDKParams -> Array SIM -> (a -> Effect Unit ) -> (DOM.Event → Effect Unit)
makeGetUpiEvent sdkParams sims push = \ev -> do
        _ <- flowToEff push fn
        {-- _ <- startUPI' (getInstalledUPIAppsPayload (upiMethodPayload orderId)) push (trackHyperPayEvent' "response_from_upi") --}
        pure unit

    where
          fn = (upiOnboardingFlow sdkParams sims)


onFocus :: forall a. (a -> Effect Unit) -> (Boolean -> a) -> Prop (Effect Unit)
onFocus push f = Handler (DOM.EventType "onFocus") (Just <<< (makeEvent (push <<< f <<< toBool)))

lazyLoadList :: forall a. (a -> Effect Unit ) -> (Unit -> a) -> Prop (Effect Unit)
lazyLoadList push f = Handler (DOM.EventType "lazyLoadList") (Just <<< fn)
    where
              fn = registerEvent "lazyLoadList" (makeLazyLoadEvent (push <<< f))


getUpiApps :: forall a b. String -> (a -> Effect Unit ) -> (b -> a) -> Prop (Effect Unit)
getUpiApps orderId push f = Handler (DOM.EventType "getUpiApps") (Just <<< fn)
	where
		fn = registerEvent "getUpiApps" (makeGetUpiAppsEvent orderId (push <<< f))


getUpi :: forall a b. SDKParams -> Array SIM -> (a -> Effect Unit ) -> (b -> a) -> Prop (Effect Unit)
getUpi sdkParams sims push f = Handler (DOM.EventType "getUpi") (Just <<< fn)
	where
		fn = registerEvent "getUpi" (makeGetUpiEvent sdkParams sims (push <<< f))


toBool :: String -> Boolean
toBool =
    case _ of
         "true" -> true
         _ -> false

cardNumberHandler :: forall b. String -> (b -> Effect Unit) -> (DOM.Event -> Effect Unit)
cardNumberHandler id push = \str -> do
	_ <- pure $ _cardNumberHanlder id str push
	pure unit

expiryHandler :: forall b. String -> (b -> Effect Unit) -> (DOM.Event -> Effect Unit)
expiryHandler id push = \str -> do
	_ <- pure $ _expiryHandler id str push
	pure unit

registerNewListener :: forall a b . (String -> (b -> Effect Unit) -> (DOM.Event -> Effect Unit)) -> String -> (a -> Effect Unit) -> (b -> a) -> Prop (Effect Unit)
registerNewListener handler id push f = Handler (DOM.EventType "onChange") (Just <<< (handler id (push <<< f)))

registerNewEvent :: forall a b . String -> (a -> Effect Unit) -> (b -> a) -> Prop (Effect Unit)
registerNewEvent eventType push f = Handler (DOM.EventType eventType) (Just <<< (makeEvent (push <<< f)))


-- foreign import timerHandlerImpl :: forall a. Int -> (a ->  Effect Unit) -> Effect Unit

-- foreign import cancelTimerHandler :: Unit -> Unit

-- timerHandler :: forall a. Int -> (a ->  Effect Unit) -> (DOM.Event → Effect Unit)
-- timerHandler time push = \ev -> do
--     _ <- timerHandlerImpl time push
--     pure unit

-- attachTimer :: forall a. Int -> (a ->  Effect Unit) -> (Int -> a) -> Prop (Effect Unit)
-- attachTimer time push f = Handler (DOM.EventType "executeTimer") (Just <<< timerHandler time (push <<< f))

toAccount :: {accountList :: Array UPIMap.AccountList, regReqId :: String, name :: String, register :: Boolean, status :: Boolean} -> Array Account
toAccount account = accMap <$> account.accountList
  where 
    accMap :: AccountList -> Account
    accMap (AccountList acc) = Account {
        bankCode : acc.bankCode
      , bankName : acc.bankName
      , maskedAccountNumber : acc.accNo
      , mpinSet :acc.mpinStatus  == "Y"
      , referenceId : show acc.accId
      , regRefId : account.regReqId
      , accountHolderName : account.name
      , register : account.register
      , ifsc : acc.ifscCode
      } 


toBank :: UPIMap.BankList -> Bank
toBank (UPIMap.BankList bank) = Bank {code: bank.iin, name : bank.name, ifsc : bank.ifsc}

generateVpa :: String -> String 
generateVpa mobile = (S.drop 2 mobile) <> "d5d37924312@yesbank"


getFlag :: String
getFlag = if os == "ANDROID" then "1" else "001"

type UPIFLOWSTATE =  {upiTab :: UPIState, sims :: Array SIM, token :: String, token' :: String, vpa :: String, banks :: Array Bank, mobile :: String, recpMob :: String, smsKey :: String, smsContent :: String}

upiOnboardingFlow :: SDKParams -> Array SIM -> Flow UPIFLOWSTATE
upiOnboardingFlow sdk sims = do
  canShowUPI <- pure $ eligibleForUPI
  if os == "IOS" || canShowUPI
    then do
      token' <- (liftFlow (UPI.getToken merchantId encKey getFlag))
      token  <- if os == "ANDROID"
        then
          (liftFlow (UPI.getToken merchantId encKey ""))
        else
          pure token'
      status <- UPIMap.checkDeviceId {token : token', tnxID : (sdk ^. _orderId), session_token : (sdk ^. _session_token), customerId : (sdk ^. _customerId), add1 : "", client_auth_token : (sdk ^. _orderToken)}
      initialVal <-  doAff (makeAff (\cb -> (UPI.init (cb <<< Right) merchantId status.encryptedResp encKey)*> pure nonCanceler))
      bnk <- UPIMap.getUPIBankList {token, tnxID : (sdk ^. _orderId), session_token : (sdk ^. _session_token), customerId : (sdk ^. _customerId), client_auth_token : (sdk ^. _orderToken)}
      {-- (FetchSIMDetailsUPIResponse sims) <- fetchSIMDetails --}
      let vpa = if (status.mobileNo /= "NA") then generateVpa status.mobileNo else "NA"
      let ad = if status.add1 /= "I" then "D" else status.add1
      let mobile = status.mobileNo
      let banks = toBank <$> bnk.bankList
      let default = {upiTab : Fresh sims, sims : sims, token, token', vpa, banks, mobile : status.mobileNo, recpMob : status.recpmob, smsKey : status.encKey, smsContent : status.smsContent }
      case status.deviceStatus,status.simStatus of
          "DR","SNM" -> do
                  acc <- UPIMap.getAccountList {token, tnxID : (sdk ^. _orderId), session_token : (sdk ^. _session_token), customerId : (sdk ^. _customerId), reqFlag : "T", vpa , bankCode : "", client_auth_token : (sdk ^. _orderToken)}
                  let accounts = toAccount acc
                  _ <- saveS "juspay_cred_upi_accounts" $ unsafeJsonStringify accounts
                  if length accounts /= 0
                    then
                        pure $ default {upiTab = Linked accounts}
                    else
                        pure $ default {upiTab = Bound banks}

          "DR",_ -> do
                --   update <- UPIMap.updateUser { token, tnxID : (sdk ^. _orderId), upType : "M", simChangeRefd : (sdk ^. _orderId) ,secretQuestion :"104" ,customerId : (sdk ^. _customerId), client_auth_token : (sdk ^. _orderToken), mob : status.mobileNo}
                  pure $ default {upiTab = Fresh sims}

          "DN","SNM" ->
                  case status.add1 of
                      "I" -> pure $ default {upiTab = Fresh sims}
                      _ -> do
                          update <- UPIMap.updateUser { token, tnxID : (sdk ^. _orderId), upType : ad, simChangeRefd : status.yblRef ,secretQuestion :"104" ,customerId : (sdk ^. _customerId), client_auth_token : (sdk ^. _orderToken), mob : status.mobileNo}
                          pure $ default {upiTab = Fresh sims}

          "DN","SNN" ->
                  case status.smsStatus,os of
                      "SS","ANDROID" ->
                            pure $ default {upiTab =Bound banks}
                      _,_ ->
                            pure $ default {upiTab =Fresh sims}


          _,_ -> pure $ default {upiTab =  Disabled}
    else
      pure {upiTab : Disabled, sims : [], token : "", token': "", vpa: "", banks :[], mobile : "", recpMob : "", smsKey : "", smsContent : "" }
  -- -- pure $ default {upiTab = Fresh sims}
  -- if status.deviceStatus == "DR"
  --   then
  --     if status.simStatus == "SNM"
  --       then do
  --         acc <- UPIMap.getAccountList {token, tnxID : (sdk ^. _orderId), session_token : (sdk ^. _session_token), customerId : (sdk ^. _customerId), reqFlag : "T", vpa , bankCode : "", client_auth_token : (sdk ^. _orderToken)}
  --         let accounts = toAccount acc
  --         if length accounts /= 0
  --           then 
  --             pure $ default {upiTab = Linked accounts} --, sims : sims, token, vpa , banks, mobile : status.mobileNo, recpMob : status.recpmob, smsKey : status.encKey, smsContent : status.smsContent}
  --           else
  --             pure $ default {upiTab = Bound banks} --, sims : sims, token, vpa , banks, mobile : status.mobileNo, recpMob : status.recpmob, smsKey : status.encKey, smsContent : status.smsContent}
  --       else do 
  --         update <- UPIMap.updateUser { token, tnxID : (sdk ^. _orderId), upType : "M", simChangeRefd : {--status.yblRef--}(sdk ^. _orderId) ,secretQuestion :"104" ,customerId : (sdk ^. _customerId), client_auth_token : (sdk ^. _orderToken), mob : status.mobileNo}
  --         pure $ default {upiTab = Fresh sims} -- , sims : sims, token, vpa , banks, mobile : status.mobileNo, recpMob : status.recpmob, smsKey : status.encKey, smsContent : status.smsContent}
  --   else 
  --     if status.deviceStatus == "DN"
  --       then
  --         if status.simStatus == "SNN"
  --           then
  --             if status.smsStatus == "SS" && os == "ANDROID" 
  --               then do
  --                 pure $ default {upiTab =Bound banks} --, sims : sims, token, vpa , banks, mobile : status.mobileNo, recpMob : status.recpmob, smsKey : status.encKey, smsContent : status.smsContent}
  --               else do
  --                 pure $ default {upiTab =Fresh sims}--, sims : sims, token, vpa, banks, mobile : status.mobileNo, recpMob : status.recpmob, smsKey : status.encKey, smsContent : status.smsContent }
  --             -- Will be removed 
  --           else
  --             if status.simStatus == "SNM"
  --               then do
  --                 update <- UPIMap.updateUser { token, tnxID : (sdk ^. _orderId), upType : ad, simChangeRefd : status.yblRef ,secretQuestion :"104" ,customerId : (sdk ^. _customerId), client_auth_token : (sdk ^. _orderToken), mob : status.mobileNo}
  --                 pure $ default {upiTab = Fresh sims}--, sims : sims, token, vpa, banks, mobile : status.mobileNo, recpMob : status.recpmob, smsKey : status.encKey, smsContent : status.smsContent }
  --               else 
  --                  pure $ default {upiTab = Disabled}--, sims : sims, token, vpa, banks, mobile : status.mobileNo, recpMob : status.recpmob, smsKey : status.encKey, smsContent : status.smsContent }
  --       else
  --           pure $ default {upiTab =  Disabled}-- sims : sims, token, vpa, banks, mobile : status.mobileNo, recpMob : status.recpmob, smsKey : status.encKey, smsContent : status.smsContent }

flowToEff :: forall a. ( a -> Effect Unit) -> Flow UPIFLOWSTATE  -> Effect Unit
flowToEff push flow = do
   let runtime = Runtime uiRunner permissionRunner apiRunner
   let freeFlow = S.evalStateT (run runtime (exeFunction push flow))
   launchAff_ (AVar.new empty >>= freeFlow)
   where
     uiRunner :: UIRunner
     uiRunner a = makeAff (\cb -> do
       _ <- runFn2 showUI' (cb <<< Right) ""
       pure $ nonCanceler)

     permissionCheckRunner :: PermissionCheckRunner
     permissionCheckRunner = P.checkIfPermissionsGranted

     permissionTakeRunner :: PermissionTakeRunner
     permissionTakeRunner = P.requestPermissions

     permissionRunner :: PermissionRunner
     permissionRunner = PermissionRunner permissionCheckRunner permissionTakeRunner

     apiRunner :: APIRunner
     apiRunner request = makeAff (\cb -> do
       _ <- callAPI' (cb <<< Left) (cb <<< Right) (mkNativeRequest request)
       pure $ nonCanceler)

     exeFunction :: (a -> Effect Unit) -> Flow UPIFLOWSTATE  -> Flow Unit
     exeFunction push' = (=<<) (\val -> doAff do (liftEffect) (push' $ U.unsafeCoerce val))

