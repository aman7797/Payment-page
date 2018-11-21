module Engineering.Helpers.Utils where

import Prelude

import Effect.Aff (Aff)
import Effect (Effect)
import Effect.Class (liftEffect)
import Control.Monad.Except (runExcept)
import Control.Monad.Except.Trans (lift, runExceptT)
import Data.Either (either)
import Foreign (Foreign, typeOf, unsafeToForeign, unsafeFromForeign, readNullOrUndefined)
import Foreign.JSON (parseJSON)
{-- import Foreign.NullOrUndefined (NullOrUndefined(..)) --}
import Data.Int (fromString) as IntUtil
import Data.Maybe (Maybe(Just, Nothing), fromMaybe)
import Data.Newtype (class Newtype, unwrap, wrap)
import Data.Nullable (toNullable)
import Data.Number (fromString) as NumUtil
import Engineering.Helpers.Commons (AffSuccess, liftFlow)
import Engineering.Types.App (ENV(SANDBOX), FlowBT, PaymentPageError, toENV)
import Externals.UPI.Types (UPIIntentPayload) as ExternalTypes
import Global.Unsafe (unsafeStringify)
import Presto.Core.Types.Language.Flow (Flow, doAff, get, set)
import Product.Types (PaymentOption, PaymentPageExitAction(..), PaymentProcessingApp(..),CallBack)
import Unsafe.Coerce (unsafeCoerce)

foreign import window :: forall window . {|window}
foreign import setDelay :: forall a. a -> Number -> Effect a
foreign import getValueFromObject' :: forall json . {|json} -> String -> Foreign
foreign import getArrayFromObject' :: forall json . {|json} -> String -> Foreign
foreign import convertJSONToParams :: forall json . {|json} -> String
foreign import eval' ::  String -> Effect Unit
foreign import readFile' :: String -> Effect String
foreign import getSessionInfo :: forall json. Effect {|json}
foreign import getCurrentMonth :: String -> Int
foreign import getCurrentYear :: String -> Int
foreign import setScreen' :: String -> Effect Unit
foreign import getValueFromPayload' :: String -> String
foreign import exitApp' :: Int -> String  -> Unit
foreign import isOnline' :: Effect Boolean
foreign import sendBillerChanges :: CallBack -> AffSuccess String -> Effect String
foreign import getSimOperators' :: Unit -> Effect String
foreign import getCurrentTime :: Effect Number
foreign import getLoaderConfig :: forall a. {|a}
foreign import eligibleForUPI :: Boolean


isOnline :: forall err. FlowBT err Boolean
isOnline = lift <<< lift $ liftFlow isOnline'

liftFlowBT :: forall resp error. Flow resp -> FlowBT error resp
liftFlowBT = lift <<< lift

liftAffToFlowBT :: forall resp. Aff resp -> FlowBT PaymentPageError resp
liftAffToFlowBT affVal = liftFlowBT (doAff do affVal)

null :: forall resp . Maybe resp
null = Nothing

mapNewtype :: forall b a. Newtype a b => (b -> b) -> a -> a
mapNewtype fn = unwrap >>> fn >>> wrap

