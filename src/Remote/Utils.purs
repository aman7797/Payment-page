module Remote.Utils where

import Prelude

import Constants (userAbortedErrorResponse) as Constants
import Effect.Class (liftEffect)
import Control.Monad.Except (ExceptT(..), throwError)
import Control.Monad.Except.Trans (class MonadThrow, lift)
import Control.Transformers.Back.Trans (BackT(..), FailBack(..))
import Data.Either (Either(..))
import Foreign.Class (class Decode, class Encode)
{-- import Foreign.NullOrUndefined (NullOrUndefined(..), unNullOrUndefined) --}
import Data.Lens ((^.))
import Data.Maybe (Maybe(..))
import Engineering.Helpers.Types.Accessor (_code)
import Engineering.Types.App (FlowBT, PaymentPageError, liftFlowBT)
import Engineering.Types.App (PaymentPageError(..)) as Err
import Presto.Core.Types.API (class RestEndpoint, ErrorPayload, Headers, Response(..))
import Presto.Core.Types.Language.Flow (callAPI)
import Product.Types (Bank, CardDetails(..), SavedCardDetails(..))
import Engineering.Helpers.Commons (startAnim)
import Engineering.Helpers.Utils (checkoutDetails, isOnline, setScreen, getLoaderConfig, null, mapNewtype)
import Presto.Core.Flow (Flow, doAff, oneOf, showScreen)
import Remote.Types (InitiateTxnReq(InitiateTxnReq), OrderStatusReq(OrderStatusReq), StoredWallet(StoredWallet))
import UI.Controller.Screen.PaymentsFlow.ErrorMessage as ErrorMessageC
import UI.Controller.Screen.PaymentsFlow.GenericError (ScreenInput(..))
import UI.Utils (logit, os)
import UI.View.Screen.PaymentsFlow.ErrorMessage as ErrorMessage
import UI.View.Screen.PaymentsFlow.ErrorMessage as GenericError
import UI.View.Screen.PaymentsFlow.Loader as Loader

type ApiConfig = {
  noOfRetries :: Int
  , shouldExitScreenWhileBackPress :: Boolean
  , shouldShowLoader :: Boolean
}

mkApiConfig :: Int -> Boolean -> Boolean -> ApiConfig
mkApiConfig noOfRetries shouldExitScreenWhileBackPress shouldShowLoader = {
  noOfRetries : noOfRetries
  , shouldExitScreenWhileBackPress : shouldExitScreenWhileBackPress
  , shouldShowLoader : if os == "IOS" then true else shouldShowLoader
  }

defaultConfig ::  Int -> ApiConfig
defaultConfig noOfRetries = {
  noOfRetries : noOfRetries
  , shouldExitScreenWhileBackPress : false
  , shouldShowLoader : true
}

callAPIWithBackHandling :: forall t199 t202. Encode t202 => Decode t199 => RestEndpoint t202 t199 => Headers -> t202 -> ApiConfig -> FlowBT PaymentPageError (Either (Response ErrorPayload) t199)
callAPIWithBackHandling headers req apiConfig = do
  BackT <<< ExceptT $ (Right <$> (oneOf $ [(NoBack <$> callAPI headers req) ] <> if apiConfig.shouldShowLoader then [] else [] ))
  where showLoadingScreen = do
          _ <- doAff do liftEffect $ setScreen "LoadingScreen"
          _ <- (showScreen (Loader.screen getLoaderConfig))
          pure $ NoBack $ Left Constants.userAbortedErrorResponse

eitherMatch :: forall a err. MonadThrow PaymentPageError err => Either PaymentPageError a -> BackT err a
eitherMatch (Left err) = BackT $ throwError err
eitherMatch (Right response) = pure response

mkRestClientCall :: forall a b. Encode a => Decode b => RestEndpoint a b => Headers -> a -> ApiConfig -> FlowBT PaymentPageError (Either PaymentPageError b)
mkRestClientCall headers req apiConfig = do
 isUserOnline <- isOnline
 if isUserOnline 
  then do 
    result <-  callAPIWithBackHandling headers req apiConfig
    case result of
      Left err@(Response { code }) -> do
        let _ = logit $ "code of response ->" <> show code
        case code of
          -1  -> handleGenericError headers req apiConfig NetworkError
          400 -> (pure <<< Left) (Err.ExitApp "Unable to process")
          401 -> (pure <<< Left) (Err.SessionExpired)
          500 -> if (apiConfig.noOfRetries > 0) then mkRestClientCall headers req (apiConfig {noOfRetries = (apiConfig.noOfRetries - 1)}) else handleGenericError headers req apiConfig Other
          _   -> if apiConfig.shouldExitScreenWhileBackPress then (pure <<< Left) (Err.ExitApp "Unable to process") else handleGenericError headers req apiConfig Other
      Right r -> (pure <<< Right) r
  else handleGenericError headers req apiConfig NetworkError

