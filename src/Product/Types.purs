module Product.Types where

import Prelude

import Foreign.Class (class Decode, class Encode)
import Data.Generic.Rep (class Generic)
import Data.Lens ((^.))
import Data.Maybe (Maybe)
import Data.Newtype (class Newtype)
import Engineering.Helpers.Types.Accessor (_code, _referenceId)
import Presto.Core.Utils.Encoding (defaultDecode, defaultEncode)
import Remote.Types (PaymentSourceResp)
import Type.Data.Boolean (kind Boolean)

data PaymentPageExitAction = ExitApp { status :: String, code :: Int }
                           | RetryPayment { errorMessage :: String, showError :: Boolean , prevPaymentMethod :: PaymentOption}
                           | Proceed

newtype Bank = Bank
  {
    code :: String
  , name :: String
  , ifsc :: String
  }

newtype BankList = BankList {
    banks :: Array Bank
}


newtype SIM = SIM {
  slotId :: Int,
  carrierName :: String,
  simId :: String
}

derive instance newtypeSim :: Newtype SIM _

-- {"slotId":0,"subscriptionId":1,"displayName":"Jio 4G","carrierName":"Jio 4G (HD)","phoneNumber":"916360887242","simId":"89918610100002489778"},{"slotId":1,"subscriptionId":2,"displayName":"airtel","carrierName":"airtel","phoneNumber":"91897179100","simId":"8991000900963301968"}

instance eqSIM :: Eq SIM where
    eq (SIM a) (SIM b) = a.simId == b.simId && a.slotId == b.slotId

derive instance genericSIM :: Generic SIM _
instance decodeSIM :: Decode SIM where decode = defaultDecode
instance encodeSIM :: Encode SIM where encode = defaultEncode

derive instance bankListGeneric :: Generic BankList _
derive instance bankGeneric :: Generic Bank _

instance decodeBankList :: Decode BankList where decode = defaultDecode
instance decodeBank :: Decode Bank where decode = defaultDecode

newtype FetchSIMDetailsUPIResponse = FetchSIMDetailsUPIResponse (Array SIM)

derive instance genericFetchSIMDetailsUPIResponse :: Generic FetchSIMDetailsUPIResponse _
derive instance newtypeFetchSIMDetailsUPIResponse :: Newtype FetchSIMDetailsUPIResponse _
instance decodeFetchSIMDetailsUPIResponse :: Decode FetchSIMDetailsUPIResponse where decode = defaultDecode




newtype CardDetails = CardDetails
  { cardNumber :: String
  , expMonth   :: String
  , expYear    :: String
  , nameOnCard :: String
  , securityCode :: String
  , saveToLocker :: Boolean
  , paymentMethod :: String
  }

newtype SavedCardDetails = SavedCardDetails
  { cvv :: String
  , cardToken :: String
  , cardType :: String
  }

newtype Wallet = Wallet
 { name :: Maybe String
 , currentBalance :: Maybe String
 , linked :: Boolean
 , token :: Maybe String
 , balance :: Maybe Number
 , refreshedAt :: Maybe String
 }

type CardToken = String

type SaveToLocker = Boolean

newtype RedirectWallet = RedirectWallet
  { paymentMethodType :: String
  , paymentMethod :: String
  }

-- data PaymentMethod = NB Bank | Card CardDetails | SavedCard SavedCardDetails | WalletPayment Wallet | WalletRedirect RedirectWallet | COD | AmazonPayWallet

-- data ExternalPaymentOption = UPISDK

data PaymentOption =  NB Bank | Card CardDetails | SavedCard SavedCardDetails | WalletPayment Wallet | WalletRedirect RedirectWallet | COD | AmazonPayWallet | UPISDK Account | UPI String | SavedUpi

data WalletType = SDK String | API String

newtype PayLaterResp = PayLaterResp {
    card_reference :: String
,   card_removed :: Boolean
,   amount :: Maybe String
}

