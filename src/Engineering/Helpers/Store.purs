module Engineering.Helpers.Store
    ( Status(..)
    , Store(..)
    , Request(..)
    , Key(..)
    , initiate
    , setValue
    , getValue
    , status
    , lazyGet
    ) where

import Prelude


import Effect.Aff (makeAff, nonCanceler, runAff_)
import Effect (Effect)
import Effect.Exception (Error)
import Effect.Uncurried as EffFn

import Data.Either (Either(Right, Left))

import Data.Maybe (Maybe(..))

foreign import setToStore :: forall a. EffFn.EffectFn2 String a Unit

foreign import setErrorToStore :: EffFn.EffectFn2 String Error Unit

foreign import getFromStore :: forall a . EffFn.EffectFn3 String (Maybe a) (a -> Maybe a) (Maybe a)

foreign import registerCallback :: forall a. EffFn.EffectFn2 String  (a -> Effect Unit) Unit

foreign import checkStatus :: EffFn.EffectFn1 String Int

newtype Key = Key String


data Request
    = Registered
    | Responsed
    | NoReq

data Store
    = Initiated
    | Populated

data Status
    = Status Store Request
    | NoKey



storeCallback :: forall a. Key -> Either Error a -> Effect Unit
storeCallback (Key key) =
    case _ of
         Left err -> EffFn.runEffectFn2 setErrorToStore key err
         Right a  -> EffFn.runEffectFn2 setToStore key a


initiate :: forall a. Key -> ((Either Error a -> Effect Unit) -> Effect Unit) -> Effect Unit
initiate key fn = do
    _ <- runAff_ (storeCallback key) $ makeAff (\cb -> fn cb *> pure nonCanceler)
    pure unit



setValue :: forall a. Key -> a -> Effect Unit
setValue (Key key) value = EffFn.runEffectFn2 setToStore key value

getValue :: forall a. Key -> Effect (Maybe a)
getValue (Key key) = EffFn.runEffectFn3 getFromStore key Nothing Just



status :: Key -> Effect Status
status (Key key) = EffFn.runEffectFn1 checkStatus key >>= pure <<<
    case _ of
         0 -> NoKey
         1 -> Status Initiated NoReq
         2 -> Status Initiated Registered
         3 -> Status Populated NoReq
         4 -> Status Populated Responsed
         _ -> NoKey

lazyGet :: forall a. Key -> (a -> Effect Unit) -> Effect Unit
lazyGet (Key key) cb = EffFn.runEffectFn2 registerCallback key cb



