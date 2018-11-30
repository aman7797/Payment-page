module Product.Core where

import Prelude

import Config.Core (staticConfigUrl) as Config
import Constants (networkStatus) as Constants
import Control.Monad.Except (runExceptT)
import Control.Transformers.Back.Trans (runBackT)
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
  {-- _ <- loadConfig *> startTrackerEngine --}
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
  { orderToken : _getString "sessionToken"
  , amount     : fromMaybe (negate 0.00) $ NumUtil.fromString $ _getString "amount"
  , orderId    : _getString "order_id"
  , merchantId: _getString "merchant_id"
  {-- , offerCode  : _getString "offerCode" --}
  , customerMobile:  _getString "customer_phone_number"
  , customerId : _getString "customer_id"
  , clientId  : _getString "client_id"
  {-- , itemCount  : fromMaybe (negate 1) $ IntUtil.fromString $ _getString "udf_itemCount" --}
  {-- , cashEnabled: (_getString "udf_cashDisabled") /= "true" --}
  , activityRecreated : (_getString "activity_recreated") == "true"
  {-- , environment:    if _getString "environment" == "" then "sandbox" else _getString "environment" --}
  , preferedBanks : _getArrayBanks "preferedBanks"
  {-- , billerCardEditable : _getString "billerCardEditable" --}
  {-- , fullfilment: _getArrayFullfilment "fullfilment" --}
  }
  where
    _getString = getString payload
    _getArrayFullfilment = getArray payload
    _getArrayBanks = getArray payload