type UpiStore = {upiTab :: UPIState, sims :: Array SIM , token :: String, token' :: String, vpa :: String, banks :: Array Bank, mobile :: String, recpMob :: String, smsKey :: String, smsContent :: String, shouldUpdate :: Boolean}

instance eqPaylaterResp :: Eq PayLaterResp
  where
    eq (PayLaterResp a) (PayLaterResp b) = a.card_reference == b.card_reference && a.amount == b.amount 

newtype CallBack = CallBack { serial_no:: String
                            , session_id::String
                            , "type"::String
                            , value ::Array {
                                  card_reference:: String 
                                , amount:: String
                                }
                            }

newtype PaymentPageInput = PaymentPageInput
  { customer  :: Customer
  , piInfo    :: PaymentSourceResp
  , orderInfo :: OrderInfo
  {-- , upiInfo   :: UPIInfo --}
  , sdk :: SDKParams
  }

data PaymentMethod
    = DEBITCARD
    | NETBANK
    | UPITAB UPIState
    | UPIAPPS

instance eqPaymentMethod :: Eq PaymentMethod where
  eq DEBITCARD DEBITCARD = true
  eq NETBANK NETBANK = true
  eq (UPITAB a) (UPITAB b) = a == b
  eq UPIAPPS UPIAPPS = true
  eq _ _ = false

instance ordPaymentMethod :: Ord PaymentMethod where
  compare DEBITCARD _ = GT
  compare _ DEBITCARD = LT
  compare NETBANK _ = GT
  compare _ NETBANK = LT
  compare (UPITAB a) _ = GT
  compare _ (UPITAB b) = LT
  compare UPIAPPS _ = GT


data CurrentOverlay
    = DebitCardOverlay (Maybe Int)
    | NetBankOverlay
    | AmountOverlay
    | UPIAppsOverlay
    | SetUPIPINOverlay
    | SelectBank
    | UPINBTabOverlay
    | UPIACCTabOverlay
    | NoOverlay

instance eqCurrentOverlay :: Eq CurrentOverlay where
    eq (DebitCardOverlay _) (DebitCardOverlay _ ) = true
    eq NetBankOverlay NetBankOverlay = true
    eq NoOverlay NoOverlay = true
    eq AmountOverlay AmountOverlay = true
    eq UPIAppsOverlay UPIAppsOverlay = true
    eq SetUPIPINOverlay SetUPIPINOverlay = true
    eq UPINBTabOverlay UPINBTabOverlay = true
    eq UPIACCTabOverlay UPIACCTabOverlay = true
    eq SelectBank SelectBank = true
    eq _ _ = false

type OrderInfo =
  { amount      :: Number
  , gateway     :: String
  , orderId     :: String
  , orderToken  :: String
  , merchantId  :: String
  {-- , fullfilment :: Array CreditCard --}
  {-- , preferedBanks       :: Array String --}
  {-- , billerCardEditable  :: String --}
  }

type Customer =
  { mobileNumber :: Maybe String
  , id :: Maybe String
  , clientId :: String
  }

newtype UPIInfo = UPIInfo 
  { apps :: Array App
  , mobile :: String
  , upiState :: UpiStore
  }

data UPIState  
  = Fresh (Array SIM)
  | Bound (Array Bank)
  | Linked (Array Account)
  | PreLink (Array Account)
  | Disabled

instance eqUPIState :: Eq UPIState where
  eq (Fresh _) (Fresh _) = true
  eq (Bound _) (Bound _) = true
  eq (Linked _) (Linked _) = true
  eq (PreLink _) (PreLink _) = true
  eq Disabled Disabled = true
  eq _ _ = false


type App = 
  { packageName :: String
  , appName :: String
  }



data PaymentProcessingApp = Godel | AmazonPay

newtype SDKParams = SDKParams
  { orderToken :: String
  , amount :: Number
  , orderId :: String
  , merchantId :: String
  , customerMobile :: String
  , customerId :: String
  , clientId :: String
  , activityRecreated :: Boolean
  , environment :: String
  {-- , fullfilment :: Array CreditCard --}
  , preferedBanks :: Array String
  {-- , billerCardEditable :: String --}
  {-- , session_token :: String --}
  }

newtype Carddetails = Carddetails
  { message :: String
  , message_color :: String
  }

newtype CreditCard = CreditCard {
    id :: String
  ,	masked_card_number	:: String --"4242424242424242”
  , card_issuer :: String
  -- , bank_code :: String
  , card_brand 	:: String --"VISA”
  , amount_payable :: String
  , amount :: String
  ,	card_reference	:: String --"7433AC1C-0187-4DBF-91F0-9AEFF5157C6D”
  , minimum_amount :: String --"3553.0"
  ,	custom_amount :: String --"0"
  , card_details :: Carddetails
  , iin :: Maybe String
}


newtype Account = Account {
		bankCode :: String
  , bankName :: String
  , maskedAccountNumber :: String
  , mpinSet :: Boolean
  , referenceId :: String
  , regRefId :: String
  , accountHolderName :: String
  , register :: Boolean
  -- , "type" :: Maybe String
  -- , branchName :: Maybe String
  -- , bankAccountUniqueId :: Maybe String
  -- , ifsc :: Maybe String
  -- , name :: Maybe String
  -- , otpLength :: Maybe String
  -- , format :: Maybe String
  -- , atmPinLength :: Maybe String
  , ifsc :: String
}

newtype BankAccount = BankAccount {
  bankCode :: String
  , bankName :: String
  , maskedAccountNumber :: String
  , mpinSet :: Boolean
  , referenceId :: String
  , regRefId :: String
  , accountHolderName :: String
  , register :: Boolean
  , ifsc :: String
}
instance eqBankAccount :: Eq BankAccount where
  eq (BankAccount a) (BankAccount b) = a.referenceId == b.referenceId

instance eqAccount :: Eq Account where
  eq (Account a) (Account b) = a.referenceId == b.referenceId

derive instance sdkParamsNewtype :: Newtype SDKParams _
derive instance paymentPageInput :: Newtype PaymentPageInput _
derive instance bankNewtype :: Newtype Bank _
derive instance ccNewtype :: Newtype CreditCard _  
derive instance userCardDetails :: Newtype Carddetails _   
derive instance bankAccountNewtype :: Newtype BankAccount _

instance eqBank :: Eq Bank where
  eq (Bank { code }) (Bank { code : c2 }) = code == c2

instance ordBank :: Ord Bank where
  compare b1 b2 | (getCardOrd b1 b2 == 0) = EQ
                | (getCardOrd b1 b2 > 0)  = GT
                | (getCardOrd b1 b2 < 0)  = LT
                | otherwise               = EQ

getCardOrd :: Bank -> Bank -> Int
getCardOrd b1 b2 = (bankCodeToInt (b1 ^. _code)) - (bankCodeToInt $ b2 ^. _code)

instance ordBankAccount :: Ord BankAccount where
  compare b1 b2 | (getBankAccountOrd b1 b2 == 0) = EQ
                | (getBankAccountOrd b1 b2 > 0)  = GT
                | (getBankAccountOrd b1 b2 < 0)  = LT
                | otherwise               = EQ

getBankAccountOrd :: BankAccount -> BankAccount -> Int
getBankAccountOrd b1 b2 = (bankCodeToInt (b1 ^. _referenceId)) - (bankCodeToInt $ b2 ^. _referenceId)

bankCodeToInt :: String -> Int
bankCodeToInt "NB_ICICI"  = 0
bankCodeToInt "NB_SBI"    = 1
bankCodeToInt "NB_HDFC"   = 2
bankCodeToInt "NB_AXIS"   = 3
bankCodeToInt "NB_KOTAK"  = 4
bankCodeToInt "NB_CANR" = 5
bankCodeToInt _ = 100

type Numeric = Number

--tracker type
newtype JusPayLoad = 
  JusPayLoad {
            you_pay :: Numeric
            ,due_in :: Numeric
            ,pay_total :: Numeric
            ,bank_name :: String
            ,card_provider :: String
            ,pay_using :: String
          }


jusPayLoad :: JusPayLoad
jusPayLoad =   JusPayLoad {
            you_pay : 0.0
            ,due_in : 0.0
            ,pay_total : 0.0
            ,bank_name : ""
            ,card_provider : ""
            ,pay_using : ""
          }

newtype ItemClick = 
  ItemClick {
            you_pay :: Numeric
            ,due_in :: Numeric
            ,pay_total :: Numeric
            ,bank_name :: String
            ,card_provider :: String
            ,pay_using :: String
            ,total_amount :: Numeric
            ,total_min :: Numeric
            ,total_custom :: Numeric
          }

itemClick :: ItemClick 
itemClick = ItemClick {
            you_pay : 0.0
            ,due_in : 0.0
            ,pay_total : 0.0
            ,bank_name : ""
            ,card_provider : ""
            ,pay_using : ""
            ,total_amount : 0.0
            ,total_min : 0.0
            ,total_custom : 0.0
          }

newtype ItemClickTotal = 
  ItemClickTotal {
            you_pay :: Numeric
            ,due_in :: Numeric
            ,pay_total :: Numeric
            ,bank_name :: String
            ,card_provider :: String
            ,pay_using :: String
            ,total_amount :: Numeric
            ,total_min :: Numeric
            ,total_custom :: Numeric
          }

itemClickTotal :: ItemClickTotal
itemClickTotal = ItemClickTotal {
            you_pay : 0.0
            ,due_in : 0.0
            ,pay_total : 0.0
            ,bank_name : ""
            ,card_provider : ""
            ,pay_using : ""
            ,total_amount : 0.0
            ,total_min : 0.0
            ,total_custom : 0.0
          }

newtype ItemClickMin =
  ItemClickMin {
            you_pay :: Numeric
            ,due_in :: Numeric
            ,pay_total :: Numeric
            ,bank_name :: String
            ,card_provider :: String
            ,pay_using :: String
            ,total_amount :: Numeric
            ,total_min :: Numeric
            ,total_custom :: Numeric
          }

itemClickMin :: ItemClickMin
itemClickMin = ItemClickMin {
            you_pay : 0.0
            ,due_in : 0.0
            ,pay_total : 0.0
            ,bank_name : ""
            ,card_provider : ""
            ,pay_using : ""
            ,total_amount : 0.0
            ,total_min : 0.0
            ,total_custom : 0.0
          }

newtype ItemClickCustom =
  ItemClickCustom {
            you_pay :: Numeric
            ,due_in :: Numeric
            ,pay_total :: Numeric
            ,bank_name :: String
            ,card_provider :: String
            ,pay_using :: String
            ,total_amount :: Numeric
            ,total_min :: Numeric
            ,total_custom :: Numeric
          }

itemClickCustom :: ItemClickCustom
itemClickCustom = ItemClickCustom {
              you_pay : 0.0
              ,due_in : 0.0
              ,pay_total : 0.0
              ,bank_name : ""
              ,card_provider : ""
              ,pay_using : ""
              ,total_amount : 0.0
              ,total_min : 0.0
              ,total_custom : 0.0            
          }

newtype ItemClickEnterCustom =
  ItemClickEnterCustom {
            entered_value :: Numeric
          }

itemClickEnterCustom :: ItemClickEnterCustom
itemClickEnterCustom = ItemClickEnterCustom {
            entered_value : 0.0
          }

newtype DebitCard =
  DebitCard {
    you_pay :: Numeric
    ,due_in :: Numeric
    ,pay_total :: Numeric
    ,bank_name :: String
    ,card_provider :: String
    ,pay_using :: String
    ,selected_debit_card_bank_name :: String
    ,selected_debit_card_provider :: String 
    ,debit_card_count :: Numeric
  }

debitCard :: DebitCard
debitCard = DebitCard {
              you_pay : 0.0
              ,due_in : 0.0
              ,pay_total : 0.0
              ,bank_name : ""
              ,card_provider : ""
              ,pay_using : ""
              ,selected_debit_card_bank_name : ""
              ,selected_debit_card_provider : "" 
              ,debit_card_count : 0.0
            }  

newtype DebitCardChange =
  DebitCardChange {
    you_pay :: Numeric
    ,due_in :: Numeric
    ,pay_total :: Numeric
    ,bank_name :: String
    ,card_provider :: String
    ,pay_using :: String
    ,selected_debit_card_bank_name :: String
    ,selected_debit_card_provider :: String 
    ,debit_card_count :: Numeric

  }

debitCardChange :: DebitCardChange
debitCardChange = 
  DebitCardChange {
    you_pay : 0.0
    ,due_in : 0.0
    ,pay_total : 0.0
    ,bank_name : ""
    ,card_provider : ""
    ,pay_using : ""
    ,selected_debit_card_bank_name : ""
    ,selected_debit_card_provider : "" 
    ,debit_card_count : 0.0    
  }

newtype DebitCardNew =  
  DebitCardNew {
    you_pay :: Numeric
    ,due_in :: Numeric
    ,pay_total :: Numeric
    ,bank_name :: String
    ,card_provider :: String
    ,pay_using :: String
    ,debit_card_count :: Numeric
  }

debitCardNew :: DebitCardNew
debitCardNew = 
  DebitCardNew {
    you_pay : 0.0
    ,due_in : 0.0
    ,pay_total : 0.0
    ,bank_name : ""
    ,card_provider : ""
    ,pay_using : ""
    ,debit_card_count : 0.0
  }

newtype DebitCardNewPageLoad = 
  DebitCardNewPageLoad {}

newtype DebitCardNewError = 
  DebitCardNewError {}

newtype DebitCardNewPay = 
  DebitCardNewPay {
    bank_name :: String
    ,card_provider :: String
  }

debitCardNewPay :: DebitCardNewPay
debitCardNewPay = 
  DebitCardNewPay {
    bank_name : ""
  , card_provider : ""
  }

newtype DebitCardPay = 
  DebitCardPay {
    you_pay :: Numeric
    ,due_in :: Numeric
    ,pay_total :: Numeric
    ,bank_name :: String
    ,card_provider :: String
    ,pay_using :: String
    ,selected_debit_card_bank_name :: String
    ,selected_debit_card_provider :: String
    ,debit_card_count :: Numeric
  }

debitCardPay :: DebitCardPay
debitCardPay = 
  DebitCardPay {
    you_pay : 0.0
    ,due_in : 0.0
    ,pay_total : 0.0
    ,bank_name : ""
    ,card_provider : ""
    ,pay_using : ""
    ,selected_debit_card_bank_name : ""
    ,selected_debit_card_provider : ""
    ,debit_card_count : 0.0
  }

newtype DebitCardPaySuccess = 
  DebitCardPaySuccess {}

newtype NetBank = 
  NetBank {
    you_pay :: Numeric
    ,due_in :: Numeric
    ,pay_total :: Numeric
    ,bank_name :: String
    ,card_provider :: String
    ,pay_using :: String
    ,selected_bank_name :: String
  }

netBank :: NetBank
netBank = 
  NetBank {
    you_pay : 0.0
    ,due_in : 0.0
    ,pay_total : 0.0
    ,bank_name : ""
    ,card_provider : ""
    ,pay_using : ""
    ,selected_bank_name : ""
  }

newtype NetBankSwitch = 
  NetBankSwitch {
    you_pay :: Numeric
    ,due_in :: Numeric
    ,pay_total :: Numeric
    ,bank_name :: String
    ,card_provider :: String
    ,pay_using :: String
    ,selected_bank_name :: String
  }

netBankSwitch :: NetBankSwitch
netBankSwitch = 
  NetBankSwitch {
    you_pay : 0.0
    ,due_in : 0.0
    ,pay_total : 0.0
    ,bank_name : ""
    ,card_provider : ""
    ,pay_using : ""
    ,selected_bank_name : ""
  }

newtype NetBankViewAll = 
  NetBankViewAll {
    you_pay :: Numeric
    ,due_in :: Numeric
    ,pay_total :: Numeric
    ,bank_name :: String
    ,card_provider :: String
    ,pay_using :: String
    ,selected_bank_name :: String
  }

netBankViewAll :: NetBankViewAll
netBankViewAll =
  NetBankViewAll {
    you_pay : 0.0
    ,due_in : 0.0
    ,pay_total : 0.0
    ,bank_name : ""
    ,card_provider : ""
    ,pay_using : ""
    ,selected_bank_name : ""
  }

newtype NetBankingViewAllPageLoad = 
  NetBankingViewAllPageLoad {
  }

netBankingViewAllPageLoad :: NetBankingViewAllPageLoad
netBankingViewAllPageLoad = NetBankingViewAllPageLoad {}

newtype NetBankingPay =
  NewBankingPay {
    you_pay :: Numeric
    ,due_in :: Numeric
    ,pay_total :: Numeric
    ,bank_name :: String
    ,card_provider :: String
    ,pay_using :: String
    ,selected_bank_name :: String
  }

netBankingPay :: NetBankingPay
netBankingPay = 
  NewBankingPay {
    you_pay : 0.0
    ,due_in : 0.0
    ,pay_total : 0.0
    ,bank_name : ""
    ,card_provider : ""
    ,pay_using : ""
    ,selected_bank_name : ""
  }

derive instance newJusPayLoad :: Newtype JusPayLoad _
derive instance newItemClick :: Newtype ItemClick _
derive instance newItemClickTotal :: Newtype ItemClickTotal _
derive instance newItemClickMin :: Newtype ItemClickMin _
derive instance newItemClickCustom :: Newtype ItemClickCustom _
derive instance newItemClickEnterCustom :: Newtype ItemClickEnterCustom _
derive instance newDebitCard :: Newtype DebitCard _
derive instance newDebitCardChange :: Newtype DebitCardChange _
derive instance newDebitCardNew :: Newtype DebitCardNew _
derive instance newDebitCardNewPageLoad :: Newtype DebitCardNewPageLoad _
derive instance newDebitCardNewError :: Newtype DebitCardNewError _
derive instance newDebitCardNewPay :: Newtype DebitCardNewPay _
derive instance newDebitCardPay :: Newtype DebitCardPay _
derive instance newDebitCardPaySuccess :: Newtype DebitCardPaySuccess _
derive instance newNetBank :: Newtype NetBank _
derive instance newNetBankingPay :: Newtype NetBankingPay _
derive instance newupiInfoPay :: Newtype UPIInfo _

-- instance showTr :: Show TrackDetails where
--   show a = toString a