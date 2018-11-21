module Externals.Amazon.Flow where

import Prelude
import Effect (Effect)
import Effect.Aff (makeAff,nonCanceler)
import Data.Either (Either(Right))
import Data.Maybe (fromMaybe)
import Data.Number (fromString)
import Data.Function.Uncurried (Fn2, Fn3, runFn2)

import Engineering.Types.App (FlowBT, PaymentPageError)
import Engineering.Helpers.Commons (AffSuccess)
import Engineering.Helpers.Utils (liftAffToFlowBT)
import Externals.Amazon.Types (AmazonLinkStatus,AmazonChargeStatusResponse)
import Remote.Amazon.Types (ValidateAmazonChargeStatusResp)
import Remote.Backend (amazonValidateChargeStatus) as Remote
import Externals.Amazon.Utils (mkValidateChargeStatusPayload)

foreign import checkAmazonSdk' :: AffSuccess String ->  Effect Unit
foreign import getAmazonBalance' :: Fn3 String Boolean (AffSuccess String)  (Effect Unit)
foreign import linkAmazonPay' :: Fn2 String (AffSuccess String ) (Effect Unit)
{-- foreign import amazonChargeStatus' --}
{--     :: forall e sc --}
{--      . Fn8 --}
{--         Int --}
{--         Int --}
{--         Boolean --}
{--         String --}
{--         (AmazonChargeStatusResponse -> Maybe AmazonChargeStatusResponse) --}
{--         (Maybe AmazonChargeStatusResponse) --}
{--         (AffSuccess (Maybe AmazonChargeStatusResponse) sc) --}
{--         (forall val . val -> Effect Unit) (Effect Unit) --}

{-- getAmazonBalance :: FlowBT PaymentPageError String --}
{-- getAmazonBalance = do --}
{--   _isSandbox <- isSandbox --}
{--   liftAffToFlowBT (makeAff(\cb -> (runFn3 getAmazonBalance' amazonSellerId _isSandbox (Right >>> cb)) *> pure nonCanceler) ) --}

{-- amazonChargeStatus :: AmazonChargeStatusResp -> FlowBT PaymentPageError (Maybe AmazonChargeStatusResponse) --}
{-- amazonChargeStatus (AmazonChargeStatusResp encRes) = do --}
{--   _isSandbox <- isSandbox --}
{--   liftAffToFlowBT (makeAff(\cb -> (runFn8 amazonChargeStatus' 600000 2000 _isSandbox encRes.payload Just Nothing (Right >>> cb) (trackHyperPayEvent' "amazonpay_charge_status")) *> pure nonCanceler)) --}

checkAmazonSdk :: FlowBT PaymentPageError String
checkAmazonSdk =  liftAffToFlowBT (makeAff(\cb -> (checkAmazonSdk' (Right >>> cb)) *> pure nonCanceler))

{-- checkAmazonLink :: FlowBT PaymentPageError AmazonLinkStatus --}
{-- checkAmazonLink = getAmazonLinkStatus <$> getAmazonBalance --}

linkAmazonPay :: FlowBT PaymentPageError String
linkAmazonPay = liftAffToFlowBT (makeAff(\cb -> (runFn2 linkAmazonPay' "#000000" (Right >>> cb)) *> pure nonCanceler))

getAmazonLinkStatus :: String -> AmazonLinkStatus
getAmazonLinkStatus balance
  | balance == "ERROR" = {linked: false , balance : (negate 1.0)}
  | otherwise = {linked : true , balance : fromMaybe (negate 1.0 ) (fromString balance)}

{-- amazonChargeStatusFlow :: String -> String -> String -> FlowBT PaymentPageError ValidateAmazonChargeStatusResp --}
{-- amazonChargeStatusFlow txn_id txn_uuid return_url = --}
{--   Remote.amazonChargeStatus (chargeStatusReqPayload txn_id txn_uuid) --}
{--     >>= amazonChargeStatus --}
{--     >>= maybe (liftLeft ChargeStatusFailure) (mkAmazonValidateChargeStatus return_url) --}

mkAmazonValidateChargeStatus :: String -> AmazonChargeStatusResponse -> FlowBT PaymentPageError ValidateAmazonChargeStatusResp
mkAmazonValidateChargeStatus return_url = Remote.amazonValidateChargeStatus <<< mkValidateChargeStatusPayload return_url