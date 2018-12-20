module Remote.Types where

import Prelude

import Control.Monad.Except (runExcept)
import Data.Either (Either(..))
import Foreign.Class (class Decode, class Encode)
{-- import Foreign.NullOrUndefined (NullOrUndefined(NullOrUndefined)) --}
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Network (urlEncodedMakeRequest)
import Presto.Core.Types.API (class RestEndpoint, Method(..), defaultDecodeResponse, defaultMakeRequest, defaultMakeRequest_)
import Presto.Core.Utils.Encoding (defaultDecode, defaultEncode)
import Remote.Config (baseUrl, eulerLocation)


-----------------------------------API 1 -------------------------------
newtype RegRespType = RegRespType {
    a :: Boolean
}

newtype Reqtype = Reqtype { a :: Boolean }


derive instance regReqGeneric :: Generic Reqtype _
derive instance regRespGeneric :: Generic RegRespType _
instance encodeRegReq :: Encode Reqtype where encode = defaultEncode
instance decodeRegReq :: Decode Reqtype where decode = defaultDecode



instance encodeRegRes :: Encode RegRespType where encode = defaultEncode
instance decodeRegRes :: Decode RegRespType where decode = defaultDecode

instance makeRegReq :: RestEndpoint Reqtype RegRespType where
    makeRequest reqBody headers = defaultMakeRequest GET "apiAddress" headers reqBody
    decodeResponse body = defaultDecodeResponse body


----------------------------------- BankList -----------------------------------------------------------


mockWallet :: String -> Maybe Boolean -> Maybe Number -> StoredWallet
mockWallet wallet isLinked bal = StoredWallet $
    { wallet : wallet
    , token : Just ""
    , linked : isLinked
    , id :  ""
    , current_balance : bal
    , last_refreshed : Just ""
    , object : Just ""
    , currentBalance : bal
    , lastRefreshed : Just ""
    , lastUsed : Just ""
    , count : Just 0.0
    , rating : Just 0.0
    }

mockOfferDescription :: OfferDescription
mockOfferDescription = OfferDescription
    { offerDescription : Just ""
    , offerDisplay1 : Just ""
    , offerDisplay2 : Just ""
    , offerDisplay3 : Just ""
    }

mockOffer :: Offer
mockOffer = Offer
    { voucherCode : ""
    , visibleToCustomer : Just false
    , paymentMethodType :  Just ""
    , paymentMethod : Just []
    , offerDescription : Just mockOfferDescription
    }



data OrderStatus
    = CHARGED
    | UNHANDLED_ERROR String
    | COD_INITIATED

newtype InitiateTxnReq = InitiateTxnReq
    { order_id :: String
    , merchant_id :: String
    , payment_method_type :: String
    , payment_method :: String
    , redirect_after_payment :: Boolean
    , format :: String
    , txn_type :: Maybe String
    , card_token :: Maybe String
    , card_security_code :: Maybe String
    , direct_wallet_token :: Maybe String
    , client_auth_token :: Maybe String
    , card_number :: Maybe String
    , card_exp_month :: Maybe String
    , card_exp_year :: Maybe String
    , name_on_card :: Maybe String
    , save_to_locker :: Maybe Boolean
    , sdk_params :: Maybe Boolean
    , upi_app :: Maybe String
    , upi_vpa   :: Maybe String
    , upi_tr_field  :: Maybe String
    }

newtype InitiateTxnResp = InitiateTxnResp
    { order_id:: String
    , txn_id:: String
    , txn_uuid:: String
    , status:: String
    , payment :: Payment
    }

newtype Authentication = Authentication
    { method :: String
    , url :: String
    , params :: Maybe String
    }

newtype Payment = Payment {
    authentication :: Authentication
}

derive instance initiateTxnReqGeneric :: Generic InitiateTxnReq _
derive instance initiateTxnRespGeneric :: Generic InitiateTxnResp _
derive instance newtypeinitiateTxnReq :: Newtype InitiateTxnReq _
derive instance newtypeinitiateTxnResp :: Newtype InitiateTxnResp _
derive instance paymentGeneric :: Generic Payment _
derive instance newtypePayment :: Newtype Payment _
derive instance authGeneric :: Generic Authentication _
derive instance newtypeAuthentication :: Newtype Authentication _

