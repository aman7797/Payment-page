module UI.Common.Controller.Screen.PaymentsFlow.PaymentPage where

import Prelude

import Config.Default as Default
import Control.Monad.Trans.Class (lift)
import Data.Array
import Data.Foldable (foldl)
import Data.Int (toNumber)
import Data.Lens (Lens', _1, (%~), (.~), (^.))
import Data.Maybe (Maybe(..), fromMaybe, maybe)
import Data.Newtype (class Newtype)
import Data.Number (fromString)
import Data.Number.Format (toString)
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import Data.Generic.Rep.Eq (genericEq)
import Effect (Effect)
import Engineering.Helpers.Commons (dpToPx, log, startAnim, getNbIin)
import Engineering.Helpers.Utils (setDelay)
import Engineering.Helpers.Types.Accessor
import JBridge (requestKeyboardShow, requestKeyboardHide)
import Engineering.Helpers.Commons (dpToPx, log, startAnim, startAnim_, getIinNb)
import Engineering.Helpers.Utils (setDelay)
import Externals.UPI.Types (UPIAppList(..))
import JBridge (requestKeyboardHide, requestKeyboardShow)
import PrestoDOM
import PrestoDOM.Events (onBackPressed, onClick)
import PrestoDOM.Utils ((<>>))
import Product.Types
import Remote.Accessors (_paymentMethod)
import Remote.Config (encKey)
import Remote.Types (StoredCard, mockWallet)
import Tracker.Tracker (trackEventMerchantV2, toString) as T
import UI.Constant.FontStyle.Default as Font
import UI.Common.Controller.Component.AddNewCard (Action(..))
import UI.Common.Controller.Component.AddNewCard as AddNewCard
import UI.Common.Controller.Component.CardsView as CardsView
import UI.Common.Controller.Component.UpiView  as UpiView
import UI.Common.Controller.Component.NetBankingView as NetBankingView
import UI.Common.Controller.Component.WalletsView as WalletsView
import Validation (InvalidState(..), ValidationState(..), getMonth, getYear)

import UI.Helpers.SingleSelectRadio as Radio
import UI.Utils

-- Types

newtype PaymentPageState = PaymentPageState
  { ppInput :: PaymentPageInput
  , uiState :: UIState
  }

data ErrorMethod = Snackbar String | Popup String

isSnackBar :: ErrorMethod -> Visibility
isSnackBar (Snackbar err) = GONE
isSnackBar (Popup err) = GONE


newtype UIState = UIState
    { sectionSelected :: Radio.State
    , sections :: Array PaymentSection
    , cardsViewState :: CardsView.State
    , upiViewState :: UpiView.State
    , netBankingViewState :: NetBankingView.State
    , walletsViewState :: WalletsView.State
    , renderType :: RenderType
    }

derive instance paymentPageStateNewtype :: Newtype PaymentPageState _

derive instance uiStateNewtype :: Newtype UIState _


data PaymentSection
    = Wallets
    | Cards
    | NetBanking
    | UPISection
    | DefaultSection

derive instance genericPaymentSection :: Generic PaymentSection _

instance showPaymentSection :: Show PaymentSection where
    show = genericShow

instance eqPaymentSection :: Eq PaymentSection where
    eq = genericEq
-- UIActions

data PaymentPageUIAction
  = BillerCard
  {-- | SectionSelected PaymentSection --}
  | SectionSelected (Radio.RadioSelected)
  | CardsViewAction CardsView.Action
  | UpiViewAction UpiView.Action
  | NetBankingViewAction  NetBankingView.Action
  | WalletsViewAction WalletsView.Action
  | Resized Int
-- Exit Type

data PaymentPageResponse
    = PaymentPageResponse PaymentPageState  PaymentPageAction
    | ScreenData PaymentPageState

-- Exit Actions

data PaymentPageAction
    = UserAborted
    | PayUsing PaymentOption
    {-- | CreateWallet String --}
    {-- | LinkWallet String --}
    | Delete PaymentOption

data ScrollType = SCROLL | HALT

-- Defaults

initialState :: PaymentPageInput -> PaymentPageState
initialState ppInput = PaymentPageState
        { ppInput
        , uiState : defaultUIState ppInput
        }

defaultUIState :: PaymentPageInput -> UIState
defaultUIState ppInput = UIState
    {-- { sectionSelected  : Radio.defaultState Radio.NothingSelected --}
    { sectionSelected  : Radio.defaultState $ Radio.RadioSelected 0
    , sections : [ Wallets, Cards, NetBanking, UPISection]
    , cardsViewState : CardsView.initialState $ ppInput ^. _piInfo ^. _cards
    , netBankingViewState : NetBankingView.initialState $ getBankList ppInput
    , walletsViewState : WalletsView.initialState (ppInput ^. _sdk ^. _customerMobile) $ getWalletsList ppInput
    , upiViewState : UpiView.initialState
    , renderType : getRenderType $ ppInput ^. _screenWidth
    }

eval
	:: PaymentPageUIAction
	-> PaymentPageState
	-> Eval PaymentPageUIAction PaymentPageResponse PaymentPageState
eval =
  case _ of
    -- component
    CardsViewAction cardAction ->
        continue <<< (_uiState <<< _cardsViewState %~ CardsView.eval cardAction)

    NetBankingViewAction action ->
        continue <<< (_uiState <<< _netBankingViewState %~ NetBankingView.eval action)

    WalletsViewAction action ->
        continue <<< (_uiState <<< _walletsViewState %~ WalletsView.eval action)

    UpiViewAction action ->
        continue <<< (_uiState <<< _upiViewState %~ UpiView.eval action)



    -- EXIT actions
    CardsViewAction (CardsView.AddNewCardAction (SubmitCard AddNewCard.AddNewCard)) ->
        exitPP $ PayUsing <<< Card <<< mkCardDetails

    {-- AddNewCardAction (SubmitCard (AddNewCard.SavedCard card)) -> --}
    {--     exitPP $ PayUsing <<< SavedCard <<< mkSavedCardDetails card --}

    CardsViewAction CardsView.SubmitSavedCard ->
        let getExitAction = \ppState ->
            let cardsViewState = ppState ^. _uiState ^. _cardsViewState
                currentSelected  = cardsViewState ^. _savedCardSelected ^. _currentSelected
                storedCards = cardsViewState ^. _storedCards
             in case currentSelected of
                                Radio.RadioSelected ind ->
                                    maybe
                                        UserAborted
                                        (PayUsing <<< SavedCard <<< mkSavedCardDetails ppState)
                                        (storedCards !! ind)
                                _ -> UserAborted -- Remove this and pass error
         in exitPP getExitAction

    NetBankingViewAction NetBankingView.SubmitNetBanking ->
        let getExitAction = \ppState ->
            let netBankingViewState = ppState ^. _uiState ^. _netBankingViewState
                currentSelected  = netBankingViewState ^. _nbSelected ^. _currentSelected
                netBankList = netBankingViewState ^. _netBankList
             in case currentSelected of
                                Radio.RadioSelected ind ->
                                    maybe
                                        UserAborted
                                        (PayUsing <<< NB <<< mkNetBankingDetails)
                                        (netBankList !! ind)
                                _ -> UserAborted -- Remove this and pass error
         in exitPP getExitAction

    UpiViewAction UpiView.SubmitUpiCollect ->
        exitPP $ PayUsing <<< UPI <<< mkUpiCollectDetails



    {-- -- LINK --}
    {-- WalletsViewAction (WalletsView.Create ind) -> --}
    {--     let getExitAction = \ppState -> --}
    {--         let walletsViewState = ppState ^. _uiState ^. _walletsViewState --}
    {--             walletList = walletsViewState ^. _walletList --}
    {--          in maybe --}
    {--                 UserAborted --}
    {--                 (\wallet -> CreateWallet $ wallet ^. _wallet) --}
    {--                 (walletList !! ind) --}
    {--      in exitPP getExitAction --}



    -- -- -- -- -- -- -- -- --
    SectionSelected action ->
        continue <<< (_uiState <<< _sectionSelected %~ Radio.eval action)

    Resized width -> continue <<< (_uiState <<< _renderType .~ getRenderType width)

    _ -> continue

exitPP
    :: (PaymentPageState -> PaymentPageAction)
    -> PaymentPageState
    -> Eval PaymentPageUIAction PaymentPageResponse PaymentPageState
exitPP action ppState = exit $ PaymentPageResponse ppState (action ppState)


mkCardDetails :: PaymentPageState -> CardDetails
mkCardDetails ppState =
    let addCardState = ppState ^. _uiState ^. _cardsViewState ^. _addNewCardState
     in CardDetails
        { cardNumber : addCardState ^. _formState ^. _cardNumber ^. _value
        , expMonth   : show <<< getMonth $ addCardState ^. _formState ^. _expiryDate ^. _value
        , expYear    : show <<< getYear $ addCardState ^. _formState ^. _expiryDate ^. _value
        , nameOnCard : Default.nameOnCard
        , securityCode : addCardState ^. _formState ^. _cvv ^. _value
        , saveToLocker : addCardState ^. _formState ^. _savedForLater
        , paymentMethod : addCardState ^. _formState ^. _cardNumber ^. _cardDetails ^. _card_type
        }

mkSavedCardDetails :: PaymentPageState -> StoredCard -> SavedCardDetails
mkSavedCardDetails ppState card =
    let cvv = ppState  ^. _uiState ^. _cardsViewState ^. _cvv
     in SavedCardDetails
        { cvv
        , cardToken : card ^. _cardToken
        , cardType : card ^. _cardType
        }

mkNetBankingDetails :: BankAccount -> Bank
mkNetBankingDetails bank =
    Bank
        { name : bank ^. _bankName
        , code  : bank ^. _bankCode
        , ifsc: bank ^. _ifsc
        }


mkUpiCollectDetails :: PaymentPageState -> String
mkUpiCollectDetails ppState =
    ppState ^. _uiState ^. _upiViewState ^. _vpa



data Overrides
    = SectionOverride PaymentSection
    | SectionSelectionOverride PaymentSection


overrides :: (PaymentPageUIAction  -> Effect Unit) -> PaymentPageState -> Overrides -> Props (Effect Unit)
overrides push state =
    let uiState = state ^. _uiState
     in case _ of
    {--     SectionSelectionOverride section -> --}
    {--         [ onClick push $ const $ SectionSelected section --}
    {--         , background $ if state ^. _uiState ^. _sectionSelected == section --}
    {--                        then "#e9e9e9" --}
    {--                        else "#ffffff" --}
    {--         ] --}

        SectionOverride section ->
            let sections = uiState ^. _sections
                currSection = case uiState ^. _sectionSelected ^. _currentSelected of
                                Radio.RadioSelected i -> fromMaybe
                                                             DefaultSection
                                                             (sections !! i)
                                Radio.NothingSelected -> DefaultSection
             in [ visibility $ if section == currSection
                              then VISIBLE
                              else GONE
                ]

        _ -> []



getBankList :: PaymentPageInput -> Array BankAccount
getBankList ppInput =
    sort <<< map mkBank <<< filter getNB $ ppInput ^. _piInfo ^. _merchantPaymentMethods
    where
          mkBank pm = BankAccount
                        { bankCode : pm  ^. _paymentMethod
                        , bankName : pm ^. _description
                        , maskedAccountNumber : ""
                        , mpinSet : true
                        , referenceId : pm  ^. _paymentMethod
                        , regRefId : ""
                        , accountHolderName : ""
                        , register : true
                        , ifsc : ""
                        , iin : getNbIin $ pm  ^. _paymentMethod
                        }

          getNB pm = (pm ^. _paymentMethodType) == "NB"

getWalletsList :: PaymentPageInput -> Array Wallet
getWalletsList ppInput =
    map mkWallet <<< filter getWallet $ ppInput ^. _piInfo ^. _merchantPaymentMethods
    where
          defaultWallet name = Wallet
                { name : name
                , currentBalance : Nothing
                , linked : Nothing
                , token : Nothing
                , lastRefreshed : Nothing
                }

          mkWallet pm =
            let walletName = pm  ^. _paymentMethod
                wallets = ppInput ^. _piInfo ^. _wallets
                boolFn = \a -> (a ^. _wallet) == walletName
                maybeWallet = findIndex boolFn wallets
                                >>= index wallets
                                >>= \w -> Just $ Wallet { name : w ^. _wallet
                                               , currentBalance : w ^. _currentBalance
                                               , linked : w ^. _linked
                                               , token : w ^. _token
                                               , lastRefreshed : w ^. _lastRefreshed
                                               }
             in fromMaybe
                    (defaultWallet walletName)
                    maybeWallet


          getWallet pm = (pm ^. _paymentMethodType) == "WALLET"





