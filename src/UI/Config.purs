module UI.Config where

import Prelude

import Data.Tuple
import UI.Utils

import PrestoDOM
import Data.Ord ( class Ord, compare)
import PrestoDOM.Core (mapDom)
import PrestoDOM.Utils ((<>>))
import UI.Helpers.SingleSelectRadio


data Expandable
    = Expandable
    | NonExpandable

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
             , height : V 600
             }
         Mobile _, RadioSelected 1 ->
             { translationY : 210.0
             , margin : MarginHorizontal 0 0
             , height : V 1826
             }
         Mobile _, RadioSelected 2 ->
             { translationY : 320.0
             , margin : MarginHorizontal 0 0
             , height : V 1600
             }
         Mobile _, RadioSelected _ ->
             { translationY : 430.0
             , margin : MarginHorizontal 0 0
             , height : V 1630
             }
         _, _ ->
             { translationY : 0.0
             , margin : MarginHorizontal 366 32
             , height : V 1600
             }



tabSelectionTheme :: RenderType -> RadioSelected -> Int -> { background :: String, translationY :: Number}
tabSelectionTheme rT selected curr =
	let baseTrans = case rT, curr of
                        _, 0 -> 0.0
                        _, 1 -> 110.0
                        _, 2 -> 220.0
                        _, _ -> 330.0
	    extra = case rT, selected of
                        Mobile _, RadioSelected 0 -> 300.0
                        Mobile _, RadioSelected 1 -> 516.0
                        Mobile _, RadioSelected 2 -> 300.0
                        Mobile _, RadioSelected _ -> 330.0
                        _, _ -> 0.0
     in case compare selected (RadioSelected curr) of
             GT ->
                 { background : "#ffffff"
                 , translationY : baseTrans + extra
                 }
             EQ ->
                 { background : "#e9e9e9"
                 , translationY : baseTrans
                 }
             LT ->
                 { background : "#ffffff"
                 , translationY : baseTrans
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


cardSelectionTheme
    :: Expandable
    -> RadioSelected
    -> Int
    -> { background :: String
       , visibility :: Visibility
       , height :: Length
       }
cardSelectionTheme expandable selected curr =
    case expandable, compare selected (RadioSelected curr) of
         Expandable, EQ ->
            { background : "#1BB3E8"
            , visibility : VISIBLE
            , height : V 221
            }
         _ ,_ ->
            { background : "#D1F0FA"
            , visibility : GONE
            , height : V 120
            }

cardSelectionTheme2
    :: RadioSelected
    -> Int
    -> { background :: String
       , visibility :: Visibility
       , height :: Length
       }
cardSelectionTheme2 selected curr =
    case compare selected (RadioSelected curr) of
         EQ ->
            { background : "#1BB3E8"
            , visibility : VISIBLE
            , height : V 356
            }
         _ ->
            { background : "#D1F0FA"
            , visibility : GONE
            , height : V 120
            }


