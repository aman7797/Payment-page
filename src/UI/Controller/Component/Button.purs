module UI.Controller.Component.Button where

import Prelude (Unit, const)
import PrestoDOM.Types.Core

import Effect (Effect)

import PrestoDOM (onClick)




type ScreenInput = String

type ScreenOutput = Unit

data Action
	= ButtonAction


type State =
	{	}


initialState :: State
initialState =
	{	}


eval
	:: Action
	-> State
	-> State
eval ButtonAction state = state


overrides
	:: String
	-> (Action -> Effect Unit)
	-> State
	-> Props (Effect Unit)
overrides "ButtonGroup" push state = [onClick push (const ButtonAction) ]
overrides _ push state = []
