module UI.Util.Style
 ( Style(..)
 , usingStyle
 )
 where

import Prelude

import PrestoDOM (Props)
import PrestoDOM.Utils ((<>>))

-- | A type to hold all the style properties. A newtype is created for this instead of just being a type alias because
-- | we wanted a way to concatenate two or more styles into one style.
-- |
-- | ~~~purescript
-- | inputLabelStyle = Style
-- |   [ color "#9e9e9e"
-- |   , textSize 12
-- |   , letterSpacing 0.0
-- |   , lineHeight "12"
-- |   , fontFamily Font.rOBOTOREGULAR
-- |   ]
-- | ~~~
-- |
-- | Apply it after any node or leaf in PrestoDOM by using the `usingStyle` function.
newtype Style i = Style (Props i)

-- | Instance for semigroup allows two styles to be concatenated. Properties in second style will override the properties
-- | in the first style.
instance semigroupStyle :: Semigroup (Style i) where
  append (Style a) (Style b) = Style (a <>> b)

-- | Applies a style to the regular properties array passed to PrestoDOM elements. Supports style properties to be
-- | overriden by the element specific properties.
usingStyle :: forall i. Style i -> Props i -> Props i
usingStyle (Style styleProps) props = styleProps <>> props
