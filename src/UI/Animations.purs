module UI.Animations where


import Prelude

import Data.Array (concatMap, singleton)
import Foreign.Object (Object, fromFoldable)
import Data.Tuple (Tuple(..))
import Engineering.Helpers.Commons (dpToPx)
import PrestoDOM.Types.Core (class IsProp, Orientation(..), PropName(..))
import Simple.JSON (writeJSON)


type Anim = Object String

data Easing = EaseIn | EaseOut | EaseInOut | Linear | Bounce | Spring | CustomEase

type Animator prop value = Tuple prop (Tuple value value)

animator :: forall val. IsProp val => Show val => PropName val -> val -> val -> Animator (PropName val) val
animator propName from to = Tuple propName (Tuple from to)

-- animation properties
ease :: Easing -> Object String
ease EaseIn    = fromFoldable [ Tuple "easing" "ease-in" ]
ease EaseOut   = fromFoldable [ Tuple "easing" "ease-out" ]
ease EaseInOut = fromFoldable [ Tuple "easing" "ease-in-out" ]
ease Linear    = fromFoldable [ Tuple "easing" "linear" ]
ease Bounce    = fromFoldable [ Tuple "easing" "bounce" ]
ease Spring    = fromFoldable [ Tuple "easing" "spring" ]
ease CustomEase = fromFoldable [ Tuple "easing" "0.17,0.59,0.4,0.77" ]

duration :: Number -> Object String
duration val = fromFoldable [ Tuple "duration" (show val) ]

delay :: Number -> Object String
delay val = fromFoldable [ Tuple "delay" (show val) ]

runOnRender :: Object String
runOnRender = fromFoldable [ Tuple "startImmediate" "true" ]

runOnRender' :: Object String
runOnRender' = fromFoldable [ Tuple "runOnRender" "true" ]

repeat :: Int -> Object String
repeat count = fromFoldable [ Tuple "repeatCount" (show count) ]

repeatAlternate :: Object String
repeatAlternate = fromFoldable [ Tuple "repeatAlternate" "true" ]

id :: String -> Object String
id animId = fromFoldable [ Tuple "id" animId ]

propAnim :: forall val. Show val => Array (Animator (PropName val) val) -> Object String
propAnim animators =
    fromFoldable [ Tuple "props" (writeJSON $ concatMap (\(Tuple (PropName name) (Tuple from to)) -> [{ "prop": name, "from": (show from), "to": (show to) }]) animators) ]

-- fade anim
fadeAnim :: Number -> Number -> Object String
fadeAnim from to = propAnim (singleton (animator (PropName "alpha") from to))

slideAnim :: Orientation -> Int -> Int -> Object String
slideAnim HORIZONTAL from to = propAnim [ animator (PropName "translationX") (dpToPx from) (dpToPx to)]
slideAnim VERTICAL from to = propAnim [ animator (PropName "translationY") (dpToPx from) (dpToPx to)]

progressAnim :: Number -> Object String
progressAnim scale = propAnim (singleton (animator (PropName "scaleX") 0.0 scale))

-- Scale Function
scaleUpAnim :: Number -> Number -> Object String
scaleUpAnim fromVal toVal   = fromFoldable [ Tuple "props" (writeJSON [ { "prop": "scaleX" , "from": show fromVal, "to": (show toVal) },  { "prop": "scaleY" , "from": show fromVal, "to": (show toVal) } ] ) ]

-- Custom Translation

progressBarAnim :: String -> Number -> Object String
progressBarAnim animId length = id animId <> duration 20000.0 <> runOnRender <> ease EaseInOut <> progressAnim length

fadeInAnim :: String -> Object String
fadeInAnim animId = id animId <> duration 250.0 <> ease EaseInOut <> fadeAnim 0.0 1.0

fadeOutAnim :: String -> Object String
fadeOutAnim animId = id animId <> duration 250.0 <> ease EaseInOut <> fadeAnim 1.0 0.0

setFadeOutAnim :: String -> Object String
setFadeOutAnim animId = id animId <> duration 1.0 <> ease Linear <> fadeAnim 1.0 0.0

slideInBottom :: String -> Int -> Object String
slideInBottom animId length = id animId <> duration 200.0 <> ease EaseIn <> slideAnim VERTICAL length 0

slideInBottomDelay :: String -> Int -> Object String
slideInBottomDelay animId length = id animId <> duration 250.0 <> ease EaseInOut <> slideAnim VERTICAL length 10

slideInTop :: String -> Int -> Object String
slideInTop animId length = id animId <> duration 200.0 <> ease EaseInOut <> slideAnim VERTICAL (-length) 0

slideOutBottom :: String -> Int -> Object String
slideOutBottom animId length = id animId <> duration 250.0 <> ease EaseInOut <> slideAnim VERTICAL 10 length

setSlideToBottom :: String -> Int -> Object String
setSlideToBottom animId length = id animId <> duration 1.0 <> ease Linear <> runOnRender <> runOnRender' <> slideAnim VERTICAL 0 length

slideOutRight :: String -> Int -> Object String
slideOutRight animId length = id animId <> duration 200.0 <> ease EaseInOut <> slideAnim HORIZONTAL 0 length

slideInLeft :: String -> Int -> Object String
slideInLeft animId length = id animId <> duration 200.0 <> ease EaseInOut <> slideAnim HORIZONTAL length 0

slideRight :: String -> Int -> Object String
slideRight animId length = id animId <> duration 600.0 <> ease EaseIn <> slideAnim HORIZONTAL 0 length

slideLeft :: String -> Int -> Object String
slideLeft animId length = id animId <> duration 600.0 <> ease EaseIn <> slideAnim HORIZONTAL length 0

slideMaView eyeD from to = id eyeD <> duration 300.0 <> ease EaseInOut <> slideAnim HORIZONTAL from to 

slideMaView1 eyeD from to = id eyeD <> duration 200.0 <> ease EaseInOut <> slideAnim HORIZONTAL from to 

slideNbList id_ from to = id id_ <> duration 300.0 <> delay 0.0 <> ease EaseInOut <> slideAnim VERTICAL from to <> runOnRender

slideNbList' id_ from to = id id_ <> duration 300.0 <> delay 0.0 <> ease EaseInOut <> slideAnim VERTICAL from to

fadeNbList id_ from to = id id_ <> duration 300.0 <> ease EaseInOut <> fadeAnim from to <> runOnRender

fadeNbList' id_ from to = id id_ <> duration 300.0 <> ease EaseInOut <> fadeAnim from to

errorSlide id_ from to = id id_ <> duration 200.0  <> ease EaseInOut <> slideAnim VERTICAL from to <> runOnRender

errorSlide' id_ from to = id id_ <> duration 200.0 <> delay 100.0 <> ease EaseInOut <> slideAnim VERTICAL from to

errorFade id_ from to = id id_ <> duration 300.0 <> ease EaseInOut <> fadeAnim from to <> runOnRender

errorFade' id_ from to = id id_ <> duration 300.0 <> ease EaseInOut <> fadeAnim from to

errorMsgSlide id_ from to = id id_ <> duration 200.0 <> delay 100.0 <>  ease EaseInOut <> slideAnim VERTICAL from to <> runOnRender

errorMsgSlide' id_ from to = id id_ <> duration 200.0 <> ease EaseInOut <> slideAnim VERTICAL from to
