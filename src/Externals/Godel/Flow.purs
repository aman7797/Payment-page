module Externals.Godel.Flow where

import Effect.Aff (makeAff, nonCanceler)
import Effect (Effect)
import Data.Either (Either(..))
import Foreign.Generic (encodeJSON)
{-- import Foreign.NullOrUndefined (unNullOrUndefined) --}
import Data.Lens ((^.))
import Data.Maybe (Maybe(..))
import Engineering.Helpers.Commons (AffSuccess)
import Engineering.Types.App (MicroAppResponse, liftFlowBT, PaymentPageError, FlowBT)
import Externals.Godel.Types (InitiateGodelReq)
import Externals.Godel.Utils (mkGodelParams')
import Prelude (Unit, pure, ($), (*>), (>>>))
import Presto.Core.Flow (doAff)
import Remote.Accessors (_authentication, _url, _method, _params)
import Remote.Types (Payment)
import Tracker.Tracker (trackHyperPayEvent')

foreign import startGodel'  :: MicroAPPInvokeSignature

type MicroAPPInvokeSignature = String -> (AffSuccess MicroAppResponse) -> (forall val . val -> Effect Unit) -> Effect Unit


startGodel :: InitiateGodelReq -> FlowBT PaymentPageError MicroAppResponse
startGodel godelReq = liftFlowBT $ doAff do makeAff (\cb -> (startGodel'  (encodeJSON godelReq) (Right >>> cb) (trackHyperPayEvent' "response_from_godel")) *> pure nonCanceler)

mkGodelParams :: Payment -> FlowBT PaymentPageError InitiateGodelReq
mkGodelParams payment =
  case payment ^. _authentication ^. _method of
    "GET" -> mkGodelParams' (payment ^. _authentication ^. _url) Nothing
    _ -> mkGodelParams' (payment ^. _authentication ^. _url) (payment ^. _authentication ^. _params)
