module UI.Controller.Component.AddNewCard where

import Prelude

import Data.Lens ((.~), (^.))
import Data.Newtype (class Newtype)
import Data.String as S
import Data.String.CodePoints (drop, length)
import Effect (Effect)
import Engineering.Helpers.Events (cardNumberHandler, expiryHandler, onFocus, registerNewListener)
import Engineering.Helpers.Types.Accessor (_cardDetails, _cardNumber, _card_type, _cvv, _expiryDate, _formState, _status, _supportedMethods, _value, _cardMethod, _currentFocused, _cvvFocusIndex)
import JBridge (CardDetails, defaultValidatorOutput, getCardValidation)
import PrestoDOM (Props, letterSpacing, color, focus, fontStyle, hint, id, imageUrl, onChange, onClick, pattern, text, textSize)
import Remote.Types (MerchantPaymentMethod, StoredCard(..))
import UI.Constant.FontColor.Default as Color
import UI.Constant.FontSize.Default (a_16)
import UI.Constant.FontStyle.Default as Font
import UI.Constant.Str.Default as STR
import UI.Utils (FieldType(..), os, getFieldTypeID)
import Validation (InvalidState(..), ValidationState(..), cardNumberError, cvvError, expiryDateError, getAllValidation, getCardIcon, getCardLabel, getCardNumberStatus, getCvvStatus, getErrorText, getExpiryDateStatus, getValidationColor)

type ScreenInput =
    { supportedMethods :: Array MerchantPaymentMethod
    , cardMethod :: Method
    }

data Method
    = AddNewCard
    | SavedCard StoredCard
-- pass makePayment as False for back press

{-- type Payload = { payload :: FreshCardTxnReq	, makePayment :: Boolean } --}


data Action
    = SubmitCard Method
    | HideCardOverLay
    | CardNumberChanged String
    | CVVChanged String
    | ExpiryDateChanged String
    | Focus FieldType Boolean
    {-- | Key Keyboard.Action --}



-- Will be used for saveCard as well.
newtype FormFieldState a = FormFieldState
    { status :: ValidationState
    , value :: String
    | a
    }


newtype FormState = FormState
    { cardNumber :: FormFieldState ( maxLength :: Int,  cardDetails :: CardDetails )
    , expiryDate :: FormFieldState ()
    , cvv :: FormFieldState (maxLength :: Int)
    , name :: FormFieldState ()
    , savedForLater :: Boolean
    }



newtype State = State
    { formState :: FormState
    , currentFocused :: FieldType
    , supportedMethods :: Array MerchantPaymentMethod
    , cvvFocusIndex :: Int
    , cardMethod :: Method
    }


derive instance formFieldStateNewtype :: Newtype (FormFieldState a) _
derive instance formStateNewtype :: Newtype FormState _
derive instance stateNewtype :: Newtype State _

initialFormState :: FormState
initialFormState = FormState
    { cardNumber : FormFieldState $
            { status : INVALID BLANK
            , value : ""
            , maxLength : 19
            , cardDetails : defaultValidatorOutput   -- Rename this i n JBridge file.
            }
    , expiryDate : FormFieldState
            { status : INVALID BLANK
            , value : ""
            }
    , cvv : FormFieldState
            { status : INVALID BLANK
            , value : ""
            , maxLength : 3
            }
    , name : FormFieldState
            { status : INVALID BLANK
            , value : ""
            }
    , savedForLater : true
    }

initialState :: ScreenInput -> State
initialState input = State $
    { formState : initialFormState
    , currentFocused : NONE
    , supportedMethods : input.supportedMethods
    , cardMethod : input.cardMethod
    , cvvFocusIndex : -1
    }

defaultState :: Array MerchantPaymentMethod -> State
defaultState supported = initialState { supportedMethods : supported, cardMethod : AddNewCard}


