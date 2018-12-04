module UI.Helpers.SingleSelectRadio where

import Prelude

import Data.Array (mapWithIndex)
import Data.Lens ((.~), (^.))
import Data.Newtype (class Newtype)
import Effect (Effect)
import Halogen.VDom.Types (VDom(..))
import Engineering.Helpers.Types.Accessor
import PrestoDOM
import PrestoDOM.Types.DomAttributes
import PrestoDOM.Utils ((<>>))
import UI.Constant.FontColor.Default as Color
import UI.Constant.FontSize.Default (a_16)
import UI.Constant.FontStyle.Default as Font
import UI.Constant.Str.Default as STR



type SingleSelectTheme =
    { selected :: Props (Effect Unit)
    , unselected :: Props (Effect Unit)
    }

data RadioSelected
    = RadioSelected Int
    | NothingSelected

instance eqRadioSelected :: Eq RadioSelected where
    eq (RadioSelected a) (RadioSelected b) = a == b
    eq NothingSelected NothingSelected = true
    eq _ _ = false

newtype State = State
    { currentSelected :: RadioSelected
    }

derive instance stateNewtype :: Newtype State _

defaultState ::  RadioSelected -> State
defaultState inp =
    State { currentSelected : inp }

eval
	:: RadioSelected
	-> State
    -> State
eval action =
    _currentSelected .~ action



singleSelectRadio
    :: forall w a
     . (RadioSelected -> Effect Unit)
    -> State
    -> (a -> Props (Effect Unit) -> PrestoDOM (Effect Unit) w)
    -> SingleSelectTheme
    -> Array a
    -> Array (PrestoDOM (Effect Unit) w)
singleSelectRadio push state view theme =
    mapWithIndex
        (\i a ->
            let selectionTheme = if state ^. _currentSelected == RadioSelected i
                                    then theme.selected
                                    else theme.unselected
             in case view a selectionTheme of
                     Elem ns eName props child ->
                        let newProps = props <>> implementation push i
                         in Elem ns eName newProps child
                     _ -> view a theme.unselected
        )

implementation
    :: (RadioSelected -> Effect Unit)
    -> Int
    -> Props (Effect Unit)
implementation push i =
    [ onClick push (const $ RadioSelected i)
    ]

