module UI.Controller.Component.UpiView where

import Prelude

import Data.Lens ((.~), (^.))
import Data.Newtype (class Newtype)
import Data.String as S
import Data.String.CodePoints (drop, length)
import Effect (Effect)
import Engineering.Helpers.Events
import Engineering.Helpers.Types.Accessor
import JBridge
import PrestoDOM
import UI.Constant.FontColor.Default as Color
import UI.Constant.FontSize.Default (a_16)
import UI.Constant.FontStyle.Default as Font
import UI.Constant.Str.Default as STR
import UI.Utils (FieldType(..), os, getFieldTypeID)



data Action
    = Submit
    | VPAchanged String




newtype State = State
    { dummy :: String
    }


derive instance stateNewtype :: Newtype State _


initialState :: State
initialState = State $
    { dummy : "dummy"
    }

data Overrides
    = UPIeditOverride
    | BtnPay


overrides :: (Action -> Effect Unit) -> State -> Overrides -> Props (Effect Unit)
overrides push state =
    case _ of
         UPIeditOverride -> [ onChange push VPAchanged ]
         _ -> []