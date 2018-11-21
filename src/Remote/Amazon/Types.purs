module Remote.Amazon.Types where

import Prelude ((<>),($))
import Data.Maybe (Maybe(Nothing),fromMaybe)
import Foreign.Class (class Decode, class Encode)
{-- import Foreign.NullOrUndefined (NullOrUndefined(..),unNullOrUndefined) --}
import Data.Generic.Rep (class Generic)

import Presto.Core.Types.API (class RestEndpoint,Method(POST), defaultDecodeResponse)
import Presto.Core.Utils.Encoding (defaultDecode, defaultEncode)

import Network (urlEncodedMakeRequest)
import Remote.Config (baseUrl)

----------------------------------------- AMAZON CHARGE STATUS -------------------------------------

newtype AmazonChargeStatusReq = AmazonChargeStatusReq
  { transactionId::String
  , transactionIdType::String
  , operationName :: String
  , txn_uuid:: Maybe String
  }

newtype AmazonChargeStatusResp = AmazonChargeStatusResp
  { payload :: String
  , status :: String
  }

derive instance amazonChargeStatusReqGeneric :: Generic AmazonChargeStatusReq _
derive instance amazonChargeStatusRespGeneric :: Generic AmazonChargeStatusResp _

instance decodeAmazonChargeStatusResp:: Decode AmazonChargeStatusResp where decode = defaultDecode
instance encodeAmazonChargeStatusReq :: Encode AmazonChargeStatusReq where encode = defaultEncode

instance makeAmazonChargeStatusReq :: RestEndpoint AmazonChargeStatusReq AmazonChargeStatusResp where
    makeRequest reqBody@(AmazonChargeStatusReq req) headers =
        urlEncodedMakeRequest
            POST
            (baseUrl <> "/txns/"<>(fromMaybe ""  req.txn_uuid) <> "/sign-and-encrypt-amazonpay-payload")
            headers (AmazonChargeStatusReq $ req {txn_uuid =  Nothing})
    decodeResponse body = defaultDecodeResponse body

----------------------------------------- VALIDATE AMAZON CHARGE STATUS -------------------------------------

newtype ValidateAmazonChargeStatusReq = ValidateAmazonChargeStatusReq
  { returnUrl :: Maybe String
  , signature :: String
  , operationName :: String
  , transactionStatusCode :: String
  , transactionStatusDescription :: String
  , merchantTransactionId :: String
  , transactionCurrencyCode :: String 
  , transactionValue :: String 
  , transactionDate :: String
  , transactionId :: String
  }

newtype ValidateAmazonChargeStatusResp = ValidateAmazonChargeStatusResp
  { status :: String
  , status_code :: String
  , message :: String
  }

derive instance validateAmazonChargeStatusReqGeneric :: Generic ValidateAmazonChargeStatusReq _
derive instance validatemazonChargeStatusRespGeneric :: Generic ValidateAmazonChargeStatusResp _

instance decodeAmazonChargeStatus :: Decode ValidateAmazonChargeStatusResp where decode = defaultDecode
instance encodeAmazonChargeStatus :: Encode ValidateAmazonChargeStatusReq where encode = defaultEncode

instance makeVerifyAmazonChargeStatusReq :: RestEndpoint ValidateAmazonChargeStatusReq ValidateAmazonChargeStatusResp where 
    makeRequest reqBody@(ValidateAmazonChargeStatusReq req) headers =
        urlEncodedMakeRequest
            POST
            (fromMaybe "" req.returnUrl )
            headers
            (ValidateAmazonChargeStatusReq $ req {returnUrl = Nothing } )
    decodeResponse body = defaultDecodeResponse body