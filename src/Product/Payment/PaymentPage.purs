module Product.Payment.PaymentPage where

import Prelude

import Constants as Constants
import Effect.Class (liftEffect)
import Effect.Aff (Milliseconds(..), makeAff, nonCanceler, throwError)
import Control.Monad.Except (runExcept, runExceptT)
import Control.Transformers.Back.Trans (BackT(..), FailBack(..), runBackT)
import Data.Array (concat, filter, fold, foldl, index, length, zipWith)
import Data.Array as Arr
import Data.Either (Either(..), hush)
{-- import Foreign.NullOrUndefined (NullOrUndefined) --}
import Data.Int (toNumber)
import Data.Lens ((.~), (?~), (^.))
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Newtype (class Newtype)
import Data.Number (fromString)
import Data.String (Pattern(..), Replacement(..), contains, replaceAll, toLower, trim)
import Data.String as S
import Data.Traversable (traverse)
import Engineering.Helpers.Commons (checkPermissions, continue, getFromWindow, liftFlow, log, requestPermissions, startAnim, startAnim_, unsafeJsonStringify, unsafeJsonDecode )
import Engineering.Helpers.Types.Accessor
import Engineering.Helpers.Utils (exitApp, exitWithSuccess, getCurrentTime, getLoaderConfig, liftFlowBT, sendBillerChanges, setScreen, (>>))
import Engineering.OS.Permission (toAndroidPermission)
import Engineering.Types.App (FlowBT, MicroAppResponse, PaymentPageError)
import Engineering.Types.App as Err
import Externals.Godel.Flow (mkGodelParams, startGodel)
import Externals.WebRedirect.Flow (startRedirect)
import Externals.UPI.Flow (openUPIApp)
import JBridge (attach, requestKeyboardHide)
import JBridge as UPI
import Presto.Core.Flow (Flow, delay, doAff, oneOf, showScreen)
import Presto.Core.Types.API (ErrorPayload(..), Response(..))
import Presto.Core.Types.Language.Flow (loadS, saveS)
import Presto.Core.Types.Permission (Permission(..))
import Presto.Core.Utils.Encoding (defaultDecodeJSON, defaultEncodeJSON)
import Product.Payment.Utils (mkPaymentPageState, fetchSIMDetails)
import Product.Types
import Remote.Accessors (_status, _payment)
import Remote.Backend (mkPayment, checkOrderStatus, getPaymentMethods) as Remote
import Remote.Config (encKey, merchantId)
import Remote.Types -- (InitiateTxnResp(..), PaymentSourceReq(PaymentSourceReq))
import Remote.Utils (mkPayReqCard, mkPayReqNB, mkPayReqSavedCard, mkPayReqUpiCollect, mkPayReqWallet)
import Tracker.Tracker (toString) as T
import Tracker.Tracker (trackEventMerchant)
import Type.Data.Boolean (kind Boolean)
import UI.Controller.Component.AddNewCard as A
import UI.Controller.Screen.PaymentsFlow.ErrorMessage as ErrorMessageC
import UI.Controller.Screen.PaymentsFlow.PaymentPage
import UI.Flow as UI
import UI.Utils (logit, logAny, os, getScreenWidth)
import UI.View.Screen.PaymentsFlow.ErrorMessage as ErrorMessage
import UI.View.Screen.PaymentsFlow.Loader as Loader
import UI.View.Screen.PaymentsFlow.Toast as Toast

startPaymentFlow
    :: SDKParams
    -> Maybe PaymentPageState
    -> Flow Unit
