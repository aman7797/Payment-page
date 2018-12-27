module UI.Flow where

import Prelude

import Constants as Constants
import Effect.Class (liftEffect)
import Effect.Aff (Milliseconds(..), makeAff, nonCanceler, throwError)
import Engineering.Helpers.Commons (setOnWindow, log)
import Data.Lens ((.~), (^.))
import Engineering.Helpers.Commons (log, setOnWindow, startAnim)
import Engineering.Helpers.Types.Accessor (_uiState, _updatedBillercardArray, _banks)
import Engineering.Helpers.Utils (liftFlowBT, setScreen, getLoaderConfig)
import Engineering.Types.App (FlowBT, PaymentPageError)
import Presto.Core.Flow (Flow, delay, doAff, runScreen, oneOf, showScreen)
import UI.Controller.Screen.PaymentsFlow.PaymentPage
import UI.Utils (os)

import UI.Controller.Screen.PaymentsFlow.ErrorMessage as ErrorMessageC

import UI.Idea.View.Screen.PaymentsFlow.PaymentPage as PaymentPage
import UI.Idea.View.Screen.PaymentsFlow.ErrorMessage as ErrorMessage
import UI.Idea.View.Screen.PaymentsFlow.Loader as Loader
import UI.Idea.View.Screen.PaymentsFlow.Toast as Toast

showPaymentPage :: PaymentPageState -> FlowBT PaymentPageError PaymentPageResponse
showPaymentPage ppState = do
  _ <- liftFlowBT $ doAff do liftEffect $ setScreen "PaymentOptions"
  r <- liftFlowBT $ runScreen (PaymentPage.screen $ log "ppState in flow" ppState)
  case r of
       (PaymentPageResponse state _) -> setOnWindow Constants.ppStateKey state
       ScreenData state -> setOnWindow Constants.ppStateKey state
  pure r




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

startLoader :: FlowBT PaymentPageError {}
startLoader = do
    _ <- liftFlowBT $ doAff do liftEffect $ setScreen "LoadingScreen"
    liftFlowBT $ oneOf
        [ showScreen $ Loader.screen getLoaderConfig
        , pure {}
        ]


animateAfterDelay :: Flow ErrorMessageC.Action
animateAfterDelay = do
    _ <- delay (Milliseconds 1800.0)
    _ <- doAff do liftEffect $ setScreen "Toast"
    _ <- doAff do liftEffect $ startAnim "toastFadeOut"
    _ <- doAff do liftEffect $ startAnim "toastSlideOut"
    _ <- delay (Milliseconds 400.0)
    pure ErrorMessageC.UserAbort

