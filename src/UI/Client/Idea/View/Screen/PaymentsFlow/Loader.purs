module UI.Client.Idea.View.Screen.PaymentsFlow.Loader where


import Effect (Effect)
import Prelude
import PrestoDOM (Gravity(..), Length(..), Margin(..), Namespace(..), Orientation(..), Padding(..), PrestoDOM, Screen, background, clickable, color, cornerRadius, fontStyle, gravity, height, lineHeight, linearLayout, linearLayout_, margin, orientation, padding, progressBar, root, text, textSize, textView, translationZ, width)
import Data.Semigroup ((<>))
import PrestoDOM (Gravity(..), Length(..), Margin(..), Namespace(..), Orientation(..), Padding(..), PrestoDOM, Screen, background, clickable, color, cornerRadius, fontStyle, gravity, height, lineHeight, linearLayout, relativeLayout, linearLayout_, margin, orientation, padding, progressBar, root, text, textSize, textView, translationZ, width, id)
import UI.Constant.FontStyle.Default (gILROYMEDIUM)
import UI.Common.Controller.Screen.PaymentsFlow.Loader (Action, ScreenOutput, State, eval, initialState, overrides)
import UI.Utils (bringToFront, os)

screen :: State -> Screen Action State ScreenOutput
screen input =
  { initialState : initialState input
  , view
  , eval
  }

view
	:: forall w
	. (Action -> Effect Unit)
	-> State
	-> PrestoDOM (Effect Unit) w
view push state =
	linearLayout_ (Namespace "LoadingScreen")
		([ height MATCH_PARENT
		, width MATCH_PARENT
		, orientation HORIZONTAL
		, gravity CENTER
        , translationZ 200.0
        , bringToFront true
		, root true
		, clickable true
		] <> overrides "MainContent" push state )
        if state.customLoader then
            [ relativeLayout
                ([ height MATCH_PARENT
                , width MATCH_PARENT
                , id state.parentId
                , gravity CENTER
                ])
                if os == "IOS" then
                [
                    progressBar
                    ([ height MATCH_PARENT
                    , width MATCH_PARENT
                    ] <> overrides "ProgressBar" push state )
                ]
                else
                []
            ]
        else
            [
                linearLayout
                ([ height (V 150)
                , width (V 304)
                , orientation VERTICAL
                , gravity CENTER_HORIZONTAL
                , padding (Padding 14 41 14 0)
                , background "#FFFFFFFF"
                , cornerRadius 6.0
                , root true
                , margin (Margin 0 0 0 0)
                ] <> (overrides "Dialog" push state))
                [ progressBar
                    ([ height $ V 34
                    , width $ V 34
                    , margin (Margin 121 0 121 0)
                    ] <> overrides "ProgressBar" push state )
                , textView
                    ([ height $ V 17
                    , width MATCH_PARENT
                    , margin (Margin 0 5 0 0)
                    , textSize 14
                    , color "#FF898989"
                    , lineHeight "15px"
                    , gravity CENTER
                    , text "Processing"
                    , fontStyle gILROYMEDIUM
                    ] <> overrides "Progress Text" push state )
                ]
            ]
