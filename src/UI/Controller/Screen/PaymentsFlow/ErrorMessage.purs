module UI.Controller.Screen.PaymentsFlow.ErrorMessage where


import Prelude

import Effect (Effect)
import Data.Newtype (class Newtype)
import Engineering.Helpers.Commons (startAnim)
import Engineering.Helpers.Utils (setDelay)
import PrestoDOM (continueWithCmd, onBackPressed)
import PrestoDOM.Types.Core (Eval, Props)
import PrestoDOM.Utils (exit)
import UI.Controller.Component.Button as Button

data ScreenInput = NetworkError | ErrorMessage String | ToastMessage String

type ScreenOutput = Action

data Action = Retry | UserAbort | Button1Action Button.Action | ExitAnimation Action

newtype GenericErrorState = GenericErrorState {
  error :: String
, typ :: ErrorType
, button1State :: Button.State
}

data ErrorType = Error | Toast 

instance typShow :: Show ErrorType where
  show Error = "error"
  show Toast = "toast"


initialState :: ScreenInput -> GenericErrorState
initialState input = GenericErrorState 
    {
      error : case input of
                NetworkError -> "Please Check Your Internet Connection"
                ErrorMessage a -> a
                ToastMessage a -> a
    , typ : case input of
                ToastMessage _ -> Toast
                _ -> Error
    , button1State : Button.initialState
    }

derive instance genericErrorStateNewtype :: Newtype GenericErrorState _
derive instance eqScreenInput :: Eq ScreenInput

eval :: Action -> GenericErrorState -> Eval Action ScreenOutput GenericErrorState
eval (ExitAnimation act) state = exit act
eval Retry state = continueWithCmd state [ runScrenAnimations state Retry ]
eval UserAbort state = continueWithCmd state [ runScrenAnimations state UserAbort ]
eval (Button1Action action) state = continueWithCmd state [ runScrenAnimations state Retry ]

runScrenAnimations :: GenericErrorState -> Action → Effect Action
runScrenAnimations (GenericErrorState state) action = do
  startAnim $ show state.typ <> "SlideOut"
  startAnim $ show state.typ <> "FadeOut"
  startAnim $ show state.typ <> "MsgFadeOut"
  setDelay (ExitAnimation action) 300.0

overrides :: String -> (Action -> Effect Unit) -> GenericErrorState -> Props (Effect Unit)
overrides "MainLayout" push state = [onBackPressed push (const UserAbort)] 
overrides _ push state = []