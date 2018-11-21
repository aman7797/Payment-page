module Externals.UPI.Types where

import Foreign.Class (class Decode)
import Data.Nullable (Nullable)
import Data.Generic.Rep (class Generic)
import Presto.Core.Utils.Encoding (defaultDecode)
import Data.Newtype (class Newtype)

type UPIIntentPayload =
  { merchant_id :: String
  , client_id :: String
  , display_note :: String
  , order_id :: String
  , currency :: String
  , environment :: String
  , "WHITE_LIST" :: String
  , "UPI_PAYMENT_METHOD" :: String
  , get_available_apps :: Nullable String
  , pay_with_app :: Nullable String
  }

newtype UPIAppListResp = UPIAppListResp
  { status :: String
  , response :: UPIAppList
  }

newtype UPIAppList = UPIAppList
  { available_apps :: Array UPIAppData
  }

newtype UPIAppData = UPIAppData
  { packageName :: String
  , appName :: String
  }

derive instance upiAppListRespGeneric :: Generic UPIAppListResp _
derive instance newtypeUPIAppListResp :: Newtype UPIAppListResp _
derive instance newtypeUPIAppList :: Newtype UPIAppList _
derive instance newtypeUPIAppData :: Newtype UPIAppData _
instance decodeUPIAppListResp :: Decode UPIAppListResp where decode = defaultDecode

derive instance upiAppListGeneric :: Generic UPIAppList _
instance decodeUPIAppList :: Decode UPIAppList where decode = defaultDecode

derive instance upiAppDataGeneric :: Generic UPIAppData _
instance decodeUPIAppData :: Decode UPIAppData where decode = defaultDecode