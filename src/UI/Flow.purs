module UI.Flow where

import Prelude

import Constants as Constants
import Effect.Class (liftEffect)
import Engineering.Helpers.Commons (setOnWindow, log)
import Data.Lens ((.~), (^.))
import Engineering.Helpers.Commons (log, setOnWindow, startAnim)
import Engineering.Helpers.Types.Accessor (_uiState, _updatedBillercardArray, _banks)
import Engineering.Helpers.Utils (liftFlowBT, setScreen)
import Engineering.Types.App (FlowBT, PaymentPageError)
import Presto.Core.Flow (doAff, runScreen, showScreen)
import UI.Controller.Screen.PaymentsFlow.PaymentPage
import UI.Utils (os)
import UI.View.Screen.PaymentsFlow.PaymentPage as PaymentPage

showPaymentPage :: PaymentPageState -> FlowBT PaymentPageError PaymentPageResponse
showPaymentPage ppState = do
  _ <- liftFlowBT $ doAff do liftEffect $ setScreen "PaymentOptions"
  r <- liftFlowBT $ runScreen (PaymentPage.screen $ log "ppState in flow" ppState)
  case r of
       (PaymentPageResponse state _ _) -> setOnWindow Constants.ppStateKey state
       ScreenData state -> setOnWindow Constants.ppStateKey state
  pure r