handleGenericError :: forall a b. Encode a => Decode b => RestEndpoint a b => Headers -> a -> ApiConfig -> ScreenInput -> FlowBT PaymentPageError (Either PaymentPageError b)
handleGenericError headers req apiConfig errorType= do
  _ <- liftFlowBT $ doAff do liftEffect $ setScreen "GenericError"
  action <- (liftFlowBT $ showScreen (GenericError.screen $ ErrorMessageC.ErrorMessage "Unable to process" ))
  case action of
    ErrorMessageC.Retry -> mkRestClientCall headers req (defaultConfig apiConfig.noOfRetries)
    ErrorMessageC.UserAbort ->  if apiConfig.shouldExitScreenWhileBackPress then (pure <<< Left) (Err.ExitApp "ApiFailed") else (pure <<< Left) (Err.ApiFailure Constants.userAbortedErrorResponse)
    (ErrorMessageC.Button1Action _) -> mkRestClientCall headers req (defaultConfig apiConfig.noOfRetries)
    ErrorMessageC.ExitAnimation _ -> if apiConfig.shouldExitScreenWhileBackPress then (pure <<< Left) (Err.ExitApp "ApiFailed") else (pure <<< Left) (Err.ApiFailure Constants.userAbortedErrorResponse)

mkFakeRestClientCall :: forall a b. Encode a => Decode b => RestEndpoint a b => Headers -> a -> Int -> FlowBT PaymentPageError (Either PaymentPageError b)
mkFakeRestClientCall headers req retries =  (pure <<< Left) (Err.ApiFailure Constants.userAbortedErrorResponse)

mkRestClientCallWithoutBackPress :: forall a b. Encode a => Decode b => RestEndpoint a b => Headers -> a -> FlowBT PaymentPageError (Either PaymentPageError b)
mkRestClientCallWithoutBackPress headers req = do
 result <- lift $ lift $ callAPI headers req
 case result of
  Left err ->  (pure <<< Left) (Err.ApiFailure err)
  Right r ->  (pure <<< Right) r


-- makeRedirectionPayload bankCode = NbTxnReq
--     { order_id : checkoutDetails.order_id
--     , merchant_id : checkoutDetails.merchant_id
--     , payment_method_type : "NB"
--     , payment_method : bankCode
--     , redirect_after_payment : true
--     , format : "json"
--     }

makeOrderStatusCheckReqPayload :: String -> OrderStatusReq
makeOrderStatusCheckReqPayload order_id = OrderStatusReq
    { merchant_id: checkoutDetails.merchant_id
    , order_id--checkoutDetails.order_id
    }

defaultTxnReq :: String -> String -> String -> InitiateTxnReq
defaultTxnReq paymentMethodType orderId paymentMethod =
  InitiateTxnReq
  { order_id : orderId   --checkoutDetails.order_id
  , merchant_id : checkoutDetails.merchant_id
  , payment_method_type : paymentMethodType
  , payment_method : paymentMethod
  , redirect_after_payment : true
  , format : "json"
  , txn_type : null -- |UPI_COLLECT
  , card_token : null
  , card_security_code  : null
  , direct_wallet_token  : null
  , client_auth_token : null
  , card_number : null
  , card_exp_month : null
  , card_exp_year : null
  , name_on_card : null
  , save_to_locker : null
  , sdk_params : null
  , upi_app: null
  , upi_vpa : null
  , upi_tr_field: null
  }

mkPayReqUPI :: String -> InitiateTxnReq
mkPayReqUPI orderId = updatePayload orderId $ defaultTxnReq "UPI" orderId "UPI"
  

updatePayload :: String -> InitiateTxnReq -> InitiateTxnReq
updatePayload orderId (InitiateTxnReq init) = InitiateTxnReq (init 
      { order_id = orderId,
        merchant_id = checkoutDetails.merchant_id,
        payment_method_type = "UPI",
        payment_method = "UPI",
        redirect_after_payment = false,
        format = "json",
        txn_type = Just "UPI_PAY",
        sdk_params = Just true,
        upi_app= Just "cred_InApp",--"(getPackageName unit)",
        upi_vpa = null,
        upi_tr_field = Just "txn_uuid"
      })