instance encodeInitiateTxnReq :: Encode InitiateTxnReq where encode = defaultEncode
instance decodeInitiateTxnResp :: Decode InitiateTxnResp where decode = defaultDecode

instance encodePayment :: Encode Payment where encode = defaultEncode
instance decodePayment :: Decode Payment where decode = defaultDecode

instance encodeAuthentication :: Encode Authentication where encode = defaultEncode
instance decodeAuthentication :: Decode Authentication where decode = defaultDecode


instance makeInitiateTxnReq :: RestEndpoint InitiateTxnReq InitiateTxnResp where
    makeRequest reqBody headers = urlEncodedMakeRequest POST (baseUrl <> "/txns") headers reqBody
    decodeResponse body = defaultDecodeResponse body

-----------------------
-- Order Status Api
-----------------------

newtype OrderStatusReq = OrderStatusReq
    { merchant_id :: String
    , order_id :: String
    }

newtype OrderStatusResp = OrderStatusResp
    { order_id :: String
    , status   :: String
    }

derive instance orderStatusReqNewtype :: Newtype OrderStatusReq _
derive instance orderStatusReqGeneric :: Generic OrderStatusReq _
derive instance orderStatusGeneric :: Generic OrderStatus _
derive instance orderStatusRespNewtype :: Newtype OrderStatusResp _
derive instance orderStatusRespGeneric :: Generic OrderStatusResp _

instance encodeOrderStatusReq  :: Encode OrderStatusReq where encode = defaultEncode
instance decodeOrderStatusResp :: Decode OrderStatusResp where decode = defaultDecode
instance decodeOrderStatus :: Decode OrderStatus where
  decode status = do
    case (runExcept $ defaultDecode status) of
      Right s -> pure s
      Left err -> pure $ UNHANDLED_ERROR (show err)


instance checkOrderStatus :: RestEndpoint OrderStatusReq OrderStatusResp where
    makeRequest reqBody headers = urlEncodedMakeRequest GET (baseUrl <> "/order/payment-status/") headers reqBody
    decodeResponse body = defaultDecodeResponse body


---------------------------
--- Wallets
---------------------------

newtype StoredWallet = StoredWallet WalletObj

---------change it to ec response
type WalletObj =
    { wallet :: String
    , token :: Maybe String
    , linked :: Maybe Boolean
    , id :: String
    , current_balance :: Maybe Number
    , last_refreshed :: Maybe String
    , object :: Maybe String
    , currentBalance :: Maybe Number
    , lastRefreshed :: Maybe String
    , lastUsed :: Maybe String
    , count :: Maybe Number
    , rating :: Maybe Number
    }

derive instance storedWalletGeneric :: Generic StoredWallet  _
derive instance storedWalletNewtype :: Newtype StoredWallet _
instance decodeStoredWallet :: Decode StoredWallet where decode = defaultDecode
instance encodeStoredWallet :: Encode StoredWallet where encode = defaultEncode
instance eqStoredWallet :: Eq StoredWallet where eq (StoredWallet s1) (StoredWallet s2) = s1.wallet == s2.wallet

-----------------------------
--- Payment Source Types
-----------------------------

newtype PaymentSourceReq = PaymentSourceReq
  { client_auth_token :: String
  , offers :: String
  , refresh :: String
  }


newtype StoredVpa = StoredVpa
  { vpa :: String
  , id :: String
  , count :: Maybe Number
  , lastUsed :: Maybe String
  , rating :: Maybe Number
  }

newtype StoredNb = StoredNb
  { method :: String
  , id :: String
  , count :: Maybe Number
  , lastUsed :: Maybe String
  , rating :: Maybe Number
  }


newtype StoredCard = StoredCard
  { nickname :: String
  , nameOnCard :: String
  , expired :: Boolean
  , cardType :: String
  , cardToken :: String
  , cardReference :: String
  , cardNumber :: String
  , cardIssuer :: String
  , cardIsin :: String
  , cardFingerprint :: String
  , cardExpYear :: String
  , cardExpMonth :: String
  , cardBrand :: String
  , count :: Maybe Number
  , lastUsed :: Maybe String
  , rating :: Maybe Number
  }

