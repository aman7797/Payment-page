module UI.Client.Idea.Helpers.TabLayout where

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
import UI.Client.Idea.Config as Config
import UI.Utils



view
    :: forall r w
     . RenderType
    -> RadioSelected
    -> Int
    -> { image :: String
       , text :: String
       , offer :: Boolean
       , tab :: PaymentSection
       , imageUrl :: String
       | r
       }
    -> PrestoDOM (Effect Unit) w
view renderType selected currIndex value =
    let config = Config.tabSelectionTheme renderType selected currIndex
     in linearLayout
        [ height $ V 100
        , width $ V 300
        , orientation VERTICAL
        , margin $ MarginBottom 10
        , shadow $ Shadow 0.0 2.0 4.0 1.0 "#12000000" 1.0
        , background config.background
        ]
        [ linearLayout
            [ height $ V 25
            , width MATCH_PARENT
            , visibility $ if value.offer
                              then VISIBLE
                              else INVISIBLE
            , orientation HORIZONTAL
            ]
            [ imageView
                [ height $ V 10
                , width $ V 21
                , margin $ MarginTop 10
                , imageUrl "offer_banner"
                ]
            , textView
                [ height $ V 12
                , width $ V 34
                , text "OFFER"
                , textSize 10
                , fontStyle "Arial-Regular"
                , margin $ Margin 5 10 0 0
                , color "#E60000"
                ]
            ]
        , linearLayout
            [ height $ V 50
            , width MATCH_PARENT
            , orientation HORIZONTAL
            , padding $ PaddingLeft 30
            , gravity $ CENTER_VERTICAL
            ]
            [ linearLayout
                [ height $ V 30
                , width $ V 40
                , gravity CENTER
                ]
                [ imageView
                    [ height MATCH_PARENT
                    , width MATCH_PARENT
                    , gravity CENTER
                    , imageUrl value.imageUrl
                    ]
                ]
            , textView
                [ height $ V 28
                , width $ V 294
                {-- , weight 1.0 --}
                , margin $ MarginLeft 30
                , fontStyle "Arial-Regular"
                , text value.text
                , textSize 24
                , color "#545758"
                ]
            ]
        ]



