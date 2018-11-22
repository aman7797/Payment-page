module UI.View.Screen.PaymentsFlow.PaymentPage where

import Prelude
import UI.Animations

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
import UI.View.Component.AddNewCard as AddNewCard
import UI.View.Component.CardLayout as CardLayout
import UI.View.Component.BillerInfo as BillerInfo

import Validation (getCardIcon)

screen :: PaymentPageState -> Screen PaymentPageUIAction PaymentPageState PaymentPageResponse
screen ppState =
	{ initialState : ppState
	, view
	, eval
    }


view
	:: forall w
	. (PaymentPageUIAction -> Effect Unit)
	-> PaymentPageState
	-> PrestoDOM (Effect Unit) w
view push (PaymentPageState {ppInput, uiState })  =
    mainScrollView
        [ headingView
        , paymentView push uiState
        ]




headingView :: forall w. PrestoDOM (Effect Unit) w
headingView =
    linearLayout
        [ height $ V 100
        , width MATCH_PARENT
        , orientation HORIZONTAL
        , gravity CENTER_VERTICAL
        ]
        [ textView
            [ height $ V 50
            , width MATCH_PARENT
            , textSize 42
            , color "#4A4D4E"
            , text "Choose Payment Mode"
            , gravity LEFT
            ]
        ]



paymentView :: forall w. (PaymentPageUIAction  -> Effect Unit) -> UIState -> PrestoDOM (Effect Unit) w
paymentView push state =
    linearLayout
        [ height $ V 100
        , width MATCH_PARENT
        , orientation HORIZONTAL
        ]
        [ tabView push state
        , commonView push state
        , BillerInfo.view
        ]


tabView :: forall w. (PaymentPageUIAction  -> Effect Unit) -> UIState -> PrestoDOM (Effect Unit) w
tabView push state =
    linearLayout
        [ height $ V 440
        , width $ V 334
        , orientation VERTICAL
        ]
        $ tabLayout push state <$>
            [ { image : "name"
              , text : "Wallets"
              , offer : false
              , tab : Wallets
              }
            , { image : "name"
              , text : "Cards"
              , offer : false
              , tab : Cards
              }
            , { image : "name"
              , text : "NetBanking"
              , offer : false
              , tab : NetBanking
              }
            , { image : "name"
              , text : "UPI"
              , offer : false
              , tab : UPI
              }
            ]


commonView :: forall w. (PaymentPageUIAction  -> Effect Unit) -> UIState -> PrestoDOM (Effect Unit) w
commonView push state =
    relativeLayout
        [ height MATCH_PARENT
        , width $ V 334
        , weight 1.0
        , orientation VERTICAL
        , padding $ PaddingHorizontal 32 32
        ]
        [ walletsView push state
        , cardsView push state
        , netBankingView push state
        , upiView push state
        , defaultView push state
        ]


walletsView :: forall w. (PaymentPageUIAction  -> Effect Unit) -> UIState -> PrestoDOM (Effect Unit) w
walletsView push state =
    linearLayout
        [ height MATCH_PARENT
        , width MATCH_PARENT
        ]
        [ CardLayout.view push state
        ]

cardsView :: forall w. (PaymentPageUIAction  -> Effect Unit) -> UIState -> PrestoDOM (Effect Unit) w
cardsView push state =
    linearLayout
        [ height MATCH_PARENT
        , width MATCH_PARENT
        ]
        [ CardLayout.view push state
        ]

netBankingView :: forall w. (PaymentPageUIAction  -> Effect Unit) -> UIState -> PrestoDOM (Effect Unit) w
netBankingView push state =
    linearLayout
        [ height MATCH_PARENT
        , width MATCH_PARENT
        ]
        [ CardLayout.view push state
        ]

upiView :: forall w. (PaymentPageUIAction  -> Effect Unit) -> UIState -> PrestoDOM (Effect Unit) w
upiView push state =
    linearLayout
        [ height MATCH_PARENT
        , width MATCH_PARENT
        ]
        [ CardLayout.view push state
        ]

defaultView :: forall w. (PaymentPageUIAction  -> Effect Unit) -> UIState -> PrestoDOM (Effect Unit) w
defaultView push state =
    linearLayout
        [ height MATCH_PARENT
        , width MATCH_PARENT
        ]
        [ CardLayout.view push state
        ]


tabLayout
    :: forall r w
     . (PaymentPageUIAction  -> Effect Unit)
    -> UIState
    -> { image :: String
       , text :: String
       , offer :: Boolean
       , tab :: Tabs
       | r
       }
    -> PrestoDOM (Effect Unit) w
tabLayout push state value =
    linearLayout
        [ height $ V 100
        , width $ V 334
        , orientation VERTICAL
        , background $ if state.currentTab == value.tab
                           then "#e9e9e9"
                           else "#ffffff"
        , margin $ MarginBottom 10
        ]
        [ linearLayout
            [ height $ V 25
            , width MATCH_PARENT
            ]
            []
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
                []
            , textView
                [ height $ V 28
                , width $ V 133
                , weight 1.0
                , text value.text
                , textSize 24
                , color "#545758"
                ]
            ]
        ]


mainScrollView
    :: forall w
     . Array (PrestoDOM (Effect Unit) w)
    -> PrestoDOM (Effect Unit) w
mainScrollView childrens =
    linearLayout
        [ height MATCH_PARENT
        , width MATCH_PARENT
        , background "#ff0000"
        , gravity CENTER_HORIZONTAL
        ]
        [ scrollView
            [ height MATCH_PARENT
            , width $ V 1440
            , background "#00ff00"
            , gravity CENTER_HORIZONTAL
            ]
            [ linearLayout
                [ height $ V 950
                , width $ V 1440
                , background "#FAFAFA"
                , orientation VERTICAL
                , padding $ PaddingHorizontal 66 56
                ]
                childrens
            ]
        ]