newtype LastUsedPaymentMethod = LastUsedPaymentMethod
  { methodType :: Maybe String
  , cardBrand :: Maybe String
  , cardExpMonth :: Maybe String
  , cardExpYear :: Maybe String
  , cardFingerprint :: Maybe String
  , cardIsin :: Maybe String
  , cardIssuer :: Maybe String
  , cardNumber :: Maybe String
  , cardReference :: Maybe String
  , cardToken :: Maybe String
  , cardType :: Maybe String
  , expired :: Maybe Boolean
  , nameOnCard :: Maybe String
  , nickname :: Maybe String
  , value :: Maybe String
  }

newtype MerchantPaymentMethod = MerchantPaymentMethod
  { paymentMethodType:: String
  , paymentMethod:: String
  , description:: String
  }


newtype PaymentSourceResp = PaymentSourceResp PaymentSource

type PaymentSource =
  { wallets :: Array StoredWallet
  , vpas :: Array StoredVpa
  , nbMethods :: Array StoredNb
  , cards :: Array StoredCard
  , lastUsedPaymentMethod :: Maybe LastUsedPaymentMethod
  , merchantPaymentMethods :: Array MerchantPaymentMethod
  , appsUsed :: Array AppUsed
  , offers :: Array Offer
  }

newtype AppUsed = AppUsed
  { packageName :: Maybe String
  , lastUsed :: Maybe String
  , id :: Maybe String
  , count :: Maybe Number
  }

------------Offers Type----------------------

newtype Offer = Offer
  { voucherCode :: String
  , visibleToCustomer :: Maybe Boolean
  , paymentMethodType :: Maybe String
  , paymentMethod :: Maybe (Array String)
  , offerDescription :: Maybe OfferDescription
  }

newtype OfferDescription = OfferDescription
  { offerDescription :: Maybe String
  , offerDisplay1 :: Maybe String
  , offerDisplay2 :: Maybe String
  , offerDisplay3 :: Maybe String
  }

derive instance storedVpaGeneric :: Generic StoredVpa _
derive instance storedNbGeneric :: Generic StoredNb _
derive instance storedCardGeneric :: Generic StoredCard _
derive instance storedCardGenericNewtype :: Newtype StoredCard _
derive instance lastUsedPaymentMethodGeneric :: Generic LastUsedPaymentMethod _
derive instance merchantPaymentMethodGeneric :: Generic MerchantPaymentMethod _
derive instance appUsedGeneric :: Generic AppUsed _
derive instance paymentSourceRespGeneric :: Generic PaymentSourceResp _
derive instance paymentSourceRespNewtype :: Newtype PaymentSourceResp _
derive instance storedOfferDescription :: Generic OfferDescription  _
derive instance storedOfferDescriptionNewtype :: Newtype OfferDescription  _
derive instance storedOffer :: Generic Offer  _
derive instance storedOfferNewType :: Newtype Offer  _
derive instance paymentSourceReqGeneric :: Generic PaymentSourceReq _

derive instance merchantPaymentMethodNewtype :: Newtype MerchantPaymentMethod _

instance decodeAppUsed :: Decode AppUsed where decode = defaultDecode
instance encodeAppUsed :: Encode AppUsed where encode = defaultEncode
instance decodeStoredNb :: Decode StoredNb where decode = defaultDecode
instance encodeStoredNb :: Encode StoredNb where encode = defaultEncode
instance decodeStoredVpa :: Decode StoredVpa where decode = defaultDecode
instance encodeStoredVpa :: Encode StoredVpa where encode = defaultEncode
instance decodeStoredCard :: Decode StoredCard where decode = defaultDecode
instance encodeStoredCard :: Encode StoredCard where encode = defaultEncode
instance decodeLastUsedPaymentMethod :: Decode LastUsedPaymentMethod where decode = defaultDecode
instance encodeLastUsedPaymentMethod :: Encode LastUsedPaymentMethod where encode = defaultEncode
instance decodeOfferDescription :: Decode OfferDescription where decode = defaultDecode
instance encodeOfferDescription :: Encode OfferDescription where encode = defaultEncode
instance decodeOffer :: Decode Offer where decode = defaultDecode
instance encodeOffer :: Encode Offer where encode = defaultEncode

instance decodeMerchantPaymentMethod :: Decode MerchantPaymentMethod where decode = defaultDecode
instance encodeMerchantPaymentMethod :: Encode MerchantPaymentMethod where encode = defaultEncode

