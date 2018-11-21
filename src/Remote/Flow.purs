module Remote.Flow where


import Presto.Core.Flow (Flow, callAPI)
import Presto.Core.Types.API (Header(..), Headers(..))
import Presto.Core.Types.Language.Flow (APIResult)
import Remote.Types (RegRespType, Reqtype(..))

loginUser :: Flow (APIResult RegRespType)
loginUser = do
      callAPI headers req where
            headers =  Headers [(Header "Content-Type" "application/json")]
            req = Reqtype {a : true}