module Externals.Godel.Utils where

import Data.Array (index)
import Foreign (unsafeToForeign, unsafeFromForeign)
{-- import Foreign.NullOrUndefined (NullOrUndefined(..)) --}
import Data.Maybe (Maybe, fromMaybe)
import Engineering.Helpers.Utils (convertStringToParams, getArray, getPayload, getString)
import Engineering.Types.App (FlowBT, PaymentPageError)
import Externals.Godel.Types (InitiateGodelReq(..))
import Prelude (($), (<$>))

getEndUrl :: forall json value . {|json} -> String -> Array value
getEndUrl payload key = unsafeFromForeign $ unsafeToForeign (getArray payload key)
  -- case spy $ typeOf endUrl of
  --   "object" -> unsafeFromForeign endUrl
  --   otherwise -> checkAndReturnArray <<< toForeign <<< runExcept <<< parseJSON <<< unsafeFromForeign $ endUrl

mkGodelParams' :: String -> Maybe String -> FlowBT PaymentPageError InitiateGodelReq
mkGodelParams' url params = mkGodelParams url params <$> getPayload

mkGodelParams :: forall json . String -> Maybe String -> {|json} -> InitiateGodelReq
mkGodelParams url params payload = InitiateGodelReq {
  customBrandingLayout : _getString "customBrandingLayout"
  , customBrandingEnabled : _getString "customBrandingEnabled"
  , customer_email : _getString "customer_email"
  , client_id : _getString "client_id"
  , customer_phone_number : _getString "customer_phone_number"
  , endUrls : payments.return_url
  , customerId : _getString "customer_id"
  , logsPostingEnabled : _getString "logsPostingEnabled"
  , amount : _getString "amount"
  , logsPostingUrl : _getString "logsPostingUrl"
  , verifyAssets : _getString "verifyAssets"
  , sessionToken : payments.juspay.client_auth_token
  , offerApplied : _getString "offerApplied"
  , customBrandingVersion : _getString "customBrandingVersion"
  , environment : _getString "environment"
  , merchant_id : _getString "merchant_id"
  , udf_cashDisabled : _getString "udf_cashDisabled"
  , clearCookies : _getString "clearCookies"
  , order_id : payments.payment_id
  , offerCode : _getString "offerCode"
  , sdkName : _getString "sdkName"
  , service : _getString "service"
  , udf_itemCount : _getString "udf_itemCount"
  , url : url
  , postData : (convertStringToParams <$> params)
  }
  where
    _getString = getString payload
    _getArrayPayment = getArray payload
    payments = fromMaybe defPayments $ index (_getArrayPayment "payments") 0

    -- defPayments :: Payments
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