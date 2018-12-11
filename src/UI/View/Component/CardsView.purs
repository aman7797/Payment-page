module UI.View.Component.CardsView where

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
import UI.Controller.Component.CardsView

import UI.View.Component.TabLayout as TabLayout
import UI.Helpers.SingleSelectRadio as Radio
import UI.View.Component.AddNewCard as AddNewCard
import UI.Utils

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


savedCardsView push state props =
    let radioState = state ^. _sectionSelected
        storedCards = state ^. _storedCards
     in linearLayout
        [ height $ V $ 120 * (length storedCards)
        , width MATCH_PARENT
        , orientation HORIZONTAL
        , gravity CENTER_VERTICAL
        , background "#effaff"
        , visibility props.visibility
        , margin $ MarginBottom 10
        ]
        []
        {-- $ Radio.singleSelectRadio --}
        {--     (push <<< SectionSelected) --}
        {--     radioState --}
        {--     (TabLayout.view renderType) --}


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







