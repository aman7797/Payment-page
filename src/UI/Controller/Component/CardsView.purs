module UI.Controller.Component.CardsView where

import Prelude


import Data.Array (null)
import Data.Lens (Lens', _1, (%~), (.~), (^.))
import Data.Newtype (class Newtype)
import Data.String as S
import Data.String.CodePoints (drop, length)
import Effect (Effect)
import Engineering.Helpers.Events
import Engineering.Helpers.Types.Accessor
import JBridge
import PrestoDOM
import Remote.Types (StoredCard(..))
import UI.Constant.FontColor.Default as Color
import UI.Constant.FontSize.Default (a_16)
import UI.Constant.FontStyle.Default as Font
import UI.Constant.Str.Default as STR
import UI.Utils (FieldType(..), os, getFieldTypeID)

import UI.Controller.Component.AddNewCard as AddNewCard




data Action
    = SubmitSavedCard StoredCard
    | AddNewCardAction AddNewCard.Action
    | SectionSelected Section


data Section
    = AddNewCard
    | SavedCard
    {-- | NoSection --}

newtype State = State
    { sectionSelected :: Section
    , storedCards :: Array StoredCard
    , addNewCardState :: AddNewCard.State
    }


derive instance stateNewtype :: Newtype State _


initialState :: Array StoredCard -> State
initialState cards =
    let storedCardsNull = null cards
     in State $
            { sectionSelected : if storedCardsNull then AddNewCard else SavedCard
            , storedCards : cards
            , addNewCardState : AddNewCard.defaultState []
            }

eval :: Action -> State -> State
eval =
    case _ of
         SubmitSavedCard _ -> identity

         AddNewCardAction cardAction ->
            _addNewCardState %~ AddNewCard.eval cardAction

         SectionSelected section ->
             _sectionSelected .~ section




data Overrides
    = SectionSelectionOverride Section
    | BtnPay


overrides :: (Action -> Effect Unit) -> State -> Overrides -> Props (Effect Unit)
overrides push state =
    case _ of
         SectionSelectionOverride section ->
             [ onClick push (const $ SectionSelected section)
             ]

         _ -> []