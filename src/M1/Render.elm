module M1.Render exposing (render)

import M1.Parse as Parse exposing (Element(..))


render : List Element -> String
render elementList =
    elementList
        |> List.map renderElement
        |> String.join "\n\n"


renderElement : Element -> String
renderElement element =
    case element of
        Paragraph content ->
            html "p" (String.join "\n" content)

        Heading content ->
            html "h1" content

        Subheading content ->
            html "h2" content


html tag content =
    "<" ++ tag ++ ">" ++ content ++ "</" ++ tag ++ ">"
