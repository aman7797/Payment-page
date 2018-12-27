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
import Product.Types (Bank, CardDetails(..), SavedCardDetails(..), Wallet(..))
import Engineering.Helpers.Commons (startAnim)
import Engineering.Helpers.Utils (checkoutDetails, isOnline, setScreen, getLoaderConfig, null, mapNewtype)
import Presto.Core.Flow (Flow, doAff, oneOf, showScreen)
import Remote.Types (InitiateTxnReq(InitiateTxnReq), OrderStatusReq(OrderStatusReq), StoredWallet(StoredWallet))
import UI.Controller.Screen.PaymentsFlow.ErrorMessage as ErrorMessageC
import UI.Controller.Screen.PaymentsFlow.GenericError (ScreenInput(..))
import UI.Utils (logit, os, logAny)

import UI.Flow as UI


type ApiConfig =
    { noOfRetries :: Int
    , shouldExitScreenWhileBackPress :: Boolean
    , shouldShowLoader :: Boolean
    }

mkApiConfig :: Int -> Boolean -> Boolean -> ApiConfig
mkApiConfig noOfRetries shouldExitScreenWhileBackPress shouldShowLoader =
    { noOfRetries : noOfRetries
    , shouldExitScreenWhileBackPress : shouldExitScreenWhileBackPress
    , shouldShowLoader : if os == "IOS" then true else shouldShowLoader
    }

defaultConfig ::  Int -> ApiConfig
defaultConfig noOfRetries =
    { noOfRetries : noOfRetries
    , shouldExitScreenWhileBackPress : false
    , shouldShowLoader : true
    }

callAPIWithBackHandling
    :: forall t199 t202
     . Encode t202
    => Decode t199
    => RestEndpoint t202 t199
    => Headers
    -> t202
    -> ApiConfig
    -> FlowBT PaymentPageError (Either (Response ErrorPayload) t199)
callAPIWithBackHandling headers req apiConfig = do
  BackT <<< ExceptT $ (Right <$> (oneOf $ [(NoBack <$> callAPI headers req) ] <> if apiConfig.shouldShowLoader then [] else [] ))

eitherMatch
    :: forall a err
     . MonadThrow PaymentPageError err
    => Either PaymentPageError a
    -> BackT err a
eitherMatch (Left err) = BackT $ throwError err
eitherMatch (Right response) = pure response

mkRestClientCall
    :: forall a b
     . Encode a
    => Decode b
    => RestEndpoint a b
    => Headers
    -> a
    -> ApiConfig
    -> FlowBT PaymentPageError (Either PaymentPageError b)
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
                         500 -> if (apiConfig.noOfRetries > 0)
                                    then mkRestClientCall headers req (apiConfig {noOfRetries = (apiConfig.noOfRetries - 1)})
                                    else handleGenericError headers req apiConfig Other
                         _   -> if apiConfig.shouldExitScreenWhileBackPress
                                    then (pure <<< Left) (Err.ExitApp "Unable to process")
                                    else handleGenericError headers req apiConfig Other
                 Right r -> (pure <<< Right) r
        else handleGenericError headers req apiConfig NetworkError



handleGenericError
    :: forall a b
     . Encode a
    => Decode b
    => RestEndpoint a b
    => Headers
    -> a
    -> ApiConfig
    -> ScreenInput
    -> FlowBT PaymentPageError (Either PaymentPageError b)