eval :: Action -> State -> State
eval =
    case _ of
         SubmitCard _ -> identity

         HideCardOverLay -> identity

         CardNumberChanged cardNumber ->
              (\state -> state # _cvvFocusIndex .~ -1) <<< updateFocus CardNumber <<< updateCardNumberStatus <<< updateCardDetails <<< updateCardNumber cardNumber

         CVVChanged newCvv ->
              (\state -> state # _cvvFocusIndex .~ (length $ state ^. _formState ^. _cvv ^. _value)) <<< updateCvvStatus <<< updateCvvValue newCvv

         ExpiryDateChanged date ->
              (\state -> state # _cvvFocusIndex .~ -1) <<< updateFocus ExpiryDate <<< updateExpiryDateStatus <<< updateExpiryDateValue date

         Focus action bool ->
              if action == CVV then (\state -> state # _cvvFocusIndex .~ (length $ state ^. _formState ^. _cvv ^. _value)) else _cvvFocusIndex .~ -1
             {-- handleFocus action bool --}

         {-- Key key -> identity --}

handleFocus :: FieldType -> Boolean -> State -> State
handleFocus CardNumber bool state@(State st) =
    let cnStatus = state ^. _formState ^. _cardNumber ^. _status
     in case cnStatus,bool of
             INVALID INPROGRESS,false ->
                 state # (_formState <<< _cardNumber <<< _status) .~ INVALID (ERROR cardNumberError)
             _,_ -> state -- State st {currentFocused = CardNumber}

handleFocus ExpiryDate bool state@(State st) =
    let status = state ^. _formState ^. _expiryDate ^. _status
     in case status,bool of
             INVALID INPROGRESS,false ->
                 state # (_formState <<< _expiryDate <<< _status) .~ INVALID (ERROR expiryDateError)
             _,_ -> state -- State st {currentFocused = ExpiryDate}

handleFocus CVV bool state@(State st) =
    let status = state ^. _formState ^. _cvv ^. _status
     in case status,bool of
             INVALID INPROGRESS,false ->
                 state # (_formState <<< _cvv <<< _status) .~ INVALID (ERROR cvvError)
             _,_ -> state -- State st {currentFocused = CVV}

handleFocus _ bool state = state

getFocus :: State -> FieldType -> Boolean
getFocus state = eq (state ^. _currentFocused)


updateCardNumber :: String -> State -> State
updateCardNumber cardNumber state = state # (_formState <<< _cardNumber <<< _value) .~ cardNumber

updateCardDetails :: State -> State
updateCardDetails state =
	let cardNumber = state ^. _formState ^. _cardNumber ^. _value
     in state # (_formState <<< _cardNumber <<< _cardDetails) .~ (getCardValidation cardNumber)

updateCardNumberStatus :: State -> State
updateCardNumberStatus state =
    let cardNumber = state ^. _formState ^. _cardNumber ^. _value
        cardDetails = state ^. _formState ^. _cardNumber^. _cardDetails
        supportedMethods = state ^. _supportedMethods
     in state # (_formState <<< _cardNumber <<< _status) .~ (getCardNumberStatus cardNumber cardDetails supportedMethods)

updateFocus :: FieldType -> State -> State
updateFocus field state =
    let card = state ^. _formState ^. _cardNumber ^. _status
        expiry = state ^. _formState ^. _expiryDate ^. _status
        cvv = state ^. _formState ^. _cvv ^. _status
     in case field    , card       , expiry     , cvv of
            CardNumber, VALID      , (INVALID _), _           -> state # _currentFocused .~ ExpiryDate
            CardNumber, VALID      , VALID      , (INVALID _) -> state # _currentFocused .~ CVV
            ExpiryDate, _          , VALID      , (INVALID _) -> state # _currentFocused .~ CVV
            -- ExpiryDate, (INVALID _), VALID      , VALID       -> state # _currentFocused .~ CardNumber
            -- CVV       , (INVALID _), _          , VALID       -> state # _currentFocused .~ CardNumber
            -- CVV       , VALID      , (INVALID _), VALID       -> state # _currentFocused .~ ExpiryDate
            -- _         , (INVALID _), (INVALID _), (INVALID _) -> state # _currentFocused .~ CardNumber
            _,_,_,_ -> state
-- TODO REVIEW OF AUTO FOCUS LOGIC

updateExpiryDateValue :: String -> State -> State
updateExpiryDateValue expDate state = state # (_formState <<< _expiryDate <<< _value) .~ expDate

updateExpiryDateStatus :: State -> State
updateExpiryDateStatus state =
	let expiryDate = state ^. _formState ^. _expiryDate ^. _value
     in state # (_formState <<< _expiryDate <<< _status) .~ (getExpiryDateStatus expiryDate)

updateCvvValue :: String -> State -> State
updateCvvValue cvv state = state # (_formState <<< _cvv <<< _value) .~ cvv

updateCvvStatus :: State -> State
updateCvvStatus state =
    let cvv = state ^. _formState ^. _cvv ^. _value
        cardType = state ^. _formState ^. _cardNumber ^. _cardDetails ^. _card_type
     in state # (_formState <<< _cvv <<< _status) .~ (getCvvStatus cvv cardType)

getCardStatus :: State -> ValidationState
getCardStatus state =
    let cnStatus = state ^. _formState ^. _cardNumber ^. _status
        expStatus = state ^. _formState ^. _expiryDate ^. _status
        cvvStatus = state ^. _formState ^. _cvv ^. _status
     in case state ^. _cardMethod of
             AddNewCard -> getAllValidation cnStatus expStatus cvvStatus
             SavedCard _ -> cvvStatus

-------------------------- OVERRIDES ----------------------------------


data Overrides
    = S String
    | MainContent
    | AddCardLabelOne
    | AddCardLabelTwo
    | CardImage
    | CardNumberLabel
    | CardNumberEditField
    | ExpiryDateLabel
    | ExpiryDateEditField
    | CvvLabel
    | CvvEditField
    | CvvEditFieldSaved
    | ErrorMsg
    | BtnPay
    | Space
    | BtnText


overrides :: Overrides -> (Action -> Effect Unit) -> State -> Props (Effect Unit)
overrides BtnPay push state =
    let cardMethod = state ^. _cardMethod
     in [ onClick push $ const (SubmitCard cardMethod)
        ]

overrides BtnText push state =
    case state ^. _cardMethod of
         AddNewCard -> [
            text "Add card & Pay"
        ]
         SavedCard _ -> [
            text "Proceed to pay"
        ]

overrides AddCardLabelOne push state =
    case state ^. _cardMethod of
         AddNewCard ->
            [text "add"]
            -- let cnStatus = state ^. _formState ^. _cardNumber ^. _status
            --     expStatus = state ^. _formState ^. _expiryDate ^. _status
            --     cvvStatus = state ^. _formState ^. _cvv ^. _status
            --     cardStatus = getAllValidation cnStatus expStatus cvvStatus

            --  in [ text $ getCardLabel cardStatus
            --     ]
         SavedCard _ ->
            [ text "pay"
            ]

overrides AddCardLabelTwo push state =
    case state ^. _cardMethod of
         AddNewCard ->
            [text " debit card"]
            -- let cnStatus = state ^. _formState ^. _cardNumber ^. _status
            --     expStatus = state ^. _formState ^. _expiryDate ^. _status
            --     cvvStatus = state ^. _formState ^. _cvv ^. _status
            --     cardStatus = getAllValidation cnStatus expStatus cvvStatus

            --  in [ text $ getCardLabel cardStatus
            --     ]
         SavedCard _ ->
            [ text "your bill"
            ]

overrides CardImage push state =
    case state ^. _cardMethod of
         AddNewCard ->
            [ imageUrl $ getCardIcon $ state ^. _formState ^. _cardNumber ^.  _cardDetails ^. _card_type
            ]
         SavedCard (StoredCard card) ->
             [ imageUrl $ getCardIcon $ card.cardBrand
             ]

-- NUMBER
overrides CardNumberLabel push state =
    let cnStatus = state ^. _formState ^. _cardNumber ^. _status

     in case state ^. _cardMethod of
             AddNewCard ->
                [ color $ getValidationColor cnStatus
                ]
             SavedCard _ ->
                [ text $ "debit card number"
                ]

overrides CardNumberEditField push state =
    case state ^. _cardMethod of
         AddNewCard ->
            [ hint STR.cardNumberText9
            {-- , registerNewListener cardNumberHandler (getFieldTypeID CardNumber) push (CardNumberChanged) --}
            , onChange push (CardNumberChanged)
            -- , focusString -- if not getFocus state CardNumber then "true" else if state ^. _currentFocused == then "false" else ""
            , focus $ getFocus state CardNumber
            , onFocus push (Focus CardNumber)
            , id $ getFieldTypeID CardNumber
            , pattern "^([0-9]| )+$,24"
            ]
         SavedCard (StoredCard card) ->
             [ text $ formattedCardNumber card.cardNumber
             , fontStyle Font.gILROYBOLD
             , textSize a_16
             , color Color.a_FF000000
             , letterSpacing 2.67
             ]

-- EXP
overrides ExpiryDateLabel push state =
    let expStatus = state ^. _formState ^. _expiryDate ^. _status

     in case state ^. _cardMethod of
             AddNewCard ->
                [ color $ getValidationColor expStatus
                ]
             SavedCard _ ->
                [ text $ "expiry date"
                ]

overrides ExpiryDateEditField push state =
    case state ^. _cardMethod of
         AddNewCard ->
            {-- [ registerNewListener expiryHandler (getFieldTypeID ExpiryDate) push (ExpiryDateChanged) --}
            [ onChange push ExpiryDateChanged
            -- , focusString $ show $ getFocus state ExpiryDate
            , focus $ getFocus state ExpiryDate
            , onFocus push (Focus ExpiryDate)
            , hint STR.expiryText11
            , id $ getFieldTypeID ExpiryDate
            -- , imeOptions 5
            , letterSpacing 2.67
            , pattern "^([0-9]|\\/)+$,5"
            ]
         SavedCard (StoredCard card) ->
             [ text $ card.cardExpMonth <> "/" <> drop 2 card.cardExpYear
             , fontStyle Font.gILROYBOLD
             , textSize a_16
             , color Color.a_FF000000
             , letterSpacing 2.67
             ]

-- CVV
overrides CvvLabel push state =
    let cvvStatus = state ^. _formState ^. _cvv ^. _status

     in [ color $ getValidationColor cvvStatus
        ]


overrides CvvEditField push state =
    [ id $ getFieldTypeID CVV
    , onChange push CVVChanged
    -- , focusString $ show $ getFocus state CVV
    , focus $ getFocus state CVV
    , onFocus push (Focus CVV)
    , pattern "^[0-9]+$,3"
    ]

overrides CvvEditFieldSaved push state =
    [ id $ getFieldTypeID SavedCardCVV 
    , onChange push CVVChanged
    -- , focusString $ show $ getFocus state CVV
    , focus $ getFocus state CVV
    , onFocus push (Focus CVV)
    , pattern "^[0-9]+$,3"
    ]


overrides ErrorMsg push state =
    let cardStatus = getCardStatus state

     in [ text $ getErrorText cardStatus
        ]

overrides Space push state =
    [ onClick push (const HideCardOverLay)
    ]

overrides _ push state =
    []



formattedCardNumber :: String -> String
formattedCardNumber cardNo = if S.length cardNo == 18
                                then
                                    "XXXX XXXX XXXX " <> S.drop 14 cardNo
                                else
                                    "XXXX XXXX XXXX XXXX " <> S.drop 17 cardNo