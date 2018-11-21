module JBridge where

import Prelude

import Effect (Effect)
import Data.Newtype (class Newtype)
import Engineering.Helpers.Commons (AffSuccess, liftFlow)
import Presto.Core.Types.Language.Flow (Flow)

foreign import logAny :: forall a . a -> Unit
foreign import getElemPostion :: String -> {x :: Int , y :: Int}
foreign import changeCursorTo :: String  -> Unit
foreign import updateLayoutCursor :: String -> String  -> Unit
foreign import updateViewPort :: ScreenSize -> Boolean
foreign import getText :: String -> String
foreign import getPaymentMethods :: String -> Array String
foreign import getFromConfig :: String -> Array String
foreign import getWalletConfigs :: Unit -> Array WalletConfig
foreign import getSessionAttribute' :: String -> String
foreign import detach :: String -> Unit
foreign import getScrollTop :: String -> Int
foreign import getKeyboardHeight :: Unit -> Int
foreign import getKeyboardDuration :: Unit -> Int

type ScreenSize = { height :: Int, width :: Int}

type WalletConfig = {
    wallet :: String
    , wait_for :: Int
    , otp_length :: Int
}

newtype CardDetails = CardDetails {
    card_type :: String,
    valid :: Boolean,
    luhn_valid :: Boolean,
    length_valid :: Boolean,
    cvv_length :: Array Int,
    supported_lengths :: Array Int
}
derive instance cardDetailsNewtype :: Newtype CardDetails _
defaultValidatorOutput :: CardDetails
defaultValidatorOutput = CardDetails $ {
    card_type : "undefined",
    valid : false,
    luhn_valid : false ,
    length_valid : false,
    cvv_length : [3],
    supported_lengths : [16]
}
foreign import getCardValidation :: String -> CardDetails
foreign import hideKeyboard :: Unit -> Unit
foreign import requestKeyboardHide :: Effect Unit
foreign import showKeyboard :: String -> Unit
foreign import requestKeyboardShow :: String -> Effect Unit


-- | pass the ScrolView ID + ChildView Id to bring the childView in focus
foreign import bringToFocus :: String -> String -> Boolean
foreign import requestFocus :: String -> Boolean
foreign import attach' :: String -> String -> String -> Effect Boolean

attach :: String -> String -> String -> Flow Boolean
attach eventListener args callbackId = (liftFlow ( attach' eventListener args callbackId))

-- | UPI Interface
foreign import getToken :: String -> String -> String -> Effect String
foreign import init ::  (AffSuccess String) -> String -> String -> String -> Effect Unit
foreign import sendSMS ::  (AffSuccess {status :: String}) -> String -> Effect Unit
foreign import setMPIN ::  (AffSuccess {status :: String, response :: {status :: String}}) -> String -> Effect String
foreign import checkBalance :: (AffSuccess String) -> String -> Effect String
foreign import transaction :: (AffSuccess {status :: String, statusCode :: String, response :: {status :: String}}) -> String -> Effect Unit
foreign import collectApprove :: (AffSuccess String) -> String -> Effect String
foreign import encrypt :: String -> String -> String
foreign import decrypt :: String -> String -> String
