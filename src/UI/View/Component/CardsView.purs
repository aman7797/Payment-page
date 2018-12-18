module UI.View.Component.CardsView where

import Prelude

import Data.Array
import Data.Lens
import Data.Maybe
import Data.Newtype
import Data.String.CodePoints as String
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
import UI.Controller.Component.CardsView

import UI.View.Component.CardLayout2 as CardLayout2
import UI.Helpers.SingleSelectRadio as Radio
import UI.View.Component.AddNewCard as AddNewCard
import UI.Utils
import Validation

view
	:: forall w
	. (Action -> Effect Unit)
	-> State
	-> Object.Object GenProp
	-> PrestoDOM (Effect Unit) w
view push state _ =
    let addNewCardState = state ^. _addNewCardState
        implementation = overrides push state
        sectionSelected = state ^. _sectionSelected
        storedCards = state ^. _storedCards
        storedCardsNull = null storedCards
     in linearLayout
        [ height MATCH_PARENT
        , width MATCH_PARENT
        , orientation VERTICAL
        ]
        [ expandButton
            { implementation : implementation $ SectionSelectionOverride SavedCard
            , text : "Saved Cards"
            , visibility : case storedCardsNull, sectionSelected of
                                false, AddNewCard -> VISIBLE
                                _, _ -> GONE
            }
        , savedCardsView push state
            { visibility : case sectionSelected of
                                SavedCard -> VISIBLE
                                _ -> GONE
            }
        , expandButton
            { implementation : implementation $ SectionSelectionOverride AddNewCard
            , text : "Add New Cards"
            , visibility : case sectionSelected of
                                SavedCard -> VISIBLE
                                _ -> GONE
            }
        , AddNewCard.view (push <<< AddNewCardAction) addNewCardState
            { visibility : case sectionSelected of
                                AddNewCard -> VISIBLE
                                _ -> GONE
            }
        ]


savedCardsView push state value =
    let radioState = state ^. _savedCardSelected
        currentSelected = radioState ^. _currentSelected
        proceedImpl = overrides push state ProceedToPay
        cvvImpl = overrides push state CvvEditField
        storedCards = state ^. _storedCards
        storedCardLength = (length storedCards)
        unselectedHeight = 120 * storedCardLength
        savedCardHeight = case currentSelected of
                               Radio.NothingSelected -> V $ unselectedHeight + 10
                               _ -> V $ unselectedHeight + 250
     in linearLayout
        [ height savedCardHeight
        , width MATCH_PARENT
        , orientation VERTICAL
        , visibility value.visibility
        {-- , margin $ MarginBottom 10 --}
        ]
        $ Radio.singleSelectRadio
            (push <<< SavedCardSelected)
            radioState
            (CardLayout2.view proceedImpl cvvImpl)
            ( storedCardInfo <$> storedCards)

    where
          storedCardInfo card =
              { cardName : card ^. _cardBrand <> " " <> card ^. _cardType <> " " <> card ^. _cardIssuer
              , cardNumber : card ^. _cardNumber
              , expiryDate : card ^. _cardExpMonth <> "/" <> (String.drop 2 $ card ^. _cardExpYear)
              , offer : ""
              , imageUrl : getCardIcon $ card ^. _cardType
              }

---- helpers
expandButton config =
    linearLayout
        ([ height $ V 120
        , width MATCH_PARENT
        , orientation HORIZONTAL
        , gravity CENTER_VERTICAL
        , padding $ PaddingHorizontal 75 35
        , margin $ MarginBottom 10
        , visibility config.visibility
        , background "#FFFFFF"
        , shadow $ Shadow 0.0 2.0 4.0 1.0 "#12000000" 1.0
        ] <>> config.implementation)
        [ iconView { imageUrl : "ic_add_card"}
        , textView
            [ height $ V 24
            , width $ V 150
            , weight 1.0
            , textSize 20
            , margin $ MarginLeft 25
            , text config.text
            , fontStyle "Arial-Regular"
            , color "#363636"
            ]
        {-- , weightLayout --}
        , actionView
        ]


iconView value =
    linearLayout
        [ height $ V 60
        , width $ V 100
        , orientation VERTICAL
        , gravity CENTER
        ]
        [ imageView
            [ height $ V 32
            , width $ V 46
            , gravity CENTER
            , imageUrl value.imageUrl
            ]
        ]


actionView =
    linearLayout
        [ height $ V 26
        , width $ V 26
        , margin $ MarginHorizontal 35 0
        , gravity CENTER
        ]
        [ imageView
            [ height MATCH_PARENT
            , width MATCH_PARENT
            , gravity CENTER
            , imageUrl "ic_forward_arrow"
            ]
        ]


