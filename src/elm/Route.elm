module Route exposing (Route(..), fromUrl)

import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, oneOf, s, string)


type Route
    = CharacterSelect
    | CharacterSheet String


parser : Parser (Route -> a) a
parser =
    oneOf
        [ Parser.map CharacterSelect Parser.top
        , Parser.map CharacterSelect (s "characters")
        , Parser.map CharacterSheet (s "character" </> string)
        ]


fromUrl : Url -> Maybe Route
fromUrl url =
    Parser.parse parser url


routeToString : Route -> String
routeToString page =
    let
        pieces =
            case page of
                CharacterSelect ->
                    [ "characters" ]

                CharacterSheet slug ->
                    [ "character", slug ]
    in
    "#/" ++ String.join "/" pieces
