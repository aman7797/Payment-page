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
import Engineering.Helpers.Types.Accessor (_cardIssuer, _cardMethod, _cardNumber, _currentFocused, _cvv, _cvvFocusIndex, _formState, _name, _value)
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
	 in mainView
        [ headingView
        , editView
            { hint : "Card Number"
            , width : MATCH_PARENT
            , weight : 0.0
            , margin : MarginTop 30
            }
            (implementation CardNumberEditField)
        , editView
            { hint : "Name on the Card"
            , width : MATCH_PARENT
            , weight : 0.0
            , margin : MarginTop 30
            }
            (implementation $ S "")
        , horizontalView
            [ editView
                { hint : "Expiry(mm/yy)"
                , width : V 100
                , weight : 1.0
                , margin : MarginLeft 0
                }
                (implementation ExpiryDateEditField)
            , editView
                { hint : "CVV"
                , width : V 100
                , weight : 1.0
                , margin : MarginLeft 40
                }
                (implementation CvvEditField)
            ]
        , saveForLaterView
        {-- , horizontalView --}
        {--     [ editView --}
        {--         { hint : "Mobile Number" --}
        {--         , width : V 100 --}
        {--         , weight : 1.0 --}
        {--         , margin : Margin 0 0 40 0 --}
        {--         } --}
        {--         (implementation $ S "") --}
        {--     , linearLayout [ height $ V 1, width $ V 100,  weight 1.0 ] [] --}
        {--     ] --}
        , payButton push state
        ]

                {-- overrides CardNumberLabel push state ) --}
                {-- overrides ExpiryDateLabel push state ) --}
                {-- overrides push state ) --}
                {--  overrides CvvLabel push state ) --}
                {-- overrides push state ) --}

--- common
headingView =
    linearLayout
        [ height $ V 33
        , width $ V 200
        , orientation HORIZONTAL
        , margin $ MarginTop 40
        ]
        [ textView
            [ height MATCH_PARENT
            , width MATCH_PARENT
            , text "Add New Card"
            , fontStyle "Arial-Regular"
            , textSize 24
            , color "#363636"
            ]
        ]


editView
    :: forall w
     . { hint :: String
       , width :: Length
       , weight :: Number
       , margin :: Margin
       }
    -> Props (Effect Unit)
    -> PrestoDOM (Effect Unit) w
editView value implementation =
    linearLayout
        [ height $ V 60
        , width value.width
        , weight value.weight
        , margin value.margin
        , gravity CENTER_VERTICAL
        , orientation HORIZONTAL
        , stroke "2,#CCCCCC"
        , cornerRadius 3.0
        , gravity CENTER
        ]
        [ editText
            ([ textSize 20
            , height $ V 25
            , width MATCH_PARENT
            {-- , hint value.hint --}
            , label value.hint
            , margin $ Margin 20 0 0 0
            ] <>> implementation)
        ]


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
        [ height $ V 550
        , width MATCH_PARENT
        , padding $ PaddingHorizontal 30 30
        , shadow $ Shadow 0.0 2.0 4.0 1.0 "#12000000" 1.0
        , orientation VERTICAL
        , background "#FFFFFF"
        ]
        children



--- common
payButton :: forall w. (Action -> Effect Unit) -> State -> PrestoDOM (Effect Unit) w
payButton push state =
    linearLayout
        ([ height $ V 60
        , width $ V 300
        , orientation HORIZONTAL
        , gravity CENTER
        , margin $ MarginTop 30
        , background "#1BB3E8"
        , cornerRadius 8.0
        ] <>> overrides BtnPay push state)
        [ textView
            [ height $ V 22
            , width MATCH_PARENT
            , gravity CENTER
            , text "Pay Securely"
            , textSize 20
            , color "#ffffff"
            ]
        ]



