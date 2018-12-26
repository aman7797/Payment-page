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
import UI.Helpers.SingleSelectRadio as Radio




data Action
    = SubmitSavedCard
    | AddNewCardAction AddNewCard.Action
    | SavedCardSelected Radio.RadioSelected
    | SectionSelected Section
    | CvvChanged String


data Section
    = AddNewCard
    | SavedCard
    {-- | NoSection --}

newtype State = State
    { sectionSelected :: Section
    , storedCards :: Array StoredCard
    , addNewCardState :: AddNewCard.State
    , cvv :: String
    , savedCardSelected :: Radio.State
    }


derive instance stateNewtype :: Newtype State _


initialState :: Array StoredCard -> State
initialState cards =
    let storedCardsNull = null cards
     in State $
            { sectionSelected : if storedCardsNull then AddNewCard else SavedCard
            , storedCards : cards
            , addNewCardState : AddNewCard.defaultState []
            , savedCardSelected : Radio.defaultState Radio.NothingSelected
            , cvv : ""
            }

eval :: Action -> State -> State
eval =
    case _ of
         SubmitSavedCard -> identity

         AddNewCardAction cardAction ->
            _addNewCardState %~ AddNewCard.eval cardAction

         SectionSelected section ->
             _sectionSelected .~ section

         SavedCardSelected action ->
             _savedCardSelected %~ Radio.eval action

         CvvChanged str ->
             _cvv .~ str

         _ -> identity




data Overrides
    = SectionSelectionOverride Section
    | ProceedToPay
    | CvvEditField


overrides :: (Action -> Effect Unit) -> State -> Overrides -> Props (Effect Unit)
overrides push state =
    case _ of
         SectionSelectionOverride section ->
             [ onClick push (const $ SectionSelected section)
             ]

         ProceedToPay ->
             [ onClick push (const SubmitSavedCard)
             , clickable true
             ]

         CvvEditField ->
             [ onChange push CvvChanged
             , clickable true
             ]

         _ -> []