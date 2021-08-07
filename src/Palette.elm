module Palette exposing (debugBorder)

import Css
import Tailwind.Utilities as Tw


debugBorder : List Css.Style -> List Css.Style
debugBorder l =
    l ++ [ Tw.border_4, Tw.border_red_500 ]
