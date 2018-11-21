module Engineering.Helpers.Commons where

import Prelude

import Effect.Aff (makeAff, nonCanceler)
import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Exception (Error)
import Control.Monad.Except.Trans (ExceptT(..))
import Control.Transformers.Back.Trans (BackT(..), FailBack(..))
import Data.Either (Either(..))
import Foreign (Foreign, isNull, unsafeFromForeign)
import Data.Function.Uncurried (Fn2, Fn3, runFn3)
import Data.Maybe (Maybe(..))
import Engineering.Types.App (FlowBT, PaymentPageError, liftFlowBT)
import Engineering.Types.App as App
import Presto.Core.Flow (Flow, doAff, oneOf, runScreen, runUI)
import Presto.Core.Types.API (Header(..), Headers(..), Request(..), URL)
import Presto.Core.Types.Language.Interaction (class Interact)
import PrestoDOM (Screen)

foreign import showUI' :: Fn2 (String -> Effect  Unit) String (Effect Unit)
foreign import callAPI' :: AffError -> AffSuccess String -> NativeRequest -> (Effect Unit)
foreign import bankList :: Unit -> String
foreign import log :: forall a. String -> a -> a
foreign import startAnim :: String -> Effect Unit
foreign import startAnim_ :: String -> Unit
foreign import onBackPress' :: (Unit -> Effect Unit) -> Effect Unit
foreign import unsafeGet' :: String -> Effect Foreign
foreign import setOnWindow' :: forall a. String -> a -> Effect Unit
foreign import dpToPx :: Int -> Int
foreign import bringToFocus :: String -> String -> Boolean
foreign import checkPermissions :: (Array String) -> Effect String
foreign import requestPermissions :: (AffSuccess String ) -> (Array String) -> Effect Unit
foreign import getIin :: String -> String
foreign import getNbIin :: String -> String
foreign import getIinNb :: String -> String
foreign import ourMaybe :: forall a. Maybe a -> a


type NativeHeader = { field :: String , value :: String}
type NativeHeaders = Array NativeHeader
type AffError = (Error -> Effect Unit)
type AffSuccess s = (s -> Effect Unit)


liftFlow :: forall val . (Effect val)  -> Flow val
liftFlow effVal = doAff do liftEffect (effVal)

newtype NativeRequest = NativeRequest
  { method :: String
  , url :: URL
  , payload :: String
  , headers :: NativeHeaders
  }


mkNativeRequest :: Request -> NativeRequest
mkNativeRequest (Request request@{headers: Headers hs}) = NativeRequest
                                          { method : show request.method
                                            , url: request.url
                                            , payload: request.payload
                                            , headers: mkNativeHeader <$> hs
                                            }

mkNativeHeader :: Header -> NativeHeader
mkNativeHeader (Header field val) = { field: field, value: val}


runUI' :: forall a b e. Interact Error a b => a -> App.Flow e b
runUI' a = ExceptT (Right <$> runUI a)

onBackPress :: forall a. Flow (FailBack a)
onBackPress = doAff do
  makeAff (\sc -> onBackPress' (Right >>> sc) *> pure nonCanceler ) *> pure GoBack

liftRunUI' :: forall action state s. (Screen action state s) -> FlowBT PaymentPageError s
liftRunUI' a = BackT <<< ExceptT $ Right <$> (((<$>) identity) <$> oneOf [ (BackPoint <$> runScreen a) , onBackPress ])


runUINoBack :: forall action state s. (Screen action state s) -> FlowBT PaymentPageError s
runUINoBack a = BackT <<< ExceptT $ Right <$> (((<$>) identity) <$> oneOf [ (NoBack <$> runScreen a) , onBackPress ])

getFromWindow :: forall a. String -> Flow (Maybe a)
getFromWindow key = do
  val <- doAff (liftEffect $ unsafeGet' key)
  case (isNull val) of
    true -> pure Nothing
    false -> pure $ Just (unsafeFromForeign val)

setOnWindow :: forall a t. String -> a -> FlowBT t Unit
setOnWindow key val = liftFlowBT $ doAff (liftEffect $ setOnWindow' key val)

continue :: forall a m. Applicative m => a -> m a
continue = pure


foreign import unsafeJsonStringify :: forall a. a -> String
foreign import unsafeJsonDecodeImpl :: forall a. Fn3 String (a -> Maybe a) (Maybe a) (Maybe a)

unsafeJsonDecode :: forall a. String -> Maybe a
unsafeJsonDecode val = runFn3 unsafeJsonDecodeImpl val Just Nothing


