module Example.Simple exposing (..)

import Parser exposing (..)


type alias Date =
    { day : Int
    , month : Int
    , year : Int
    }


date : Parser Date
date =
    succeed Date
        |= int
        |. symbol "/"
        |= int
        |. symbol "/"
        |= int
