module UI.Controller.Screen.PaymentsFlow.PaymentPage where

import Prelude

import Config.Default as Default
import Control.Monad.Trans.Class (lift)
import Data.Array
import Data.Foldable (foldl)
import Data.Int (toNumber)
import Data.Lens (Lens', _1, (%~), (.~), (^.))
import Data.Maybe (Maybe(..), fromMaybe, maybe)
import Data.Newtype (class Newtype)
import Data.Number (fromString)
import Data.Number.Format (toString)
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import Data.Generic.Rep.Eq (genericEq)
import Effect (Effect)
import Engineering.Helpers.Commons (dpToPx, log, startAnim)
import Engineering.Helpers.Utils (setDelay)
import Engineering.Helpers.Types.Accessor
import JBridge (requestKeyboardShow, requestKeyboardHide)
import Engineering.Helpers.Commons (dpToPx, log, startAnim, startAnim_, getIinNb)
import Engineering.Helpers.Utils (setDelay)
import Externals.UPI.Types (UPIAppList(..))
import JBridge (requestKeyboardHide, requestKeyboardShow)
import PrestoDOM
import PrestoDOM.Events (onBackPressed, onClick)
import PrestoDOM.Utils ((<>>))
import Product.Types
import Remote.Accessors (_paymentMethod)
import Remote.Config (encKey)
import Remote.Types (StoredCard)
import Tracker.Tracker (trackEventMerchantV2, toString) as T
import UI.Constant.FontStyle.Default as Font
import UI.Controller.Component.AddNewCard (Action(..))
import UI.Controller.Component.AddNewCard as AddNewCard
import  UI.Controller.Component.UpiView  as UpiView
import Validation (InvalidState(..), ValidationState(..), getMonth, getYear)

import UI.Utils

-- Types

newtype PaymentPageState = PaymentPageState
  { ppInput :: PaymentPageInput
  , uiState :: UIState
  }

data ErrorMethod = Snackbar String | Popup String

isSnackBar :: ErrorMethod -> Visibility
isSnackBar (Snackbar err) = GONE
isSnackBar (Popup err) = GONE


newtype UIState = UIState
    { sectionSelected :: PaymentSection
    , addNewCardState :: AddNewCard.State
    , upiViewState :: UpiView.State
    }

derive instance paymentPageStateNewtype :: Newtype PaymentPageState _

derive instance uiStateNewtype :: Newtype UIState _


data PaymentSection
    = Wallets
    | Cards
    | NetBanking
    | UPI
    | DefaultSection

derive instance genericPaymentSection :: Generic PaymentSection _

instance showPaymentSection :: Show PaymentSection where
    show = genericShow

instance eqPaymentSection :: Eq PaymentSection where
    eq = genericEq
-- UIActions

data PaymentPageUIAction
  = BillerCard
  | SectionSelected PaymentSection
  | AddNewCardAction AddNewCard.Action
  | UpiViewAction UpiView.Action
-- Exit Type

data PaymentPageResponse
    = PaymentPageResponse PaymentPageState  PaymentPageAction
    | ScreenData PaymentPageState

-- Exit Actions

data PaymentPageAction
    = UserAborted
    | PayUsing PaymentOption

data ScrollType = SCROLL | HALT

-- Defaults

initialState :: PaymentPageInput -> PaymentPageState
initialState ppInput = PaymentPageState
        { ppInput
        , uiState : defaultUIState ppInput
        }

defaultUIState :: PaymentPageInput -> UIState
defaultUIState ppInput = UIState
    { sectionSelected  : UPI
    , addNewCardState : AddNewCard.initialState { supportedMethods : [], cardMethod : AddNewCard.AddNewCard}
    , upiViewState : UpiView.initialState
    }

eval
	:: PaymentPageUIAction
	-> PaymentPageState
	-> Eval PaymentPageUIAction PaymentPageResponse PaymentPageState
eval =
  case _ of
    SectionSelected tab -> continue <<<  (_uiState <<<  _sectionSelected .~ tab)

    AddNewCardAction (SubmitCard AddNewCard.AddNewCard)->
        exitPP $ PayUsing <<< Card <<< mkCardDetails

    AddNewCardAction (SubmitCard (AddNewCard.SavedCard card)) ->
        exitPP $ PayUsing <<< SavedCard <<< mkSavedCardDetails card


    AddNewCardAction cardAction ->
        \ppState -> continue $ ppState # (_uiState <<< _addNewCardState) .~ (logAny $ AddNewCard.eval cardAction $ ppState ^. _uiState ^. _addNewCardState)
    _ -> continue

exitPP
    :: (PaymentPageState -> PaymentPageAction)
    -> PaymentPageState
    -> Eval PaymentPageUIAction PaymentPageResponse PaymentPageState
exitPP action ppState = exit $ PaymentPageResponse ppState (action ppState)


mkCardDetails :: PaymentPageState -> CardDetails
mkCardDetails ppState =
    let addCardState = ppState ^. _uiState ^. _addNewCardState
     in CardDetails
        { cardNumber : addCardState ^. _formState ^. _cardNumber ^. _value
        , expMonth   : show <<< getMonth $ addCardState ^. _formState ^. _expiryDate ^. _value
        , expYear    : show <<< getYear $ addCardState ^. _formState ^. _expiryDate ^. _value
        , nameOnCard : Default.nameOnCard
        , securityCode : addCardState ^. _formState ^. _cvv ^. _value
        , saveToLocker : addCardState ^. _formState ^. _savedForLater
        , paymentMethod : addCardState ^. _formState ^. _cardNumber ^. _cardDetails ^. _card_type
        }

mkSavedCardDetails :: StoredCard -> PaymentPageState -> SavedCardDetails
mkSavedCardDetails card ppState =
    let cardState = ppState  ^. _uiState ^. _addNewCardState
     in SavedCardDetails
        { cvv : cardState ^. _formState ^. _cvv ^. _value
        , cardToken : card ^. _cardToken
        , cardType : card ^. _cardType
        }


data Overrides
    = SectionOverride PaymentSection
    | SectionSelectionOverride  PaymentSection


overrides :: (PaymentPageUIAction  -> Effect Unit) -> PaymentPageState -> Overrides -> Props (Effect Unit)
overrides push state =
    case _ of
        SectionSelectionOverride section ->
            [ onClick push $ const $ SectionSelected section
            , background $ if state ^. _uiState ^. _sectionSelected == section
                           then "#e9e9e9"
                           else "#ffffff"
            ]

        SectionOverride section ->
            [ visibility $ if state ^. _uiState ^. _sectionSelected == section
                              then VISIBLE
                              else GONE
            ]

