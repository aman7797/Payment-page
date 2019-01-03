module UI.Client.Idea.Helpers.BillerInfo where

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

import Engineering.Helpers.Types.Accessor
import PrestoDOM
import PrestoDOM.Core (mapDom)
import PrestoDOM.Utils ((<>>))

import Product.Types (CurrentOverlay(DebitCardOverlay), SIM(..), UPIState(..))
import Product.Types as Types
import UI.Common.Controller.Screen.PaymentsFlow.PaymentPage

import UI.Client.Idea.Helpers.CommonView
import UI.Client.Idea.Config as Config

import UI.Utils

view :: forall w. PaymentPageState -> PrestoDOM (Effect Unit) w
view state =
    let renderType = state ^. _uiState ^. _renderType
        config = Config.billerViewConfig renderType
     in linearLayout
        [ height config.height
        , width config.width
        , translationY 120.0
        , orientation config.orientation
        ]
        [ verticalView
            [ labelText "Mobile No:" $ MarginTop 0
            , contentText "9438317998" $ MarginVertical 8 40
            ]
        , weightLayout
        , verticalView
            [ labelText "Amount:" $ MarginTop 0
            , contentText "₹ 300.00" $ MarginVertical 8 40
            ]
        ]

    where
        verticalView child =
            linearLayout
                [ height $ V 72
                , width $ V 224
                , orientation VERTICAL
                ]
                child


labelText value marginVal =
    textView
        [ height $ V 26
        , width MATCH_PARENT
        , margin marginVal
        , fontStyle "Arial-Regular"
        , color "#9B9B9B"
        , gravity LEFT
        , text value
        , textSize 22
        ]

contentText value marginVal =
    textView
        [ height $ V 38
        , width MATCH_PARENT
        , margin marginVal
        , fontStyle "Arial-Regular"
        , color "#4A4D4E"
        , gravity LEFT
        , text value
        , textSize 32
        ]

