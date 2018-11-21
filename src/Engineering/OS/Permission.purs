module Engineering.OS.Permission where

import Prelude

import Effect.Aff (makeAff, Aff, nonCanceler)
import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Exception (Error, error)
import Control.Monad.Except (runExcept, throwError)
import Control.Monad.Rec.Class (class MonadRec, Step(Done, Loop), tailRecM)
import Data.Array (singleton, zip)
import Data.Either (Either(..))
import Data.Foldable (all)
import Foreign.Generic (decodeJSON)
import Data.Function.Uncurried (Fn3, runFn3)
import Data.List (List(..), (:),fromFoldable)
import Data.String (Pattern(..), contains)
import Data.Tuple (Tuple(..))
import Presto.Core.Types.Language.Flow (Flow, checkPermissions, takePermissions)
import Presto.Core.Types.Permission (Permission(..), PermissionResponse, PermissionStatus(..))

{-- foreign import getPermissionStatus' :: Fn3 (Error -> Effect Unit) (String -> Effect Unit) String (Effect Unit) --}
foreign import getPermissionStatus' :: Array String -> (Effect String)
foreign import requestPermission' :: Fn3 (Error -> Effect Unit) (String -> Effect Unit) String (Effect Unit)


toAndroidPermission :: Permission -> String
toAndroidPermission PermissionSendSms = "android.permission.SEND_SMS"
toAndroidPermission PermissionReadPhoneState = "android.permission.READ_PHONE_STATE"
toAndroidPermission PermissionWriteStorage = "android.permission.WRITE_EXTERNAL_STORAGE"
toAndroidPermission PermissionReadStorage = "android.permission.READ_EXTERNAL_STORAGE"
toAndroidPermission PermissionCamera = "android.permission.CAMERA"
toAndroidPermission PermissionLocation = "android.permission.ACCESS_FINE_LOCATION"
toAndroidPermission PermissionCoarseLocation = "android.permission.ACCESS_COARSE_LOCATION"
toAndroidPermission PermissionContacts =  "android.permission.READ_CONTACTS"

allPermissionGranted :: Array PermissionResponse -> Boolean
allPermissionGranted = all (\(Tuple _ status) -> status == PermissionGranted)

getStoragePermission :: Flow Boolean
getStoragePermission =
  ifM (storageGranted) (pure true) (askForStorage)
  where
    storageGranted :: Flow Boolean
    storageGranted = do
    	 status <- checkPermissions [PermissionWriteStorage]
    	 case status of
    	 	PermissionGranted -> pure true
    		_ -> pure false
    askForStorage :: Flow Boolean
    askForStorage = pure <<< allPermissionGranted =<< takePermissions [PermissionWriteStorage]

storagePermissionGranted :: Flow Boolean
storagePermissionGranted = do
	 status <- checkPermissions [PermissionWriteStorage]
	 case status of
	 	PermissionGranted -> pure true
		_ -> pure false

getPermissionStatus :: Permission -> Effect Boolean
getPermissionStatus permission = do
  value <- getPermissionStatus' $ singleton $ toAndroidPermission permission
  pure $ contains (Pattern "true") value

checkIfPermissionsGranted :: Array Permission -> Aff PermissionStatus
checkIfPermissionsGranted permissions = do
  check <- liftEffect $ allM getPermissionStatus $ fromFoldable permissions
  pure $ if check
    then PermissionGranted
    else PermissionDeclined

requestPermissions :: Array Permission -> Aff (Array PermissionResponse)
requestPermissions permissions = do
  response <- makeAff (\cb -> runFn3 requestPermission' (cb <<< Left) (cb <<< Right) (show jPermission) *> pure nonCanceler)
  case runExcept $ decodeJSON response of
    Right (statuses :: Array Boolean) -> pure $ zip permissions (map toResponse statuses)
    Left err -> throwError (error (show err))
  where
    toResponse wasGranted = if wasGranted then PermissionGranted else PermissionDeclined
    jPermission = map toAndroidPermission permissions

allM :: forall m a. MonadRec m => (a -> m Boolean) -> List a -> m Boolean
allM p = tailRecM go where
  go Nil    = pure $ Done true
  go (x:xs) = ifM (p x) (pure $ Loop xs) (pure $ Done false)


