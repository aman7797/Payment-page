module UI.Idea.View.Screen.PaymentsFlow.GenericError where

import Data.Lens ((^.))
import Effect (Effect)
import Engineering.Helpers.Types.Accessor (_button1State)
import Prelude
import PrestoDOM (Namespace(..), PrestoDOM, Screen, background, clickable, color, cornerRadius, fontStyle, gravity, height, imageUrl, imageView, letterSpacing, lineHeight, linearLayout, linearLayout_, margin, onClick, orientation, padding, root, text, textSize, textView, translationZ, weight, width)
import PrestoDOM.Core (mapDom)
import PrestoDOM.Properties.SetChildProps (height_c, margin_c, override_c, width_c)
import PrestoDOM.Types.DomAttributes (Gravity(..), Length(..), Margin(..), Orientation(..), Padding(..))
import UI.Constant.FontStyle.Default as Font
import UI.Constant.Str.Default as STR
import UI.Common.Controller.Screen.PaymentsFlow.GenericError (Action(..), GenericErrorState, ScreenInput, ScreenOutput, initialState, eval, overrides)
import UI.Utils (bringToFront)


screen :: ScreenInput -> Screen Action GenericErrorState ScreenOutput
screen input =
	{ initialState : (initialState input)
	, view
	, eval
	}



view
	:: forall w
	. (Action -> Effect Unit)
	-> GenericErrorState
	-> PrestoDOM (Effect Unit) w
view push state =
	linearLayout_ (Namespace "GenericError")
		([ height MATCH_PARENT
		, width MATCH_PARENT
		, orientation VERTICAL
		, translationZ 200.0
        , bringToFront true
		, cornerRadius 0.00
		, root true
		] <> overrides "MainLayout" push state )
		[ linearLayout
			([ height $ V 0
        , width MATCH_PARENT
        , background "#B2000000"
        , weight 1.0
        , clickable true
        , onClick push (const UserAbort)
			] <> overrides "Space" push state )
			[]
		, linearLayout
			([ height $ V 311
			, width MATCH_PARENT
			, orientation VERTICAL
			, padding (Padding 30 30 30 30)
			, background "#FFFFFFFF"
			, cornerRadius 0.00
      , clickable true
			] <> overrides "ErrorOverlayGroup" push state )
			[ imageView
				([ height $ V 94
				, width $ V 108
				, margin (MarginRight 192)
				, imageUrl "webfailed"
				] <> overrides "IcError" push state )
			, textView
				([ height $ V 17
				, width MATCH_PARENT
				, margin (MarginTop 30)
				, letterSpacing 0.58
				, text STR.errorTitleText5
				, textSize 14
				, color "#FF000000"
				, fontStyle Font.gILROYSEMIBOLD
				, gravity LEFT
				] <> overrides "ErrorTitleText" push state )
			, textView
				([ height $ V 22
				, width MATCH_PARENT
				, margin (MarginTop 12)
				, letterSpacing 0.46
				, text STR.errorHelpText6
				, textSize 13
				, color "#FF919BAC"
				, fontStyle Font.gILROYREGULAR
				, lineHeight "22px"
				, gravity LEFT
				] <> overrides "ErrorHelpText" push state )
			{-- , (Button.view (push <<< Button1Action ) (state ^. _button1State) --}
                {-- {  width : V 204 --}
			{-- 	, margin : MarginTop 30 --}
			{-- 	, text : "RETRY WITH DEBIT CARD" --}
                {-- }) --}
			]
		]

