module UI.Idea.View.Component.UpiView where

import Prelude

import Data.Array
import Data.Lens
import Data.Maybe
import Data.Newtype
import Foreign.Object as Object
import Data.String.CodePoints as S
import Effect
import Data.Int
import Data.Lens
import Engineering.Helpers.Commons
import Engineering.Helpers.Events

import PrestoDOM
import PrestoDOM.Core (mapDom)
import PrestoDOM.Utils ((<>>))

import Product.Types (CurrentOverlay(DebitCardOverlay), SIM(..), UPIState(..))
import Product.Types as Types
import UI.Constant.Color.Default as Color
import UI.Constant.FontColor.Default as FontColor
import UI.Constant.FontSize.Default as FontSize
import UI.Constant.FontStyle.Default as Font
import UI.Constant.FontStyle.Default as FontStyle
import UI.Constant.Str.Default as STR
import UI.Constant.Type (FontColor, FontStyle)

import UI.Helpers.CommonView
import UI.Controller.Component.UpiView

import UI.Utils

view
	:: forall w
	. (Action -> Effect Unit)
	-> State
	-> Object.Object GenProp
	-> PrestoDOM (Effect Unit) w
view push state _ =
    linearLayout
        [ height $ V 430
        , width MATCH_PARENT
        , orientation VERTICAL
        , padding $ Padding 30 22 30 0
        , shadow $ Shadow 0.0 2.0 4.0 1.0 "#12000000" 1.0
        , background "#FFFFFF"
        ]
        [ headingView {text : "Enter your VPA"}
        , editField (overrides push state UPIeditOverride)
            { hint : "123456@UPI"
            , width: MATCH_PARENT
            , weight : 0.0
            , margin : MarginTop 30
            , inputType : TypeText
            }
        , infoView
        , buttonView (overrides push state ProceedToPay)
            { width : V 300
            , margin : MarginTop 30
            , text : "Pay Securely"
            }
        ]


infoView =
    linearLayout
        [ height $ V 140
        , width MATCH_PARENT
        , orientation VERTICAL
        , padding $ Padding 20 10 20 0
        , margin $ MarginTop 24
        , background "#FAFAFA"
        ]
        ([ contentText
            { text : "Complete your online payment please follow the steps below:"
            , margin : MarginTop 0
            , height : V 21
            , textSize : 18
            }
        ]
        <> ( contentText <$> [ { text : "• Login into your PSP(@UPI) application."
                              , margin : MarginTop 24
                              , height : V 17
                              , textSize : 14
                              }
                            , { text : "• You will receive a collect request from indiaideas@icici"
                              , margin : MarginTop 5
                              , height : V 17
                              , textSize : 14
                              }
                            , { text : "• Authorise payment"
                              , margin : MarginTop 5
                              , height : V 17
                              , textSize : 14
                              }
                            ]
            )
        )



contentText value =
    textView
        [ height value.height
        , width MATCH_PARENT
        , margin value.margin
        , color "#333333"
        , fontStyle "Arial-Regular"
        , gravity LEFT
        , text value.text
        , textSize value.textSize
        ]


