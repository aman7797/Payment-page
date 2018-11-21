module Externals.Amazon.Types where

type AmazonLinkStatus =
  { linked :: Boolean
  , balance :: Number
  }

type AmazonChargeStatusResponse =
  { transactionStatusDescription :: String
  , signature :: String
  , verificationOperationName :: String
  , merchantTransactionId :: String
  , transactionCurrencyCode :: String
  , transactionStatusCode :: String
  , transactionValue :: String
  , transactionDate :: String
  , transactionId :: String
  }