module UI.Idea.View.Screen.PaymentsFlow.ErrorMessage where

import Prelude
import UI.Animations

import Effect (Effect)
import Data.Int (toNumber)
import Data.Lens ((^.))
import Engineering.Helpers.Commons (dpToPx)
import Engineering.Helpers.Types.Accessor (_button1State, _error)
import PrestoDOM
import PrestoDOM.Core (mapDom)
import PrestoDOM.Properties.SetChildProps (height_c, margin_c, override_c, width_c)
import PrestoDOM.Types.DomAttributes (Gravity(..), Length(..), Margin(..), Orientation(..), Padding(..), Gradient(..), Shadow(..))
import PrestoDOM.Utils ((<>>))
import Simple.JSON (writeJSON)
import UI.Common.Controller.Screen.PaymentsFlow.ErrorMessage (Action(..), GenericErrorState, ScreenInput, ScreenOutput, initialState, eval, overrides)
import UI.Constant.FontStyle.Default as Font
import UI.Utils (bringToFront, os)


screen :: ScreenInput -> Screen Action GenericErrorState ScreenOutput
screen input =
	{ initialState : (initialState input)
	, view
	, eval
	}



view
	:: forall w eff
	. (Action -> Effect Unit)
	-> GenericErrorState
	-> PrestoDOM (Effect Unit) w
view push state =
	relativeLayout_ (Namespace "ErrorMessage")
        ([ height MATCH_PARENT
        , width MATCH_PARENT
        , orientation VERTICAL
        , onClick push (const UserAbort)
        ] <> overrides "MainLayout" push state )
        [ linearLayout
            ([ height $ V 540
            , width MATCH_PARENT
            , orientation VERTICAL
            , gravity CENTER_HORIZONTAL
            , alignParentBottom "true,-1"
            , alpha 0.0
            , animation $ writeJSON [ errorFade "errorFadeIn" 0.0 1.0, errorFade' "errorFadeOut" 1.0 0.0 ]
            , gradient $ Linear 90.0 ["#00191B1F", "#191B1F"]
            ]) []
        , linearLayout
            [ height $ V 50
            , width MATCH_PARENT
            , orientation VERTICAL
            , margin (Margin 48 0 48 64)
            , alignParentBottom "true,-1"
            -- , translationY $ toNumber $ dpToPx 200
            , animation $ writeJSON [ errorSlide "errorSlide" 200 0, errorSlide' "errorSlideOut" 0 200 ]
            , shadow $ Shadow 2.0 10.0 27.0 (-10.0) "#0D0D0F" 1.0
            ]
            [ linearLayout
                [ height $ V 50
                , width MATCH_PARENT
                , gravity CENTER
                , orientation VERTICAL
                , cornerRadius 8.0
                , padding (Padding 40 18 40 18)
                , onClick push (const UserAbort)
                , case os of
                    "IOS" -> gradient $ Linear 0.0 ["#F47B7B", "#E35D5D"]
                    _ -> background "#E35D5D"
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
                        , imageUrl "ic_cross"
                        ]
                    , textView
                        [ height $ V 14
                        , width $ V 168
                        , letterSpacing 0.83
                        , gravity CENTER
                        , margin (Margin 10 0 0 0)
                        , text $ state ^. _error
                        , textSize 12
                        , color "#FFFFFFFF"
                        , fontStyle Font.gILROYMEDIUM
                        ]
                    ]
                ]
            ]
            , linearLayout
                ([ height $ V 14
                , width MATCH_PARENT
                , orientation VERTICAL
                , margin (Margin 0 20 0 28)
                , alignParentBottom "true,-1"
                -- , translationY $ toNumber $ dpToPx 100
                , animation $ writeJSON [ errorMsgSlide "errorMsgFade" 100 0, errorMsgSlide' "errorMsgFadeOut" 0 100 ]
                ] <>> overrides "" push state )
                [ textView
                    ([ height MATCH_PARENT
                    , width MATCH_PARENT
                    , text "Try another payment method"
                    , textSize 12
                    , letterSpacing 0.87
                    , color "#FFFFFFFF"
                    , fontStyle Font.gILROYBOLD
                    , gravity CENTER
                    ] <> overrides "" push state )
                ]
        ]
