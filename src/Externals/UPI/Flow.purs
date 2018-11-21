module Externals.UPI.Flow where

import Prelude
import Effect (Effect)
import Effect.Aff(makeAff,nonCanceler)
import Foreign.Generic (decodeJSON)
import Control.Monad.Except (runExcept)
import Data.Either (Either(Right),either)
import Data.Nullable (toNullable)
import Data.Maybe (Maybe(Just))
import Data.Lens (view)

import Presto.Core.Flow (doAff)

import Engineering.Helpers.Commons (AffSuccess)
import Engineering.Types.App(FlowBT, MicroAppResponse, PaymentPageError(MicroAppError),liftFlowBT,liftLeft)
import Engineering.Helpers.Utils(upiMethodPayload)
import Tracker.Tracker (trackHyperPayEvent')
import Externals.UPI.Types (UPIAppList, UPIAppListResp, UPIIntentPayload)
import Engineering.Helpers.Types.Accessor(_response)

foreign import startUPI'    :: MicroAPPInvokeSignature

type MicroAPPInvokeSignature = UPIIntentPayload -> AffSuccess MicroAppResponse -> (forall val . val -> Effect Unit) -> Effect Unit

startUPIFlow :: String -> FlowBT PaymentPageError MicroAppResponse
startUPIFlow = invokeUPIAPP <<< upiMethodPayload

invokeUPIAPP :: UPIIntentPayload -> FlowBT PaymentPageError MicroAppResponse
invokeUPIAPP payload = liftFlowBT $ doAff do makeAff (\cb -> (startUPI' payload (Right >>> cb) (trackHyperPayEvent' "response_from_upi"))*> pure nonCanceler )

getInstalledUPIApps :: String -> FlowBT PaymentPageError UPIAppList
getInstalledUPIApps order_id = (view _response) <$> (extractAPPList <<< _.status =<< invokeUPIAPP (getInstalledUPIAppsPayload (upiMethodPayload order_id)))

extractAPPList :: String -> FlowBT PaymentPageError UPIAppListResp
extractAPPList = decodeJSON
                  >>> runExcept
                  >>> either (const (liftLeft (MicroAppError "Error while decoding Installed Upi App List Array"))) pure

openUPIApp :: String -> String -> FlowBT PaymentPageError MicroAppResponse
openUPIApp order_id = invokeUPIAPP <<< getOpenUPIAppPayload (upiMethodPayload order_id)

getInstalledUPIAppsPayload :: UPIIntentPayload -> UPIIntentPayload
getInstalledUPIAppsPayload payload =
  payload
  { "UPI_PAYMENT_METHOD" = "NA"
  , get_available_apps = toNullable (Just "true")
  }

getOpenUPIAppPayload :: UPIIntentPayload -> String -> UPIIntentPayload
getOpenUPIAppPayload payload packageName =
  payload
  { pay_with_app = toNullable (Just packageName)
  }