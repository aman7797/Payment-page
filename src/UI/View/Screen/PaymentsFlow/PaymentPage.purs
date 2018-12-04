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

import Engineering.Helpers.Types.Accessor
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
import UI.View.Component.UpiView as UpiView

import UI.Helpers.SingleSelectRadio as Radio

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
view push ppState  =
    mainScrollView push
        [ headingView
        , paymentPageView push ppState
        , poweredByView
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
            , textSize 40
            , color "#4A4D4E"
            , fontStyle "Arial-Regular"
            , text "Choose Payment Mode"
            , gravity LEFT
            ]
        ]



paymentPageView :: forall w. (PaymentPageUIAction  -> Effect Unit) -> PaymentPageState -> PrestoDOM (Effect Unit) w
paymentPageView push state =
    linearLayout
        [ height $ V 440
        , weight 1.0
        , width MATCH_PARENT
        , orientation HORIZONTAL
        ]
        [ paymentView push state
        , BillerInfo.view
        ]

paymentView :: forall w. (PaymentPageUIAction  -> Effect Unit) -> PaymentPageState -> PrestoDOM (Effect Unit) w
paymentView push state =
    linearLayout
        [ height $ V 440
        , weight 1.0
        , width $ V 860
        , orientation HORIZONTAL
        ]
        [ tabView push state
        , commonView push state
        ]



tabView :: forall w. (PaymentPageUIAction  -> Effect Unit) -> PaymentPageState -> PrestoDOM (Effect Unit) w
tabView push state =
    let radioState = state ^. _uiState ^. _sectionSelected
     in linearLayout
        [ height $ V 440
        , width $ V 334
        , orientation VERTICAL
        ]
        $ Radio.singleSelectRadio (push <<< SectionSelected) radioState tabLayout tabSelectionTheme
            [ { image : "name"
              , text : "Wallets"
              , offer : false
              , tab : Wallets
              , imageUrl : "tab_wallets"
              }
            , { image : "name"
              , text : "Cards"
              , offer : false
              , tab : Cards
              , imageUrl : "tab_cards"
              }
            , { image : "name"
              , text : "NetBanking"
              , offer : false
              , tab : NetBanking
              , imageUrl : "tab_net_banking"
              }
            , { image : "name"
              , text : "UPI"
              , offer : false
              , tab : UPI
              , imageUrl : "tab_upi"
              }
            ]


commonView :: forall w. (PaymentPageUIAction  -> Effect Unit) -> PaymentPageState -> PrestoDOM (Effect Unit) w
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


walletsView :: forall w. (PaymentPageUIAction  -> Effect Unit) -> PaymentPageState -> PrestoDOM (Effect Unit) w
walletsView push state =
    let implementation = overrides push state
     in linearLayout
        ([ height MATCH_PARENT
        , width MATCH_PARENT
        , orientation VERTICAL
        ] <>> implementation (SectionOverride Wallets))
        [ CardLayout.view push $ state ^. _uiState
        , CardLayout.view push $ state ^. _uiState
        ]

cardsView :: forall w. (PaymentPageUIAction  -> Effect Unit) -> PaymentPageState -> PrestoDOM (Effect Unit) w
cardsView push state =
    let addNewCardState = state ^. (_uiState <<< _addNewCardState)
        implementation = overrides push state
     in linearLayout
        ([ height MATCH_PARENT
        , width MATCH_PARENT
        , orientation VERTICAL
        ] <>> implementation (SectionOverride Cards))
        [ mapDom AddNewCard.view push addNewCardState AddNewCardAction []
        ]

netBankingView :: forall w. (PaymentPageUIAction  -> Effect Unit) -> PaymentPageState -> PrestoDOM (Effect Unit) w
netBankingView push state =
    let implementation = overrides push state
     in linearLayout
        ([ height MATCH_PARENT
        , width MATCH_PARENT
        , orientation VERTICAL
        ] <>> implementation (SectionOverride NetBanking))
        [ CardLayout.view push $ state ^. _uiState
        ]

upiView :: forall w. (PaymentPageUIAction  -> Effect Unit) -> PaymentPageState -> PrestoDOM (Effect Unit) w
upiView push state =
    let implementation = overrides push state
        upiState = state ^. _uiState ^. _upiViewState
     in linearLayout
        ([ height MATCH_PARENT
        , width MATCH_PARENT
        , orientation VERTICAL
        ] <>> implementation (SectionOverride UPI))
        [ mapDom UpiView.view push upiState UpiViewAction []
        ]

defaultView :: forall w. (PaymentPageUIAction  -> Effect Unit) -> PaymentPageState -> PrestoDOM (Effect Unit) w
defaultView push state =
    let implementation = overrides push state
     in linearLayout
        ([ height MATCH_PARENT
        , width MATCH_PARENT
        , orientation VERTICAL
        ] <>> implementation (SectionOverride DefaultSection))
        [ CardLayout.view push $ state ^. _uiState
        ]



tabLayout
    :: forall r w
     . { image :: String
       , text :: String
       , offer :: Boolean
       , tab :: PaymentSection
       , imageUrl :: String
       | r
       }
    -> Props (Effect Unit)
    -> PrestoDOM (Effect Unit) w
tabLayout value selectionTheme =
     linearLayout
        ([ height $ V 100
        , width $ V 334
        , orientation VERTICAL
        , margin $ MarginBottom 10
        , shadow $ Shadow 0.0 2.0 4.0 1.0 "#12000000" 1.0
        ] <>> selectionTheme)
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
                , width $ V 133
                , weight 1.0
                , margin $ MarginLeft 30
                , fontStyle "Arial-Regular"
                , text value.text
                , textSize 24
                , color "#545758"
                ]
            ]
        ]



mainScrollView
    :: forall w
     . (PaymentPageUIAction  -> Effect Unit)
    -> Array (PrestoDOM (Effect Unit) w)
    -> PrestoDOM (Effect Unit) w
mainScrollView push children =
    linearLayout
        [ height MATCH_PARENT
        , width MATCH_PARENT
        {-- , background "#ff0000" --}
        , gravity CENTER_HORIZONTAL
        , onResize push (const Resized)
        ]
        [ scrollView
            [ height MATCH_PARENT
            {-- , width $ V 1440 --}
            , width MATCH_PARENT
            {-- , background "#00ff00" --}
            , gravity CENTER_HORIZONTAL
            ]
            [ linearLayout
                [ height $ V 950
                {-- , width $ V 1440 --}
                , width MATCH_PARENT
                , background "#FAFAFA"
                , orientation VERTICAL
                , padding $ PaddingHorizontal 66 56
                ]
                children
            ]
        ]


poweredByView =
    linearLayout
        [ height $ V 150
        {-- , width $ V 1325 --}
        , width MATCH_PARENT
        , orientation HORIZONTAL
        , margin $ MarginTop 40
        , gravity CENTER_VERTICAL
        ]
        ([ textView
            [ height $ V 18
            , width $ V 96
            , textSize 16
            , fontStyle "Arial-Regular"
            , text "Powered by:"
            , color "#9B9B9B"
            ]
        ]
        <> ((\img ->
                imageView
                    [ height $ V 50
                    , width $ V 150
                    , gravity CENTER
                    , margin $ Margin 30 50 0 50
                    , weight 1.0
                    , imageUrl img
                    ]
            ) <$> [ "p_norton", "p_visa", "p_master_card", "p_pci", "p_amex", "p_npci", "p_creator"]
            )
        )