mkPayReqNB :: Bank -> String ->  InitiateTxnReq
mkPayReqNB bank orderId = defaultTxnReq "NB" orderId (bank ^. _code) 

mkPayReqCard :: CardDetails -> String -> InitiateTxnReq
mkPayReqCard (CardDetails state) orderId = do
  let updateState = (\cardData ->
        cardData
        { card_number = Just state.cardNumber
        , card_exp_month = Just state.expMonth
        , card_exp_year = Just state.expYear
        , name_on_card = Just state.nameOnCard
        , card_security_code = Just state.securityCode
        , save_to_locker = Just state.saveToLocker
        , redirect_after_payment = true
        }
      )
  state.paymentMethod # defaultTxnReq "CARD" orderId >>> mapNewtype updateState 

mkPayReqSavedCard :: SavedCardDetails -> String -> InitiateTxnReq
mkPayReqSavedCard (SavedCardDetails cardData) orderId = do
    let updateState = (\state ->
            state
            { card_security_code = Just cardData.cvv
            , card_token = Just cardData.cardToken
            , save_to_locker =  Just true
            }
        )
    cardData.cardType # defaultTxnReq "CARD" orderId >>> mapNewtype updateState

-- mkInitiateTxnPayload :: PaymentMethod -> InitiateTxnReq
-- mkInitiateTxnPayload (NB (Bank bankCode)) = defaultTxnReq "NB" bankCode
-- mkInitiateTxnPayload (SavedCard (SavedCardDetails cardData)) = do
--     let updateState = (\state -> state{ card_security_code = liftNullOrUndefined cardData.cvv, card_token = liftNullOrUndefined cardData.cardToken})
--     cardData.cardType # defaultTxnReq "CARD" >>> mapNewtype updateState

-- mkInitiateTxnPayload (Card (CardDetails state)) = do
--   let updateState = (\cardData ->
--         cardData
--         { card_number = liftNullOrUndefined state.cardNumber
--         , card_exp_month = liftNullOrUndefined state.expMonth
--         , card_exp_year = liftNullOrUndefined state.expYear
--         , name_on_card = liftNullOrUndefined state.nameOnCard
--         , card_security_code = liftNullOrUndefined state.securityCode
--         , save_to_locker = liftNullOrUndefined state.saveToLocker
--         , redirect_after_payment = false
--         }
--       )
--   state.paymentMethod # defaultTxnReq "CARD" >>> mapNewtype updateState

-- mkInitiateTxnPayload (WalletRedirect (RedirectWallet wallet)) = defaultTxnReq wallet.paymentMethodType wallet.paymentMethod

-- mkInitiateTxnPayload (WalletPayment (Wallet wallet)) = do
--     let updateState = (\state -> state{ direct_wallet_token = wallet.token , client_auth_token = liftNullOrUndefined (checkoutDetails.order_token)})
--     wallet.token # unNullOrUndefined >>> fromMaybe ""  >>> defaultTxnReq "WALLET" >>> mapNewtype updateState

-- mkInitiateTxnPayload AmazonPayWallet = do
--   let updateState = (\state -> state{sdk_params = liftNullOrUndefined true})
--   mapNewtype updateState (defaultTxnReq "WALLET" "AMAZONPAY")

-- mkInitiateTxnPayload (COD) = defaultTxnReq "CASH" "CASH"

-- mkInitiateTxnPayload _  = defaultTxnReq "Default" "Default"

mockWallet :: String -> Boolean -> Number -> StoredWallet
mockWallet wallet isLinked bal = StoredWallet
  { wallet : Just wallet
  , token : Just ""
  , linked : Just isLinked
  , id :  ""
  , current_balance : Just bal
  , last_refreshed : Just ""
  , object : Just ""
  , currentBalance : Just bal
  , lastRefreshed : Just ""
  , lastUsed : Just ""
  , count : Just 0.0
  , rating : Just 0.0
  }

-- showScreen' = if os == "IOS" then runScreen else showScreen


errorMessage :: String -> Flow ErrorMessageC.Action
errorMessage a  = do
          _ <- doAff do liftEffect $ setScreen "ErrorMessage"
          _ <- doAff do liftEffect $ startAnim "errorFadeIn"
          _ <- doAff do liftEffect $ startAnim "errorSlide"
          _ <- doAff do liftEffect $ startAnim "errorMsgFade"
          (showScreen (ErrorMessage.screen (ErrorMessageC.ErrorMessage a)))