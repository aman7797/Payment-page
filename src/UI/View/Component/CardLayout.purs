module UI.View.Component.CardLayout where

import Prelude

import Data.Array
import Data.Lens
import Data.Maybe
import Data.Newtype
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
import UI.Controller.Screen.PaymentsFlow.PaymentPage

import UI.Utils

view :: forall w. (PaymentPageUIAction  -> Effect Unit) -> UIState -> PrestoDOM (Effect Unit) w
view push state =
    linearLayout
        [ height $ V 120
        , width MATCH_PARENT
        , orientation HORIZONTAL
        , gravity CENTER_VERTICAL
        , shadow $ Shadow 0.0 2.0 4.0 1.0 "#12000000" 1.0
        , background "#ffffff"
        , margin $ MarginBottom 10
        ]
        [ piInfoView
        , offerView
        , nextView
        ]


piInfoView =
    linearLayout
        [ height $ V 120
        , width $ V 140
        , orientation VERTICAL
        , padding $ Padding 24 24 24 0
        , gravity CENTER_HORIZONTAL
        ]
        [ imageView
            [ height $ V 68
            , width MATCH_PARENT
            , background "#ff0000"
            , gravity CENTER
            ]
        , textView
            [ height $ V 17
            , width MATCH_PARENT
            , text "Amazon Pay"
            , fontStyle "Arial-Regular"
            , textSize 14
            , color "#545758"
            , gravity CENTER
            ]
        ]

offerView =
    linearLayout
        [ height $ V 18
        , width $ V 150
        , weight 1.0
        , orientation VERTICAL
        , gravity CENTER_HORIZONTAL
        ]
        [ textView
            [ height $ V 18
            , width MATCH_PARENT
            , weight 1.0
            , text "Rs 10 cash back"
            , fontStyle "Arial-Regular"
            , textSize 16
            , color "#E60000"
            , gravity CENTER
            ]
        ]

nextView =
    linearLayout
        [ height $ V 20
        , width $ V 12
        , margin $ MarginRight 30
        , gravity CENTER
        ]
        [ imageView
            [ height MATCH_PARENT
            , width MATCH_PARENT
            , background "#ff0000"
            , gravity CENTER
            ]
        ]

