module UI.Theme where

import Prelude ((<>))
import UI.Util.Style

import PrestoDOM.Properties (background, color, cornerRadius, fontFamily, letterSpacing, lineHeight, textSize, translationZ, weight)
import UI.Constant.Color.Default as Color
import UI.Constant.FontStyle.Default as Font


fontStyleGroupDef :: forall t9. Style t9
fontStyleGroupDef = Style 
      [ color "#2F68AD"
      , textSize 12
      , letterSpacing 0.0
      , fontFamily Font.gILROYREGULAR
      ]

shapeStyleGroupDef :: forall t1. Style t1
shapeStyleGroupDef = Style 
      [ background "#0FCE84"
      , cornerRadius 0.0
      ]

-------- SPACING ------------
verticalSpacing :: Int
verticalSpacing = 10

horizontalSpacing :: Int
horizontalSpacing = 30


------- STYLE SHEET for fonts---------

bodyText :: forall t21. Style t21
bodyText 				= fontStyleGroupDef <> Style [ color "#FF97A9B3", textSize 14, lineHeight "12", weight 1.0 ]

primaryButtonSolidText :: forall t15. Style t15
primaryButtonSolidText 	= fontStyleGroupDef <> Style [ color Color.a_FFFFFFFF, textSize 16, fontFamily Font.gILROYREGULAR ]


------- STYLE SHEET for shapes --------
primaryButtonSolid :: forall t5. Style t5
primaryButtonSolid		= shapeStyleGroupDef <> Style [cornerRadius 4.0, translationZ 8.0]

-- editBox					= shapeStyleGroupDef <> Style [background Color.a_FFFFFFFF, cornerRadius 2.0, stroke "1,#2F68AD"]