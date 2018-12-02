module UI.View.Component.BillerInfo where

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

import UI.Utils

view :: forall w. PrestoDOM (Effect Unit) w
view =
    linearLayout
        [ height $ V 184
        , width $ V 224
        , orientation VERTICAL
        ]
        [ labelText "Mobile No:" 0
        , contentText "9438317998" 8
        , labelText "Amount:" 40
        , contentText "300.00" 8
        ]


labelText value marginTop =
    textView
        [ height $ V 26
        , width MATCH_PARENT
        , margin $ MarginTop marginTop
        , fontStyle "Arial-Regular"
        , color "#9B9B9B"
        , gravity LEFT
        , text value
        , textSize 22
        ]

contentText value marginTop =
    textView
        [ height $ V 38
        , width MATCH_PARENT
        , margin $ MarginTop marginTop
        , fontStyle "Arial-Regular"
        , color "#4A4D4E"
        , gravity LEFT
        , text value
        , textSize 32
        ]

