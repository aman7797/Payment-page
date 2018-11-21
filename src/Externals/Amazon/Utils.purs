module Externals.Amazon.Utils where

import Externals.Amazon.Types (AmazonChargeStatusResponse)
import Remote.Amazon.Types (AmazonChargeStatusReq(..),ValidateAmazonChargeStatusReq(..))
import Engineering.Helpers.Constants (transactionIdType,chargeStatusOperationName,chargeValidateOperationName)
import Data.Maybe (Maybe(..))

chargeStatusReqPayload :: String -> String -> AmazonChargeStatusReq
chargeStatusReqPayload txn_id txn_uuid =
  AmazonChargeStatusReq
  { transactionId : txn_id
  , transactionIdType : transactionIdType
  , operationName : chargeStatusOperationName
  , txn_uuid : Just txn_uuid
  }

mkValidateChargeStatusPayload :: String -> AmazonChargeStatusResponse -> ValidateAmazonChargeStatusReq
mkValidateChargeStatusPayload return_url resp =
  ValidateAmazonChargeStatusReq
  { returnUrl : Just return_url
  , signature : resp.signature
  , operationName : chargeValidateOperationName
  , transactionStatusCode : resp.transactionStatusCode 
  , transactionStatusDescription : resp.transactionStatusDescription
  , merchantTransactionId : resp.merchantTransactionId
  , transactionCurrencyCode : resp.transactionCurrencyCode
  , transactionValue : resp.transactionValue
  , transactionDate : resp.transactionDate
  , transactionId : resp.transactionId
  }