module Network where
  
import Prelude (Unit, pure, ($), (*>), (<<<), (<>), (==), (>>=), (>>>))

import Effect (Effect)
import Effect.Aff (makeAff, nonCanceler)
import Control.Monad.Except (runExcept)
import Data.Array (concatMap, (:))
import Data.Either (Either(..), either)
import Foreign (Foreign, readString, typeOf)
import Foreign.Class (class Encode, encode)
import Foreign.Generic (decodeJSON)
import Foreign.Class (class Encode, encode)
import Foreign.Generic (decodeJSON)
import Foreign.Generic.Class (class GenericEncode)
import Foreign.Index (readProp)
import Data.Generic.Rep (class Generic)
import Foreign.Keys (keys)
import Data.List (List(..), fromFoldable)
import Data.Tuple (Tuple(..))
import Presto.Core.Utils.Encoding (defaultEncodeJSON)
import UI.Utils (logit)
import Unsafe.Coerce (unsafeCoerce)

--import Engineering.Types.API (class RestEndpoint, ErrorPayload(..), Header(..), Headers(..), Method, ParameterValue, Request(Request), URL, ErrorResponse(..), decodeResponse, makeRequest)

import Presto.Core.Types.API (ErrorResponse, Header(..), Headers(..), Method, Request(..), URL)
import Global.Unsafe (unsafeEncodeURIComponent)
import Presto.Core.Flow (Flow,doAff)
import Engineering.Helpers.Commons (AffSuccess)

foreign import jsonStringify :: forall a. a -> String
foreign import backPressHandler' :: AffSuccess String ->  Effect Unit

urlEncodedMakeRequest
    :: forall r2 req
     . Encode req
    => Generic req r2
    => GenericEncode r2
    => Method
    -> URL
    -> Headers
    -> req
    -> Request
urlEncodedMakeRequest method url (Headers headers) req = Request
    { method
    , url
    , headers : Headers (Header "Content-Type" "application/x-www-form-urlencoded"
                : headers)
    , payload: defaultEncodeJSON req
  }

toKeyVals :: forall req. Encode req => req -> Array (Tuple String String)
toKeyVals body = concatMap (\key' ->
  case runExcept $ readProp key' body' of
    Left _ -> []
    Right parameter -> if typeOf parameter == "undefined"
      then []
      else [Tuple key' $ getParam parameter]) (getObjectKeys <<< encode $ body)
  where body' = encode body
        getParam parameter = either
          (\e -> jsonStringify parameter) (\s -> s)
          (runExcept <<< readString $ parameter)

getObjectKeys :: Foreign -> Array String
getObjectKeys body = either
  (\_ -> []) (\objectKeys -> objectKeys)
  (runExcept <<< keys <<< encode $ body)

urlEncode :: forall a. Encode a => a -> String
urlEncode a = toUrlEncoded $ fromFoldable $ toKeyVals a
  where toUrlEncoded :: List (Tuple String String) -> String
        toUrlEncoded  Nil = ""
        toUrlEncoded (Cons (Tuple key val) Nil) = (unsafeEncodeURIComponent key) <> "=" <> (unsafeEncodeURIComponent val)
        toUrlEncoded (Cons (Tuple key val) as) = (unsafeEncodeURIComponent key) <> "=" <> (unsafeEncodeURIComponent val) <> "&" <> toUrlEncoded as

_backPressHandler :: Flow String
_backPressHandler = doAff do makeAff (\cb ->backPressHandler' (Right >>> cb) *> pure nonCanceler)

backPressHandler :: Flow ErrorResponse
backPressHandler = _backPressHandler >>= decodeErrorPayload

decodeErrorPayload :: String -> Flow ErrorResponse
decodeErrorPayload = either (unsafeCoerce <<< logit) pure <<< runExcept <<< decodeJSON