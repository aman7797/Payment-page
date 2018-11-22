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
import Validation (InvalidState(..), ValidationState(..), getMonth, getYear)

-- Types

newtype PaymentPageState = PaymentPageState
  { ppInput :: PaymentPageInput
  , uiState :: UIState
  }

data ErrorMethod = Snackbar String | Popup String

isSnackBar :: ErrorMethod -> Visibility
isSnackBar (Snackbar err) = GONE
isSnackBar (Popup err) = GONE


type UIState =
    { currentTab :: Tabs
    }


data Tabs
    = Wallets
    | Cards
    | NetBanking
    | UPI
    | NoTabSelected

derive instance genericTabs :: Generic Tabs _

instance showTabs :: Show Tabs where
    show = genericShow

instance eqTabs :: Eq Tabs where
    eq = genericEq
-- UIActions

data PaymentPageUIAction
  = BillerCard
  | TabSelect Tabs
-- Exit Type

data PaymentPageResponse
    = PaymentPageResponse PaymentPageState (Array PayLaterResp) PaymentPageAction
    | ScreenData PaymentPageState

-- Exit Actions

data PaymentPageAction
    = UserAborted

data ScrollType = SCROLL | HALT

-- Defaults

initialState :: PaymentPageInput -> PaymentPageState
initialState ppInput = PaymentPageState
        { ppInput
        , uiState : defaultUIState ppInput
        }

defaultUIState :: PaymentPageInput -> UIState
defaultUIState ppInput =
    { currentTab : Wallets
    }

eval
	:: PaymentPageUIAction
	-> PaymentPageState
	-> Eval PaymentPageUIAction PaymentPageResponse PaymentPageState
eval action ppState = continue ppState
  {-- case action of --}





data Overrides
    = TabOverride

