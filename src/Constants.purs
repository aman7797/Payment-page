module Constants where

import Prelude

import Presto.Core.Types.API (ErrorPayload(..), Response(..))

ppStateKey :: String
ppStateKey = "jpPPState"

failureMsg :: String
failureMsg = "Failed"

networkErrorMsg :: String
networkErrorMsg = "Failed"

networkStatus :: String
networkStatus = "NETWORK_STATUS"

-- TODO Change ExitApp as a SumType

userAbortedErrorResponse :: Response ErrorPayload
userAbortedErrorResponse = Response $ { code : 0, status : "FAILED", response : ErrorPayload { error : true, errorMessage : "INVALID_DATA", userMessage : "Invalid data recived." } }