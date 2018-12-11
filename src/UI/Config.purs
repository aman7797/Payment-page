module UI.Config where

import Prelude

import Data.Tuple
import UI.Utils

import PrestoDOM
import PrestoDOM.Core (mapDom)
import PrestoDOM.Utils ((<>>))
import UI.Helpers.SingleSelectRadio


mainViewWidth :: RenderType -> Length
mainViewWidth =
    case _ of
        Desktop Fit -> V 1440
        _ -> MATCH_PARENT

{-- getPaymentPageView  :: forall v. RenderType -> v -> v -> Array v --}
getPaymentPageView rT pV bV =
    case rT of
         {-- Desktop Fit -> [ pV, bV ] --}
         {-- Desktop Normal -> [ pV, bV ] --}
         {-- _ -> [ bV, pV ] --}
         Desktop Fit -> [ Tuple "paymentPageV1" pV, Tuple "paymentPageV2" bV ]
         Desktop Normal -> [ Tuple "paymentPageV1" pV, Tuple "paymentPageV2" bV ]
         _ -> [ Tuple "paymentPageV2" bV, Tuple "paymentPageV1" pV ]

paymentPageViewOrientation :: RenderType -> Orientation
paymentPageViewOrientation =
    case _ of
         Desktop Fit -> HORIZONTAL
         Desktop Normal -> HORIZONTAL
         _ -> VERTICAL

billerViewConfig
    :: RenderType
    -> { orientation :: Orientation
       , width :: Length
       , height :: Length
       }
billerViewConfig =
    case _ of
         Desktop Fit ->
             { orientation : VERTICAL
             , width : V 224
             , height : V 184
             }
         Desktop Normal ->
             { orientation : VERTICAL
             , width : V 224
             , height : V 184
             }
         _ ->
             { orientation : HORIZONTAL
             , width : MATCH_PARENT
             , height : V 92
             }


{-- paymentViewOrientation --}
{--     :: RenderType --}
{--     -> Orientation --}
{-- paymentViewOrientation = --}
{--     case _ of --}
{--          Desktop _ -> HORIZONTAL --}
{--          Mobile _ -> VERTICAL --}


commonViewConfig
    :: RenderType
    -> RadioSelected
    -> { translationY :: Number
       , margin :: Margin
       , height :: Length
       }
commonViewConfig =
    case _, _ of
         Mobile _, RadioSelected 0 ->
             { translationY : 100.0
             , margin : MarginHorizontal 0 0
             , height : V 300
             }
         Mobile _, RadioSelected 1 ->
             { translationY : 210.0
             , margin : MarginHorizontal 0 0
             , height : V 826
             }
         Mobile _, RadioSelected 2 ->
             { translationY : 320.0
             , margin : MarginHorizontal 0 0
             , height : V 300
             }
         Mobile _, RadioSelected _ ->
             { translationY : 430.0
             , margin : MarginHorizontal 0 0
             , height : V 330
             }
         _, _ ->
             { translationY : 0.0
             , margin : MarginHorizontal 366 32
             , height : V 300
             }



tabSelectionTheme :: RenderType -> RadioSelected -> RadioSelected -> SingleSelectTheme
tabSelectionTheme rT curr s =
	let baseTrans = case rT, s of
                        _, RadioSelected 0 -> 0.0
                        _, RadioSelected 1 -> 110.0
                        _, RadioSelected 2 -> 220.0
                        _, RadioSelected _ -> 330.0
                        _, _ -> 0.0
	    extra = case rT, curr of
                        Mobile _, RadioSelected 0 -> 300.0
                        Mobile _, RadioSelected 1 -> 516.0
                        Mobile _, RadioSelected 2 -> 300.0
                        Mobile _, RadioSelected _ -> 330.0
                        _, _ -> 0.0
     in { selected :
            [ background "#e9e9e9"
            ]
        , unselected :
            [ background "#ffffff"
            ]
        , lessThanOrEq :
            [ translationY baseTrans
            ]
        , greaterThan :
            [ translationY $ baseTrans + extra
            ]
        }

tabViewWidth :: RenderType -> Length
tabViewWidth =
    case _ of
         Desktop _ -> V 334
         Mobile _ -> MATCH_PARENT


tabLayoutWidth :: RenderType -> Length
tabLayoutWidth =
    case _ of
         Desktop _ -> V 334
         Mobile _ -> V 800

