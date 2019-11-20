module Route exposing (Route(..), fromUrl, toHref)

import Json.Encode as Encode
import Ports exposing (log)
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), (<?>), Parser, oneOf, s, string)
import Url.Parser.Query as Query


type Route
    = CharacterSelect
    | CharacterSheet String (Maybe String)
    | CreateCharacter
    | Loading


parser : Parser (Route -> a) a
parser =
    oneOf
        [ Parser.map CharacterSelect Parser.top
        , Parser.map CharacterSelect (s "characters")
        , Parser.map CharacterSheet (s "character" </> string <?> Query.string "tab")
        , Parser.map CreateCharacter (s "createCharacter")
        ]


fromUrl : Url -> Maybe Route
fromUrl url =
    Parser.parse parser url


toHref : Route -> String
toHref route =
    case route of
        CharacterSelect ->
            "/characters"

        CharacterSheet slug tab ->
            case tab of
                Just tabName ->
                    "/character/" ++ slug ++ "?tab=" ++ tabName

                Nothing ->
                    "/character/" ++ slug

        CreateCharacter ->
            "/createCharacter"

        Loading ->
            ""


routeToString : Route -> String
routeToString page =
    let
        pieces =
            case page of
                CharacterSelect ->
                    [ "characters" ]

                CharacterSheet slug tab ->
                    case tab of
                        Just tabName ->
                            [ "character", slug, tabName ]

                        Nothing ->
                            [ "character", slug ]

                CreateCharacter ->
                    [ "createCharacter" ]

                Loading ->
                    [ "" ]
    in
    "#/" ++ String.join "/" pieces
