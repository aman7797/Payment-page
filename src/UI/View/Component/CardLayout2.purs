module UI.View.Component.CardLayout2 where

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
import UI.Helpers.SingleSelectRadio (RadioSelected(..))
import UI.Helpers.CommonView

import UI.Config as Config
import UI.Utils

view
    :: forall r w
     . Props (Effect Unit)
    -> RadioSelected
    -> Int
    -> { cardName :: String
       , cardNumber :: String
       , expiryDate :: String
       , offer :: String
       , imageUrl :: String
       | r
       }
    -> PrestoDOM (Effect Unit) w
view proceedImpl selected currIndex value =
    let config = logAny $ Config.cardSelectionTheme selected currIndex
     in mainView config
            [ linearLayout
                [ height MATCH_PARENT
                , width MATCH_PARENT
                , orientation HORIZONTAL
                , gravity CENTER_VERTICAL
                ]
                [ radioButton config
                , iconView value
                , detailsView value
                , otherDetailsView value
                , actionView value
                ]
            , expandedView proceedImpl config
            ]

radioButton config =
    linearLayout
        [ height $ V 20
        , width $ V 20
        , gravity CENTER
        ]
        [ linearLayout
            [ height $ MATCH_PARENT
            , width $ MATCH_PARENT
            , stroke "2,#80979797"
            , cornerRadius 50.0
            , gravity CENTER
            ]
            [ linearLayout
                [ height $ V 10
                , width $ V 10
                , background config.background
                , cornerRadius 50.0
                , gravity CENTER
                ]
                []
            ]
        ]

iconView value =
    linearLayout
        [ height $ V 60
        , width $ V 100
        , orientation VERTICAL
        , padding $ Padding 24 24 24 0
        , gravity CENTER_HORIZONTAL
        ]
        [ imageView
            [ height $ V 50
            , width $ V 50
            , background "#ff0000"
            , gravity CENTER
            ]
        {-- , textView --}
        {--     [ height $ V 17 --}
        {--     , width MATCH_PARENT --}
        {--     , text value.piName --}
        {--     , fontStyle "Arial-Regular" --}
        {--     , textSize 14 --}
        {--     , color "#545758" --}
        {--     , gravity CENTER --}
        {--     ] --}
        ]

detailsView value =
    linearLayout
        [ height $ V 44
        , width $ V 150
        , weight 1.0
        , orientation VERTICAL
        {-- , gravity CENTER_HORIZONTAL --}
        ]
        [ textView
            [ height $ V 18
            , width MATCH_PARENT
            , text value.cardName
            , fontStyle "Arial-Regular"
            , textSize 16
            , color "#363636"
            {-- , gravity CENTER --}
            ]
        , textView
            [ height $ V 23
            , width MATCH_PARENT
            , text value.cardNumber
            , fontStyle "Arial-Regular"
            , textSize 20
            , color "#363636"
            {-- , gravity CENTER --}
            ]
        ]

otherDetailsView value =
    linearLayout
        [ height $ V 47
        , width $ V 56
        , orientation VERTICAL
        {-- , gravity CENTER_HORIZONTAL --}
        ]
        [ textView
            [ height $ V 21
            , width MATCH_PARENT
            , text "Expiry"
            , fontStyle "Arial-Regular"
            , textSize 18
            , color "#9B9B9B"
            {-- , gravity CENTER --}
            ]
        , textView
            [ height $ V 25
            , width MATCH_PARENT
            , text value.expiryDate
            , fontStyle "Arial-Regular"
            , textSize 22
            , color "#363636"
            {-- , gravity CENTER --}
            ]
        ]

actionView value =
    linearLayout
        [ height $ V 20
        , width $ V 12
        , margin $ MarginRight 30
        , gravity CENTER
        ]
        [ imageView
            [ height MATCH_PARENT
            , width MATCH_PARENT
            , gravity CENTER
            , imageUrl value.imageUrl
            ]
        ]

expandedView impl config =
    linearLayout
        [ height $ V 101
        , width MATCH_PARENT
        , visibility config.visibility
        ]
        [ buttonView
            impl
            { width : V 300
            , text : "Pay Securely"
            , margin : MarginTop 10
            }
        ]

mainView config child =
    linearLayout
        [ height config.height
        , width MATCH_PARENT
        , orientation VERTICAL
        , shadow $ Shadow 0.0 2.0 4.0 1.0 "#12000000" 1.0
        , background "#ffffff"
        , padding $ PaddingLeft 35
        , margin $ MarginBottom 10
        ]
        child

