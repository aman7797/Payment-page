module UI.View.Component.Button where

import Effect (Effect)
import Prelude
import PrestoDOM
import PrestoDOM.Properties.GetChildProps
import PrestoDOM.Types.DomAttributes
import Foreign.Object as Object
import Data.Maybe (Maybe(..))
import Simple.JSON (writeJSON)
import UI.Animations (slideMaView1)
import UI.Constant.Accessibility.Default as HINT
import UI.Constant.Color.Default as Color
import UI.Constant.FontColor.Default as FontColor
import UI.Constant.FontSize.Default as FontSize
import UI.Constant.FontStyle.Default as Font
import UI.Constant.Str.Default as STR
import UI.Controller.Component.Button (Action, State, overrides)

t_btnText :: forall t1. Object.Object GenProp -> Prop t1
t_btnText = override_p "t_btnText" STR.buttonText6

view
	:: forall w
	. (Action -> Effect Unit)
	-> State
	-> Object.Object GenProp
	-> PrestoDOM (Effect Unit) w
view push state parent =
	linearLayout
		([ height_p (V 46) parent
		, width_p MATCH_PARENT parent
		, orientation_p HORIZONTAL parent
		, gravity_p CENTER_VERTICAL parent
		, background_p Color.a_FF4353B2 parent
		, stroke_p "1,#FF4354B3" parent
		, cornerRadius_p 6.00 parent
		, root_p true parent
		, margin_p (Margin 0 0 0 0) parent
		, visibility_p VISIBLE parent
		, animation $ writeJSON $ [ slideMaView1 (case Object.lookup "t_teg" parent of
													Just (TextP a) ->  a <> "slydIn"
													_ -> "something"
												)  (-100) 0 ]
		] <> (overrides "ButtonGroup" push state))
		[ 
			textView
			([ height $ V 16
			, width MATCH_PARENT
			, letterSpacing 0.86
			, t_btnText parent
			, textSize FontSize.a_14
			, color_p FontColor.a_FFFFFFFF parent
			, fontStyle Font.gILROYBOLD
			, gravity CENTER
			] <> overrides "ButtonText" push state )
		]

