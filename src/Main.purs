module Main where

import Prelude

import Effect.Aff (launchAff_, makeAff, nonCanceler)
import Effect.Aff.AVar (new) as AVar
import Effect (Effect)
import Control.Monad.State as S
import Data.Either (Either(..))
import Data.Function.Uncurried (runFn2)
import Foreign.Object (empty)
import Engineering.Helpers.Commons (callAPI', mkNativeRequest, showUI')
import Engineering.Helpers.Utils (checkoutDetails)
import Engineering.OS.Permission (checkIfPermissionsGranted, requestPermissions)
import Presto.Core.Language.Runtime.API (APIRunner)
import Presto.Core.Language.Runtime.Interpreter (PermissionCheckRunner, PermissionRunner(..), PermissionTakeRunner, Runtime(..), UIRunner, run)
import Product.Core(appFlow)


runFreeAndNativeFlows :: forall a b. Discard a => Bind b => Applicative b => b a -> b Unit
runFreeAndNativeFlows freeFlow = do
  freeFlow
  pure $ unit

main :: Effect Unit
main = do
  let runtime  = Runtime uiRunner permissionRunner apiRunner
  let isActivityRecreated = (checkoutDetails.activity_recreated == "true")
  let freeFlow = S.evalStateT (run runtime (appFlow isActivityRecreated))
  launchAff_ (AVar.new empty >>= runFreeAndNativeFlows <<< freeFlow)
  where

  uiRunner :: UIRunner
  uiRunner a = makeAff (\cb -> do
      _ <- runFn2 showUI' (cb <<< Right) ""
      pure $ nonCanceler
                          )
  permissionCheckRunner :: PermissionCheckRunner
  permissionCheckRunner = checkIfPermissionsGranted

  permissionTakeRunner :: PermissionTakeRunner
  permissionTakeRunner = requestPermissions

  permissionRunner :: PermissionRunner
  permissionRunner = PermissionRunner permissionCheckRunner permissionTakeRunner

  apiRunner :: APIRunner
  apiRunner request = makeAff (\cb -> do
      _ <- callAPI' (cb <<< Left) (cb <<< Right) (mkNativeRequest request)
      pure $ nonCanceler
    )

-- appFlow :: Flow Unit
-- appFlow = initUI *> runScreen (UI.screen "")
