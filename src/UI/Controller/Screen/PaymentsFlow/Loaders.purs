module UI.Controller.Screen.PaymentsFlow.Loader where

import Prelude

import Effect (Effect)
import PrestoDOM.Types.Core (Eval, Props)
import PrestoDOM (afterRender)
import PrestoDOM.Utils (continue, exit)
import UI.Utils (loaderAfterRender)

type ScreenInput = State

type ScreenOutput = {}

data Action = BackPressed | AfterRender

type State = {
  customLoader :: Boolean
, parentId :: String
}


initialState :: State -> State
initialState input = {
  customLoader: input.customLoader
, parentId: input.parentId
}



eval :: Action -> State -> Eval Action ScreenOutput State
eval action state = 
  case action of 
    AfterRender -> (pure $ loaderAfterRender state.parentId) *> exit {}
    _ -> continue state

overrides :: String -> (Action -> Effect Unit) -> State -> Props (Effect Unit)
overrides "MainContent" push state =
    [ afterRender push (const AfterRender) ]
overrides _ push state = []