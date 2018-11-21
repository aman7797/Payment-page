module Remote.Backend where

import Prelude

import Engineering.Types.App (FlowBT, PaymentPageError)
import Presto.Core.Types.API (Header(..), Headers(..))
import Presto.Core.Types.Language.Flow (APIResult, Flow, callAPI)
import Remote.Amazon.Types (AmazonChargeStatusReq, AmazonChargeStatusResp, ValidateAmazonChargeStatusReq, ValidateAmazonChargeStatusResp)
import Remote.Types (DeleteCardReq, DeleteCardResp, DeleteVpaReq, DeleteVpaResp, DelinkWalletReq, DelinkWalletResp, InitiateTxnReq, InitiateTxnResp, OrderStatusResp, PaymentSourceReq, PaymentSourceResp)
import Remote.Utils (eitherMatch, makeOrderStatusCheckReqPayload, mkApiConfig, mkRestClientCall)

checkOrderStatus :: String -> FlowBT PaymentPageError OrderStatusResp
checkOrderStatus order_id = eitherMatch =<< mkRestClientCall headers req (mkApiConfig 1 false true)
  where
    headers = Headers []
    req = makeOrderStatusCheckReqPayload order_id

-- initiateTxn :: PaymentMethod -> FlowBT PaymentPageError InitiateTxnResp
-- initiateTxn paymentMethod = eitherMatch =<< mkRestClientCall headers req 1 
--   where
--     headers = Headers [(Header "x-api" "txns")]
--     req = (mkInitiateTxnPayload paymentMethod)

amazonChargeStatus :: AmazonChargeStatusReq -> FlowBT PaymentPageError AmazonChargeStatusResp
amazonChargeStatus reqBody = eitherMatch =<< mkRestClientCall headers req (mkApiConfig 0 false true)
  where
    headers =  Headers []
    req = reqBody

amazonValidateChargeStatus :: ValidateAmazonChargeStatusReq -> FlowBT PaymentPageError ValidateAmazonChargeStatusResp
amazonValidateChargeStatus reqBody = eitherMatch =<< mkRestClientCall headers req (mkApiConfig 0 false true)
  where
      headers =  Headers []
      req = reqBody

-- TODO split this into getSavedPaymentMethods and getSupportedPaymentMethods
getPaymentMethods :: PaymentSourceReq -> FlowBT PaymentPageError PaymentSourceResp
getPaymentMethods reqBody = eitherMatch =<< mkRestClientCall headers req (mkApiConfig 1 true false)
  where
      headers =  Headers []
      req = reqBody

--- need to remove after management changed to FLOWBT
getPaymentMethodsForManagement :: PaymentSourceReq -> Flow (APIResult PaymentSourceResp)
getPaymentMethodsForManagement reqBody = callAPI headers req
  where
      headers =  Headers []
      req = reqBody


deleteCard :: DeleteCardReq -> Flow (APIResult DeleteCardResp)
deleteCard reqBody = callAPI headers req where
  headers = Headers []
  req = reqBody

 
deleteVpa :: DeleteVpaReq -> Flow (APIResult DeleteVpaResp)
deleteVpa reqBody = callAPI headers req where
  headers = Headers []
  req = reqBody

delinkWallet :: DelinkWalletReq -> Flow (APIResult DelinkWalletResp)
delinkWallet reqBody = callAPI headers req where
  headers = Headers []
  req = reqBody

mkPayment :: InitiateTxnReq -> FlowBT PaymentPageError InitiateTxnResp
mkPayment req = eitherMatch =<< mkRestClientCall headers req (mkApiConfig 1 false true)
  where
    headers = Headers [(Header "x-api" "txns")]