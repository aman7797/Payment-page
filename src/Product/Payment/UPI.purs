module Product.Payment.UPI where

import Prelude

import Control.Monad.Except (runExceptT)
import Control.Transformers.Back.Trans (runBackT)
import Data.Either (Either(..))
import Engineering.Types.App (FlowBT, UPIError)
import Presto.Core.Types.Language.Flow (Flow)

startUPIFlow :: Flow Unit
startUPIFlow = do
    result <- runExceptT <<< runBackT $ upiPage  -- Change to UI Call
    case result of
        Right _ -> pure unit
        Left _  -> pure unit


upiPage :: FlowBT UPIError Unit -- UPI PAGE RESPONSE
upiPage = do
    -- action <- liftFlowBT $ runScreen (SelectBankPage.screen "")
    -- case action of
    --     Register account -> 
    --         -- register <- UPI.Register account
    --         pure unit
    --     FetchAccounts bank -> 
            -- accounts <- UPI.getAccounts bank
            -- startUPIFlow  --- MOVE TO SOME RIGHT CASE IN FLOW
            pure unit