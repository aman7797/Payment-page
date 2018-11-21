module Tracker.Tracker where

import Prelude

import Effect (Effect)
import Effect.Timer (IntervalId)
import Data.Array (length, slice, take)
import Engineering.Helpers.Commons (liftFlow)
import Engineering.Types.App (FlowBT, PaymentPageError, liftFlowBT)

foreign import preProcessEvent :: String -> String -> String -> String -> Effect String
foreign import preProcessTrackExceptionEvent ::  String -> String -> String -> Effect String
foreign import preProcessTrackInfo ::  String -> Effect String
foreign import preProcessSessionInfo :: forall a. {|a} -> Effect String
foreign import preProcessPaymentDetails ::  Effect String
foreign import addToLogList' ::  Boolean -> String -> Effect Unit
foreign import canPostLogs ::  Effect Boolean
foreign import updateLogList ::  Array String -> Effect Unit
foreign import getLogList ::  Effect (Array String)
foreign import postLogsToAnalytics ::  Array String -> Effect Unit
foreign import preProcessTrackPage ::  String -> String -> Effect String
foreign import preProcessHyperPayEvent :: forall a. String -> a -> Effect String
foreign import submitAllLogs ::  Effect Unit
foreign import trackAPICalls' ::  String -> String -> String -> Int -> Effect Unit
foreign import setInterval :: Int -> Effect Unit -> Effect IntervalId
foreign import toString :: forall a. a -> String

addToLogList :: String -> FlowBT PaymentPageError Unit
addToLogList =  liftFlowBT <<< liftFlow <<< addToLogList' false

trackEvent' :: String -> String -> String -> String -> Boolean -> Effect Unit
trackEvent' category action label value shouldShareWithMerchant = addToLogList' shouldShareWithMerchant =<< preProcessEvent category action label value

theOthertrackEventT :: Boolean -> String -> String -> String -> String -> Effect Unit
theOthertrackEventT shouldShareWithMerchant category action label value = (trackEvent' category action label value shouldShareWithMerchant)

trackEventMerchantV2 :: String -> String -> Effect Unit
trackEventMerchantV2 = theOthertrackEventT true "UserFlow" "Event"

trackEventT ::Boolean -> String -> String -> String -> String -> FlowBT PaymentPageError Unit
trackEventT shouldShareWithMerchant category action label value = liftFlowBT $ liftFlow (trackEvent' category action label value shouldShareWithMerchant)

trackEventMerchant :: String -> String -> String -> String -> FlowBT PaymentPageError Unit
trackEventMerchant = trackEventT true

trackEvent :: String -> String -> String -> String -> FlowBT PaymentPageError Unit
trackEvent = trackEventT false

trackInfo :: String -> FlowBT PaymentPageError Unit
trackInfo infoVal = addToLogList =<< (liftFlowBT $ liftFlow (preProcessTrackInfo infoVal))

trackHyperPayEvent' :: forall a. String -> a -> Effect Unit
trackHyperPayEvent' key value = addToLogList' false =<< preProcessHyperPayEvent key value

trackHyperPayEvent :: forall a .String -> a -> FlowBT PaymentPageError Unit
trackHyperPayEvent key value = liftFlowBT $ liftFlow (trackHyperPayEvent' key value)

trackException ::  String -> String -> String -> FlowBT PaymentPageError Unit
trackException desc msg trace = addToLogList =<< (liftFlowBT $ liftFlow (preProcessTrackExceptionEvent desc msg trace))

trackPage' :: String -> String -> Effect Unit
trackPage' startTime fragmentName = addToLogList' false =<< preProcessTrackPage "" fragmentName

trackPage ::  String -> String -> FlowBT PaymentPageError Unit
trackPage startTime fragmentName = liftFlowBT $ liftFlow (trackPage' startTime fragmentName)

trackSession :: forall a . {|a} -> FlowBT PaymentPageError Unit
trackSession session = addToLogList =<< (liftFlowBT $ liftFlow (preProcessSessionInfo session))

trackPaymentDetails :: FlowBT PaymentPageError Unit
trackPaymentDetails = addToLogList =<< (liftFlowBT $ liftFlow preProcessPaymentDetails)

trackAPICalls :: String -> String -> String -> Int -> FlowBT PaymentPageError Unit
trackAPICalls url startTime endTime statusCode = liftFlowBT $ liftFlow (trackAPICalls' url startTime endTime statusCode)

initTracking :: Int -> Effect Unit
initTracking batch = do
  t <- setInterval batch do
    ifM (canPostLogs) postLogs (pure unit)
  pure unit

postLogs :: Effect Unit
postLogs = ((getLogList >>= chopChop) >>= postLogsToAnalytics)

chopChop :: Array String -> Effect (Array String)
chopChop list
  | length list > 75 = let extraLogs = slice 75 (length list) list in sliceNdice list extraLogs
  | otherwise        = sliceNdice list []

sliceNdice :: Array String -> Array String -> Effect (Array String)
sliceNdice list extra = do
  updateLogList extra
  pure $ take 75 list