module UI.View.Screen.PaymentsFlow.PaymentPage where

import Prelude
import UI.Animations

import Data.Array
import Data.Lens
import Data.Maybe
import Data.Newtype
import Data.String.CodePoints as S
import Effect
import Data.Int
import Data.Lens
import Engineering.Helpers.Commons
import Engineering.Helpers.Events

import PrestoDOM
import PrestoDOM.Core (mapDom)
import PrestoDOM.Utils ((<>>))

import Product.Types (CurrentOverlay(DebitCardOverlay), SIM(..), UPIState(..))
import Product.Types as Types
import UI.Constant.Color.Default as Color
import UI.Constant.FontColor.Default as FontColor
import UI.Constant.FontSize.Default as FontSize
import UI.Constant.FontStyle.Default as Font
import UI.Constant.FontStyle.Default as FontStyle
import UI.Constant.Str.Default as STR
import UI.Constant.Type (FontColor, FontStyle)
import UI.Controller.Screen.PaymentsFlow.PaymentPage

import UI.Utils
import UI.View.Component.AddNewCard as AddNewCard

import Validation (getCardIcon)

view
	:: forall w
	. (PaymentPageUIAction -> Effect Unit)
	-> PaymentPageState
	-> PrestoDOM (Effect Unit) w
view push state =
    linearLayout
        [ height MATCH_PARENT
        , width MATCH_PARENT
        , background "#ff0000"
        ]
        [ textView
            [ text "HELLO"]
        ]

screen :: PaymentPageState -> Screen PaymentPageUIAction PaymentPageState PaymentPageResponse
screen ppState =
	{ initialState : ppState
	, view
	, eval
	}
