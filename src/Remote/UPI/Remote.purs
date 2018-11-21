module UPI.Remote where

import Prelude

import Foreign.Class (class Decode, class Encode)
import Foreign.Generic.Class (class GenericEncode)
import Data.Generic.Rep (class Generic)
import Engineering.Helpers.Commons (log)
import JBridge (encrypt)
import Presto.Core.Types.API (class RestEndpoint, Header(..), Headers(..), Method(..), Request(..), URL, defaultDecodeResponse)
import Presto.Core.Types.Language.Flow (APIResult, Flow, callAPI)
import Presto.Core.Utils.Encoding (defaultDecode, defaultEncode, defaultEncodeJSON)
import Remote.Config (baseUPI, encKey)
import Type.Data.Boolean (kind Boolean)

foreign import getOSVersion ::Unit -> String
foreign import getPackageName ::Unit -> String


upiCall :: RequestObject -> Flow (APIResult UPIRequest)
upiCall (RequestObject req) = do
  let _ = log "Request Body" (encyptMsg req)
  callAPI header (RequestObject $ encyptMsg req)
  where
    header = Headers [
        Header "Content-Type" "application/json"
    ]
    -- req = RequestObject {  requestMsg   : "YES0000000010334|GKvhzZ3H1nf|123|com.mindgate.SDK.UI.SampleApp|19.112088,72.930825|Mumbai|172.16.50.211|MOB|7446489340284893413847123456709876|IOS 10.2|3DF8E14CEBD3012B4D288DB31747145B21F4F496D845D23B73B0E301694D30A797C0ED3D05418EB6F6A7D840298445C22E9569B9BFC84A774B4D8DF0E90A5E640AB4C372DFB149F1ECB973AEB9551B5E|3DF8E14CEBD3012B4D288DB31747145B21F4F496D845D23B73B0E301694D30A797C0ED3D05418EB6F6A7D840298445C22E9569B9BFC84A774B4D8DF0E90A5E640AB4C372DFB149F1ECB973AEB9551B5E|1|1|1|||||||||NA|NA"
    --                     ,  url : "https://uatsky.yesbank.in:443/app/uat/IntegrationServices/deviceStatusMEService"
    --                     ,  token : "7F8D44CF8272407337BBF0648EFC6E75D74473EBF7E20DADFB97970532F0B41D1AADE1DF9B09BE39B2335AB8155B522645A667CFF4445F2E887316FE1202B506A989A321D7ADB31BDC2DD1C004D92B98"
    --                     ,  pgMerchantId : "YES0000000010334"
    --                     }
-------------------------------------------------------------------------------------

encyptMsg :: forall t24.
  { requestMsg :: String
  | t24
  }
  -> { requestMsg :: String
     | t24
     }
encyptMsg req = req {requestMsg = encrypt (log "DECR REQUEST" req.requestMsg) encKey}

newtype UPIRequest = UPIRequest {
  responseMsg           :: String,
  responseMsgEncrypted  :: String,
  pgMerchantId          :: String
}

instance encodeUPIRequest :: Encode UPIRequest where
  encode = defaultEncode

instance decodeUPIRequest :: Decode UPIRequest where
  decode = defaultDecode

derive instance genericUPIReqt :: Generic UPIRequest _
derive instance genericUPIResp :: Generic UPIResponse _

-- instance upiAPIInstance :: RestEndpoint UPIRequest UPIResponse where
--     makeRequest reqBody headers = defaultMakeRequest POST "https://uatsky.yesbank.in:444/app/uat/IntegrationServices/deviceStatusMEService" headers reqBody
--     decodeResponse body = defaultDecodeResponse body

newtype UPIResponse = UPIResponse {
  response :: String
}

---------------------------------------------------------------------------
newtype RequestObject = RequestObject 
  { requestMsg :: String
  , url :: String
  , token :: String
  , pgMerchantId :: String
  , client_auth_token :: String
  , encryptionRequired :: Boolean
  }

instance encodeRequestObject :: Encode RequestObject where
  encode = defaultEncode

instance decodeUPIResponse :: Decode UPIResponse where
  decode = defaultDecode

derive instance genericRequestObject :: Generic RequestObject _

instance upiARequestObject :: RestEndpoint RequestObject UPIRequest where
    makeRequest req@(RequestObject reqBody) headers = defaultMakeRequest POST (baseUPI <> "?client_auth_token=" <> reqBody.client_auth_token) headers req
    decodeResponse body = defaultDecodeResponse body

 -- RELPACE FOR TESTING --"http://192.168.34.117:8081/v1/yes/callYesApis"-- 

defaultMakeRequest :: forall a x. Generic a x => GenericEncode x
                   => Method -> URL -> Headers -> a -> Request
defaultMakeRequest method url headers req = Request { method:  method
                                                    , url: url
                                                    , headers: headers
                                                    , payload: defaultEncodeJSON req
                                                    }