instance encodePaymentSourceReq :: Encode PaymentSourceReq where encode = defaultEncode
instance decodePaymentSourceResp :: Decode PaymentSourceResp where decode = defaultDecode

instance makePaymentSourceApiReq :: RestEndpoint PaymentSourceReq PaymentSourceResp where
  makeRequest (PaymentSourceReq reqBody) headers = defaultMakeRequest_ GET (eulerLocation <> "/savedPaymentMethods?client_auth_token="<>reqBody.client_auth_token <> "&offers=" <>reqBody.offers <> "&refresh="<> reqBody.refresh) headers
  decodeResponse body = defaultDecodeResponse body


  ----------- Fresh Card Transaction -------------------------------

newtype FreshCardTxnReq = FreshCardTxnReq {
  order_id :: String,
  merchant_id :: String,
  payment_method_type :: String, 
  payment_method :: String,
  card_number :: String,
  card_exp_month :: String,
  card_exp_year :: String,
  name_on_card :: String,
  card_security_code :: String,
  save_to_locker :: Boolean,
  redirect_after_payment :: Boolean,
  format :: String
}


newtype FreshCardTxnResp = FreshCardTxnResp {
  order_id :: String,
  txn_id :: String,
  txn_uuid :: String,
  status :: String,
  payment :: Payment
}


derive instance freshCardTxnReqGeneric :: Generic FreshCardTxnReq _
derive instance freshCardTxnRespGeneric :: Generic FreshCardTxnResp _

instance encodeFreshCardTxnReq :: Encode FreshCardTxnReq where encode = defaultEncode
instance decodeFreshCardTxnReq :: Decode FreshCardTxnReq where decode = defaultDecode

instance encodeFreshCardTxnResp :: Encode FreshCardTxnResp where encode = defaultEncode
instance decodeFreshCardTxnResp :: Decode FreshCardTxnResp where decode = defaultDecode

instance makeFreshCardTxn :: RestEndpoint FreshCardTxnReq FreshCardTxnResp where
    makeRequest reqBody headers = urlEncodedMakeRequest POST (baseUrl <> "/txns") headers reqBody
    decodeResponse body = defaultDecodeResponse body

------------------------------------------------------------------------------------------

newtype CreateWalletReq = CreateWalletReq
    { gateway :: String
    {-- , customer_id :: String --}
	, command :: String
    , client_auth_token :: String
    }

newtype CreateWalletResp = CreateWalletResp WalletObj

derive instance createWalletReqGeneric :: Generic CreateWalletReq _
derive instance createWalletRespGeneric :: Generic CreateWalletResp _

instance encodeCreateWalletReq :: Encode CreateWalletReq where encode = defaultEncode
instance decodeCreateWalletResp :: Decode CreateWalletResp where decode = defaultDecode

{-- instance createWalletInstance :: RestEndpoint CreateWalletReq CreateWalletResp where --}
{--     makeRequest (CreateWalletReq reqBody) headers = --}
{--         urlEncodedMakeRequest --}
{--             POST --}
{--             (baseUrl <> "/customers/" <> reqBody.customer_id <> "/wallets") --}
{--             headers --}
{--             (CreateWalletReq reqBody) --}
{--     decodeResponse body = defaultDecodeResponse body --}



-------------------------------------------------------------------------------------
----------- Stored Card Transaction -------------------------------

newtype StoredCardTxnReq = StoredCardTxnReq {
   order_id :: String,
   merchant_id :: String,
   payment_method_type :: String, 
   card_token :: String, 
   card_security_code :: String,
   redirect_after_payment :: Boolean,
   format :: String
}


newtype StoredCardTxnResp = StoredCardTxnResp {
  order_id:: String,
  txn_id:: String,
  txn_uuid:: String,
  status:: String,
  payment :: Payment
}

newtype StatusType = StatusType { status :: String}

derive instance statusTypesGeneric :: Generic StatusType _

instance decodeStatus :: Decode StatusType where decode = defaultDecode


derive instance storedCardTxnReqGeneric :: Generic StoredCardTxnReq _
derive instance storedCardTxnRespGeneric :: Generic StoredCardTxnResp _

instance encodeStoredCardTxnReq :: Encode StoredCardTxnReq where encode = defaultEncode
instance decodeStoredCardTxnResp :: Decode StoredCardTxnResp where decode = defaultDecode

