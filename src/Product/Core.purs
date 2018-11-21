module Product.Core where

import Prelude

import Config.Core (staticConfigUrl) as Config
import Constants (networkStatus) as Constants
import Control.Monad.Except (runExceptT)
import Control.Transformers.Back.Trans (runBackT)
import Data.Array (index)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Number as NumUtil
import Engineering.Helpers.Commons (log, liftFlow)
import Engineering.Helpers.Utils (_getPayload, getString, getArray, eval, readFile, getSessionInfo)
import JBridge (attach)
import Presto.Core.Flow (Flow, initUI)
import Product.Payment.PaymentPage (startPaymentFlow)
import Product.Types (SDKParams(..))
import Tracker.Tracker (initTracking, trackSession, trackPaymentDetails)

appFlow :: Boolean -> Flow Unit
appFlow recreated = do
  _ <- attach Constants.networkStatus "{}" ""
  sdkParams <- readSDKParams <$> _getPayload
  _ <- loadConfig *> startTrackerEngine
  initUI *> startPaymentFlow sdkParams Nothing

startTrackerEngine :: Flow Unit
startTrackerEngine = do
  liftFlow (initTracking 10000)
  sessionInfo <- liftFlow getSessionInfo
  _ <- runExceptT <<< runBackT $ trackSession sessionInfo
  _ <- runExceptT <<< runBackT $ trackPaymentDetails
  pure unit

loadConfig :: Flow Unit
loadConfig = eval =<< (readFile Config.staticConfigUrl)

readSDKParams :: forall json . {|json} -> SDKParams
readSDKParams payload = log "SDKParams" $ SDKParams
  { orderToken : payments.juspay.client_auth_token
  , amount     : fromMaybe (negate 0.00) $ NumUtil.fromString $ _getString "amount" 
  , orderId    : payments.payment_id 
  , merchantId: _getString "merchant_id"
  , customerMobile:  _getString "customer_phone_number" --X
  , customerId : _getString "customer_id"
  , clientId  : _getString "client_id"
  , activityRecreated : (_getString "activity_recreated") == "true" --X
  , environment:    if _getString "environment" == "" then "sandbox" else _getString "environment"
  , fullfilment: _getArrayFullfilment "fulfillments"
  , preferedBanks : payments.preferred_banks
  , billerCardEditable : _getString "cart_editable"
  , session_token : _getString "session_token"
  }
  where
    _getString = getString payload
    _getArrayFullfilment = getArray payload
    _getArrayBanks = getArray payload
    _getArrayPayment = getArray payload
    payments = fromMaybe defPayments $ index (_getArrayPayment "payments") 0

type Payments = {
    return_url :: String,
    payment_id :: String,
    juspay :: {
        client_auth_token_expiry :: String,
        client_auth_token :: String
    },
    amount:: Int,
    preferred_banks :: Array String
  }

defPayments :: Payments
defPayments = {
           return_url: "localhost",
           payment_id: "DREAM11",
           juspay: {
               client_auth_token_expiry: "2018-08-20T15:06:44Z",
               client_auth_token: "tkn_5b993cdf974c442eb11d364dd8cf0a00"
           },
           amount: 100,
           preferred_banks : ["508548","508547"]
       }

