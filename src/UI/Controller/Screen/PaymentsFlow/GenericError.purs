module UI.Controller.Screen.PaymentsFlow.GenericError where


import Prelude

import Data.Lens ((^.))
import Effect (Effect)
import Data.Newtype (class Newtype)
import Engineering.Helpers.Types.Accessor (_error)
import PrestoDOM (onBackPressed, onNetworkChanged)
import PrestoDOM.Types.Core (Eval, Props)
import PrestoDOM.Utils (exit)

data ScreenInput = NetworkError | Other

type ScreenOutput = Action

data Action = Retry | UserAbort

newtype GenericErrorState = GenericErrorState {
    error :: ScreenInput
}


initialState :: ScreenInput -> GenericErrorState
initialState input = GenericErrorState 
    {
    error : input 
    }

derive instance genericErrorStateNewtype :: Newtype GenericErrorState _
derive instance eqScreenInput :: Eq ScreenInput

eval :: Action -> GenericErrorState -> Eval Action ScreenOutput GenericErrorState
eval Retry _ = exit Retry
eval UserAbort _ = exit UserAbort

overrides :: String -> (Action -> Effect Unit) -> GenericErrorState -> Props (Effect Unit)
overrides "MainLayout" push state = [onBackPressed push (const UserAbort)] <> if state ^. _error == NetworkError then [onNetworkChanged push (const Retry)] else []
overrides _ push state = []