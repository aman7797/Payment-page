module Product.Payment.Utils where

import Prelude

import Control.Monad.Except (runExcept)
import Data.Array
import Data.Lens ((^.))
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))

import Foreign.Generic (decodeJSON)
import Engineering.Helpers.Types.Accessor
import Engineering.Helpers.Commons
import Engineering.Helpers.Utils (getSimOperators')
import Product.Types
import Remote.Types (PaymentSourceResp)
import Presto.Core.Flow (Flow)
import UI.Controller.Screen.PaymentsFlow.PaymentPage (PaymentPageState, initialState)
import UI.Utils (os)

mkPaymentPageState :: SDKParams -> PaymentSourceResp -> Int -> PaymentPageState
mkPaymentPageState sdkParams paymentMethods width = (initialState mkPPInput)

    where

        mkPPInput =
          PaymentPageInput
            { piInfo : paymentMethods
            , customer : mkCustomer
            , orderInfo : mkOrderInfo sdkParams
            , sdk : sdkParams
            , screenWidth : width
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
 {-- , fullfilment : sdkParams ^. _fullfilment --}
 {-- , preferedBanks : sdkParams ^. _preferedBanks --}
 {-- , billerCardEditable : sdkParams ^. _billerCardEditable --}
 }



fetchSIMDetails :: Flow FetchSIMDetailsUPIResponse
fetchSIMDetails = do
    operators <- liftFlow (getSimOperators' unit)
    case (runExcept (decodeJSON operators)) of
        Right (simOperators :: FetchSIMDetailsUPIResponse) -> pure simOperators
        Left err ->  if os == "IOS" then pure $ FetchSIMDetailsUPIResponse [ SIM { slotId: 0, carrierName : "", simId : "1234567"  } ] else pure $ FetchSIMDetailsUPIResponse []
          --(BackT <<< ExceptT) $ Left <$> pure (Err.UPIFlowError $ BindDeviceErr $ GetOperatorFailure $ (ErrorData {status:"FAILURE",errorCode:"SIM_CARD_NOT_AVAILABLE",errorMessage:"SIM card(s) not available"}))

getBankList :: PaymentPageInput -> Array BankAccount
getBankList ppInput =
    sort <<< map mkBank <<< filter getNB $ ppInput ^. _piInfo ^. _merchantPaymentMethods
    where
          mkBank pm = BankAccount
                        { bankCode : pm  ^. _paymentMethod
                        , bankName : pm ^. _description,maskedAccountNumber: ""
                        , mpinSet:true,referenceId:pm  ^. _paymentMethod
                        , regRefId : ""
                        , accountHolderName : ""
                        , register: true
                        , ifsc : ""
                        {-- , iin : getNbIin $ pm  ^. _paymentMethod --}
                        }

          getNB pm = (pm ^. _paymentMethodType) == "NB"





