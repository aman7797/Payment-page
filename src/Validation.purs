module Validation where

import Prelude

import Data.Array (elemLastIndex, foldl, index)
import Data.Int (fromString)
import Data.Lens ((^.))
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Number as Number
import Data.String as String
import Engineering.Helpers.Types.Accessor (_luhn_valid, _supported_lengths)
import Engineering.Helpers.Utils (getCurrentMonth, getCurrentYear)
import JBridge (CardDetails(..))
import Remote.Types (MerchantPaymentMethod(..))
import UI.Constant.Str.Default as Str


-- Config

correctBoxStroke :: String
correctBoxStroke = "1,#0FCE84"
errorBoxStroke :: String
errorBoxStroke = "1,#f0615e"
defaultBoxStroke :: String
defaultBoxStroke = "1,#97a9b3"

correctStateColor :: String
correctStateColor = "#666970"

errorStateColor :: String
errorStateColor = "#DD5C64"

defaultStateColor :: String
defaultStateColor = "#878992"

cardNumberError :: String
cardNumberError = "• Re-check the card number"

expiryDateError :: String
expiryDateError = "• Re-check the expiry date"

cvvError :: String
cvvError = "• Re-check your cvv"

-- Will be used for saveCard as well.
data InvalidState
    = BLANK
    | INPROGRESS
    | ERROR String

derive instance eqInvalidState :: Eq InvalidState

data ValidationState
    = VALID
    | INVALID InvalidState

derive instance eqEditFieldState :: Eq ValidationState


-- ADD_NEW_CARD VALIDATIONS
extractOutMethod
  :: MerchantPaymentMethod
  -> { paymentMethodType :: String , paymentMethod :: String , description :: String }
extractOutMethod (MerchantPaymentMethod mpM) =
    { paymentMethodType :  mpM.paymentMethodType
    , paymentMethod : mpM.paymentMethod
    , description : mpM.description
    }

compare'
  :: forall a
   . { card_type :: String | a }
  -> MerchantPaymentMethod
  -> Boolean
compare' d c = ( ( (String.toLower d.card_type)  )==   ( String.toLower  (extractOutMethod c).paymentMethod ) )



