module UI.View.Component.WalletsView where

import Prelude

import Data.Array
import Data.Lens
import Data.Maybe
import Data.Newtype
import Foreign.Object as Object
import Data.String.CodePoints as S
import Effect
import Engineering.Helpers.Types.Accessor
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
import UI.Controller.Component.WalletsView
import UI.View.Component.CardLayout as CardLayout
import UI.Helpers.SingleSelectRadio as Radio
import UI.Utils
import UI.Config as Config

view
	:: forall w
	. (Action -> Effect Unit)
	-> State
	-> Object.Object GenProp
	-> PrestoDOM (Effect Unit) w
view push state _ =
    relativeLayout
        [ height MATCH_PARENT
        , width MATCH_PARENT
        , orientation VERTICAL
        ]
        [ walletListView push state
        , linkWalletSection push state
        ]


walletListView push state@(State st) =
    let radioState = st.walletSelected
        walletList = st.walletList
        currentSelected = radioState ^. _currentSelected
        proceedImpl = overrides push state ProceedToPay
        actionImpl = overrides push state LinkButton
        sectionSelected = state ^. _sectionSelected
     in linearLayout
        [ height $ V 600
        , width MATCH_PARENT
        , orientation VERTICAL
        , visibility $ case sectionSelected of
                            WalletListSection -> VISIBLE
                            _ -> GONE
        ]
        $ Radio.singleSelectRadio
            (push <<< WalletSelected)
            radioState
            (CardLayout.view proceedImpl actionImpl)
            ( walletInfo <$> walletList )

    where
          walletInfo = \w -> { piName : w ^. _wallet
                         , offer : ""
                         , imageUrl : "ic_wallet_" <> (w ^. _wallet)
                         , actionButton : CardLayout.LinkAccount
                         }


linkWalletSection push state =
    let sectionSelected = state ^. _sectionSelected
        expandBtnImpl = overrides push state $ SectionSelectionOverride  WalletListSection
     in linearLayout
        [ height $ V 431
        , width MATCH_PARENT
        , orientation VERTICAL
        , visibility $ case sectionSelected of
                            LinkWalletSection -> VISIBLE
                            _ -> GONE
        ]
        [ expandButton { text : "Other Wallets", visibility : VISIBLE, implementation : expandBtnImpl}
        , linkWalletView push state
        ]


linkWalletView push state@(State st) =
    let radioState = st.walletSelected
        walletList = st.walletList
        currentSelected = radioState ^. _currentSelected
        piName = "JusPay" -- currentSelected ^. _wallet
     in linearLayout
        [ height $ V 321
        , width MATCH_PARENT
        , orientation VERTICAL
        , padding $ PaddingLeft 35
        , background "#FFFFFF"
        , shadow $ Shadow 0.0 2.0 4.0 1.0 "#12000000" 1.0
        ]
        [  linearLayout
            [ height $ V 66
            , width MATCH_PARENT
            ]
            [ CardLayout.piInfoView
                { imageUrl : "ic_wallets_" <> piName
                , piName : piName
                }
            ]
        , textView
            [ height $ V 16
            , width MATCH_PARENT
            , margin $ MarginTop 60
            , text $ "Proceed to link " <> piName <> " wallet with your number:"
            , textSize 14
            ]
        , textView
            [ height $ V 27
            , width MATCH_PARENT
            , margin $ MarginTop 15
            , text "9030173494"
            , textSize 24
            ]
        , buttonView
            [] -- impl
            { width : V 300
            , text : "Proceed"
            , margin : MarginTop 52
            }
        ]



expandButton config =
    linearLayout
        ([ height $ V 100
        , width MATCH_PARENT
        , orientation HORIZONTAL
        , gravity CENTER_VERTICAL
        , padding $ PaddingHorizontal 35 33
        , margin $ MarginBottom 10
        , visibility config.visibility
        , background "#FFFFFF"
        , shadow $ Shadow 0.0 2.0 4.0 1.0 "#12000000" 1.0
        ] <>> config.implementation)
        [ textView
            [ height $ V 28
            , textSize 24
            , text config.text
            , fontStyle "Arial-Regular"
            ]
        ]







