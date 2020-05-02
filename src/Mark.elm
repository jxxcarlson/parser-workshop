module Mark exposing (..)

import Parser exposing (..)


type Term
    = Heading String
    | Subheading String
    | Paragraph (List String)


type alias Par =
    List String


line : Parser String
line =
    getChompedString <|
        succeed ()
            |. chompIf (\c -> c /= '\n')
            |. chompWhile (\c -> c /= '\n')
            |. symbol "\n"


paragraph : Parser Term
paragraph =
    (succeed identity
        |= loop [] nextLine
        |. spaces
    )
        |> map Paragraph


nextLine : Par -> Parser (Step Par Par)
nextLine revPar =
    oneOf
        [ succeed (\line_ -> Loop (line_ :: revPar))
            |= line
        , succeed (symbol "\n")
            |> map (\_ -> Done (List.reverse revPar))
        ]