startPaymentFlow sdkParams optPPState = do
    {-- _ <- doAff do liftEffect $ setScreen "LoadingScreen" --}
    {-- _ <- showScreen (Loader.screen getLoaderConfig) --}
    {-- _ <- if os /= "IOS" then getRequiredPermissions else (pure true) --}
    result <- runExceptT <<< runBackT $ paymentPageFlow sdkParams optPPState
    ppState <- getFromWindow Constants.ppStateKey

    case result of
        -- ExitApp
        Right (BackPoint (ExitApp { status, code })) ->
            exitApp (-1) $ logFinal status

        Right (NoBack    (ExitApp { status, code })) ->
            exitApp (-1) $ logFinal status

        -- RetryPayment
        Right (BackPoint (RetryPayment opts)) ->
            startPaymentFlow sdkParams ppState

        Right (NoBack    (RetryPayment opts)) ->
            startPaymentFlow sdkParams ppState

        -- UPI
        Right (BackPoint Proceed) ->
            exitApp 0 $ logFinal $ unableToProcessError

        Right (NoBack    Proceed) ->
            exitApp 0 $ logFinal $ unableToProcessError

        Right GoBack ->
            exitApp 0 $ logFinal $ unableToProcessError

        -- Error Scenarios
        Left (Err.ExitApp reason) ->
            exitApp 0 $ logFinal $ paymentFailedError

        Left Err.UserAborted ->
            exitApp 0 $ logFinal $ userAbortedError

        {-- Left Err.ChargeStatusFailure -> --}
        {--     startPaymentFlow sdkParams (ppState <#> (_uiState <<< _error) ?~ (Snackbar "Some problem" )) --}

        Left (Err.ApiFailure (Response {response})) ->
            exitApp 0 $ logFinal $ unableToProcessError

        Left (Err.MicroAppError reason) ->
            exitApp 0 $ logFinal $ paymentFailedError

        Left Err.SessionExpired ->
            exitApp 0 $ logFinal $ makeErrorMessage "failure" (sdkParams ^. _orderId ) "Token Expired"

        _  -> exitApp 0 $ logFinal $ unableToProcessError

    where
          logFinal = log "The final Message"

          unableToProcessError = makeErrorMessage "failure" (sdkParams ^. _orderId ) "Unable to process"

          paymentFailedError = makeErrorMessage "failure" (sdkParams ^. _orderId ) "Payment Failed"

          userAbortedError = makeErrorMessage "cancel" (sdkParams ^. _orderId ) "User aborted"


-- parrallelUPIBankList :: Flow Either
-- parrallelUPIBankList  = unit


paymentPageFlow
    :: SDKParams
    -> Maybe PaymentPageState
    -> FlowBT PaymentPageError PaymentPageExitAction
paymentPageFlow sdkParams optPPState = do

    ppState <- case optPPState of
        Nothing -> do
            screenWidth <- liftFlowBT $ doAff do liftEffect $ getScreenWidth
            paymentMethods <-
                case sdkParams ^. _paymentSource of
                     Nothing ->
                        Remote.getPaymentMethods
                                $ PaymentSourceReq { client_auth_token: sdkParams ^. _orderToken
                                                   , offers: ""
                                                   , refresh : ""
                                                   }
                     Just a -> pure a
            pure $ fromMaybe
                        (mkPaymentPageState sdkParams paymentMethods screenWidth)
                        optPPState
        Just state -> pure state

    res <- UI.showPaymentPage ppState

    case res of
        ScreenData state ->  paymentPageFlow sdkParams (Just state)

        PaymentPageResponse state userChoice -> callRestOfTheCode state userChoice

    where
        callRestOfTheCode :: PaymentPageState -> PaymentPageAction -> FlowBT PaymentPageError PaymentPageExitAction
        callRestOfTheCode ppState userChoice = do
            _ <- liftFlowBT $ liftFlow requestKeyboardHide
            _ <- startLoader

            case userChoice of
                 -- In-App Payment
                 PayUsing value -> payUsing ppState Nothing value

                 -- Failures
                 UserAborted                   -> BackT $ throwError $ Err.UserAborted
                 {-- PayLater (PayLaterResp plrp)  -> orderId >>= \oid -> continue $ ExitApp { status: makeErrorMessage "success" (oid) "Empty Fulfillment", code : (-1)} --}
                 _                             -> BackT $ throwError $ Err.ExitApp "Unable to process"

        payUsing :: PaymentPageState -> Maybe UpiStore -> PaymentOption -> FlowBT PaymentPageError PaymentPageExitAction
        payUsing ppState upi paymentOption =
            let order_id = sdkParams ^. _orderId
             in case paymentOption of
                     NB bank             -> mkPayReqNB bank order_id        # processPayment >>= \_ -> processExit paymentOption
                     Card cd             -> mkPayReqCard cd order_id        # processPayment >>= \_ -> processExit paymentOption
                     SavedCard scd       -> mkPayReqSavedCard scd order_id  # processPayment >>= \_ -> processExit paymentOption
                     UPI vpa             -> mkPayReqUpiCollect vpa order_id # processPayment >>= \_ -> processExit paymentOption
                     WalletPayment wallet -> mkPayReqWallet wallet order_id # processPayment >>= \_ -> processExit paymentOption
                     {-- SavedUpi vpaAccount -> mkPayReqUPI order_id            # processPayment >>= \_ -> processExit paymentOption --}
                     _                   -> BackT $ throwError $ Err.ExitApp "Unable to process"

        processPayment :: InitiateTxnReq -> FlowBT PaymentPageError MicroAppResponse
        processPayment value = do
            res <- Remote.mkPayment value
            case os of
                "WEB" -> redirectForWeb res
                _ -> addlAuth res

        processExit :: PaymentOption -> FlowBT PaymentPageError PaymentPageExitAction
        processExit paymentOption =
            Remote.checkOrderStatus (sdkParams ^. _orderId)
                >>= getStatus >>> handlePayResp paymentOption sdkParams


        scanAndGetStatus :: String -> Array String -> Boolean
        scanAndGetStatus endUrl success = foldl (||) false $ map (\val -> contains (Pattern val) endUrl) success











addlAuth :: InitiateTxnResp -> FlowBT PaymentPageError MicroAppResponse
addlAuth resp = (startGodel =<< mkGodelParams (resp ^. _payment)) <* (liftFlowBT $ attach Constants.networkStatus "{}" "")

redirectForWeb :: InitiateTxnResp -> FlowBT PaymentPageError MicroAppResponse
redirectForWeb resp = (startRedirect resp) <* (liftFlowBT $ attach Constants.networkStatus "{}" "")

getStatus :: forall response b. Newtype response { status :: String | b } => response -> String
getStatus response = response ^. _status

handlePayResp :: PaymentOption -> SDKParams -> String -> FlowBT PaymentPageError PaymentPageExitAction
handlePayResp paymentOption sdkParams status = do
  let order_id = sdkParams ^. _orderId
  case status of
    -- Successful
    "CHARGED"       -> pure $ exitWithSuccess order_id
    "COD_INITIATED" -> pure $ exitWithSuccess order_id

    -- Pending -- Failure
    value           -> BackT $ throwError $ Err.MicroAppError "Payment Failed"
                  -- RetryPayment { showError : true, errorMessage : Config.paymentsPendingErrMsg, prevPaymentMethod : paymentOption }
    -- activity recreated has to handled - need to discuss about where to handle

----------------------------------------------- MOVE TO UTILS ----------------------------------------------

stringToBoolean :: String -> Boolean
stringToBoolean = eq "true" <<< toLower <<< trim


eqArrayMapping :: forall a. Eq a => Array a -> Array a -> Boolean
eqArrayMapping a b = foldl (&&) true $ zipWith (\c d -> a == b) a b


startLoader :: FlowBT PaymentPageError {}
startLoader = do
    _ <- liftFlowBT $ doAff do liftEffect $ setScreen "LoadingScreen"
    liftFlowBT $ oneOf
        [ showScreen $ Loader.screen getLoaderConfig
        , pure {}
        ]

errorMessage :: String -> FlowBT PaymentPageError ErrorMessageC.Action
errorMessage a  = do
    _ <- liftFlowBT $ doAff do liftEffect $ setScreen "ErrorMessage"
    _ <- liftFlowBT $ doAff do liftEffect $ startAnim "errorFadeIn"
    _ <- liftFlowBT $ doAff do liftEffect $ startAnim "errorSlide"
    _ <- liftFlowBT $ doAff do liftEffect $ startAnim "errorMsgFade"
    liftFlowBT $ showScreen $ ErrorMessage.screen (ErrorMessageC.ErrorMessage a)

toast :: String -> FlowBT PaymentPageError ErrorMessageC.Action
toast a  = do
    _ <- liftFlowBT $ doAff do liftEffect $ setScreen "Toast"
    _ <- liftFlowBT $ doAff do liftEffect $ startAnim "toastFadeIn"
    _ <- liftFlowBT $ doAff do liftEffect $ startAnim "toastSlide"
    liftFlowBT $ oneOf
        [ showScreen $ Toast.screen (ErrorMessageC.ToastMessage a)
        , animateAfterDelay
        ]

makeErrorMessage :: String -> String -> String -> String
makeErrorMessage status orderId message =
    "{\"status\":\"" <> status <> "\",\"order_id\":\"" <> orderId <> "\",\"message\":\"" <> message <> "\"}"



animateAfterDelay :: Flow ErrorMessageC.Action
animateAfterDelay = do
    _ <- delay (Milliseconds 1800.0)
    _ <- doAff do liftEffect $ setScreen "Toast"
    _ <- doAff do liftEffect $ startAnim "toastFadeOut"
    _ <- doAff do liftEffect $ startAnim "toastSlideOut"
    _ <- delay (Milliseconds 400.0)
    pure ErrorMessageC.UserAbort


