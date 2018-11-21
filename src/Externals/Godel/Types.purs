module Externals.Godel.Types where

import Foreign.Class (class Encode)
{-- import Foreign.Generic (encodeJSON) --}
{-- import Foreign.NullOrUndefined (NullOrUndefined) --}
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe)
import Data.Newtype (class Newtype)
import Presto.Core.Utils.Encoding (defaultEncode)
{-- import Remote.Types (Reqtype(..)) --}

newtype InitiateGodelReq = InitiateGodelReq
  { customBrandingLayout :: String
  , customBrandingEnabled :: String
  , customer_email :: String
  , client_id :: String
  , customer_phone_number :: String
  , endUrls :: String
  , customerId :: String
  , logsPostingEnabled :: String
  , amount :: String
  , logsPostingUrl :: String
  , verifyAssets :: String
  , sessionToken :: String
  , offerApplied :: String
  , customBrandingVersion :: String
  , environment :: String
  , merchant_id :: String
  , udf_cashDisabled :: String
  , clearCookies :: String
  , order_id :: String
  , offerCode :: String
  , sdkName :: String
  , service :: String
  , udf_itemCount :: String
  , url :: String
  , postData :: Maybe String
  }

derive instance initiateGodelReq :: Generic InitiateGodelReq _
derive instance initiateGodelReqNew :: Newtype InitiateGodelReq _
instance encodeInitateGodeReq :: Encode InitiateGodelReq where encode = defaultEncode