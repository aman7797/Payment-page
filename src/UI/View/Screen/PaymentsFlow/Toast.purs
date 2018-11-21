module UI.View.Screen.PaymentsFlow.Toast where

import Prelude

import Effect
import Data.Lens ((^.))
import Engineering.Helpers.Types.Accessor (_error)
import PrestoDOM 
import Simple.JSON (writeJSON)
import UI.Animations (errorFade, errorFade', errorSlide, errorSlide')
import UI.Constant.FontColor.Default as FontColor
import UI.Constant.FontSize.Default as FontSize
import UI.Constant.FontStyle.Default as Font
import UI.Controller.Screen.PaymentsFlow.ErrorMessage (Action(UserAbort), GenericErrorState, ScreenInput, ScreenOutput, eval, initialState)
import UI.Utils (os)


screen :: ScreenInput -> Screen Action GenericErrorState ScreenOutput
screen input =
	{ initialState : (initialState input)
	, view
	, eval
	}


view :: forall w.
    (Action -> Effect Unit)
    -> GenericErrorState
    -> PrestoDOM (Effect Unit) w
view push state =
    linearLayout_ (Namespace "Toast")
        [ height $ V 540
        , width MATCH_PARENT
        , orientation VERTICAL
        , padding (Padding 48 54 48 0)
        , gradient $ Linear 90.0 ["#191B1F", "#00191B1F"]
        , alpha 0.0
        , animation $ writeJSON [ errorFade "toastFadeIn" 0.0 1.0, errorFade' "toastFadeOut" 1.0 0.0 ]
        , onClick push (const UserAbort)
        ]
        [ linearLayout
            [ height $ V 50
            , width MATCH_PARENT
            -- , gravity CENTER
            , orientation VERTICAL
            -- , cornerRadius 8.0
            -- , gradient "{\"values\":[\"#36955F\",\"#4FB278\"],\"type\":\"linear\",\"angle\":\"90\"}"
            , shadow $ Shadow 2.0 10.0 27.0 (-10.0) "#0D0D0F" 1.0
            ]
            [ linearLayout
                [ height $ V 50
                , width MATCH_PARENT
                , gravity CENTER
                , orientation VERTICAL
                , cornerRadius 8.0
                , padding (Padding 40 18 40 18)
                , animation $ writeJSON [ errorSlide "toastSlide" (-200) 0, errorSlide' "toastSlideOut" 0 (-200) ]
                -- , padding (Padding 40 18 40 18)
                , if os == "IOS"
                    then gradient $ Linear 0.0 ["#4FB278", "#36955F"]
                    else background "#4FB278"
                -- , gradient "{\"values\":[\"#4FB278\",\"#36955F\"],\"type\":\"linear\",\"angle\":\"0\"}"
                -- , shadow $ Shadow 2.0 10.0 27.0 (-10.0) "#0D0D0F" 1.0
                ]
                [ linearLayout
                    [ height $ V 16
                    , width $ V 192
                    , orientation HORIZONTAL
                    , gravity CENTER_VERTICAL
                    ]
                    [ imageView
                            [ height $ V 16
                            , width $ V 16
                            , orientation HORIZONTAL
                            , imageUrl "ic_tick"
                            ]
                    , textView
                        [ height $ V 14
                        , width $ V 168
                        , letterSpacing 0.83
                        , margin (Margin 10 0 0 0)
                        , text $ state ^. _error
                        , textSize FontSize.a_12
                        , color FontColor.a_FFFFFFFF
                        , fontStyle Font.gILROYMEDIUM
                        ]
                    ]
                ]
            ]
        ]
