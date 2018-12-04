module UI.Helpers.CommonView where

import Effect (Effect)
import Prelude
import PrestoDOM
import PrestoDOM.Properties.GetChildProps
import PrestoDOM.Types.DomAttributes
import PrestoDOM.Utils ((<>>))
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
import UI.Utils


buttonView
	:: forall w
	.  Props (Effect Unit)
    -> { width :: Length
       , margin :: Margin
       , text :: String
       }
	-> PrestoDOM (Effect Unit) w
buttonView implementation props =
    linearLayout
        ([ height $ V 60
        , width props.width
        , orientation HORIZONTAL
        , gravity CENTER
        , margin props.margin
        , background "#1BB3E8"
        , cornerRadius 8.0
        ] <>> implementation)
        [ textView
            [ height $ V 22
            , width MATCH_PARENT
            , gravity CENTER
            , text props.text
            , textSize 20
            , color "#ffffff"
            ]
        ]


headingView
    :: forall w
     . { text :: String
       }
    -> PrestoDOM (Effect Unit) w
headingView props =
    linearLayout
        [ height $ V 33
        , width $ V 200
        , orientation HORIZONTAL
        ]
        [ textView
            [ height MATCH_PARENT
            , width MATCH_PARENT
            , text props.text
            , fontStyle "Arial-Regular"
            , textSize 24
            , color "#363636"
            ]
        ]


editField
    :: forall w
     . Props (Effect Unit)
    -> { hint :: String
       , width :: Length
       , weight :: Number
       , margin :: Margin
       }
    -> PrestoDOM (Effect Unit) w
editField implementation value =
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




