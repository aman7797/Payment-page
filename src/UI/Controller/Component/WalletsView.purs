module UI.Controller.Component.WalletsView where

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
import Remote.Types (StoredWallet)
import UI.Constant.FontColor.Default as Color
import UI.Constant.FontSize.Default (a_16)
import UI.Constant.FontStyle.Default as Font
import UI.Constant.Str.Default as STR
import UI.Utils (FieldType(..), os, getFieldTypeID)
import UI.Helpers.SingleSelectRadio as Radio





data Action
    = SubmitWallet
    | LinkWallet
    | WalletSelected Radio.RadioSelected


newtype State = State
    { walletSelected :: Radio.State
    , walletList :: Array StoredWallet
    }


derive instance stateNewtype :: Newtype State _


initialState :: Array StoredWallet -> State
initialState wallets = State $
    { walletSelected : Radio.defaultState Radio.NothingSelected
    , walletList : wallets
    }

eval :: Action -> State -> State
eval =
    case _ of
         SubmitWallet -> identity

         LinkWallet -> identity

         WalletSelected action ->
             _walletSelected %~ Radio.eval action

         _ -> identity

         {-- AddNewCardAction cardAction -> --}
         {--    _addNewCardState %~ AddNewCard.eval cardAction --}

         {-- SectionSelected section -> --}
         {--     _sectionSelected .~ section --}




data Overrides
    = ShowAllOverride
    | ProceedToPay
    | LinkButton


overrides :: (Action -> Effect Unit) -> State -> Overrides -> Props (Effect Unit)
overrides push state =
    case _ of
         ProceedToPay ->
             [ onClick push (const SubmitWallet)
             ]

         LinkButton ->
             [ onClick push (const LinkWallet)]
         _ -> []