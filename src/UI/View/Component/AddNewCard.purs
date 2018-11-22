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
import PrestoDOM.Properties.GetChildProps (background_p, cornerRadius_p, height_p, margin_p, orientation_p, root_p, visibility_p, width_p)
import PrestoDOM.Properties.SetChildProps (height_c, margin_c, override_c, visibility_c, width_c)
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
    let getCvvValue = state ^. _formState ^. _cvv ^. _value
        getCardNum = case state ^. _cardMethod of
                         SavedCard a -> a ^. _cardNumber
                         _ -> ""
        getCardIssuer = case state ^. _cardMethod of
                            SavedCard a -> a ^. _cardIssuer
                            _ -> ""
        getBankName = getCardIssuer <> " " <> ( drop ((length getCardNum) - 4) getCardNum )
        getCvvFocusIndex = state ^. _cvvFocusIndex
        cardHeight = (case state ^. _cardMethod of   
                        SavedCard _ -> 250
                        _ -> 339) + (getKeyboardHeight unit)
     in linearLayout
        ([ height_p MATCH_PARENT parent
        , width_p MATCH_PARENT parent
        , orientation_p VERTICAL parent
        , background_p Color.a_B2000000 parent
        , cornerRadius_p 0.00 parent
        , root_p true parent
        , margin_p (Margin 0 0 0 0) parent
        , clickable true
        , visibility_p VISIBLE parent
        , alpha 0.0
		, animation $ writeJSON $ [fadeOutAnim "ACFadePopDown", fadeInAnim "ACFadePopUp", setFadeOutAnim "FadeDefADDCard" ]
        ] <> (overrides (S "Group") push state))
        [ linearLayout
            ([ weight 1.0
            , width MATCH_PARENT
            ] <>> overrides Space push state )
            []
        , linearLayout
            ([ height $ V cardHeight
            , width MATCH_PARENT
            , orientation VERTICAL
            , padding (Padding 0 40 0 0)
            , background Color.a_FFFFFFFF
            , cornerRadius 6.00
            -- , translationY (toNumber cardHeight)
			      , animation $ writeJSON $ [slideInBottomDelay "ACPopUp" cardHeight ,slideOutBottom "ACPopDown" cardHeight]
            ])
            [ linearLayout
                ([ height $ V 221
                , width MATCH_PARENT
                , orientation VERTICAL
                , background Color.a_FFFFFFFF
                , padding (PaddingHorizontal 30 30)
                , cornerRadius 6.00
                , case state ^. _cardMethod of   
                            SavedCard _ -> visibility GONE
                            _ -> visibility VISIBLE
                -- , animation $ writeJSON $ [slideInBottomDelay "ACPopUp" 318 ,slideOutBottom "ACPopDown" 318 , setSlideToBottom "SLIDEACPOP" 318 ]
                ] <> overrides (S "AddCardGroup") push state )
                [ linearLayout 
                    [height $ V 18
                    , width MATCH_PARENT
                    , orientation HORIZONTAL
                    ]
                    [ linearLayout
                            [
                                height $ V 16
                            ,	width MATCH_PARENT
                            , orientation HORIZONTAL
                            ] 
                            [ textView
                                ([ height $ V 16
                                , width $ V 28
                                , textSize FontSize.a_14
                                , color FontColor.a_FF373B3B
                                , letterSpacing 0.47
                                , fontStyle Font.gILROYBOLD
                                , text "add"
                                , gravity LEFT
                                ] <>> overrides AddCardLabelOne push state )
                            , textView
                                ([ height $ V 16
                                , width $ V 90
                                , textSize FontSize.a_14
                                , color FontColor.a_FF373B3B
                                , fontStyle Font.gILROYREGULAR
                                , letterSpacing 0.47
                                , text " debit card"
                                , gravity LEFT
                                ] <>> overrides AddCardLabelTwo push state )
                            ]
                    ]
                , linearLayout
                    [ height (V 20)
                    , width MATCH_PARENT
                    , margin (MarginTop 22)
                    , orientation HORIZONTAL
                    , gravity CENTER
                    ]
                    [ textView
                        ([ height $ V 20
                        , width MATCH_PARENT
                        , text STR.cardNumberLabel8
                        , textSize FontSize.a_12
                        , letterSpacing 0.7
                        , color FontColor.a_FF000000
                        , fontStyle Font.gILROYREGULAR
                        ] <>> overrides CardNumberLabel push state )
                    ]
                , linearLayout
                    [ height $ V 29
                    , width MATCH_PARENT
                    , gravity CENTER_HORIZONTAL
                    , margin (MarginTop 6)
                    ]
                    [ editField
                        ([ height $ V 29
                        , width MATCH_PARENT
                        , padding $ PaddingTop 0
                        , background "#00ffffff"
                        , textSize FontSize.a_24
                        , fontStyle Font.gILROYBOLD
                        -- , becomeFirstResponder ""
                        , letterSpacing 1.75
                        , color FontColor.a_FF000000
                        ] <>> overrides CardNumberEditField push state )
                    ]
                , linearLayout
                    ([ height $ V 52
                    , width $ V 270
                    , orientation HORIZONTAL
                    , margin (MarginTop 32)
                    ] <> overrides (S "ExpiryAndCvv") push state )
                    [ linearLayout
                        ([ height $ V 52
                        , width $ V 120
                        , orientation VERTICAL
                        ] <> overrides (S "ExpiryGroup") push state )
                        [ textView
                            ([ height $ V 20
                            , text STR.expiryLabel10
                            , textSize FontSize.a_12
                            , width MATCH_PARENT
                            , letterSpacing 0.7
                            , color FontColor.a_FF000000
                            , fontStyle Font.gILROYREGULAR
                            ] <>> overrides ExpiryDateLabel push state )
                        , linearLayout [
                            weight 1.0
                        ] []
                        , editField
                            ([ height $ V 29
                            , width MATCH_PARENT
                            , padding $ PaddingTop 0
                            , background "#ffffff"
                            , textSize FontSize.a_24
                            , fontStyle Font.gILROYBOLD
                            , letterSpacing 0.75
                            , color FontColor.a_FF000000
                            , gravity LEFT
                            ] <>> overrides ExpiryDateEditField push state )
                        ]
                    , linearLayout
                        ([ height $ V 52
                        , width $ V 100
                        , orientation VERTICAL
                        , margin (MarginLeft 50)
                        ] <> overrides (S "CvvGroup") push state )
                        [ textView
                            ([ height $ V 20
                            , width MATCH_PARENT
                            , margin (MarginBottom 2)
                            , text STR.cvvLabel12
                            , textSize FontSize.a_12
                            , letterSpacing 0.7
                            , color FontColor.a_FF000000
                            , fontStyle Font.gILROYREGULAR
                            ] <>> overrides CvvLabel push state )
                        , linearLayout [
                            weight 1.0
                        ][]
                        , relativeLayout
                            [ height $ V 29
                            , width MATCH_PARENT
                            ]
                            [  editText
                                ([ height $ V 25
                                , width MATCH_PARENT
                                , hint STR.cvvText13
                                , textSize FontSize.a_16
                                , color FontColor.a_FF000000
                                , gravity CENTER_VERTICAL
                                , inputType Numeric
                            ] {--<>> if (length (state ^. _formState ^. _cardNumber ^. _value) )== 16 then [becomeFirstResponder ""] else []--}
                                <>> overrides CvvEditField push state )
                            , linearLayout
                                [ height MATCH_PARENT
                                , width MATCH_PARENT
                                , background Color.a_FFFFFFFF
                                , clickable false
                                , userInteraction false
                                , gravity CENTER_VERTICAL
                                ]
                                [ linearLayout
                                    [ height (V 14)
                                    , width (V 14)
                                    , background $ getCVVColor 0 $ state ^. _formState ^. _cvv ^. _value
                                    , stroke $ "1," <> (getStrokeColor $ 0 == (state ^. _cvvFocusIndex)) --if state ^. _currentFocused /= CVV then getCVVColor 0 $ state ^. _formState ^. _cvv ^. _value else "#645645"
                                    , cornerRadius 7.0
                                    ] []
                                , linearLayout
                                    [ height (V 14)
                                    , width (V 14)
                                    , margin (MarginLeft 15)
                                    , background $ getCVVColor 1 $ state ^. _formState ^. _cvv ^. _value
                                    , stroke $ "1," <> (getStrokeColor $ 1 == (state ^. _cvvFocusIndex))
                                    , cornerRadius 7.0
                                    ] []
                                , linearLayout
                                    [ height (V 14)
                                    , width (V 14)
                                    , margin (MarginLeft 15)
                                    , background $ getCVVColor 2 $ state ^. _formState ^. _cvv ^. _value
                                    , stroke $ "1," <> (getStrokeColor $ 2 == (state ^. _cvvFocusIndex))
                                    , cornerRadius 7.0
                                    ] []
                                ]
                            ]
                        ]
                    ]
                , linearLayout
                    ([ height (V 41)
                    , width (V 1)
                    ] <> overrides (S "Space") push state )
                    []
                {-- , mapDom Keyboard.view push {keyState : "" } Key [] --}
                ]
                , proceedOrErrorPlace push state

            ]
        ]
    

    where
          editField a =
            case state ^. _cardMethod of
                 AddNewCard -> editText (a <>> [inputType Numeric])
                 SavedCard _ -> textView a

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