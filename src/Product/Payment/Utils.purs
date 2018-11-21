module Product.Payment.Utils where

import Prelude

import Control.Monad.Except (runExcept)
import Data.Lens ((^.))
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))

import Foreign.Generic (decodeJSON)
import Engineering.Helpers.Types.Accessor (_amount, _billerCardEditable, _clientId, _customerId, _customerMobile, _fullfilment, _merchantId, _orderId, _orderToken, _preferedBanks)
import Engineering.Helpers.Commons (liftFlow)
import Engineering.Helpers.Utils (getSimOperators')
import Product.Types (FetchSIMDetailsUPIResponse(..), OrderInfo, PaymentPageInput(..), SDKParams, SIM(..), UPIInfo(..), UPIState)
import Remote.Types (PaymentSourceResp)
import Presto.Core.Flow (Flow)
import UI.Controller.Screen.PaymentsFlow.PaymentPage (PaymentPageState, initialState)
import UI.Utils (os)

mkPaymentPageState :: SDKParams -> PaymentPageState
mkPaymentPageState sdkParams = (initialState mkPPInput)

    where

        mkPPInput =
          PaymentPageInput
            {-- { piInfo : paymentMethods --}
            { customer : mkCustomer
            , orderInfo : mkOrderInfo sdkParams
            , sdk : sdkParams
            }

        mkCustomer =
            { mobileNumber : Just (sdkParams ^. _customerMobile)
            , id : Just (sdkParams ^. _customerId)
            , clientId : sdkParams ^. _clientId
            }



mkOrderInfo :: SDKParams -> OrderInfo
mkOrderInfo sdkParams =
 { amount : sdkParams ^. _amount
 , orderId : sdkParams ^. _orderId
 , orderToken : sdkParams ^. _orderToken
 , gateway : ""
 , merchantId : sdkParams ^. _merchantId
 , fullfilment : sdkParams ^. _fullfilment
 , preferedBanks : sdkParams ^. _preferedBanks
 , billerCardEditable : sdkParams ^. _billerCardEditable
 }



fetchSIMDetails :: Flow FetchSIMDetailsUPIResponse
fetchSIMDetails = do
    operators <- liftFlow (getSimOperators' unit)
    case (runExcept (decodeJSON operators)) of
        Right (simOperators :: FetchSIMDetailsUPIResponse) -> pure simOperators
        Left err ->  if os == "IOS" then pure $ FetchSIMDetailsUPIResponse [ SIM { slotId: 0, carrierName : "", simId : "1234567"  } ] else pure $ FetchSIMDetailsUPIResponse []
          --(BackT <<< ExceptT) $ Left <$> pure (Err.UPIFlowError $ BindDeviceErr $ GetOperatorFailure $ (ErrorData {status:"FAILURE",errorCode:"SIM_CARD_NOT_AVAILABLE",errorMessage:"SIM card(s) not available"}))