isNotSupported :: CardDetails -> Array MerchantPaymentMethod -> Boolean
isNotSupported (CardDetails cardDetails) supportedMethods = --false
    {-- let desiredArray = supportedMethods --}
    {--     sampleF q = compare' cardDetails q --}
	 {-- in ( 0 == ( length (filter sampleF desiredArray) ) ) --}
    -- | DreamPlug specific code incoming. 
    case cardDetails.card_type of
        "amex" -> true
        "diners" -> true
        _ -> false
    -- | That's all for now.


getMinLength :: Array Int -> Int
getMinLength =
    foldl
        (\b i -> if i < b then i else b
        )
        1000

getMaxLength :: Array Int -> Int
getMaxLength =
    foldl
        (\b i -> if b > i then b else i
        )
        0

isCardIncomplete :: String -> CardDetails -> Boolean
isCardIncomplete cardNumber cardDetails =
    let l = getMaxLength (cardDetails ^. _supported_lengths)
     in String.length cardNumber < l


isMaxCardLength :: String -> CardDetails -> Boolean
isMaxCardLength cardNumber cardDetails =
    let l = getMaxLength (cardDetails ^. _supported_lengths)
     in l /= 0 && String.length cardNumber == l

isCardLengthInvalid :: String -> CardDetails -> Boolean
isCardLengthInvalid cardNumber cardDetails =
    let l = getMaxLength (cardDetails ^. _supported_lengths)
     in l /= 0 && String.length cardNumber > l

isCardStartInvalid :: String -> Boolean
isCardStartInvalid cardNum =
    let index = elemLastIndex (String.take 1 cardNum) ["1","7","8","9","0"]
     in case index of
           Just _ -> true
           Nothing -> false

isValidCandidate :: String -> CardDetails -> Boolean
isValidCandidate cardNumber cardDetails =
    let l = getMinLength (cardDetails ^. _supported_lengths)
     in l /= 1000 && String.length cardNumber >= l


getCardIcon :: String -> String
getCardIcon cardType = case (String.toLower $ cardType) of
	"amex" -> "card_type_amex"
	"diners" -> "card_type_diners_club_carte_blanche"
	{-- "diners" -> "card_type_diners_club_international" --}
	"jcb" -> "card_type_jcb"
	"laser" -> "card_type_laser"
	"visa_electron" -> "card_type_visa_electron"
	"visa" -> "card_type_visa"
	"master" -> "card_type_mastercard"
	"mastercard" -> "card_type_mastercard"
	"maestro" -> "card_type_maestro"
	"rupay" -> "card_type_rupay"
	"discover" -> "card_type_discover"
	"default" -> "white_img"
	_ -> "white_img"

getWalletName :: String -> String
getWalletName =
    case _ of
         "MOBIKWIK" -> "MobiKwik"
         "PAYTM" -> "PayTM"
         "FREECHARGE" -> "FreeCharge"
         "OLAMONEY" -> "Ola Money"
         "PAYUMONEY" -> "Payu Money"
         "AIRTEL_MONEY" -> "Airtel Money"
         "OXIGEN" -> "Oxigen"
         "PAYZAPP" -> "PayZapp"
         "JANACASH" -> "Jana Cash"
         "JIOMONEY" -> "JioMoney"
         "PHONEPE" -> "PhonePe"
         "AMAZONPAY" -> "Amazon Pay"
         "PAYPAL" -> "PayPal"
         _ -> "JusPay"

getWalletIcon :: String -> String
getWalletIcon = (<>) "wallet_" <<< String.toLower

getCardNumberStatus :: String -> CardDetails -> Array MerchantPaymentMethod -> ValidationState
getCardNumberStatus cardNumber cardDetails supportedMethods = getStatus
    where
        getStatus | ( String.length cardNumber ) == 0 = INVALID BLANK
                  | isCardStartInvalid cardNumber = INVALID $ ERROR cardNumberError -- "start invalid"
                  | isCardIncomplete cardNumber cardDetails = INVALID INPROGRESS
                  | isMaxCardLength cardNumber cardDetails && not luhnValid = INVALID $ ERROR cardNumberError -- "luhn failed"
                  | isCardLengthInvalid cardNumber cardDetails = INVALID $ ERROR cardNumberError --  "Length Invalid"
                  | isMaxCardLength cardNumber cardDetails && isNotSupported cardDetails supportedMethods = INVALID $ ERROR "Card is not supported."
                  | isValidCandidate cardNumber cardDetails && luhnValid = VALID
                  | otherwise = INVALID INPROGRESS

        luhnValid = cardDetails ^. _luhn_valid

        supportedLengths =  cardDetails ^. _supported_lengths


-- | TODO : Change year < ((getCurrentYear "") `mod` 100) logic to patch cards meant to expire in 2100+
getExpiryDateStatus :: String -> ValidationState
getExpiryDateStatus expiryDate = getStatus
    where
        getStatus | ( String.length expiryDate ) == 0 = INVALID BLANK
                  | String.length expiryDate < 5  = INVALID INPROGRESS
                  | year < currentYear = INVALID $ ERROR "Card expired"
                  | year == currentYear && month < (getCurrentMonth "") = INVALID $ ERROR "Card expired"
                  | year > 50 = INVALID $ ERROR "Card not supported" -- | This logic is here because EC don't suport card with exp date above 50
                  | month > 12 = INVALID $ ERROR "Invalid Month"
                  | month < 1 = INVALID $ ERROR "Invalid Month"
                  | otherwise = VALID

        month = getMonth expiryDate
        year = getYear expiryDate
        currentYear = (getCurrentYear "") `mod` 100


getMonth :: String -> Int
getMonth expiryDate = fromMaybe (negate 1) (fromString ( fromMaybe "-1" (index (String.split (String.Pattern "/") expiryDate) 0) ) )

getYear :: String -> Int
getYear expiryDate = fromMaybe (negate 1) (fromString ( fromMaybe "-1" (index (String.split (String.Pattern "/") expiryDate) 1) ) )



getCvvStatus :: String -> String -> ValidationState
getCvvStatus cvv cardType
    | ( String.length cvv ) == 0 = INVALID BLANK
    | ( String.length cvv ) <= 2 = INVALID INPROGRESS
    | (String.toLower (cardType) == "maestro") = VALID
    | ( if String.toLower (cardType) == "amex" then 4 else 3 ) == ( String.length cvv ) = VALID
    | otherwise = INVALID $ ERROR "Invalid CVV"

         {-- cvv = state.formState.cvv.value --}

         {-- cardType = state.formState.cardNumber.cardDetails.card_type --}


getAllValidation :: ValidationState -> ValidationState -> ValidationState -> ValidationState
getAllValidation =
    case _,_,_ of
        VALID,VALID,VALID         -> VALID
        INVALID err@(ERROR _),_,_ -> INVALID err
        _,INVALID err@(ERROR _),_ -> INVALID err
        _,_,INVALID err@(ERROR _) -> INVALID err
        _,_,_                     -> INVALID BLANK


validateData :: ValidationState -> Boolean
validateData =
    case _ of
         VALID -> true
         _ -> false

getValidationColor :: ValidationState -> String
getValidationColor =
    case _ of
         INVALID (ERROR _) -> errorStateColor
         VALID -> correctStateColor
         _ -> defaultStateColor

getErrorText :: ValidationState -> String
getErrorText =
    case _ of
         INVALID (ERROR txt) -> txt
         _ -> ""

getCardLabel :: ValidationState -> String
getCardLabel =
    case _ of
         VALID -> "PAY YOUR BILL"
         INVALID (ERROR _) -> "VERIFY CARD"
         _ -> "add new card"

getAmountValidation :: String -> String -> String -> ValidationState
getAmountValidation currAmount minAmount maxAmount = do
    if currAmount == "" 
        then INVALID BLANK
        else do
            let amountint = Number.fromString currAmount
            let min = 1.0--fromMaybe 0.0 $ Number.fromString minAmount
            let max = 1000000.0--fromMaybe 1000000.0 $ Number.fromString maxAmount
            case amountint of
                Just a -> if (a >= min && a <= max) 
                            then VALID
                            else INVALID $ ERROR Str.errorText4
                Nothing -> INVALID $ ERROR Str.errorText4