handleGenericError headers req apiConfig errorType = do
    action <- UI.errorMessage "Unable to process"
    case action of
         ErrorMessageC.Retry ->
            mkRestClientCall headers req (defaultConfig apiConfig.noOfRetries)

         ErrorMessageC.UserAbort ->
            if apiConfig.shouldExitScreenWhileBackPress
                then (pure <<< Left) (Err.ExitApp "ApiFailed")
                else (pure <<< Left) (Err.ApiFailure Constants.userAbortedErrorResponse)

         ErrorMessageC.ExitAnimation _ ->
            if apiConfig.shouldExitScreenWhileBackPress
                then (pure <<< Left) (Err.ExitApp "ApiFailed")
                else (pure <<< Left) (Err.ApiFailure Constants.userAbortedErrorResponse)


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
defaultTxnReq paymentMethodType paymentMethod orderId = InitiateTxnReq
    { order_id : orderId   --checkoutDetails.order_id
    , merchant_id : checkoutDetails.merchant_id
    , payment_method_type : paymentMethodType
    , payment_method : paymentMethod
    , redirect_after_payment : true
    , format : "json"
    , txn_type : Nothing -- |UPI_COLLECT
    , card_token : Nothing
    , card_security_code  : Nothing
    , direct_wallet_token  : Nothing
    , client_auth_token : Nothing
    , card_number : Nothing
    , card_exp_month : Nothing
    , card_exp_year : Nothing
    , name_on_card : Nothing
    , save_to_locker : Nothing
    , sdk_params : Nothing
    , upi_app: Nothing
    , upi_vpa : Nothing
    , upi_tr_field: Nothing
    }

{-- mkPayReqUPI :: String -> InitiateTxnReq --}
{-- mkPayReqUPI orderId = updatePayload orderId $ defaultTxnReq "UPI" orderId "UPI" --}


{-- updatePayload :: String -> InitiateTxnReq -> InitiateTxnReq --}
{-- updatePayload orderId (InitiateTxnReq init) = InitiateTxnReq (init --}
{--       { order_id = orderId, --}
{--         merchant_id = checkoutDetails.merchant_id, --}
{--         payment_method_type = "UPI", --}
{--         payment_method = "UPI", --}
{--         redirect_after_payment = false, --}
{--         format = "json", --}
{--         txn_type = Just "UPI_PAY", --}
{--         sdk_params = Just true, --}
{--         upi_app= Just "cred_InApp",--"(getPackageName unit)", --}
{--         upi_vpa = null, --}
{--         upi_tr_field = Just "txn_uuid" --}
{--       }) --}

mkPayReqNB :: Bank -> String ->  InitiateTxnReq
mkPayReqNB bank = defaultTxnReq "NB" (bank ^. _code)


mkPayReqCard :: CardDetails -> String -> InitiateTxnReq
mkPayReqCard (CardDetails state) =
    let updateState = _ { card_number = Just state.cardNumber
                        , card_exp_month = Just state.expMonth
                        , card_exp_year = Just state.expYear
                        , name_on_card = Just state.nameOnCard
                        , card_security_code = Just state.securityCode
                        , save_to_locker = Just state.saveToLocker
                        , redirect_after_payment = true
                        }
     in mapNewtype updateState <<< defaultTxnReq "CARD" state.paymentMethod


mkPayReqUpiCollect :: String -> String -> InitiateTxnReq
mkPayReqUpiCollect vpa =
    let updateState = _ { txn_type = Just "UPI_COLLECT"
                        , upi_vpa = Just vpa
                        , redirect_after_payment = true
                        }
     in mapNewtype updateState <<< defaultTxnReq "UPI" "UPI"


mkPayReqSavedCard :: SavedCardDetails -> String -> InitiateTxnReq
mkPayReqSavedCard (SavedCardDetails cardData) =
    let updateState = _ { card_security_code = Just cardData.cvv
                        , card_token = Just cardData.cardToken
                        , save_to_locker =  Just true
                        }
     in mapNewtype updateState <<< defaultTxnReq "CARD" cardData.cardType


mkPayReqWallet :: Wallet -> String -> InitiateTxnReq
mkPayReqWallet (Wallet wallet) =
    let updateState = case wallet.token, wallet.linked of
            Just token, Just true ->
                _   { direct_wallet_token = Just token
                    , payment_method = wallet.name
                    , client_auth_token = Just checkoutDetails.order_token
                    }
            _, _ ->
                _   { payment_method = wallet.name
                    }
     in mapNewtype updateState <<< defaultTxnReq "WALLET" ""


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

