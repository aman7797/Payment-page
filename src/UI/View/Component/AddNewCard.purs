module UI.View.Component.AddNewCard where

import Prelude

import Data.Int (toNumber)
import Data.Lens ((^.))
import Foreign.Object as Object
import Data.String (length)
import Effect (Effect)
import Engineering.Helpers.Types.Accessor (_cardMethod, _cvv, _cvvFocusIndex, _formState, _value)
import PrestoDOM
import Data.String (length, drop)
import Engineering.Helpers.Commons (log)
import Engineering.Helpers.Types.Accessor (_cardIssuer, _cardMethod, _cardNumber, _currentFocused, _cvv, _cvvFocusIndex, _formState, _name, _value, _proceedButtonState)
import JBridge (getKeyboardHeight)
import PrestoDOM.Core (mapDom)
import PrestoDOM.Types.DomAttributes (Gravity(..), InputType(..), Length(..), Margin(..), Orientation(..), Padding(..), Visibility(..))
import PrestoDOM.Utils ((<>>))
import Simple.JSON (writeJSON)
import UI.Animations (slideInBottomDelay, slideOutBottom, setSlideToBottom, fadeInAnim, fadeOutAnim, setFadeOutAnim)
import UI.Constant.Color.Default as Color
import UI.Constant.FontColor.Default as FontColor
import UI.Constant.FontSize.Default as FontSize
import UI.Constant.FontStyle.Default as Font
import UI.Constant.Str.Default as STR
import UI.Controller.Component.AddNewCard (Action, Method(..), Overrides(..), State, getCardStatus, overrides)
import UI.View.Component.CommonView
import UI.Utils
import Validation (ValidationState(..))


import UI.Controller.Component.AddNewCard (Action(..), Method(..), Overrides(..), State, getCardStatus, overrides)
import UI.Utils (userInteraction, FieldType(..))
import Validation (InvalidState(..), ValidationState(..))

view
	:: forall w
	. (Action -> Effect Unit)
	-> State
	-> Object.Object GenProp
	-> PrestoDOM (Effect Unit) w
view push state parent =
    let implementation = \a -> overrides a push state
        cardMethod = state ^. _cardMethod
	 in mainView
        [ headingView {text : "Add New Card"}
        , editField (implementation CardNumberEditField)
            { hint : "Card Number"
            , width : MATCH_PARENT
            , weight : 0.0
            , margin : MarginTop 30
            }
        , editField (implementation $ S "")
            { hint : "Name on the Card"
            , width : MATCH_PARENT
            , weight : 0.0
            , margin : MarginTop 30
            }
        , horizontalView
            [ editField (implementation ExpiryDateEditField)
                { hint : "Expiry(mm/yy)"
                , width : V 100
                , weight : 1.0
                , margin : MarginLeft 0
                }
            , editField (implementation CvvEditField)
                { hint : "CVV"
                , width : V 100
                , weight : 1.0
                , margin : MarginLeft 40
                }
            ]
        , saveForLaterView
        {-- , horizontalView --}
        {--     [ editField --}
        {--         { hint : "Mobile Number" --}
        {--         , width : V 100 --}
        {--         , weight : 1.0 --}
        {--         , margin : Margin 0 0 40 0 --}
        {--         } --}
        {--         (implementation $ S "") --}
        {--     , linearLayout [ height $ V 1, width $ V 100,  weight 1.0 ] [] --}
        {--     ] --}
        , buttonView (implementation BtnPay)
            { width : V 300
            , margin : MarginTop 30
            , text : "Pay Securely"
            }
        ]

                {-- overrides CardNumberLabel push state ) --}
                {-- overrides ExpiryDateLabel push state ) --}
                {-- overrides push state ) --}
                {--  overrides CvvLabel push state ) --}
                {-- overrides push state ) --}


horizontalView children =
    linearLayout
        [ height $ V 60
        , width MATCH_PARENT
        , orientation HORIZONTAL
        , margin $ MarginTop 30
        ]
        children

saveForLaterView :: forall w. PrestoDOM (Effect Unit) w
saveForLaterView =
    linearLayout
        [ height $ V 17
        , width $ V 300
        , orientation HORIZONTAL
        , gravity CENTER_VERTICAL
        , margin $ MarginTop 30
        ]
        [ checkBox
            [ height $ V 16
            , width $ V 16
            , cornerRadius 3.0
            , checked true
            , stroke "2,#363636"
            ]
            {-- [] --}
        , textView
            [ height $ V 17
            , weight 1.0
            , text "Save this card for faster payments"
            , margin $ MarginLeft 10
            , color "#333333"
            , textSize 14
            , gravity LEFT
            ]
        ]

mainView
    :: forall w
     . Array (PrestoDOM (Effect Unit) w)
    -> PrestoDOM (Effect Unit) w
mainView children =
    linearLayout
        [ height $ V 516
        , width MATCH_PARENT
        , padding $ Padding 30 40 30 0
        , shadow $ Shadow 0.0 2.0 4.0 1.0 "#12000000" 1.0
        , orientation VERTICAL
        , background "#FFFFFF"
        ]
        children



