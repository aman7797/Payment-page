module UI.Controller.Screen.PaymentsFlow.GenericError where


import Prelude

import Data.Lens ((^.))
import Effect (Effect)
import Data.Newtype (class Newtype)
import Engineering.Helpers.Types.Accessor (_error)
import PrestoDOM (onBackPressed, onNetworkChanged)
import PrestoDOM.Types.Core (Eval, Props)
import PrestoDOM.Utils (exit)
import UI.Controller.Component.Button as Button

data ScreenInput = NetworkError | Other

type ScreenOutput = Action

data Action = Retry | UserAbort | Button1Action Button.Action

newtype GenericErrorState = GenericErrorState {
    error :: ScreenInput
    , button1State :: Button.State
}


initialState :: ScreenInput -> GenericErrorState
initialState input = GenericErrorState 
    {
    error : input 
    , button1State : Button.initialState
    }

derive instance genericErrorStateNewtype :: Newtype GenericErrorState _
derive instance eqScreenInput :: Eq ScreenInput

eval :: Action -> GenericErrorState -> Eval Action ScreenOutput GenericErrorState
eval Retry _ = exit Retry
eval UserAbort _ = exit UserAbort
eval (Button1Action action) _ = exit Retry

overrides :: String -> (Action -> Effect Unit) -> GenericErrorState -> Props (Effect Unit)
overrides "MainLayout" push state = [onBackPressed push (const UserAbort)] <> if state ^. _error == NetworkError then [onNetworkChanged push (const Retry)] else []
overrides _ push state = []