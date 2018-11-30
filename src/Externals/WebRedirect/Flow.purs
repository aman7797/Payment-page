module Externals.WebRedirect.Flow where

import Effect.Aff (makeAff, nonCanceler)
import Effect (Effect)
import Effect.Uncurried
import Data.Either (Either(..))
import Foreign.Generic (encodeJSON)
{-- import Foreign.NullOrUndefined (unNullOrUndefined) --}
import Data.Lens ((^.))
import Data.Maybe (Maybe(..))
import Engineering.Helpers.Commons (AffSuccess)
import Engineering.Types.App (MicroAppResponse, liftFlowBT, PaymentPageError, FlowBT)
import Prelude (Unit, pure, ($), (*>), (>>>))
import Presto.Core.Flow (doAff)
import Remote.Accessors (_payment, _authentication, _url, _method, _params)
import Remote.Types
import Tracker.Tracker (trackHyperPayEvent')

foreign import redirect
    :: EffectFn3
        String
        (Maybe String)
        (AffSuccess MicroAppResponse)
        Unit

{-- type MicroAPPInvokeSignature = String -> (AffSuccess MicroAppResponse) -> (forall val . val -> Effect Unit) -> Effect Unit --}


startRedirect :: InitiateTxnResp -> FlowBT PaymentPageError MicroAppResponse
startRedirect resp = liftFlowBT $ doAff do makeAff (\cb -> (runEffectFn3 redirect  (resp ^. _payment ^. _authentication ^. _url) Nothing  (Right >>> cb)) *> pure nonCanceler)

{-- mkWebRedirectParams : --} 
{-- mkWebRedirectParams payment = --}
{--   case payment ^. _authentication ^. _method of --}
{--     "GET" -> (payment ^. _authentication ^. _url) Nothing --}
{--     _ -> mkGodelParams' (payment ^. _authentication ^. _url) (payment ^. _authentication ^. _params) --}
