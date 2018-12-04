module UI.Helpers.SingleSelectRadio where

import Prelude

import Data.Lens ((.~), (^.))
import Data.Newtype (class Newtype)
import Effect (Effect)
import PrestoDOM
import PrestoDOM.Types.DomAttributes
import UI.Constant.FontColor.Default as Color
import UI.Constant.FontSize.Default (a_16)
import UI.Constant.FontStyle.Default as Font
import UI.Constant.Str.Default as STR



singleSelectRadio
    :: forall w a
     . (a -> PrestoDOM (Effect Unit) w)
    -> Array a
    -> Array (PrestoDOM (Effect Unit) w)
singleSelectRadio =  map


