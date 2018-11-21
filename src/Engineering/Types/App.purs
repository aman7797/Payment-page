module Engineering.Types.App where

import Control.Monad.Except.Trans (ExceptT(..))
import Control.Monad.Free (Free)
import Control.Transformers.Back.Trans (BackT(..), FailBack(..))
import Data.Either (Either(..))
import Prelude (class Eq, eq, pure, ($), (<$>), (<<<))
import Presto.Core.Flow (Flow) as Presto
import Presto.Core.Types.API (ErrorResponse)
import Presto.Core.Types.Language.Flow (FlowWrapper)

-- foreign import data TIMER :: Effect

fromENV :: ENV -> String
fromENV PROD = "prod"
fromENV PRE_PROD = "pre_prod"
fromENV SANDBOX = "sandbox"
fromENV DEV = "dev"

toENV :: String -> ENV
toENV "prod" = PROD
toENV "pre_prod" = PRE_PROD
toENV "sandbox" = SANDBOX
toENV "dev" = DEV
toENV _ = PROD

data ENV = PROD | PRE_PROD | SANDBOX | DEV
instance eqENV :: Eq ENV where eq s1 s2 = eq (fromENV s1) (fromENV s2)

data PaymentPageError = UserAborted | SessionExpired | ChargeStatusFailure | ApiFailure ErrorResponse | ExitApp String | MicroAppError String | UPIFlowError UPIError

type MicroAppResponse = {
  code :: Int,
  status :: String
}

type Flow e a = (ExceptT e (Free FlowWrapper) a)
type FlowBT e a = BackableFlow e a
type BackableFlow e a = BackT (ExceptT e (Free FlowWrapper)) a


liftLeft :: forall b. PaymentPageError -> FlowBT PaymentPageError b
liftLeft = BackT <<< ExceptT <<< (<$>) Left <<< pure


liftFlowBT :: forall a e. Presto.Flow a -> FlowBT e a
liftFlowBT a = BackT <<< ExceptT $ Right <$> NoBack <$> a


type AmazonProcessChargeResponse =
    { signature::String
    , transactionId::String
    , verificationOperationName::String
    , txn_uuid::String
    }




type AmazonChargeStatusResponse =
    { transactionStatusDescription::String
    , signature::String
    , verificationOperationName::String
    , merchantTransactionId::String
    , transactionCurrencyCode::String
    , transactionStatusCode::String
    , transactionValue::String
    , transactionDate::String
    , transactionId::String
    }

type EcResponse =
    { code :: String
    , status :: String
    }

type DateResponse =
    { date :: String
    , code :: Int
    }


-------------------------------------- UPI ERROR TYPES ---------------------------------------------------

data UPIError = OnBoardingErr OnBoardingErrTypes
            | BindDeviceErr BindDeviceErrTypes
            | AccountManagementErr AccountManagementErrTypes
            | PayErr PayErrTypes
            | SDKWebCollectErr SDKWebCollectErrTypes
            | MerchantErr ErrorData
            | UIErr ErrorData

data OnBoardingErrTypes = TriggerOtpFailure ErrorData | VpaAvailabilityFailure ErrorData | InitiateRegisterFailure ErrorData | FetchAccountsFailure ErrorData
data BindDeviceErrTypes = SendSmsFailure ErrorData | TokenVerificationFailure ErrorData | GetOperatorFailure ErrorData | BankFetchFailed ErrorData | ChangeSIMFailure ErrorData
data AccountManagementErrTypes = RegistrationChecksumFailure ErrorData | DeleteAccountFailure ErrorData | DeregisterFailure ErrorData | BalanceCheckFailure ErrorData
data PayErrTypes = CLFailure ErrorData | MakePaymentFailure ErrorData | IntentFailure ErrorData
data SDKWebCollectErrTypes = VpaValidityFailure ErrorData | SDKWebCollectedFailure ErrorData | SDKStatusFailure ErrorData

newtype ErrorData =
    ErrorData { status :: String
              , errorCode :: String
              , errorMessage :: String
              }
