module UI.Common.Controller.Component.WalletsView where

import Prelude

import Data.Array ((!!))
import Data.Lens (Lens', _1, (%~), (.~), (^.))
import Data.Maybe
import Data.Newtype (class Newtype)
import Data.String as S
import Data.String.CodePoints (drop, length)
import Effect (Effect)
import Engineering.Helpers.Events
import Engineering.Helpers.Types.Accessor
import JBridge
import PrestoDOM
import Product.Types
import Remote.Types
import UI.Constant.FontStyle.Default as Font
import UI.Constant.Str.Default as STR
import UI.Utils (FieldType(..), os, getFieldTypeID, logAny,  LinkingState(..))
import UI.Common.Helpers.SingleSelectRadio as Radio





data Action
    = SubmitWallet
    | LinkAction Int
    | Create  LinkingState (Maybe CreateWalletResp)
    | WalletSelected Radio.RadioSelected
    | SectionSelected Section
    | OTPChanged String


data Section
    = WalletListSection
    | LinkWalletSection LinkingState

newtype LinkWalletDetails = LinkWalletDetails
    { id :: String
    , otp :: String
    , linked :: Maybe Boolean
    , current_balance :: Maybe Number
    , token :: Maybe String
    }

newtype State = State
    { sectionSelected :: Section
    , walletSelected :: Radio.State
    , walletList :: Array Wallet
    , customerMobile :: String
    , linkWalletDetails :: LinkWalletDetails
    }


derive instance stateNewtype :: Newtype State _
derive instance linkWalletDetailsNewtype :: Newtype LinkWalletDetails  _


initialState :: String -> Array Wallet -> State
initialState mobile wallets = State $
    { sectionSelected : WalletListSection
    , walletSelected : Radio.defaultState Radio.NothingSelected
    , walletList : wallets
    , customerMobile : mobile
    , linkWalletDetails : LinkWalletDetails { id : "", otp : "", linked : Nothing, current_balance : Nothing, token : Nothing }
    }

eval :: Action -> State -> State
eval =
    case _ of
         SectionSelected section ->
             _sectionSelected .~ section

         SubmitWallet -> identity

         Create Linking res ->
             case logAny res of
                  Just (CreateWalletResp r) ->
                      ((_linkWalletDetails <<< _id) .~ r.id)
                      <<< (_sectionSelected .~ LinkWalletSection OTPView)

                  _ -> identity ---- handle error

         Create OTPView res ->
             case logAny res of
                  Just (CreateWalletResp r) ->
                      ((_linkWalletDetails <<< _id) .~ r.id)
                      <<< ((_linkWalletDetails <<< _linked) .~ r.linked)
                      <<< ((_linkWalletDetails <<< _token) .~ r.token)
                      <<< ((_linkWalletDetails <<< _current_balance) .~ r.current_balance)
                      <<< (_sectionSelected .~ LinkWalletSection PayView)

                  _ -> identity ---- handle error

         LinkAction ind ->
            (_walletSelected %~ Radio.eval (Radio.RadioSelected ind))
            <<< (_sectionSelected .~ LinkWalletSection Linking)

         WalletSelected action ->
             _walletSelected %~ Radio.eval action

         OTPChanged str ->
            logAny <<< (_linkWalletDetails <<< _otp) .~ str

         _ -> identity

         {-- AddNewCardAction cardAction -> --}
         {--    _addNewCardState %~ AddNewCard.eval cardAction --}

         {-- SectionSelected section -> --}
         {--     _sectionSelected .~ section --}

unsafeGetGateway :: Array Wallet -> Radio.RadioSelected -> String
unsafeGetGateway wallets =
    case _ of
         Radio.RadioSelected ind ->
             fromMaybe
                ""
                ((\w -> w ^. _name) <$>  (wallets !! ind))
         _ -> ""


data Overrides
    = SectionSelectionOverride Section
    | ProceedToPay
    | LinkButton Int
    | CreateWalletOverride LinkingState Radio.RadioSelected
    | OTPField


overrides :: (Action -> Effect Unit) -> State -> Overrides -> Props (Effect Unit)
overrides push state =
    let wallets = state ^. _walletList
        otp = state ^. _linkWalletDetails ^. _otp
        walletId = state ^. _linkWalletDetails ^. _id
    in case _ of
            SectionSelectionOverride section ->
             [ onClick push (const $ SectionSelected section)
             ]

            ProceedToPay ->
             [ onClick push (const SubmitWallet)
             ]

            LinkButton curr ->
             [ onClick push $ const $ LinkAction curr
             , clickable true
             ]

            CreateWalletOverride st curr ->
             [ onClickHandleWallet st (unsafeGetGateway wallets curr) otp walletId push (Create st)
             , clickable true
             ]

            OTPField ->
             [ onChange push OTPChanged
             , clickable true
             ]


            _ -> []