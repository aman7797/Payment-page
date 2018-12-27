module UI.Common.Helpers.SingleSelectRadio where

import Prelude

import Data.Array (mapWithIndex)
import Data.Lens ((.~), (^.))
import Data.Newtype (class Newtype)
import Data.Ord ( class Ord, compare)
import Data.Ordering (Ordering(..))
import Effect (Effect)
import Halogen.VDom.Types (VDom(..))
import Engineering.Helpers.Types.Accessor
import PrestoDOM
import PrestoDOM.Types.DomAttributes
import PrestoDOM.Utils ((<>>))



{-- type SingleSelectTheme = --}
{--     { selected :: Props (Effect Unit) --}
{--     , unselected :: Props (Effect Unit) --}
{--     , lessThanOrEq :: Props (Effect Unit) --}
{--     , greaterThan :: Props (Effect Unit) --}
{--     } --}

data RadioSelected
    = RadioSelected Int
    | NothingSelected

instance eqRadioSelected :: Eq RadioSelected where
    eq (RadioSelected a) (RadioSelected b) = a == b
    eq NothingSelected NothingSelected = true
    eq _ _ = false

instance ordRadioSelected :: Ord RadioSelected where
    compare (RadioSelected a) (RadioSelected b) = compare a b
    compare NothingSelected NothingSelected = EQ
    compare NothingSelected (RadioSelected _) = LT
    compare (RadioSelected _) NothingSelected = GT

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
    -> (RadioSelected -> Int -> a -> PrestoDOM (Effect Unit) w)
    -> Array a
    -> Array (PrestoDOM (Effect Unit) w)
singleSelectRadio push state view =
    let currentSelected = state ^. _currentSelected
     in mapWithIndex
            (\i a ->
                case view currentSelected i a of
                     Elem ns eName props child ->
                        let newProps = props <>> implementation push i
                         in Elem ns eName newProps child
                     v -> v
            )

implementation
    :: (RadioSelected -> Effect Unit)
    -> Int
    -> Props (Effect Unit)
implementation push i =
    [ onClick push (const $ RadioSelected i)
    ]

