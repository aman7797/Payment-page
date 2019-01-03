module UI.Client.Idea.Helpers.CardLayout where

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
import UI.Common.Controller.Screen.PaymentsFlow.PaymentPage
import UI.Common.Helpers.SingleSelectRadio (RadioSelected(..))
import UI.Client.Idea.Helpers.CommonView

import UI.Client.Idea.Config as Config
import UI.Utils

data ActionButton
    = LinkAccount
    | DeleteAccount
    | DefaultAction

view
    :: forall r w
     . Props (Effect Unit)
    -> (Int -> Props (Effect Unit))
    -> RadioSelected
    -> Int
    -> { piName :: String
       , offer :: String
       , imageUrl :: String
       , actionButton :: ActionButton
       , balance :: Maybe Number
       | r
       }
    -> PrestoDOM (Effect Unit) w
view proceedImpl actionImplFn selected currIndex value =
    let expandable = case value.actionButton of
                          LinkAccount -> Config.NonExpandable
                          _ -> Config.Expandable
        config = Config.cardSelectionTheme expandable selected currIndex
     in mainView value config
            [ linearLayout
                [ height MATCH_PARENT
                , width MATCH_PARENT
                , orientation HORIZONTAL
                , gravity CENTER_VERTICAL
                ]
                [ radioButton config
                , piInfoView value
                , offerView value
                , detailsView value
                , actionView (actionImplFn currIndex) value
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


piInfoView
    :: forall w r
     . { imageUrl :: String
       , piName :: String
       | r
       }
    -> PrestoDOM (Effect Unit) w
piInfoView value =
    linearLayout
        [ height MATCH_PARENT
        , width $ V 540
        , orientation HORIZONTAL
        , padding $ Padding 24 24 24 0
        , gravity CENTER_HORIZONTAL
        , margin $ MarginTop 11
        ]
        [ imageView
            [ height $ V 46
            , width $ V 96
            , gravity CENTER
            , imageUrl value.imageUrl
            , margin $ Margin 7 0 7 7
            ]
        , textView
            [ height $ V 24
            , width MATCH_PARENT
            , text value.piName
            {-- , margin $ MarginTop 5 --}
            , fontStyle "Arial-Regular"
            , textSize 20
            , color "#545758"
            , gravity LEFT
            , margin $ Margin 20 10 0 0
            ]
        ]

offerView value =
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
            , text value.offer
            , fontStyle "Arial-Regular"
            , textSize 16
            , color "#E60000"
            , gravity CENTER
            ]
        ]

detailsView value =
    linearLayout
        [ height $ V 47
        , width $ V 101
        , orientation VERTICAL
        , visibility $ case value.actionButton of
                            DeleteAccount -> VISIBLE
                            _ -> GONE
        ]
        [ textView
            [ height $ V 21
            , width MATCH_PARENT
            , text "Balance"
            , fontStyle "Arial-Regular"
            , textSize 16
            , color "#9B9B9B"
            , gravity CENTER
            ]
        , textView
            [ height $ V 26
            , width MATCH_PARENT
            , text $ case value.balance of
                          Just b -> "₹ " <> show b
                          Nothing -> "Fetching"
            , fontStyle "Arial-Regular"
            , textSize 22
            , color "#545758"
            , gravity CENTER
            ]
        ]


actionView actionImpl value =
    case value.actionButton of
         LinkAccount ->
             linearLayout
                ([ height $ V 38
                , width $ V 58
                , margin $ MarginHorizontal 60 25
                , gravity CENTER
                ] <>> actionImpl)
                [ textView
                    [ height $ V 18
                    , width MATCH_PARENT
                    , gravity CENTER
                    , text "LINK"
                    , fontStyle "Arial-Bold"
                    , textSize 16
                    , color "#1BB3E8"
                    ]
                ]

         DeleteAccount ->
            linearLayout
                [ height $ V 24
                , width $ V 26
                , margin $ MarginHorizontal 35 35
                , gravity CENTER
                ]
                [ imageView
                    [ height MATCH_PARENT
                    , width MATCH_PARENT
                    , gravity CENTER
                    , imageUrl "ic_delete"
                    ]
                ]

         DefaultAction ->
             linearLayout
                ([ height $ V 26
                , width $ V 26
                , margin $ MarginHorizontal 35 35
                , gravity CENTER
                ] <>> actionImpl)
                []


expandedView impl config =
    linearLayout
        [ height $ V 101
        , width MATCH_PARENT
        , clickable false
        , visibility config.visibility
        , clickable false
        ]
        [ buttonView
            impl
            { width : V 300
            , text : "Pay Securely"
            , margin : MarginTop 10
            }
        ]

mainView value config child =
    linearLayout
        [ height config.height
        , width MATCH_PARENT
        , orientation VERTICAL
        , shadow $ Shadow 0.0 2.0 4.0 1.0 "#12000000" 1.0
        , background "#ffffff"
        , padding $ PaddingLeft 35
        , margin $ MarginBottom 10
        , clickable $ case value.actionButton of
                           LinkAccount -> false
                           _ -> true
        ]
        child

