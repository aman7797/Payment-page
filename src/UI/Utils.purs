module UI.Utils where

import Prelude

import Effect (Effect)
import Web.Event.Event (Event) as DOM
import Engineering.Helpers.Commons (AffSuccess)
import PrestoDOM (Prop, PropName(..), prop)
import Type.Data.Boolean (kind Boolean)

type MicroAPPInvokeSignature =
    forall a. {|a} -> (AffSuccess {code:: Int, status :: String}) -> (forall val . val -> Effect Unit) -> Effect Unit

foreign import _cardNumberHanlder :: forall a. String -> DOM.Event -> (a ->  Effect Unit) -> Unit
foreign import _expiryHandler :: forall a. String -> DOM.Event -> (a ->  Effect Unit) -> Unit
foreign import getOs :: Unit -> String
foreign import resetTextFields :: Array String -> Effect Unit
foreign import resetBillerFields :: Unit -> Effect Unit
foreign import getMaxHeight  :: Int -> Int
foreign import date :: forall a. a ->  String
foreign import logit :: forall a. a ->  Unit
foreign import screenHeight :: Unit -> Int
foreign import screenWidth :: Unit -> Int
foreign import safeMarginTop :: Unit -> Int
foreign import safeMarginBottom :: Unit -> Int
foreign import statusBarHeight :: Unit -> Int

foreign import asyncDelay :: forall a. (a -> Effect Unit) -> a -> a -> Number -> Effect a

foreign import loaderAfterRender :: String -> Unit


data FieldType = CardNumber | ExpiryDate | CVV | SavedCardCVV | NONE -- | Name | SavedForLater

derive instance eqFieldType :: Eq FieldType

-- Generate ids instead of hard coding.
getFieldTypeID :: FieldType -> String
getFieldTypeID =
    case _ of
         CardNumber -> "987654321"
         ExpiryDate -> "987654322"
         CVV        -> "987654323"
         SavedCardCVV -> "987654329"
         NONE       -> "987654320" -- replace with text field selection condition


resetText :: Array String -> Effect Unit
resetText = resetTextFields

resetBillerText :: Effect Unit
resetBillerText = resetBillerFields unit

os :: String
os = getOs unit

-- | Boolean String
multipleLine :: forall i. String -> Prop i
multipleLine = prop (PropName "multipleLine")

-- | Boolean String
swipeEnabled :: forall i. String -> Prop i
swipeEnabled = prop (PropName "swipeEnable")

-- | Boolean String
becomeFirstResponder :: forall i. String -> Prop i
becomeFirstResponder = prop (PropName "becomeFirstResponder")

-- | String
placeHolder :: forall i. String -> Prop i
placeHolder = prop (PropName "placeHolder")

-- | String
imeOptions :: forall i. Int -> Prop i
imeOptions = prop (PropName "imeOptions")

bringToFront :: forall i. Boolean -> Prop i
bringToFront = prop (PropName "bringSubViewToFront")

userInteraction :: forall i. Boolean -> Prop i
userInteraction = prop (PropName "userInteraction")

-- | Boolie
baseAlign :: forall i. Boolean -> Prop i
baseAlign = prop (PropName "baseAlign")

androidShadow :: forall i. String -> Prop i
androidShadow = prop (PropName "androidShadow")

shadowTag :: forall i. String -> Prop i
shadowTag = prop (PropName "shadowTag")

packageIcon :: forall i. String -> Prop i
packageIcon = prop (PropName "packageIcon")

scrollEnabled :: forall i. String -> Prop i
scrollEnabled =  prop (PropName "scrollEnabled")

scrollTo :: forall i. String -> Prop i
scrollTo =  prop (PropName "scrollTo")

focusString :: forall i. String -> Prop i
focusString = prop (PropName "focus")

contentMode :: forall i. String -> Prop i
contentMode = prop (PropName "contentMode")

-- TODO MOVIE TO REMOTE TYPES


-------------------------------------------------


-- generatePayload :: forall a. Payment -> {|a}
-- generatePayload (Payment payment) = do
--   let (Authentication auth) = payment.authentication
--   case auth.method of
--     "GET" ->
--       generatePayload' auth.url "null"
--     _ ->
--       generatePayload' auth.url (fromMaybe "null" $ unNullOrUndefined auth.params)

----------------------------------------------------------------------------------------------------------------
-- MAPERS WRITTEN BELOW

makeGridNames :: {code:: String, name ::String} ->  {code:: String,name ::String}
makeGridNames ({code}) =  { code , name :
	case code of
		"000000" -> "NB_DUMMY" 
		"607153" -> "NB_AXIS" 
		"508505" -> "NB_BOI" 
		"607387" -> "NB_BOM" 
		"607115" -> "NB_CBI" 
		"607184" -> "NB_CORP" 
		"607290" -> "NB_DCB" 
		"607165" -> "NB_FED" 
		"607152" -> "NB_HDFC" 
		"508534" -> "NB_ICICI"	
		"607095" -> "NB_IDBI" 
		"607105" -> "NB_INDB" 
		"607189" -> "NB_INDUS" 
		"508541" -> "NB_IOB" 
		"607440" -> "NB_JNK" 
		"607270" -> "NB_KARN" 
		"607100" -> "NB_KVB" 
		"508548" -> "NB_SBI" 
		"607167" -> "NB_SOIB" 
		"508500" -> "NB_UBI" 
		"" -> "NB_UNIB" 
		"" -> "NB_VJYB" 
		"" -> "NB_YESB" 
		"" -> "NB_CUB" 
		"" -> "NB_CANR" 
		"" -> "NB_SBP" 
		"" -> "NB_CITI" 
		"" -> "NB_DEUT" 
		"" -> "NB_KOTAK" 
		"" -> "NB_ING" 
		"" -> "NB_ANDHRA" 
		"" -> "NB_PNBCORP" 
		"" -> "NB_PNB" 
		"" -> "NB_BOB" 
		"" -> "NB_CSB" 
		"" -> "NB_OBC" 
		"" -> "NB_SCB" 
		"" -> "NB_TMB" 
		"" -> "NB_SARASB" 
		"" -> "NB_SYNB" 
		"" -> "NB_UCOB" 
		"" -> "NB_BOBCORP" 
		"" -> "NB_ALLB" 
		"" -> "NB_BBKM" 
		"" -> "NB_JSB" 
		"" -> "NB_LVBCORP" 
		"" -> "NB_LVB" 
		"" -> "NB_NKGSB" 
		"" -> "NB_PMCB" 
		"" -> "NB_PNJSB" 
		"" -> "NB_RATN" 
		"" -> "NB_RBS" 
		"" -> "NB_SVCB" 
		"" -> "NB_TNSC" 
		"" -> "NB_DENA" 
		"" -> "NB_COSMOS" 
		"" -> "NB_DBS" 
		"" -> "NB_DCBB" 
		"" -> "NB_SVC" 
		"" -> "NB_BHARAT" 
		"" -> "NB_KVBCORP" 
		"" -> "NB_UBICORP" 
		"" -> "NB_IDFC" 
		"" -> "NB_NAIB" 
		_ -> code 
}
