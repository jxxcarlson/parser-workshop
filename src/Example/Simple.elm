module Example.Simple exposing (..)

import Parser exposing (..)


type alias Date =
    { day : Int
    , month : Int
    , year : Int
    }


usDate : Parser Date
usDate =
    succeed Date
        |= int
        |. symbol "/"
        |= int
        |. symbol "/"
        |= int