getValueFromObject :: forall json resp . {|json} -> String -> resp -> resp
getValueFromObject json key defaultValue =
    either
      (const defaultValue)
      (fromMaybe defaultValue <<< (<$>) unsafeFromForeign)
      (runExcept (readNullOrUndefined (getValueFromObject' json key)))

getArrayFromObject :: forall json resp . {|json} -> String -> resp -> resp
getArrayFromObject json key defaultValue =
    either
      (const defaultValue)
      (fromMaybe defaultValue <<< (<$>) unsafeFromForeign)
      (runExcept (readNullOrUndefined (getArrayFromObject' json key)))


getPayloadFromWindow :: Foreign
getPayloadFromWindow = unsafeToForeign (getValueFromObject window "__payload" {})

appEnvironment :: forall json . {|json} -> ENV
appEnvironment payload = toENV (getValueFromObject payload "environment" "")

isSandbox :: FlowBT PaymentPageError Boolean
isSandbox = (eq SANDBOX <<< appEnvironment) <$> getPayload

convertStringToParams :: String -> String
convertStringToParams param = either (const param) (convertJSONToParams <<< unsafeFromForeign) (runExcept (parseJSON param))

getJSONObject :: forall json. String -> {|json}
getJSONObject = either (const (unsafeCoerce {})) (checkAndReturnJSON <<< unsafeToForeign) <<< runExcept <<< parseJSON

checkAndReturnJSON :: forall json . Foreign -> {|json}
checkAndReturnJSON foreignVal
  | (typeOf foreignVal) == "object" = unsafeFromForeign foreignVal
  | otherwise = unsafeCoerce {}

checkAndReturnArray :: forall value . Foreign -> Array value
checkAndReturnArray foreignVal
  | (typeOf foreignVal)  == "object" = unsafeFromForeign foreignVal
  | otherwise = []

getPayload :: forall json . FlowBT PaymentPageError {|json}
getPayload = liftFlowBT (_getPayload)

_getPayload :: forall json . Flow {|json}
_getPayload = do
  maybePayload <- get "hyperPayload"
  case maybePayload of
    Just payload -> pure (getJSONObject payload)
    Nothing -> do
      let payload = getPayloadFromWindow
      let stringifiedObject = case typeOf payload of
                                "object" -> unsafeStringify payload
                                "string" -> unsafeFromForeign payload
                                otherwise -> "{}"
      set "hyperPayload" stringifiedObject
      pure (getJSONObject stringifiedObject)

getString :: forall json . {|json} -> String -> String
getString payload key = getValueFromObject payload key ""

getArray :: forall json value . {|json} -> String -> Array value
getArray payload key = getArrayFromObject payload key []

eval :: String -> Flow Unit
eval str = doAff do liftEffect (eval' str)

readFile :: String -> Flow String
readFile filePath = either (const "") identity <$> (runExceptT $ lift $ doAff do liftEffect $ readFile' filePath)

setScreen :: String -> Effect Unit
setScreen fragmentName = do
  setScreen' fragmentName
  -- flip trackPage' fragmentName =<< getCurrentTime'

exitAppBT :: forall b. { code :: Int, status :: String } -> FlowBT b Unit
exitAppBT { code, status } = pure $ exitApp' code status

exitApp :: Int -> String -> Flow Unit
exitApp code status = pure $ exitApp' code status


-- -- TODO: Change this!!

checkoutDetails :: { order_token :: String
                    , amount :: Number
                    , order_id :: String
                    , merchant_id :: String
                    , offerCode :: String
                    , customerMobile :: String
                    , customerId :: String
                    , client_id :: String
                    , itemCount :: Int
                    , cashEnabled :: String
                    , activity_recreated :: String
                    , environment :: String
                    }
checkoutDetails =
    { order_token:    getValueFromPayload' "sessionToken"
    , amount:          fromMaybe (negate 0.00) $ NumUtil.fromString $ getValueFromPayload' "amount"
    , order_id:        getValueFromPayload' "order_id"
    , merchant_id:     getValueFromPayload' "merchant_id"
    , offerCode:       getValueFromPayload' "offerCode"
    , customerMobile:  getValueFromPayload' "customer_phone_number"
    , customerId:      getValueFromPayload' "customerId"
    , client_id:       getValueFromPayload' "client_id"
    , itemCount:       fromMaybe (negate 1) $ IntUtil.fromString $ getValueFromPayload' "udf_itemCount"
    , cashEnabled:     if getValueFromPayload' "udf_cashDisabled" == "true" then "false" else "true"
    , activity_recreated : if ((getValueFromPayload' "activity_recreated") == "true") then "true" else "false"
    , environment:    if getValueFromPayload' "environment" == "" then "prod" else getValueFromPayload' "environment"
    }


upiMethodPayload :: String -> ExternalTypes.UPIIntentPayload
upiMethodPayload order_id =
  {   merchant_id : checkoutDetails.merchant_id
  ,   client_id : checkoutDetails.client_id
  ,   display_note : "Please finish the payment to make this order"
  ,   order_id -- : checkoutDetails.order_id
  ,   currency : "INR"
  ,   environment : if checkoutDetails.environment == "sandbox" then "https://sandbox.juspay.in" else "https://api.juspay.in" -- please please check enviroment and add url
  ,   "WHITE_LIST" : ""
  ,   "UPI_PAYMENT_METHOD" : "INTENT"
  ,   get_available_apps : toNullable Nothing
  ,   pay_with_app : toNullable Nothing
  }


exitWithSuccess :: String -> PaymentPageExitAction
exitWithSuccess order_id = ExitApp { code : (-1), status : "{\"status\":\"success\",\"order_id\":\"" <> order_id <> "\",\"message\":\"Payment is successful\"}" }

getPaymentProcessingApp :: PaymentOption -> PaymentProcessingApp
getPaymentProcessingApp pm = Godel


partialApply :: forall m a b. Monad m => m a -> m b -> m b 
partialApply f1 f2 = f1 >>= (\_ -> f2)

infixl 1 partialApply as >>
