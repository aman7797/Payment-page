module UI.View.Component.NetBankingView where

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
import UI.Controller.Component.NetBankingView
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
    linearLayout
        [ height MATCH_PARENT
        , width MATCH_PARENT
        , orientation VERTICAL
        ]
        [ savedCardsView push state
        ]


savedCardsView push state@(State st) =
    let radioState = st.nbSelected
        netBankList = st.netBankList
        currentSelected = radioState ^. _currentSelected
        proceedImpl = overrides push state ProceedToPay
        lists = if length netBankList < 6 then netBankList else take 5 netBankList
     in linearLayout
        [ height $ V 600
        , width MATCH_PARENT
        , orientation VERTICAL
        ]
        $ Radio.singleSelectRadio
            (push <<< NetBankSelected)
            radioState
            (CardLayout.view proceedImpl (\_ -> []))
            ( nbInfo <$> lists )

    where
          nbInfo = \bankAcc -> { piName : bankAcc ^. _bankName
                         , offer : ""
                         , imageUrl : baseUrl <> "ic_bank_" <> (bankAcc ^. _iin)
                         , actionButton : CardLayout.DefaultAction
                         , balance : Nothing
                         }
          baseUrl = "https://d2pv62lkmtdxww.cloudfront.net/banks/Images/"


expandButton config =
    linearLayout
        ([ height $ V 120
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







