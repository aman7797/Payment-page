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
import UI.Utils (userInteraction)
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
        [ editView
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
                , margin : MarginTop 30
                }
                (implementation ExpiryDateEditField)
            , editView
                { hint : "CVV"
                , width : V 100
                , weight : 1.0
                , margin : Margin 40 30 0 0
                }
                (implementation CvvEditField)
            ]
        , saveForLaterView
        , horizontalView
            [ editView
                { hint : "Mobile Number"
                , width : V 100
                , weight : 1.0
                , margin : Margin 0 30 40 0
                }
                (implementation $ S "")
            , linearLayout [ height $ V 1, width $ V 100,  weight 1.0 ] []
            ]
        , payButton
        ]

                {-- overrides CardNumberLabel push state ) --}
                {-- overrides ExpiryDateLabel push state ) --}
                {-- overrides push state ) --}
                {--  overrides CvvLabel push state ) --}
                {-- overrides push state ) --}


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
        , stroke "1,#E9E9E9"
        , gravity CENTER
        ]
        [ editText
            ([ textSize 20
            , height $ V 23
            , width MATCH_PARENT
            , hint value.hint
            , margin $ MarginLeft 20
            ] <>> implementation)
        ]


horizontalView children =
    linearLayout
        [ height $ V 60
        , width MATCH_PARENT
        , orientation HORIZONTAL
        ]
        children

saveForLaterView :: forall w. PrestoDOM (Effect Unit) w
saveForLaterView =
    linearLayout
        [ height $ V 24
        , width $ V 300
        , orientation HORIZONTAL
        , gravity CENTER_VERTICAL
        , margin $ MarginTop 60
        ]
        [ linearLayout
            [ height $ V 18
            , width $ V 18
            , stroke "1,#666666"
            ]
            []
        , textView
            [ height $ V 18
            , weight 1.0
            , text "Save this card for faster payments"
            , margin $ MarginLeft 8
            , textSize 16
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
        , orientation VERTICAL
        , background "#FFFFFF"
        ]
        children



getCVVColor :: Int → String → String
getCVVColor i st =
    if (length st) > i
        then
            Color.a_FF000000
        else
            Color.a_FFE9EBEF

getStrokeColor :: Boolean -> String
getStrokeColor = if _ then "#646464" else Color.a_FFE9EBEF

proceedOrErrorPlace
    :: forall w
     . (Action -> Effect Unit)
	-> State
	-> PrestoDOM (Effect Unit) w
proceedOrErrorPlace push state =
    case getCardStatus state of
         VALID ->
            linearLayout
            ([ height (V 46)
            , width (V 183)
            , orientation HORIZONTAL
            , gravity CENTER
            , background "#FF4354B2"
            , cornerRadius 6.00
            , root true
            , margin (Margin 30 0 0 22)
            , visibility VISIBLE
            ] <>> (overrides BtnPay push state))
            [ textView
                ([ height $ V 16
                , width MATCH_PARENT
                , letterSpacing 0.65
                -- , text "Proceed" -- Add from state
                , textSize FontSize.a_14
                , color Color.a_FFFFFFFF
                , fontStyle Font.gILROYSEMIBOLD
                , gravity CENTER
                ] <>> (overrides BtnText push state ))
            ]
         INVALID (ERROR msg) ->
            linearLayout
            [ height (V 52)
            , width MATCH_PARENT
            , orientation HORIZONTAL
            , gravity CENTER
            , background Color.a_FFFFFFFF
            , margin $ MarginTop 16
            -- , padding $ PaddingTop 5
            , translationZ 30.0
            , shadow $ Shadow 2.0 (-8.0) 27.0 (-15.0) "#AB1923" 0.27
            -- , margin (Margin 0 0 30 0)
            ]
            [ textView
                [ height $ V 17
                , width MATCH_PARENT
                , textSize FontSize.a_14
                -- , margin $ Margin 10 10 10 10
                -- , translationZ 50.00
                , text msg
                , color FontColor.a_FFDD5C64
                , letterSpacing 1.8
                , background Color.a_FFFFFFFF
                , fontStyle Font.gILROYMEDIUM
                , gravity CENTER
                ] --  <>> overrides ErrorMsg push state )
            ]
         _ ->
            linearLayout
            [height (V 46)
            , width (V 183)
            , orientation HORIZONTAL
            , gravity CENTER
            , background Color.a_FFFFFFFF
            , cornerRadius 6.00
            , root true
            , margin (Margin 30 0 0 22)
            , visibility VISIBLE
            ][]



payButton :: forall w. PrestoDOM (Effect Unit) w
payButton =
    linearLayout
        [ height $ V 60
        , width $ V 300
        , orientation HORIZONTAL
        , gravity CENTER
        , margin $ MarginTop 60
        , background "#E9E9E9"
        ]
        [ textView
            [ height $ V 23
            , width MATCH_PARENT
            , gravity CENTER
            , text "Pay Securely"
            ]
        ]



