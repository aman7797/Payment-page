module UI.Common.Controller.Component.NetBankingView where

import Prelude

import Data.Lens (Lens', _1, (%~), (.~), (^.))
import Data.Newtype (class Newtype)
import Data.String as S
import Data.String.CodePoints (drop, length)
import Effect (Effect)
import Engineering.Helpers.Events
import Engineering.Helpers.Types.Accessor
import JBridge
import PrestoDOM
import Product.Types
import Remote.Types (StoredCard(..))
import UI.Constant.FontStyle.Default as Font
import UI.Constant.Str.Default as STR
import UI.Utils (FieldType(..), os, getFieldTypeID)
import UI.Helpers.SingleSelectRadio as Radio





data Action
    = SubmitNetBanking
    | NetBankSelected Radio.RadioSelected


newtype State = State
    { nbSelected :: Radio.State
    , netBankList :: Array BankAccount
    }


derive instance stateNewtype :: Newtype State _


initialState :: Array BankAccount -> State
initialState nb = State $
    { nbSelected : Radio.defaultState Radio.NothingSelected
    , netBankList : nb
    }

eval :: Action -> State -> State
eval =
    case _ of
         SubmitNetBanking -> identity

         NetBankSelected action ->
             _nbSelected %~ Radio.eval action

         _ -> identity

         {-- AddNewCardAction cardAction -> --}
         {--    _addNewCardState %~ AddNewCard.eval cardAction --}

         {-- SectionSelected section -> --}
         {--     _sectionSelected .~ section --}




data Overrides
    = ShowAllOverride
    | ProceedToPay


overrides :: (Action -> Effect Unit) -> State -> Overrides -> Props (Effect Unit)
overrides push state =
    case _ of
         ProceedToPay ->
             [ onClick push (const SubmitNetBanking)
             , clickable true
             ]

         _ -> []