instance makeStoredCardTxn :: RestEndpoint StoredCardTxnReq StoredCardTxnResp where
  makeRequest reqBody headers = urlEncodedMakeRequest POST (baseUrl <> "/txns/") headers reqBody
  decodeResponse body = defaultDecodeResponse body

------------------------------------------------------------------------------------------
---------------------------Link API ----------------------

newtype LinkWalletReq = LinkWalletReq
    { command :: String
    , otp :: String
    , wallet_id :: String
    , client_auth_token :: String
    , customer_id :: String
    }

newtype LinkWalletResp = LinkWalletResp WalletObj

derive instance linkWalletReqGeneric :: Generic LinkWalletReq _
derive instance linkWalletRespGeneric :: Generic LinkWalletResp _

instance encodeLinkWalletReq :: Encode LinkWalletReq where encode = defaultEncode
instance decodeLinkWalletResp :: Decode LinkWalletResp where decode = defaultDecode

instance makeWalletLink :: RestEndpoint LinkWalletReq LinkWalletResp where
    makeRequest (LinkWalletReq reqBody) headers = urlEncodedMakeRequest POST (baseUrl <> "/wallets/"<>reqBody.wallet_id) headers (LinkWalletReq $ reqBody)
    decodeResponse body = defaultDecodeResponse body


-------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------


newtype DeleteCardReq = DeleteCardReq {
   card_token :: String,
   client_auth_token :: String,
   customer_id :: String
}

newtype DeleteCardResp = DeleteCardResp {
  card_token::String,
  card_reference::String,
  deleted:: Boolean
}


derive instance deleteCardReqGeneric :: Generic DeleteCardReq _
derive instance deleteCardRespGeneric :: Generic DeleteCardResp _

instance encodeDeleteCardReq :: Encode DeleteCardReq where encode = defaultEncode
instance decodeDeleteCardReq :: Decode DeleteCardReq where decode = defaultDecode

instance encodeDeleteCardResp :: Encode DeleteCardResp where encode = defaultEncode
instance decodeDeleteCardResp :: Decode DeleteCardResp where decode = defaultDecode

instance makeDeleteCard :: RestEndpoint DeleteCardReq DeleteCardResp where
    makeRequest reqBody headers = urlEncodedMakeRequest POST (baseUrl <> "/card/delete") headers reqBody
    decodeResponse body = defaultDecodeResponse body

-----------------------

newtype DeleteVpaReq = DeleteVpaReq {
   client_auth_token :: String,
   id :: String
}

newtype DeleteVpaResp = DeleteVpaResp String


derive instance deleteVpaReqGeneric :: Generic DeleteVpaReq _
derive instance deleteVpaRespGeneric :: Generic DeleteVpaResp _

instance encodeDeleteVpaReq :: Encode DeleteVpaReq where encode = defaultEncode
instance decodeDeleteVpaResp :: Decode DeleteVpaResp where decode = defaultDecode


instance makeDeleteVpa :: RestEndpoint DeleteVpaReq DeleteVpaResp where
  makeRequest (DeleteVpaReq reqBody) headers = defaultMakeRequest_ DELETE (eulerLocation <>"/savedPaymentMethods/upi/"<>reqBody.id<>"?client_auth_token="<>reqBody.client_auth_token) headers
  decodeResponse body = defaultDecodeResponse body



---------------------------Delink API ----------------------

newtype DelinkWalletReq = DelinkWalletReq
    { command :: String
    , wallet_id :: String
    , client_auth_token :: String
    }

newtype DelinkWalletResp = DelinkWalletResp WalletObj

derive instance delinkWalletReqGeneric :: Generic DelinkWalletReq _
derive instance delinkWalletRespGeneric :: Generic DelinkWalletResp _

instance encodeDelinkWalletReq :: Encode DelinkWalletReq where encode = defaultEncode
instance decodeDelinkWalletResp :: Decode DelinkWalletResp where decode = defaultDecode

instance makeWalletDelink :: RestEndpoint DelinkWalletReq DelinkWalletResp where
    makeRequest (DelinkWalletReq reqBody) headers = urlEncodedMakeRequest POST (baseUrl <> "/wallets/"<>reqBody.wallet_id) headers (DelinkWalletReq $ reqBody)
    decodeResponse body = defaultDecodeResponse body



